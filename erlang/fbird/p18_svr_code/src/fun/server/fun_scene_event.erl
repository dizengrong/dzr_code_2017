%% @doc 一些地图事件处理
-module(fun_scene_event).
-include("common.hrl").
-export([handle_scene_event/2, handle/1]).

%% usr进入场景事件
handle_scene_event(usr_enter_scene, Uid) ->
	fun_scene_inspire:on_usr_enter(Uid),
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data =#scene_usr_ex{hid=AgentPid}} -> 
			mod_msg:handle_to_agent(AgentPid, ?MODULE, {usr_enter_scene, get(scene)}),
			fun_scene_cd:clear_cd(Uid),
			fun_scene_cd:clear_entourage_cd(Uid),
			on_tmp_test(get('scene_lev')),
			ok;
		_ ->
			skip
	end;

%% usr离开场景事件
handle_scene_event(usr_out_scene, _Uid) ->
	ok;

%% usr死亡事件
handle_scene_event(usr_die, Uid) ->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data =#scene_usr_ex{hid=AgentPid}} -> 
			mod_msg:handle_to_agent(AgentPid, ?MODULE, {usr_die, Uid}),
			ok;
		_ ->
			skip
	end.
%% ================= agent内消息处理 =================
handle({usr_enter_scene, _Scene}) ->
	ok;
handle({usr_die, _Uid}) ->
	?debug("usr_die"),
	%% 玩家死亡的会跳转场景，下面的代码会在usr_enter_scene后会调用
	ok.



on_tmp_test(SceneLev = 1) ->
	case db:get_config(test_flag) of
		1 ->
			Type1 = 1000040,
			Type2 = 1000041,
			#st_dungeons_config{dungenScene = SceneId} = data_dungeons_config:get_dungeons(SceneLev),
			#st_scene_config{points = PointList} = data_scene_config:get_scene(SceneId),
			{X, _, Z} = hd(PointList),
			Pos1 = {X + 6, 0, Z + 6},
			Pos2 = {X + 8, 0, Z + 8},
			Camp1 = ?CAMP_ROLE_DEFAULT,
			Camp2 = ?CAMP_MONSTER_DEFAULT,
			fun_interface:s_add_monster(no, Type1, Pos1, Camp1, 180, 0),
			fun_interface:s_add_monster(no, Type1, Pos1, Camp1, 180, 0),
			fun_interface:s_add_monster(no, Type1, Pos1, Camp1, 180, 0),

			fun_interface:s_add_monster(no, Type2, Pos2, Camp2, 180, 0),
			fun_interface:s_add_monster(no, Type2, Pos2, Camp2, 180, 0),
			fun_interface:s_add_monster(no, Type2, Pos2, Camp2, 180, 0);
		_ -> skip
	end;
on_tmp_test(_) ->
	ok.