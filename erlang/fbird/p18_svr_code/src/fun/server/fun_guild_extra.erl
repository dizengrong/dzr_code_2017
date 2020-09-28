-module(fun_guild_extra).
-include("common.hrl").
-export([req_blessing_info/3,req_guild_blessing/3,refresh_blessing/1]).
-export([req_guild_impeach/3,req_guild_impeach_result/4]).
-export([handle/1]).
-export([check_impeach_result/1,check_impeach_data/1]).
-export([init_impeach/0]).

-define(DISAGREE , 	0).%% 不同意
-define(AGREE , 	1).%% 同意

init_impeach() ->
	[init_impeach_help(Uid, GuildId, Time) || #guild_impeach_president{uid = Uid, guild_id = GuildId, time = Time} <- db:dirty_match(guild_impeach_president, #guild_impeach_president{_='_'})].

init_impeach_help(_Uid, GuildId, Time) ->
	NewTime = Time + util:get_data_para_num(1217) * 3600,
	Now = util_time:unixtime(),
	case NewTime - Now > 0 of
		true -> erlang:start_timer((NewTime - Now) * 1000, self(), {?MODULE, check_impeach_result, GuildId});
		_ -> req_guild_impeach_result(fun_guild:get_guild_president_uid(GuildId), 0, 0, ?AGREE)
	end.

%% agent
handle({guild_impeach_help, Uid, Sid, GuildId, SpendItems}) ->
	Succ = fun() ->
		?error_report(Sid, "society_accuse"),
		mod_msg:handle_to_agnetmng(?MODULE, {guild_impeach_succ, Uid, GuildId})
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);

