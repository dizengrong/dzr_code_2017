%%竞技场
-module(fun_arena).
-include("common.hrl").
-export([handle/1]).
-export([has_in_guard/2,is_robot/1,refresh_times/1,get_all_on_battled_heros/1,arena_end_help/6,get_arena_used_shenqi/1]).
-export([req_arena_info/3,req_arena_challenge_info/3]).
-export([req_set_guard_list/5, req_arena_challenge_single_info/4]).
-export([req_enter_arena/8,req_arena_revenge/7]).

%% =============================================================================
get_data(Uid) ->
	case db_api:dirty_read(t_arena_info, Uid) of
		[] -> #t_arena_info{uid = Uid, times = data_arena:get_free_times(?PERSONAL_ARENA)};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	db_api:dirty_write(Rec).

%% =============================================================================

handle({enter_arena_cost,Uid, Sid, Seq, SpendItems, Data}) ->
	Succ = fun() ->
		mod_msg:handle_to_agnetmng(?MODULE, {enter_arena, Uid, Sid, Seq, Data}),
		ok
	end,
	Args = #api_item_args{
		way      = ?ITEM_WAY_ARENA,
		spend    = SpendItems,
		succ_fun = Succ
	},
	fun_item_api:add_items(Uid, Sid, Seq, Args);

handle({on_enter_arena, Uid, Sid, Seq, NewList, ShenqiId}) ->
	fun_count:on_count_event(Uid, Sid, ?TASK_PERSPNAL_ARENA, 0, 1),
	mod_entourage_data:set_entourage_data(Uid, NewList, ShenqiId, ?PERSONAL_ARENA_ATTACK),
	mod_entourage_data:send_on_battle_heros(Uid, Sid, Seq, ?PERSONAL_ARENA_ATTACK),
	ok;

handle({enter_arena, Uid, Sid, Seq, {NewRec, ChallUid, EntourageList, ShenqiId, AgentHid}}) ->
	enter_arena(Uid, Sid, Seq, NewRec, ChallUid, EntourageList, ShenqiId, AgentHid);

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

%% 获取所有在竞技场中上阵的英雄 return: [{ItemId, Type, Pos}]
get_all_on_battled_heros(Uid) ->
	{List, _} = mod_entourage_data:get_entourage_data(Uid, ?PERSONAL_ARENA_GUARD),
	List.

get_arena_used_shenqi_id(Uid) ->
	{_, ShenqiId} = mod_entourage_data:get_entourage_data(Uid, ?PERSONAL_ARENA_GUARD),
	ShenqiId.

