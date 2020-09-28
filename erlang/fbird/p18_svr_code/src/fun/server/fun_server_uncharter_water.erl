%% 后台活动——大航海(agent部分)
-module(fun_server_uncharter_water).
-include("common.hrl").
-export([req_sailing_info/3,req_sailing_guard_info/3,req_sailing_buy_time/3,req_sailing_buy_inspire/3,req_sailing_help/3,req_refresh_sailing_plunder/3,req_sailing_reward/3]).
-export([req_sailing_guard/4,req_sailing/4]).
-export([check_data/2,handle/1,arena_result/1,refresh_daily_data/1]).
-export([req_sailing_plunder/5]).

-define(SAILING_START, 		0).
-define(SAILING_GUARD, 		1).
-define(SAILING_GUARD_SUCC, 2).
-define(SAILING_GUARD_FAIL, 3).
-define(SAILING_END,   		4).

-define(NOT_SAILING,  0).
-define(IN_SAILING,   1).
-define(END_SAILING,  2).

-define(CAN_GUARD, 0).
-define(IS_GUARD,  1).

-define(NOT_SIGN, 0).
-define(HAS_SIGN, 1).

init_data(Uid) ->
	#usr_sailing{
		uid 		 = Uid,
		sailing_time = util:get_data_para_num(1198),
		plunder_time = util:get_data_para_num(1199),
		guard_time 	 = util:get_data_para_num(1201)
	}.

