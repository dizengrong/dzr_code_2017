-module(mod_scene_lev).
-include("common.hrl").

-export([handle/1,get_curr_scene_lv/1,get_winned_scene_lv/1]).
-export([gm_set_scene_lv/3, is_in_change_barrier_state/0]).
-export([agent_move_pos/3, agent_atk_boss/3, main_scene_lose/3, req_copy_out/3]).

-define(BATTLE_START, 	0). %%战斗开始
-define(BATTLE_END, 	1). %%战斗结束

%% =============================================================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_main_scene) of
		[] -> #t_main_scene{uid = Uid, scene_lev = 1};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	mod_role_tab:insert(Rec#t_main_scene.uid, Rec).

%% 获取当前所在关卡（但是未通关的）
get_curr_scene_lv(Uid) ->
	#t_main_scene{scene_lev = Stage} = get_data(Uid),
	Stage.

%% 获取当前已通关的关卡
get_winned_scene_lv(Uid) ->
	#t_main_scene{scene_lev = Stage} = get_data(Uid),
	Stage - 1.
%% =============================================================================

agent_move_pos(Uid, Sid, Seq) ->
	[#usr{lev = Lv, fighting = Gs}] = db:dirty_get(usr, Uid),
	Stage = get_curr_scene_lv(Uid),
	#st_dungeons_config{lvRestriction = NeedLv, forceLimitation = NeedGs} = data_dungeons_config:get_dungeons(Stage),
	case Lv < NeedLv orelse Gs < NeedGs orelse fun_entourage:get_battle_entourage(Uid) == [] of
		true ->
			?error_report(Sid, "error_atk_boss_lv", Seq);
		_ ->
			fun_agent:handle_to_scene(fun_scene_main, {move_pos, Uid, Stage}),
			put(stage_battle, true),
			send_battle_statsu_to_client(Sid, Seq, ?BATTLE_START),
			% fun_count:on_count_event(Uid, Sid, ?TASK_STAGE_BOSS, 0, 1),
			ok
	end.

agent_atk_boss(Uid, Sid, Seq) ->
	case get(stage_battle) of
		true ->
			[#usr{lev = Lv, fighting = Gs}] = db:dirty_get(usr, Uid),
			Stage = get_curr_scene_lv(Uid),
			#st_dungeons_config{lvRestriction = NeedLv, forceLimitation = NeedGs} = data_dungeons_config:get_dungeons(Stage),
			case Lv < NeedLv orelse Gs < NeedGs of
				true -> ?error_report(Sid, "error_atk_boss_lv", Seq);
				_ ->
					fun_agent:handle_to_scene(fun_scene_main, {atk_boss, Uid, Stage}),
					% fun_count:on_count_event(Uid, Sid, ?TASK_STAGE_BOSS, 0, 1),
					ok
			end;
		_ -> skip
	end.

main_scene_lose(Uid, _Sid, _Seq) ->
	case get(stage_battle) of
		true -> fun_agent:handle_to_scene(fun_scene_main, {scene_lose, Uid});
		_ -> skip
	end.

gm_set_scene_lv(Uid, Sid, SceneLev) ->
	Rec = get_data(Uid),
	Rec2 = Rec#t_main_scene{scene_lev = SceneLev},
	set_data(Rec2),
	update_scene_lev(Uid, Sid, SceneLev),
	% on_pass_stage(Uid, Sid, Stage),
	% send_stage_info(Uid, Sid),
	mod_scene_api:enter_stage(Uid, Sid, 0),
	ok.

update_scene_lev(Uid, Sid, SceneLev) ->
	SceneLev = get_curr_scene_lv(Uid),
	send_scene_lev(Sid, Uid, SceneLev),
	ok.

handle({stage_finished, Stage, ItemList}) ->
	set_change_barrier_state(),
	Uid = get(uid),
	Sid = get(sid),
	Next = get_next_scenelev(Stage),
	Rec = get_data(Uid),
	NewRec = Rec#t_main_scene{scene_lev = Next},
	set_data(NewRec),
	fun_count:on_count_event(Uid, Sid, ?TASK_PASS_STAGE, 0, Next),
	update_scene_lev(Uid, Sid, Next),
	put(stage_battle, false),
	send_battle_statsu_to_client(Sid, 0, ?BATTLE_END),
	Args = #api_item_args{
		way = ?ITEM_WAY_CLEAR_STAGE,
		add = ItemList
	},
	fun_item_api:add_items(Uid, Sid, 0, Args),
	ok;

handle({stage_lose}) ->
	Sid = get(sid),
	put(stage_battle, false),
	send_battle_statsu_to_client(Sid, 0, ?BATTLE_END),
	ok;

handle(copy_out) ->
	req_copy_out(get(uid), get(sid), 0),
	ok;

handle(_Msg) -> ?ERROR("unknow msg,Msg = ~p",[_Msg]).

%% 请求退出副本
req_copy_out(Uid, Sid, Seq) ->
	mod_scene_api:enter_stage(Uid, Sid, Seq).


get_next_scenelev(SceneLev) ->
	case data_dungeons_config:get_dungeons(SceneLev) of
		#st_dungeons_config{nextStage = NextSceneLev} -> NextSceneLev;
		_ -> SceneLev + 1
	end.

send_scene_lev(Sid,Uid,Lev) ->
	List = [
		{?PROPERTY_SCENE_LEV, Lev}
	],
	PtBin = fun_property:make_property_pt(Uid, List),
	?send(Sid, PtBin).

set_change_barrier_state() ->
	put(change_barrier_state, util_time:unixtime()).

%% 是否处在改变关卡副本的状态(agent进程调用)
is_in_change_barrier_state() ->
	Val = util:get_process_dict(change_barrier_state, 0),
	util_time:unixtime() =< (Val + 3).

send_battle_statsu_to_client(Sid, Seq, Status) ->
	Pt = #pt_main_scene_status{status = Status},
	?send(Sid, proto:pack(Pt, Seq)).