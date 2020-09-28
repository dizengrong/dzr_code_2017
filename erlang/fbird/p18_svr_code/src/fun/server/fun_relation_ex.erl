-module(fun_relation_ex).
-include("common.hrl").
-export([init_data/0]).
-export([init_data/1]).
-export([req_friend_info/3, req_one_delete_friend_apply/3, req_recommend_list/3]).
-export([req_friend_apply/4, req_pass_friend_apply/4, req_delete_friend_apply/4, req_delete_friend/4, req_friend_top/4]).
-export([req_search_friend/4]).
-export([req_friend_attack/7]).
-export([send_friend_to_sid/3, send_apply_to_sid/3]).
-export([check_is_friend/2]).

-define(MAX_FRIEND, 30).

%% =============================================================================
get_data(Uid) ->
	case db_api:dirty_read(t_role_relation, Uid) of
		[] -> #t_role_relation{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	db_api:dirty_write(Rec).
%% =============================================================================

init_data() ->
	init_data({}),
	ok.

init_data(_) ->
	Now = util_time:unixtime(),
	put(recommend_list, init_data_help(db:dirty_all_keys(usr), Now, [])),
	srv_loop:add_callback(10 * 60, ?MODULE, init_data, {}).

init_data_help([], _Now, Acc) -> Acc;
init_data_help([Uid | Rest], Now, Acc) ->
	case db:dirty_get(usr, Uid) of
		[#usr{id = Uid, last_login_time = LoginTime}] when LoginTime + ?ONE_DAY_SECONDS >= Now -> init_data_help(Rest, Now, [Uid | Acc]);
		_ -> init_data_help(Rest, Now, Acc)
	end.

req_friend_info(Uid, Sid, Seq) ->
	send_friend_to_sid(Uid, Sid, Seq).

req_friend_apply(Uid, Sid, Seq, TUid) ->
	case check_friend_apply(Uid, TUid) of
		{ok, NewRec} ->
			set_data(NewRec),
			case db:dirty_get(ply, TUid) of
				[#ply{sid = TSid}] ->
					send_apply_to_sid(TUid, TSid, Seq);
				_ -> skip
			end;
		{error, Reason} -> ?error_report(Sid, Reason, Seq)
	end.

req_pass_friend_apply(Uid, Sid, Seq, TUid) ->
	case check_friend(Uid, TUid) of
		{ok, NewRec, NewTRec} ->
			set_data(NewRec),
			set_data(NewTRec),
			send_friend_to_sid(Uid, Sid, Seq),
			send_apply_to_sid(Uid, Sid, Seq),
			case db:dirty_get(ply, TUid) of
				[#ply{sid = TSid}] ->
					send_friend_to_sid(TUid, TSid, Seq);
				_ -> skip
			end;
		{error, Reason} -> ?error_report(Sid, Reason, Seq)
	end.

req_delete_friend_apply(Uid, Sid, Seq, TUid) ->
	delete_apply(Uid, TUid),
	send_apply_to_sid(Uid, Sid, Seq).

req_delete_friend(Uid, Sid, Seq, TUid) ->
	Rec = get_data(Uid),
	TRec = get_data(TUid),
	case check_is_friend(Rec, TUid) of
		true ->
			NewFriendList = lists:keydelete(TUid, 1, Rec#t_role_relation.friend_list),
			NewTFriendList = lists:keydelete(Uid, 1, TRec#t_role_relation.friend_list),
			NewRec = Rec#t_role_relation{friend_list = NewFriendList},
			NewTRec = TRec#t_role_relation{friend_list = NewTFriendList},
			set_data(NewRec),
			set_data(NewTRec),
			send_friend_to_sid(Uid, Sid, Seq),
			case db:dirty_get(ply, TUid) of
				[#ply{sid = TSid}] ->
					send_friend_to_sid(TUid, TSid, Seq);
				_ -> skip
			end;
		_ -> skip
	end.

req_one_delete_friend_apply(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#t_role_relation.friend_apply of
		[] -> skip;
		_ ->
			NewRec = Rec#t_role_relation{friend_apply = []},
			set_data(NewRec),
			send_apply_to_sid(Uid, Sid, Seq)
	end.

req_recommend_list(Uid, Sid, Seq) ->
	List = lists:sublist(get(recommend_list), 10),
	Pt = #pt_recommend_friends_info{
		list = [#pt_public_pending_list{uid = TUid, name = util:get_name_by_uid(TUid), lev = util:get_lev_by_uid(TUid), vip_lev = fun_vip:get_vip_lev(TUid)} || TUid <- List, TUid /= Uid andalso (not check_is_friend(Uid, TUid))]
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_search_friend(Uid, Sid, Seq, Name) ->
	case util:to_list(Name) of
		[] -> skip;
		_ ->
			BName = util:to_binary(Name),
			List = make_name_list(db:dirty_all_keys(usr), BName, 1, []),
			Pt = #pt_search_friends_result{
				list = [#pt_public_pending_list{uid = TUid, name = util:get_name_by_uid(TUid), lev = util:get_lev_by_uid(TUid), vip_lev = fun_vip:get_vip_lev(TUid)} || TUid <- List, TUid /= Uid andalso (not check_is_friend(Uid, TUid))]
			},
			?send(Sid, proto:pack(Pt, Seq))
	end.

req_friend_top(Uid, Sid, Seq, TUid) ->
	Rec = get_data(Uid),
	case lists:keyfind(TUid, 1, Rec#t_role_relation.friend_list) of
		{TUid, Lev} ->
			NewLev = case Lev of
				0 -> 1;
				1 -> 0
			end,
			NewList = lists:keystore(TUid, 1, Rec#t_role_relation.friend_list, {TUid, NewLev}),
			NewRec = Rec#t_role_relation{friend_list = NewList},
			set_data(NewRec),
			send_friend_to_sid(Uid, Sid, Seq);
		_ -> skip
	end.

make_name_list([], _BName, _Num, Acc) -> Acc;
make_name_list(_List, _BName, 100, Acc) -> Acc;
make_name_list([Uid | Rest], BName, Num, Acc) ->
	case db:dirty_get(usr, Uid) of
		[#usr{name = Name}] ->
			case binary:match(util:to_binary(Name), BName) of
				{0, _} -> make_name_list(Rest, BName, Num + 1, [Uid | Acc]);
				_ -> make_name_list(Rest, BName, Num, Acc)
			end;
		_ -> make_name_list(Rest, BName, Num, Acc)
	end.

delete_apply(Uid, TUid) ->
	Rec = get_data(Uid),
	NewList = lists:delete(TUid, Rec#t_role_relation.friend_apply),
	NewRec = Rec#t_role_relation{friend_apply = NewList},
	set_data(NewRec).

check_friend(Uid, TUid) ->
	Rec = get_data(Uid),
	TRec = get_data(TUid),
	IsFriend = check_is_friend(Rec, TUid),
	FriendMax = length(Rec#t_role_relation.friend_list) >= ?MAX_FRIEND,
	ApplyFriendMax = length(TRec#t_role_relation.friend_list) >= ?MAX_FRIEND,
	NotApply = not lists:member(TUid, Rec#t_role_relation.friend_apply),
	if
		IsFriend -> {error, "friend"};
		FriendMax -> {error, "friend_own_full"};
		ApplyFriendMax -> {error, "friend_others_full"};
		NotApply -> {error, "check_data_error"};
		true ->
			NewFriendList = lists:keystore(TUid, 1, Rec#t_role_relation.friend_list, {TUid, 0}),
			NewApplyList = lists:delete(TUid, Rec#t_role_relation.friend_apply),
			NewTFriendList = lists:keystore(Uid, 1, TRec#t_role_relation.friend_list, {Uid, 0}),
			NewTApplyList = lists:delete(Uid, TRec#t_role_relation.friend_apply),
			{ok, Rec#t_role_relation{friend_list = NewFriendList, friend_apply = NewApplyList}, TRec#t_role_relation{friend_list = NewTFriendList, friend_apply = NewTApplyList}}
	end.

check_friend_apply(Uid, TUid) ->
	Rec = get_data(Uid),
	TRec = get_data(TUid),
	IsFriend = check_is_friend(Rec, TUid),
	HasApply = check_apply(TRec, Uid),
	FriendMax = length(Rec#t_role_relation.friend_list) >= ?MAX_FRIEND,
	ApplyFriendMax = length(TRec#t_role_relation.friend_list) >= ?MAX_FRIEND,
	ApplyMax =  length(TRec#t_role_relation.friend_apply) >= ?MAX_FRIEND,
	if
		IsFriend -> {error, "friend"};
		HasApply -> {error, "friend_addto"};
		FriendMax -> {error, "friend_own_full"};
		ApplyFriendMax -> {error, "friend_others_full"};
		ApplyMax -> {error, "friend_addto_max"};
		true -> {ok, TRec#t_role_relation{friend_apply = [Uid | TRec#t_role_relation.friend_apply]}}
	end.

check_is_friend(#t_role_relation{friend_list = FriendList}, Uid) ->
	case lists:keyfind(Uid, 1, FriendList) of
		false -> false;
		_ -> true
	end;
check_is_friend(Uid, TUid) ->
	Rec = get_data(Uid),
	check_is_friend(Rec, TUid).

check_apply(#t_role_relation{friend_apply = ApplyList}, Uid) ->
	lists:member(Uid, ApplyList).

send_friend_to_sid(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Fun = fun({TUid,Rank}) ->
		#pt_public_friend_list{
			uid              = TUid,
			name             = util:get_name_by_uid(TUid),
			guild_name       = fun_guild:get_guild_name_by_uid(TUid),
			lev              = util:get_lev_by_uid(TUid),
			vip_lev          = fun_vip:get_vip_lev(TUid),
			rank             = Rank,
			online           = util:get_usr_online(TUid),
			last_logout_time = util:get_last_logout_time_by_uid(TUid)
		}
	end,
	Pt = #pt_friends_info{list = [Fun(U) || U <- Rec#t_role_relation.friend_list]},
	?send(Sid, proto:pack(Pt, Seq)).

send_apply_to_sid(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Fun = fun(TUid) ->
		#pt_public_pending_list{
			uid     = TUid,
			name    = util:get_name_by_uid(TUid),
			lev     = util:get_lev_by_uid(TUid),
			vip_lev = fun_vip:get_vip_lev(TUid)
		}
	end,
	Pt = #pt_friends_apply_info{list = [Fun(U) || U <- Rec#t_role_relation.friend_apply]},
	?send(Sid, proto:pack(Pt, Seq)).

%% =======================================切磋相关======================================
req_friend_attack(_Uid, _Sid, _Seq, _ChallUid, _ChallType, [], _ShenqiId) -> ?log_error("error entourage list");
req_friend_attack(Uid, Sid, Seq, ChallUid, ?FRIEND_ARENA, EntourageList, ShenqiId) when length(EntourageList) =< ?MAX_ENTOURAGE ->
	case util_pk:get_robot_data(ChallUid) of
		[] -> ?error_report(Sid, "none_guard", Seq);
		{ChallData, ChallObjData} ->
			NewList = util_entourage:make_entourage_list(Uid, EntourageList),
			{UsrData, UsrObjData} = util_pk:get_target_role(Uid, NewList, ShenqiId),
			#st_scene_config{sort=?SCENE_SORT_ARENA, points = PointList} = data_scene_config:get_scene(?PK_SCENE_ID),
			UsrInfoList=[{Uid,Seq,lists:nth(3, PointList),#ply_scene_data{sid = Sid}}],
			SceneData={friend_arena_scene,Uid,UsrData,UsrObjData,lists:nth(1, PointList),ChallUid,ChallData,ChallObjData,lists:nth(2, PointList)},
			[#ply{agent_hid = AgentHid}] = db:dirty_get(ply, Uid),
			util_misc:msg_handle_cast(AgentHid, mod_scene_api, {enter_pk_scene,Uid,UsrInfoList,SceneData}),
			ok
	end;
req_friend_attack(Uid, _Sid, _Seq, _ChallUid, _ChallType, EntourageList, _ShenqiId) -> ?log_error("~p error entourage list: ~p",[Uid, EntourageList]).