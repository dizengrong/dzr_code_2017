-module(fun_scene_arena).
-include("common.hrl").
-export([on_user_enter/1]).
-export([on_create/1,on_stop/1]).
-export([doMsg/1,do_on_time/1,onTimer/3]).
-export([send_result/1,entourage_die/1]).
-export([start_help/1]).

-define (TIME_LEN, 180).

on_create(_Scene) ->
%% 	erlang:put(sys_object,1),
	erlang:put(sys_object,?INSTANCE_OFF),
	erlang:put(robot_attack_robot, true),
	erlang:put(cannot_attack_usr, true),
	put(arena_finish,0),
	%%添加场景触发脚本 satan 2016.1.30
	fun_scene:run_scene_script(onCreate,[]).

on_stop(_Scene) ->
	case get(arena_finish) of
		0 ->
			send_result(?LOSE);
		_ -> skip
	end.

on_user_enter(_Id) ->
	scene_big_loop:add_callback(3, ?MODULE, start_help, 5),
	add_robot(),
	scene_big_loop:add_callback(?TIME_LEN, ?MODULE, send_result, ?LOSE).

start_help(Time) ->
	Pt=#pt_arena_start_time{
		start_time = Time
	},
	fun_scene_obj:send_all_usr(proto:pack(Pt)).

entourage_die(OwnerId) ->
	{UsrId, UsrEntourageNum} = get(usr_robot),
	{ChaId, ChallEntourageNum} = get(chall_robot),
	case get(arena_finish) of
		0 ->
			case OwnerId of
				UsrId ->
					case get(usr_die) of
						undefined -> put(usr_die, 1);
						Val -> put(usr_die, Val + 1)
					end,
					case get(usr_die) >= UsrEntourageNum of
						true ->
							scene_big_loop:add_callback(3, ?MODULE, send_result, ?LOSE);
						_ -> skip
					end;
				ChaId ->
					case get(robot_die) of
						undefined -> put(robot_die, 1);
						Val -> put(robot_die, Val + 1)
					end,
					case get(robot_die) >= ChallEntourageNum of
						true ->
							scene_big_loop:add_callback(3, ?MODULE, send_result, ?WIN);
						_ -> skip
					end;
				_ -> ?log_error("arena data error, whoes entourage die : ~p",[OwnerId])
			end;
		_ -> skip
	end.

add_robot() ->
	case get(scene_info) of
		{arena_scene,Uid,UsrData,UsrPoint,{UsrObjData,UsrEntourageData},UsrPos,ChallUid,ChallData,ChallPoint,{ChallObjData,ChallEntourageData},ChallPos} ->
			put(arena_type,?PERSONAL_ARENA),
			put(uid,Uid),
			put(chall_id,ChallUid),
			put(usr_data,UsrData),
			put(usr_point,UsrPoint),
			put(chall_data,ChallData),
			put(chall_point,ChallPoint),
			{ok, UsrId} = fun_scene:robot_enter_scene(UsrObjData,ChallPos,UsrPos,UsrEntourageData,90),
			{ok, ChaId} = fun_scene:robot_enter_scene(ChallObjData,UsrPos,ChallPos,ChallEntourageData,270),
			EntourageList = [Entourage#item.type || {Entourage, _, _, _, _} <- ChallEntourageData],
			util_scene:send_defender_zhenfa(Uid, EntourageList),
			put(usr_robot, {UsrId, length(UsrEntourageData)}),
			put(chall_robot, {ChaId, length(ChallEntourageData)});
		{friend_arena_scene,Uid,UsrData,{UsrObjData,UsrEntourageData},UsrPos,ChallUid,ChallData,{ChallObjData,ChallEntourageData},ChallPos} ->
			put(arena_type,?FRIEND_ARENA),
			put(uid,Uid),
			put(chall_id,ChallUid),
			put(usr_data,UsrData),
			put(chall_data,ChallData),
			{ok, UsrId} = fun_scene:robot_enter_scene(UsrObjData,ChallPos,UsrPos,UsrEntourageData,90),
			{ok, ChaId} = fun_scene:robot_enter_scene(ChallObjData,UsrPos,ChallPos,ChallEntourageData,270),
			EntourageList = [Entourage#item.type || {Entourage, _, _, _, _} <- ChallEntourageData],
			util_scene:send_defender_zhenfa(Uid, EntourageList),
			put(usr_robot, {UsrId, length(UsrEntourageData)}),
			put(chall_robot, {ChaId, length(ChallEntourageData)});
		_ -> ?log_error("scenedata match fail~n"),skip
	end.

do_on_time(_Cmd) -> continue.

doMsg(_Msg) -> continue.
onTimer(Obj,_Now,_Scene) -> Obj.

send_result(Result) ->
	case get(arena_finish) of
		0 ->
			put(arena_finish, 1),
			{UsrName, UsrLev} = get(usr_data),
			{ChallName, ChallLev} = get(chall_data),
			{UsrPoint, ChallPoint, UsrChange, Reward} = case get(arena_type) of
				?PERSONAL_ARENA ->
					UsrPoint1 = get(usr_point),
					ChallPoint1 = get(chall_point),
					{UsrChange1, ChallChange1, Reward1} = case Result of
						?WIN ->
							{
								mod_arena_ranklist:get_win_point_change(?PERSONAL_ARENA, UsrPoint1, ChallPoint1), 
								-mod_arena_ranklist:get_lose_point_change(?PERSONAL_ARENA, ChallPoint1),
								fun_draw:box(data_arena:get_win_reward(?PERSONAL_ARENA))
							};
						?LOSE ->
							{
								-mod_arena_ranklist:get_lose_point_change(?PERSONAL_ARENA, UsrPoint1),
								mod_arena_ranklist:get_win_point_change(?PERSONAL_ARENA, ChallPoint1, UsrPoint1),
								fun_draw:box(data_arena:get_fail_reward(?PERSONAL_ARENA))
							}
					end,
					mod_msg:handle_to_agnetmng(mod_arena_ranklist, {get(uid), get(chall_id), UsrChange1, ChallChange1, Reward1, Result}),
					{UsrPoint1, ChallPoint1, UsrChange1, Reward1};
				_ -> {0, 0, 0, []}
			end,
			Pt = #pt_arena_result{
				arena_type	 = get(arena_type),
				result 		 = Result,
				point_change = abs(UsrChange),
				usr_name     = util:to_list(UsrName),
				chall_name   = util:to_list(ChallName),
				usr_point    = UsrPoint,
				chall_point  = ChallPoint,
				usr_lev      = UsrLev,
				chall_lev    = ChallLev,
				reward_list  = fun_item_api:make_item_pt_list(Reward),
				damage_list  = util_pt:make_damage_list_pt(fun_scene_skill:get_scene_damage_list()),
				treat_list 	 = util_pt:make_damage_list_pt(fun_scene_skill:get_scene_treat_list())
			},
			fun_scene_obj:send_all_usr(proto:pack(Pt));
		_ -> skip
	end.