%% agent_mng
handle({guild_impeach_succ, Uid, GuildId}) ->
	db:insert(#guild_impeach_president{guild_id = GuildId,uid = Uid, time = util_time:unixtime()}),
	erlang:start_timer(util:get_data_para_num(1217) * 3600000, self(), {?MODULE, check_impeach_result, GuildId});

handle({guild_blessing_succ, GuildId, AddExp, Uid, Sid}) ->
	add_guild_exp(GuildId, AddExp, Uid, Sid).

check_impeach_data(Uid) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, ?PERM_PRESIDENT} ->
			case db:dirty_get(guild_impeach_president, GuildId, #guild_impeach_president.guild_id) of
				[#guild_impeach_president{uid = TUid}] ->
					Pt = #pt_guild_impeach{impeach_person = util:to_list(util:get_name_by_uid(TUid))},
					?send(util:get_sid_by_uid(Uid), proto:pack(Pt));
				_ -> skip
			end;
		_ -> skip
	end.

check_impeach_result(GuildId) ->
	case db:dirty_get(guild_impeach_president, GuildId, #guild_impeach_president.guild_id) of
		[#guild_impeach_president{id = Id, uid = Uid}] ->
			case fun_guild:get_guild_baseinfo(Uid) of
				{ok, GuildId, Perm} when Perm /= ?PERM_PRESIDENT ->
					fun_guild:updata_guild_perm(fun_guild:get_guild_president_uid(GuildId), Uid, ?PERM_PRESIDENT, 0, 0),
					Fun = fun(#guild_member{uid = TUid}) ->
						#mail_content{mailName = Title, text = Content} = data_mail:data_mail(accuse_succeed),
						Content2 = util:format_lang(util:to_binary(Content), [util:get_name_by_uid(Uid)]),
						mod_mail_new:sys_send_personal_mail(TUid, Title, Content2, [], ?MAIL_TIME_LEN)
					end,
					lists:foreach(Fun, db:dirty_get(guild_member, GuildId, #guild_member.guild_id)),
					db:dirty_del(guild_impeach_president, Id);
				_ -> db:dirty_del(guild_impeach_president, Id)
			end;
		_ -> skip
	end.

req_blessing_info(Uid, Sid, Seq) ->
	Step = fun_usr_misc:get_misc_data(Uid, guild_blessing),
	Pt = #pt_guild_blessing_info{blessing_step = Step},
	?send(Sid, proto:pack(Pt, Seq)).

req_guild_blessing(Uid, Sid, Seq) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			Step = fun_usr_misc:get_misc_data(Uid, guild_blessing),
			?debug("Step = ~p",[Step]),
			case data_guild_blessing:get_data(Step) of
				#st_data_guild_blessing{cost = Cost, reward = Rewards, add_exp = AddExp} ->
					SpendItems = [{?ITEM_WAY_GUILD_BLESSING, T, N} || {T, N} <- Cost],
					AddItems = [{?ITEM_WAY_GUILD_BLESSING, T, N} || {T, N} <- Rewards],
					Succ = fun() ->
						fun_usr_misc:set_misc_data(Uid, guild_blessing, Step + 1),
						mod_msg:handle_to_agnetmng(?MODULE, {guild_blessing_succ, GuildId, AddExp, Uid, Sid}),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
						req_blessing_info(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

add_guild_exp(GuildId, AddExp, Uid, Sid) ->
	case db:dirty_get(guild, GuildId) of
		[Rec = #guild{level = Lev, exp = Exp}] ->
			case data_guild_level:get_data(Lev) of
				#st_data_guild_level{needexp = NeedExp} ->
					NewExp = AddExp + Exp,
					Rec1 = Rec#guild{exp = NewExp},
					case NewExp >= NeedExp of
						true ->
							NewRec = Rec1#guild{level = Lev + 1},
							new_add_guikd_exp(GuildId, NewRec, NewExp, Uid, NeedExp, Sid);
						_ -> 
							db:dirty_put(Rec1),
							send_info_to_client(Uid, Sid, GuildId)
					end;
				_ -> skip
			end;
		_ -> skip
	end.

new_add_guikd_exp(GuildId, Rec = #guild{level = Lev}, Exp, Uid, NeedExp, Sid) ->
	case data_guild_level:get_data(Lev) of
		#st_data_guild_level{needexp = NewNeedExp} ->
			case Exp >= NewNeedExp of
				true ->
					NewRec = Rec#guild{level = Lev + 1},
					new_add_guikd_exp(GuildId, NewRec, Exp, Uid, NewNeedExp, Sid);
				_ ->
					db:dirty_put(Rec),
					fun_guild:send_guild_to_sid(Uid, Sid, GuildId, [{util_time:unixtime(),?SUCCESS_GUILD_LEVEL_UP,Uid,Lev}]),
					send_info_to_client(Uid, Sid, GuildId)
			end;
		_ ->
			Rec1 = Rec#guild{level = Lev - 1, exp = NeedExp},
			db:dirty_put(Rec1),
			fun_guild:send_guild_to_sid(Uid, Sid, GuildId, [{util_time:unixtime(),?SUCCESS_GUILD_LEVEL_UP,Uid,Lev-1}]),
			send_info_to_client(Uid, Sid, GuildId)
	end.

send_info_to_client(Uid, Sid, GuildId) ->
	fun_guild:send_guild_all_info_to_sid(Uid),
	fun_guild:send_guild_to_sid(Uid, Sid, GuildId, [{util_time:unixtime(),?SUCCESS_GUILD_BLESSING,Uid,fun_usr_misc:get_misc_data(Uid, guild_blessing)}]).

refresh_blessing(Uid) -> fun_usr_misc:set_misc_data(Uid, guild_blessing, 1).

req_guild_impeach(Uid, Sid, Seq) ->
	case check_impeach(Uid) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, Hid, GuildId, SpendItems} -> mod_msg:handle_to_agent(Hid, ?MODULE, {guild_impeach_help, Uid, Sid, GuildId, SpendItems})
	end.

check_impeach(Uid) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			case fun_guild:get_event_permission(Uid, 1) of
				true ->
					LeaderId = fun_guild:get_guild_president_uid(GuildId),
					case db:dirty_get(ply, LeaderId) of
						[#ply{}] -> {error, "society_accuse02"};
						_ ->
							case db:dirty_get(guild_impeach_president, GuildId, #guild_impeach_president.guild_id) of
								[] ->
									[#ply{agent_hid = Hid}] = db:dirty_get(ply, Uid),
									{ok, Hid, GuildId, [{?ITEM_WAY_GUILD_IMPEACH, ?RESOUCE_COIN_NUM, util:get_data_para_num(1216)}]};
								_ -> {error, "society_accuse02"}
							end
					end;
				_ -> {error, "society_accuse02"}
			end;
		_ -> {error, "society_accuse02"}
	end.

req_guild_impeach_result(Uid, _Sid, _Seq, ?DISAGREE) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, ?PERM_PRESIDENT} ->
			case db:dirty_get(guild_impeach_president, GuildId, #guild_impeach_president.guild_id) of
				[#guild_impeach_president{id = Id, uid = TUid}] ->
					#mail_content{mailName = Title, text = Content} = data_mail:data_mail(accuse_nothing),
					mod_mail_new:sys_send_personal_mail(TUid, Title, Content, [], ?MAIL_TIME_LEN),
					db:dirty_del(guild_impeach_president, Id);
				_ -> skip
			end;
		_ -> skip
	end;
req_guild_impeach_result(Uid, _Sid, _Seq, ?AGREE) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, ?PERM_PRESIDENT} -> check_impeach_result(GuildId);
		_ -> skip
	end;
req_guild_impeach_result(_Uid, _Sid, _Seq, _Type) -> skip.