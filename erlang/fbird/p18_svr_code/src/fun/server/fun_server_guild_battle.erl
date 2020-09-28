%% @doc 游戏服公会战模块
-module (fun_server_guild_battle).
-include("common.hrl").
-export ([to_global/1, sync_top_16_guild_to_global/0, global_get_guild_members/1]).
-export ([req_info/3, req_watch/4, handle/1, req_my_team_info/3, req_battle_log/3]).
-export ([req_change_strategy/4, req_inspire/3, req_stake/6, req_group/4, req_use_shenqi/4]).

% fun_server_guild_battle:to_global({test_enter, hd(db:dirty_get(ply, 200000000008))}).

to_global(Msg) -> 
	Msg2 = {fun_global_guild_battle, Msg},
	gen_server:cast({global, global_client_ggb}, {to_global, Msg2}).


%% 注意这个方法只能在fun_toplist_new进程内调用
sync_top_16_guild_to_global() -> skip.
	% List = fun_toplist_new:get_top_n_in_process(?RANKLIST_GUILD_FIGHTING, 16),
	% List2 = [make_ggb_team(GuildId, Fighting) || #ranklist_guild_fighting{guild_id = GuildId, num = Fighting} <- List],
	% to_global({top_16_guild, List2}).


% make_ggb_team(GuildId, Fighting) ->
% 	ServerId   = db:get_all_config(serverid),
% 	ServerName = db:get_all_config(servername),
% 	GuildName  = fun_guild:get_guild_name(GuildId),
% 	#ggb_team{
% 		team_id     = {ServerId, GuildId},
% 		server_name = ServerName,
% 		guild_name  = GuildName,
% 		fighting    = Fighting
% 	}.


req_battle_log(Uid, Sid, _Seq) -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	to_global({req_battle_log, Sid, MyGuildId}),
	ok.

req_info(Uid, Sid, _Seq) -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	to_global({req_info, Uid, Sid, MyGuildId}),
	ok.

req_inspire(Uid, Sid, _Seq) ->
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	to_global({req_inspire, self(), Sid, MyGuildId}),
	ok.


req_watch(Uid, _Sid, _Seq, GroupId) -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	[PlyRec] = db:dirty_get(ply, Uid),
	to_global({req_watch, PlyRec, MyGuildId, GroupId}),
	ok.


req_use_shenqi(Uid, _Sid, _Seq, ToTeam) -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	[PlyRec] = db:dirty_get(ply, Uid),
	to_global({req_use_shenqi, PlyRec, MyGuildId, ToTeam}),
	ok.


req_change_strategy(Uid, Sid, _Seq, NewStrategy) -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	case fun_guild:get_guild_president_uid(MyGuildId) of
		Uid -> 
			to_global({req_change_strategy, Sid, MyGuildId, NewStrategy});
		_ -> 
			?error_report(Sid, "error_common_just_president_can")
	end,
	ok.


req_stake(Uid, Sid, _Seq, StakeType, StakeServerId, StakeGuildId) 
	when StakeType == ?STAKE_TYPE_1 orelse 
		 StakeType == ?STAKE_TYPE_2 -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	to_global({req_stake, Uid, self(), Sid, MyGuildId, StakeType, {StakeServerId, StakeGuildId}}),
	ok.


req_group(Uid, Sid, _Seq, GroupId) -> 
	?debug("GroupId:~p", [GroupId]),
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	to_global({req_group, Uid, Sid, MyGuildId, GroupId}),
	ok.


req_my_team_info(Uid, Sid, _Seq) -> 
	MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
	to_global({req_my_team_info, Sid, MyGuildId}),
	ok.


%% global节点请求获取公会成员的数据
global_get_guild_members(GuildId) ->
	List  = fun_guild:get_members(GuildId),
	List2 = [begin 
		{Rec, EntourageData} = fun_arena:get_ply_data(Uid),
		{Rec#scene_spirit_ex{camp = 11}, EntourageData}
		end || #guild_member{uid=Uid} <- List],
	to_global({guild_members, GuildId, List2}).


handle({stake_check_ok, StakeType, TeamId}) -> 
	{Costs, _, _} = data_ggb:get_stake(StakeType),
	Uid = get(uid),
	Sid = get(sid),
	SpendItems = [{?ITEM_WAY_GGB_STAKE, I, N} || {I, N} <- Costs],
	SuccCallBack = fun() ->
		MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
		to_global({req_stake_payed, Uid, Sid, MyGuildId, StakeType, TeamId})
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, undefined);


%% agent_mng消息
handle({do_broadcast, Id, Datas}) -> 
	StringList = [integer_to_list(Id) | Datas],
	mod_msg:handle_to_chat_server({send_system_speaker, StringList});

handle({battle_begin_broadcasted, Status}) -> 
	Pt = #pt_ggb_nofity{status = Status},
	PtBin = proto:pack(Pt),
	Fun = fun(Uid) -> 
		[#ply{sid = Sid}] = db:dirty_get(ply, Uid),
		?send(Sid, PtBin)
	end, 
	[Fun(Uid) || Uid <- db:dirty_all_keys(ply)];

handle({promotion_mail, Rank, GuildId}) -> 
	{Reward1, Reward2} = data_ggb:get_promotion_reward(Rank),
	case Rank of
		1 -> 
			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(society_champion);
		2 -> 
			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(society_second);
		_ -> 
			#mail_content{mailName = Title, text = Content0} = data_mail:data_mail(society9),
			Content = util:format_lang(Content0, [util:to_list(Rank)])
	end,
	Fun = fun(#guild_member{uid = Uid, perm = Perm}) -> 
		Reward = ?_IF(Perm == ?PERM_PRESIDENT, Reward1, Reward2),
		mod_mail_new:sys_send_personal_mail(Uid, Title, Content, Reward, ?MAIL_TIME_LEN)
	end,
	[Fun(M) || M <- fun_guild:get_members(GuildId)],
	ok;

handle({stake_mail, ServerName, GuildName, Uid, MailId, Rewards}) -> 
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(MailId),
	Content2 = util:format_lang(Content, [ServerName, GuildName]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, Rewards, ?MAIL_TIME_LEN);

handle({send_battle_win_reward_mail, WinGuildId}) -> 
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(society_win),
	Fun = fun(#guild_member{uid = Uid, perm = _Perm}) -> 
		Reward = data_guild_battle_setting:first_period_battle_win_reward(),
		mod_mail_new:sys_send_personal_mail(Uid, Title, Content, Reward, ?MAIL_TIME_LEN)
	end,
	[Fun(M) || M <- fun_guild:get_members(WinGuildId)],
	ok;

%% agent消息
handle({send_watch_reward}) -> 
	Uid = get(uid),
	Rewards = [{?RESOUCE_COIN_NUM, util:get_data_para_num(1167)}],
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(watch_award),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content, Rewards, ?MAIL_TIME_LEN);

handle({inspire_check_ok, Inspire}) -> 
	{Costs, _} = data_ggb:get_inspire(Inspire + 1),
	Uid = get(uid),
	Sid = get(sid),
	SpendItems = [{?ITEM_WAY_BUY_INSPIRE, I, N} || {I, N} <- Costs],
	SuccCallBack = fun() ->
		MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
		to_global({req_inspire_payed, Sid, MyGuildId, true})
	end,
	FailCallBack = fun() -> 
		MyGuildId = fun_guild:get_guild_id_by_uid(Uid),
		to_global({req_inspire_payed, Sid, MyGuildId, false})
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, FailCallBack);

handle({global_get_guild_members, GuildId}) ->
	global_get_guild_members(GuildId).