get_arena_used_shenqi(Uid) ->
	ShenqiId = get_arena_used_shenqi_id(Uid),
	case fun_item_api:get_item_by_id2(Uid, ShenqiId) of
		[] -> {0, 0, 0};
		[#item{type = Type, star = Star, lev = Lv}] -> 
			{Type, Star, Lv}
	end.

refresh_times(Uid) ->
	Rec = get_data(Uid),
	set_data(Rec#t_arena_info{times = data_arena:get_free_times(?PERSONAL_ARENA)}).

req_set_guard_list(Uid, Sid, EntourageList, ShenqiId, Seq) ->
	NewList = util_entourage:make_entourage_list(Uid, EntourageList),
	mod_entourage_data:set_entourage_data(Uid, NewList, ShenqiId, ?PERSONAL_ARENA_GUARD),
	case db_api:dirty_index_read(?T_RANK_ARENA, Uid, #ranklist_arena.uid) of
		[] -> mod_rank_service:update_arena(0, Uid, util:get_name_by_uid(Uid), util:get_lev_by_uid(Uid));
		_ -> skip
	end,
	mod_entourage_data:send_on_battle_heros(Uid, Sid, Seq, ?PERSONAL_ARENA_GUARD).

req_arena_info(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_arena_info{
		times         = Rec#t_arena_info.times,
		fighting      = mod_entourage_property:get_total_gs(Uid, [ItemId || {ItemId, _, _} <- get_all_on_battled_heros(Uid)]),
		rank          = mod_arena_ranklist:get_rank_by_uid(Uid, ?T_RANK_ARENA),
		point         = mod_arena_ranklist:get_value_by_uid(Uid, ?T_RANK_ARENA),
		last_rank     = mod_arena_ranklist:get_last_rank(Uid, ?PERSONAL_ARENA),
		arena_record  = [#pt_public_arena_record_list{t_uid = TUid, name = util:to_list(Name), time = Time, result = Result, change = abs(Change), revenge = Revenge} || {TUid, Name, Time, Result, Change, Revenge} <- Rec#t_arena_info.arena_record]
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_arena_challenge_info(Uid, Sid, Seq) ->
	case get_all_on_battled_heros(Uid) of
		[] -> skip;
		_ ->
			Rank = mod_arena_ranklist:get_rank_by_uid(Uid, ?T_RANK_ARENA),
			ChallengeList = mod_arena_ranklist:get_chall_info(Rank, ?PERSONAL_ARENA),
			Fun = fun({TUid, TRank, Name}) ->
				#pt_public_challenge_list{
					uid  = TUid,
					rank = TRank,
					name = util:to_list(Name)
				}
			end,
			Pt = #pt_arena_challenge_info{
				challenge_list = lists:map(Fun, ChallengeList)
			},
			?send(Sid, proto:pack(Pt, Seq))
	end.

req_arena_challenge_single_info(_Uid, Sid, Seq, TUid) ->
	case get_chall_single_data(TUid) of
		{ShenqiType, Fighting, EntourageList} ->
			Fun = fun({Etype, Lev, Star}) ->
				#pt_public_entourage_info_list{
					etype = Etype,
					lev = Lev,
					estar = Star
				}
			end,
			Pt = #pt_arena_challenge_single_info{
				uid 	       = TUid,
				shenqi         = ShenqiType,
				fighting       = Fighting,
				entourage_list = lists:map(Fun, EntourageList)
			},
			?send(Sid, proto:pack(Pt, Seq));
		_ -> skip
	end.

req_arena_revenge(_Uid, _Sid, _Seq, _ChallUid, _ChallType, [], _ShenqiId) -> ?log_error("error entourage list");
req_arena_revenge(Uid, Sid, Seq, ChallUid, ChallType, EntourageList, ShenqiId) when length(EntourageList) =< ?MAX_ENTOURAGE ->
	case get(personal_arena) of
		1 ->
			Rec = get_data(Uid),
			List = Rec#t_arena_info.arena_record,
			case lists:keyfind(ChallUid, 1, List) of
				{ChallUid, Name, Time, Result, Change, Revenge} ->
					case Revenge of
						?CAN_REVENGE ->
							NewList = lists:keystore(ChallUid, 1, List, {ChallUid, Name, Time, Result, Change, ?CANNOT_REVENGE}),
							NewRec = Rec#t_arena_info{arena_record = NewList},
							set_data(NewRec),
							req_enter_arena(Uid, Sid, Seq, ChallUid, ChallType, EntourageList, ShenqiId, true);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> ?error_report(Sid, "arena_notopen", Seq)
	end;
req_arena_revenge(Uid, _Sid, _Seq, _ChallUid, _ChallType, EntourageList, _ShenqiId) -> ?log_error("~p error entourage list: ~p",[Uid, EntourageList]).

req_enter_arena(_Uid, _Sid, _Seq, _ChallUid, _ChallType, [], _ShenqiId, _IsRevenge) -> ?log_error("error entourage list");
req_enter_arena(Uid, Sid, Seq, ChallUid, ?PERSONAL_ARENA, EntourageList, ShenqiId, _IsRevenge) when length(EntourageList) =< ?MAX_ENTOURAGE ->
	case get(personal_arena) of
		1 ->
			Rec = get_data(Uid),
			{NewRec, SpendItems} = case Rec#t_arena_info.times > 0 of
				true -> {Rec#t_arena_info{times = Rec#t_arena_info.times - 1}, []};
				_ -> {Rec, data_arena:get_cost(?PERSONAL_ARENA)}
			end,
			[#ply{agent_hid = AgentHid}] = db:dirty_get(ply, Uid),
			case SpendItems of
				[] -> enter_arena(Uid, Sid, Seq, NewRec, ChallUid, EntourageList, ShenqiId, AgentHid);
				_ -> util_misc:msg_handle_cast(AgentHid, ?MODULE, {enter_arena_cost,Uid, Sid, Seq, SpendItems, {NewRec, ChallUid, EntourageList, ShenqiId, AgentHid}})
			end;
		_ -> ?error_report(Sid, "arena_notopen", Seq)
	end;
req_enter_arena(Uid, _Sid, _Seq, _ChallUid, _ChallType, EntourageList, _ShenqiId, _IsRevenge) -> ?log_error("~p error entourage list: ~p",[Uid, EntourageList]).

enter_arena(Uid, Sid, Seq, NewRec, ChallUid, EntourageList, ShenqiId, AgentHid) ->
	UsrPoint = mod_arena_ranklist:get_value_by_uid(Uid, ?T_RANK_ARENA),
	ChallPoint = mod_arena_ranklist:get_value_by_uid(ChallUid, ?T_RANK_ARENA),
	NewList = util_entourage:make_entourage_list(Uid, EntourageList),
	{UsrData, UsrObjData} = util_pk:get_target_role(Uid, NewList, ShenqiId),
	{ChallData, ChallObjData} = util_pk:get_robot_data(ChallUid),
	#st_scene_config{sort=?SCENE_SORT_ARENA, points = PointList} = data_scene_config:get_scene(?PK_SCENE_ID),
	UsrInfoList=[{Uid,Seq,lists:nth(3, PointList),#ply_scene_data{sid = Sid}}],
	SceneData={arena_scene,Uid,UsrData,UsrPoint,UsrObjData,lists:nth(1, PointList),ChallUid,ChallData,ChallPoint,ChallObjData,lists:nth(2, PointList)},
	util_misc:msg_handle_cast(AgentHid, mod_scene_api, {enter_pk_scene,Uid,UsrInfoList,SceneData}),
	util_misc:msg_handle_cast(AgentHid, ?MODULE, {on_enter_arena, Uid, Sid, Seq, NewList, ShenqiId}),
	set_data(NewRec).

has_in_guard(Uid, ItemId) ->
	case lists:keyfind(ItemId, 1, get_all_on_battled_heros(Uid)) of
		false -> false;
		_ -> true
	end.

is_robot(Uid) ->
	case data_robot:get_data(Uid) of
		#st_robot{} -> true;
		_ -> false
	end.

get_chall_single_data(Uid) ->
	case is_robot(Uid) of
		true ->
			#st_robot{entourageList = EntourageList, artifact = {ShenqiType, _, _}} = data_robot:get_data(Uid),
			Fun = fun({Eid, Etype}, {Acc1, Acc2}) ->
				case data_monster:get_monster(Eid) of
					#st_monster_config{level = Lev, star = Star} ->
						Battle = fun_property:get_monster_property_by_difficulty(Eid, #st_dungeon_dificulty{}),
						Attrs = fun_property:property_get_data_by_type(Battle),
						Fighting = fun_agent_property:get_attr_gs(Attrs),
						{[{Etype, Lev, Star} | Acc1], Fighting + Acc2};
					_ -> {Acc1, Acc2}
				end
			end,
			{EL, Gs} = lists:foldl(Fun, {[], 0}, EntourageList),
			{ShenqiType, Gs, EL};
		_ ->
			{ShenqiType, _, _} = get_arena_used_shenqi(Uid),
			EntourageList = get_all_on_battled_heros(Uid),
			Fun = fun({Eid, Etype, _}, {Acc1, Acc2}) ->
				 case fun_item_api:get_item_by_id(Uid, Eid) of
					#item{lev = Lev, star = Star} ->
						Battle = mod_entourage_property:get_entourage_prop(Uid, Eid),
						Attrs = fun_property:property_get_data_by_type(Battle),
						Fighting = fun_agent_property:get_attr_gs(Attrs),
						{[{Etype, Lev, Star} | Acc1], Fighting + Acc2};
					_ -> {Acc1, Acc2}
				end
			end,
			{EL, Gs} = lists:foldl(Fun, {[], 0}, EntourageList),
			{ShenqiType, Gs, EL}
	end.

arena_end_help(Uid, ChallUid, UsrChange, ChallChange, Result, Args) ->
	usr_arena_end(Uid, ChallUid, UsrChange, Result, Args),
	case is_robot(ChallUid) of
		true -> skip;
		_ -> chall_arena_end_help(ChallUid, Uid, ChallChange, Result)
	end.

usr_arena_end(Uid, ChallUid, Change, Result, Args) ->
	Rec = get_data(Uid),
	List = Rec#t_arena_info.arena_record,
	NewList = case lists:keyfind(ChallUid, 1, List) of
		{ChallUid, Name, _, _, _, _} -> lists:keystore(ChallUid, 1, List, {ChallUid, Name, agent:agent_now(), Result, Change, ?CANNOT_REVENGE});
		_ ->
			case is_robot(ChallUid) of
				true ->
					#st_robot{name = Name} = data_robot:get_data(ChallUid),
					lists:sublist([{ChallUid, Name, util_time:unixtime(), Result, Change, ?CANNOT_REVENGE} | List], 10);
				_ -> lists:sublist([{ChallUid, util:get_name_by_uid(ChallUid), util_time:unixtime(), Result, Change, ?CANNOT_REVENGE} | List], 10)
			end
	end,
	NewRec = Rec#t_arena_info{arena_record = NewList},
	set_data(NewRec),
	fun_item_api:add_items(Uid, get(sid), 0, Args),
	ok.

chall_arena_end_help(Uid, ChallUid, Change, Result) ->
	[Rec = #t_arena_info{arena_record = List}] = db_api:dirty_read(t_arena_info, Uid),
	NewResult = case Result of
		?WIN -> ?LOSE;
		_ -> ?WIN
	end,
	Revenge = case NewResult of
		?WIN -> ?CANNOT_REVENGE;
		_ -> ?CAN_REVENGE
	end,
	NewList = case lists:keyfind(ChallUid, 1, List) of
		{ChallUid, Name, _, _, _, _} -> lists:keystore(ChallUid, 1, List, {ChallUid, Name, util_time:unixtime(), NewResult, Change, Revenge});
		_ -> lists:sublist([{ChallUid, util:get_name_by_uid(ChallUid), util_time:unixtime(), NewResult, Change, Revenge} | List], 10)
	end,
	NewRec = Rec#t_arena_info{arena_record = NewList},
	db_api:dirty_write(t_arena_info, NewRec),
	ok.