get_data(Uid) ->
	case fun_agent_ets:lookup(Uid, usr_sailing) of
		[Rec = #usr_sailing{}] ->
			Rec#usr_sailing{
				records 	 = util:string_to_term(util:to_list(Rec#usr_sailing.records)),
				plunder_list = util:string_to_term(util:to_list(Rec#usr_sailing.plunder_list))
			};
		_ -> init_data(Uid)
	end.

set_data(Rec) ->
	NewRec = Rec#usr_sailing{
		records 	 = util:term_to_string(Rec#usr_sailing.records),
		plunder_list = util:term_to_string(Rec#usr_sailing.plunder_list)
	},
	fun_agent_ets:insert(NewRec#usr_sailing.uid, NewRec).

init_guild_data(GuildId) ->
	#guild_sailing{
		guild_id = GuildId
	}.

get_guild_data(GuildId) ->
	case db:dirty_get(guild_sailing, GuildId, #guild_sailing.guild_id) of
		[Rec = #guild_sailing{}] ->
			Rec#guild_sailing{
				sign = util:string_to_term(util:to_list(Rec#guild_sailing.sign))
			};
		_ -> init_guild_data(GuildId)
	end.

set_guild_data(Rec) ->
	NewRec = Rec#guild_sailing{
		sign = util:term_to_string(Rec#guild_sailing.sign)
	},
	case NewRec#guild_sailing.id of
		0 -> db:insert(NewRec);
		_ -> db:dirty_put(NewRec)
	end.


%% agent_mng消息
handle({get_plunder_info_succ, FUid, FUsrHid, FServerSid, Uid}) ->
	Rec = get_data(Uid),
	Msg = case Rec#usr_sailing.status of
		?IN_SAILING ->
			GuardData = case Rec#usr_sailing.has_be_guard of
				0 -> {};
				GUid -> fun_arena:get_ply_data(GUid)
			end,
			MyData = fun_arena:get_ply_data(Uid),
			{get_plunder_info_end, ok, FUid, FUsrHid, FServerSid, {Uid, fun_guild:get_guild_id_by_uid(Uid), MyData, GuardData, Rec#usr_sailing.type, Rec#usr_sailing.inspire, mod_scene_lev:get_curr_scene_lv(Uid)}};
		_ -> {get_plunder_info_end, out_sailing, FUid, FUsrHid, FServerSid, {}}
	end,
	system_uncharter_water:to_global(Msg);

handle({get_plunder_result, Uid, Result, Data1, Data2}) ->
	Rec = get_data(Uid),
	NewRec1 = Rec#usr_sailing{
		records = [Data1 | Rec#usr_sailing.records]
	},
	NewRec = case Result of
		win -> NewRec1;
		_ ->
			{TServerId, TGuildId} = Data2,
			GuildId = fun_guild:get_guild_id_by_uid(Uid),
			case is_sign(GuildId,TGuildId,TServerId) of
				true -> skip;
				_ -> add_sign(GuildId,TGuildId,TServerId)
			end,
			NewRec1#usr_sailing{
				has_be_plunder = 1
			}
	end,
	set_data(NewRec),
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] -> send_info_to_client(Uid, Sid, 0);
		_ -> skip
	end;

handle({ranklist_reward, RankNum, GuildId, Rewards}) ->
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(sailing_award),
	Content2 = util:format_lang(util:to_binary(Content), [RankNum]),
	List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
	[mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, Rewards, ?MAIL_TIME_LEN) || #guild_member{uid = Uid} <- List],
	ok;

%% agent消息
handle({get_plunder_list_ok, Uid, PlunderList}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			Rec = get_data(Uid),
			NewRec = Rec#usr_sailing{
				plunder_list = PlunderList
			},
			send_plunder_info_to_client(Uid, Sid, 0, PlunderList),
			set_data(NewRec);
		_ -> skip
	end;

handle({get_plunder_info_end, Result, Reason, Uid, Data}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			case Result of
				succ ->
					Rec = get_data(Uid),
					case Rec#usr_sailing.plunder_time > 0 of
						true ->
							NewRec = Rec#usr_sailing{
								plunder_time = Rec#usr_sailing.plunder_time - 1
							},
							set_data(NewRec),
							send_info_to_client(Uid, Sid, 0),
							{TUid, TGuildId, TData, GuardData, Type, Inspire, TSceneLev, TServerId, TServerSid} = Data,
							case data_scene_config:get_scene(?COMPLEX_ARENA_SCENE) of
								#st_scene_config{sort=?SCENE_SORT_COMPLEX_ARENA,points = PointList} ->
									fun_arena:save_usr_pos(Uid),
									UsrInfoList=[{Uid,0,lists:nth(2, PointList),#ply_scene_data{sid = Sid}}],
									SceneData={complex_arena_scene,global_sailing,{TUid,TGuildId,TData,GuardData,Type,Inspire,TSceneLev,TServerId,TServerSid},lists:nth(3, PointList)},
									gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList, ?COMPLEX_ARENA_SCENE, SceneData});
								_ -> skip
							end;
						_ -> skip
					end;
				_ ->
					Code = case Reason of
						out_sailing -> "sailing_pillage04";
						sailing_end -> "sailing_pillage01";
						has_be_plunder -> "sailing_pillage02";
						_ -> "sailing_pillage04"
					end,
					?error_report(Sid, Code),
					req_refresh_sailing_plunder(Uid, Sid, 0)
			end;
		_ -> skip
	end;

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

check_data(Uid, Sid) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_} ->
			Rec = get_data(Uid),
			case Rec#usr_sailing.plunder_list of
				[] ->
					GuildRec = get_guild_data(GuildId),
					[#ply{agent_hid = Hid}] = db:dirty_get(ply, Uid),
					system_uncharter_water:to_global({get_plunder_list, Uid, Sid, Hid, GuildId, GuildRec#guild_sailing.sign});
				List -> send_plunder_info_to_client(Uid, Sid, 0, List)
			end,
			system_uncharter_water:to_global({get_ranklist, Uid, Sid, GuildId});
		_ -> skip
	end.

req_sailing_info(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Now = util_time:unixtime(),
	case Rec#usr_sailing.status == ?IN_SAILING andalso Now >= Rec#usr_sailing.end_time of
		true ->
			NewRec = Rec#usr_sailing{
				status  = ?END_SAILING,
				records = [{?SAILING_END,"","","",Rec#usr_sailing.end_time} | Rec#usr_sailing.records]
			},
			system_uncharter_water:to_global({end_sailing, Uid}),
			set_data(NewRec);
		_ -> skip
	end,
	send_info_to_client(Uid, Sid, Seq).

req_sailing_guard_info(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_sailing_guard_info{
		guard_time = Rec#usr_sailing.guard_time,
		guard_type = Rec#usr_sailing.is_guard,
		guard_list = make_guard_list_pt(Uid, fun_guild:get_guild_id_by_uid(Uid))
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_sailing_buy_time(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	MaxTime = fun_vip:get_privilege_added(sailing_times, Uid),
	case Rec#usr_sailing.buy_times >= MaxTime of
		false ->
			#st_buy_time_price{cost = Costs} = data_buy_time_price:get_data(?BUY_SAILING, min(data_buy_time_price:get_max_times(?BUY_SAILING), Rec#usr_sailing.buy_times + 1)),
			SpendItems = [{?ITEM_WAY_SAILING, T, N} || {T, N} <- Costs],
			Succ = fun() ->
				NewRec = Rec#usr_sailing{
					sailing_time = Rec#usr_sailing.sailing_time + 1,
					buy_times 	 =  Rec#usr_sailing.buy_times + 1
				},
				set_data(NewRec),
				send_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		_ -> skip
	end.

req_sailing_buy_inspire(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#usr_sailing.status of
		?IN_SAILING ->
			Inspire = Rec#usr_sailing.inspire,
			case Inspire >= data_inspire:get_max(?SAILING_INSPIRE) of
				true -> skip;
				_ ->
					#st_inspire{cost = Cost} = data_inspire:get_data(Inspire, ?SAILING_INSPIRE),
					SpendItems = [{?ITEM_WAY_SAILING, T, N} || {T, N} <- Cost],
					Succ = fun() ->
						NewRec = Rec#usr_sailing{
							inspire = Rec#usr_sailing.inspire + 1
						},
						set_data(NewRec),
						send_info_to_client(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined)
			end;
		_ -> skip
	end.

req_sailing_help(Uid, Sid, Seq) ->
	case fun_gm_operation:check_shutup(Sid,Uid,Seq) of
		true ->
			case fun_guild:get_guild_baseinfo(Uid) of
				{ok,_,_} ->
					RecName = "", 
					Channel = ?CHANLE_GUILD,
					Content = util:get_data_text(71),
					mod_msg:handle_to_chat_server({req_chat, Uid, Sid, Seq, RecName, Channel, Content, ?NONE}),
					?error_report(Sid, "sailing_help", Seq);
				_ -> skip
			end;
		_ -> skip
	end.

req_refresh_sailing_plunder(Uid, Sid, _Seq) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_} ->
			[#ply{agent_hid = Hid}] = db:dirty_get(ply, Uid),
			GuildRec = get_guild_data(GuildId),
			system_uncharter_water:to_global({get_plunder_list, Uid, Sid, Hid, GuildId, GuildRec#guild_sailing.sign});
		_ -> skip
	end.

req_sailing_guard(Uid, Sid, Seq, TUid) ->
	case (fun_guild:get_guild_id_by_uid(Uid) == fun_guild:get_guild_id_by_uid(TUid)) andalso (fun_guild:get_guild_id_by_uid(Uid) /= 0) of
		true ->
			Rec = get_data(Uid),
			TRec = get_data(TUid),
			case TRec#usr_sailing.has_be_guard == 0 andalso TRec#usr_sailing.status == ?IN_SAILING andalso TRec#usr_sailing.end_time > util_time:unixtime() andalso Rec#usr_sailing.guard_time > 0 of
				true ->
					AddItems = [{?ITEM_WAY_SAILING, ?RESOUCE_COIN_NUM, util:get_data_para_num(1202)}],
					Succ = fun() ->
						NewTRec = TRec#usr_sailing{
							has_be_guard = Uid,
							records 	 = [{?SAILING_GUARD,util:get_name_by_uid(Uid),"","",util_time:unixtime()} | TRec#usr_sailing.records]
						},
						NewRec = Rec#usr_sailing{
							guard_time = Rec#usr_sailing.guard_time - 1
						},
						set_data(NewTRec),
						set_data(NewRec),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, [{?RESOUCE_COIN_NUM, util:get_data_para_num(1202)}]),
						req_sailing_guard_info(Uid, Sid, Seq),
						send_info_to_client(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

req_sailing(Uid, Sid, Seq, Type) ->
	Rec = get_data(Uid),
	case check_sailing(Uid, Rec) of
		{error, Reason} -> ?debug("Reason = ~p",[Reason]),?error_report(Sid, Reason, Seq);
		_ ->
			case data_uncharted_waters:get_ship_data(Type) of
				#st_data_ship{cost = Cost, sailing_time = Time} ->
					Now = util_time:unixtime(),
					GuildId = fun_guild:get_guild_id_by_uid(Uid),
					SpendItems = [{?ITEM_WAY_SAILING, T, N} || {T, N} <- Cost],
					Succ = fun() ->
						NewRec = Rec#usr_sailing{
							status  	 = ?IN_SAILING,
							sailing_time = Rec#usr_sailing.sailing_time - 1,
							type 		 = Type,
							end_time 	 = Now + Time * 60,
							records 	 = [{?SAILING_START, util:get_name_by_uid(Uid), fun_guild:get_guild_name(GuildId), db:get_all_config(servername), Now}]
						},
						Data = {
							Uid,
							util:get_name_by_uid(Uid),
							GuildId,
							fun_guild:get_guild_name(GuildId),
							db:get_all_config(serverid),
							db:get_all_config(servername),
							Type,
							Now + Time * 60,
							fun_property:get_usr_fighting(Uid),
							mod_scene_lev:get_curr_scene_lv(Uid)
						},
						system_uncharter_water:to_global({to_sailing, Data}),
						set_data(NewRec),
						send_info_to_client(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
				_ -> skip
			end
	end.

req_sailing_plunder(Uid, _Sid, TUid, TServerId, _Seq) ->
	[#ply{agent_hid = Hid}] = db:dirty_get(ply, Uid),
	Rec = get_data(Uid),
	case Rec#usr_sailing.plunder_time > 0 of
		true -> system_uncharter_water:to_global({get_plunder_info, Uid, Hid, TUid, TServerId});
		_ -> skip
	end.

req_sailing_reward(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#usr_sailing.status of
		?END_SAILING ->
			Type = Rec#usr_sailing.type,
			case data_uncharted_waters:get_ship_data(Type) of
				#st_data_ship{reward = Rewards, points = Point, reward_plunder1 = Plunder, final_reward = Reward2} ->
					Base = data_uncharted_waters:get_reward_mag(mod_scene_lev:get_curr_scene_lv(Uid)),
					{NewReward, NewPoint} = case Rec#usr_sailing.has_be_plunder of
						0 ->
							Reward12 = [{T, N*Base} || {T, N} <- Rewards],
							Reward1 = lists:append(Reward12, Reward2),
							{Reward1, Point};
						_ ->
							Reward12 = [{T, util:floor(N*Base*(1-(Plunder/100)))} || {T, N} <- Rewards],
							Reward22 = [{T, util:floor(N*(1-(Plunder/100)))} || {T, N} <- Reward2],
							Reward1 = lists:append(Reward12, Reward22),
							{Reward1, util:floor(Point*(1-(Plunder/100)))}
					end,
					AddItems = [{?ITEM_WAY_SAILING, T, N} || {T, N} <- NewReward],
					Succ = fun() ->
						GuildId = fun_guild:get_guild_id_by_uid(Uid),
						add_guild_point(GuildId, NewPoint),
						NewRec = Rec#usr_sailing{
							status 			= ?NOT_SAILING,
							has_be_plunder  = 0,
							has_be_guard 	= 0,
							end_time 		= 0,
							type 			= 0,
							inspire 		= 0,
							records 		= []
						},
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, NewReward),
						set_data(NewRec),
						send_info_to_client(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	{GuardName, GuardHead} = case Rec#usr_sailing.has_be_guard of
		0 -> {"", 0};
		_ -> {util:get_name_by_uid(Rec#usr_sailing.has_be_guard), fun_usr_head:get_headid(Rec#usr_sailing.has_be_guard)}
	end,
	Pt = #pt_sailing_info{
		type 			= Rec#usr_sailing.type,
		status 			= Rec#usr_sailing.status,
		sailing_time 	= Rec#usr_sailing.sailing_time,
		buy_times 		= Rec#usr_sailing.buy_times,
		has_be_plunder 	= Rec#usr_sailing.has_be_plunder,
		inspire 		= Rec#usr_sailing.inspire,
		succ_guard_time = get_record_times(?SAILING_GUARD_SUCC, Rec#usr_sailing.records),
		guard_name 		= util:to_list(GuardName),
		guard_head 		= GuardHead,
		end_time 		= Rec#usr_sailing.end_time,
		sailing_records = make_record_pt(Rec#usr_sailing.records, [])
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_plunder_info_to_client(Uid, Sid, Seq, List) ->
	Rec = get_data(Uid),
	Pt = #pt_sailing_plunder_info{
		plunder_time = Rec#usr_sailing.plunder_time,
		plunder_list = make_plunder_list_pt(List, [])
	},
	?send(Sid, proto:pack(Pt, Seq)).

arena_result({Result, Uid, _Type, Data, Time}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			{TUid,TGuildId,SType,TSceneLev,TServerId,TServerSid} = Data,
			{PtReward, PtPoint} = case Result of
				win ->
					case data_uncharted_waters:get_ship_data(SType) of
						#st_data_ship{reward = Rewards, points = Point, reward_plunder1 = Plunder1, reward_plunder2 = Plunder2, extra_plunder = ExPlunder, final_reward = Reward2} ->
							GuildId = fun_guild:get_guild_id_by_uid(Uid),
							SceneLev = mod_scene_lev:get_curr_scene_lv(Uid),
							Base = data_uncharted_waters:get_reward_mag(TSceneLev),
							Pro = case is_sign(GuildId,TGuildId,TServerId) of
								true ->
									del_sign(GuildId,TGuildId,TServerId),
									case SceneLev - TSceneLev >= util:get_data_para_num(1200) of
										true -> Plunder2 + ExPlunder;
										_ -> Plunder1 + ExPlunder
									end;
								_ ->
									case SceneLev - TSceneLev >= util:get_data_para_num(1200) of
										true -> Plunder2;
										_ -> Plunder1
									end
							end,
							NewReward1 = [{T, util:ceil(N*Base*Pro/100)} || {T, N} <- Rewards],
							Reward22 = [{T, util:ceil(N*Pro/100)} || {T, N} <- Reward2],
							NewReward = lists:append(NewReward1, Reward22),
							NewPoint = util:ceil(Point*Pro/100),
							AddItems = [{?ITEM_WAY_SAILING, T, N} || {T, N} <- NewReward],
							Succ = fun() ->
								add_guild_point(GuildId, NewPoint),
								system_uncharter_water:to_global({sailing_plunder_result, TUid, TServerSid, lose, {?SAILING_GUARD_FAIL,util:get_name_by_uid(Uid),fun_guild:get_guild_name_by_uid(Uid),db:get_all_config(servername),Time},{db:get_all_config(serverid), GuildId}})
							end,
							fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined),
							{NewReward, NewPoint};
						_ ->
							system_uncharter_water:to_global({sailing_plunder_result, TUid, TServerSid, win, {?SAILING_GUARD_SUCC,util:get_name_by_uid(Uid),fun_guild:get_guild_name_by_uid(Uid),db:get_all_config(servername),Time},{}}),
							{[], 0}
					end;
				_ ->
					system_uncharter_water:to_global({sailing_plunder_result, TUid, TServerSid, win, {?SAILING_GUARD_SUCC,util:get_name_by_uid(Uid),fun_guild:get_guild_name_by_uid(Uid),db:get_all_config(servername),Time},{}}),
					{[], 0}
			end,
			Result1 = get_result(Result),
			Pt = #pt_global_arena_result{
				type = ?GLOBAL_ARNEA_WATER,
				win_lose 	 = Result1,
				honor_change = PtPoint,
				item_list 	 = fun_item_api:make_item_pt_list(PtReward)
			},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

get_result(Result) ->
	case Result of
		win -> ?ARENA_WIN;
		_ -> ?ARENA_LOSE
	end.

get_record_times(Type, List) ->
	Fun = fun({Type1,_,_,_,_}) ->
		Type1 == Type
	end,
	length(lists:filter(Fun, List)).

make_record_pt([], Acc) -> Acc;
make_record_pt([{Type,Name,GuildName,ServerName,Time} | Rest], Acc) ->
	Ptm = #pt_public_sailing_record{
			type 		= Type,
			name 		= util:to_list(Name),
			guild_name  = util:to_list(GuildName),
			server_name = util:to_list(ServerName),
			time 		= Time
	},
	make_record_pt(Rest, [Ptm | Acc]).

make_guard_list_pt(Uid, GuildId) ->
	List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
	Fun = fun(#guild_member{uid = TUid}, Acc) ->
		case TUid /= Uid of
			true ->
				Rec = get_data(TUid),
				case Rec#usr_sailing.has_be_guard == 0 andalso Rec#usr_sailing.status == ?IN_SAILING andalso Rec#usr_sailing.end_time > util_time:unixtime() andalso Rec#usr_sailing.has_be_plunder == 0 of
					true -> [{Rec#usr_sailing.type, TUid, util:get_name_by_uid(TUid), mod_scene_lev:get_curr_scene_lv(TUid), fun_property:get_usr_fighting(TUid)} | Acc];
					_ -> Acc
				end;
			_ -> Acc
		end
	end,
	NewList = lists:foldl(Fun, [], List),
	case NewList of
		[] -> [];
		_ ->
			FunPt = fun({Type, TUid, Name, SceneLev, Fighting}) ->
				#pt_public_guard_list{
					type 	 = Type,
					uid 	 = TUid,
					name 	 = util:to_list(Name),
					barrier  = SceneLev,
					fighting = Fighting
				}
			end,
			lists:map(FunPt, NewList)
	end.

make_plunder_list_pt([], Acc) -> Acc;
make_plunder_list_pt([{Uid, Name, GuildName, ServerId, ServerName, Type, HasSign, Fighting, SceneLev} | Rest], Acc) ->
	Ptm = #pt_public_plunder_list{
		has_sign 	= HasSign,
		type 		= Type,
		uid 		= Uid,
		name 		= util:to_list(Name),
		guild_name  = util:to_list(GuildName),
		server_id 	= ServerId,
		server_name = util:to_list(ServerName),
		fighting 	= Fighting,
		scene_lev 	= SceneLev
	},
	make_plunder_list_pt(Rest, [Ptm | Acc]).

is_sign(GuildId,TGuildId,TServerId) ->
	Rec = get_guild_data(GuildId),
	SignList = Rec#guild_sailing.sign,
	Fun = fun({ServerId, TgGuildId}) ->
		ServerId == TServerId andalso TgGuildId == TGuildId
	end,
	length(lists:filter(Fun, SignList)) > 0.

del_sign(GuildId,TGuildId,TServerId) ->
	Rec = get_guild_data(GuildId),
	NewRec = Rec#guild_sailing{
		sign = lists:delete({TServerId, TGuildId}, Rec#guild_sailing.sign)
	},
	set_guild_data(NewRec).

add_sign(GuildId,TGuildId,TServerId) ->
	Rec = get_guild_data(GuildId),
	NewRec = Rec#guild_sailing{
		sign = [{TServerId, TGuildId} | Rec#guild_sailing.sign]
	},
	set_guild_data(NewRec).

add_guild_point(GuildId, Point) ->
	case fun_system_activity:find_open_activity(?SYSTEM_UNCHARTER_WATER) of
		{ok, _} ->
			Rec = get_guild_data(GuildId),
			NewRec = Rec#guild_sailing{
				point = Rec#guild_sailing.point + Point
			},
			system_uncharter_water:to_global({update_toplist, db:get_all_config(servername), GuildId, fun_guild:get_guild_name(GuildId), NewRec#guild_sailing.point}),
			set_guild_data(NewRec);
		_ -> skip
	end.

refresh_daily_data(Uid) ->
	Rec = get_data(Uid),
	NewRec = Rec#usr_sailing{
		sailing_time = util:get_data_para_num(1198),
		buy_times 	 = 0,
		guard_time 	 = util:get_data_para_num(1201),
		plunder_list = [],
		plunder_time = util:get_data_para_num(1199)
	},
	set_data(NewRec).

check_sailing(Uid, Rec) ->
	case db:dirty_get(system_activity, ?SYSTEM_UNCHARTER_WATER, #system_activity.act_type) of
		[#system_activity{act_status=Status}] ->
			case Status of
				?ACT_OPEN ->
					case fun_guild:get_guild_baseinfo(Uid) of
						{ok, _, _} ->
							case Rec#usr_sailing.status of
								?NOT_SAILING ->
									case Rec#usr_sailing.sailing_time > 0 of
										true ->
											case fun_agent_mng:get_global_value(sailing_end_time, 0) > util_time:unixtime() of
												true -> ok;
												_ -> {error, "sailing_over02"}
											end;
										_ -> {error, "sailing_number"}
									end;
								_ -> {error, "sailing_underway"}
							end;
						_ -> {error, "sailing_cant_sailing"}
					end;
				_ -> {error, "sailing_over"}
			end;
		_ -> {error, "sailing_over"}
	end.