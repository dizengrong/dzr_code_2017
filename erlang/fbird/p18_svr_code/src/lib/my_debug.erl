%% @author dzr
%% @doc 
-module(my_debug).
-include("common.hrl").
-include_lib("kernel/include/file.hrl").
-compile([export_all]).


get_uid_by_name(Name)->
	[#usr{id = Id}] =  db:dirty_get(usr, Name, #usr.name),
	Id.

%% 给玩家的agent进程发消息
to_agent(UsrId, Msg) ->
	AgentPid = get_player_agent_pid(UsrId),
	gen_server:cast(AgentPid, Msg).

to_scene(UsrId, Msg) ->
	ScenePid = get_player_scene_pid(UsrId),
	gen_server:cast(ScenePid, Msg).

%% 获取玩家的AgentPid
get_player_agent_pid(UsrId) ->
	[Rec] = db:dirty_get(ply, UsrId),
	Rec#ply.agent_hid.

get_player_scene_pid(UsrId) ->
	[Rec] = db:dirty_get(ply, UsrId),
	Rec#ply.scene_hid.


%% 获取进程字典
dict(PidTerm) -> 
	Pid = recon_lib:term_to_pid(PidTerm),
	erlang:process_info(Pid, dictionary). 


agent_dict(Uid) ->
	erlang:process_info(get_player_agent_pid(Uid), dictionary). 


%% 获取场景进程字典
scene_dict(Uid) ->
	ScenePid = get_player_scene_pid(Uid),
	erlang:process_info(ScenePid, dictionary). 


%% 获取场景里的怪物
scene_monster(Uid) ->
	scene:debug_call(Uid, fun() -> fun_scene_obj:get_ml() end).

scene_self(Uid) ->
	scene:debug_call(Uid, fun() -> fun_scene_obj:get_obj(Uid) end).


agent_call(Uid, Fun) ->
	agent:debug_call(Uid, Fun).

scene_call(Uid, Fun) ->
	scene:debug_call(Uid, Fun).

world_svr_call(PidName, Fun) -> 
	world_svr:debug_call(PidName, Fun).

common_svr_call(PidName, Fun) -> 
	common_server:debug_call(PidName, Fun).


test_scene() -> 
	Fun = fun() -> 
		[lib_map_module:check_point(tool_vect:to_map_point({40.4147, 20.04096, 108.6871})) || _ <- lists:seq(1, 10000)] 
	end,
	my_debug:scene_call(10000000001, fun() -> timer:tc(Fun) end).


%%下面是测试从进程字典获取时间和直接获取时间的性能差别，结果表明从进程字典获取快些
test_time() -> 
	Fun = fun() -> 
		[util_time:unixtime() || _ <- lists:seq(1, 10000)],
		ok
	end,
	timer:tc(Fun).

test_time2() -> 
	Fun = fun() -> 
		[util_misc:get_process_dict(long_now, 0) || _ <- lists:seq(1, 10000)],
		ok
	end,
	timer:tc(Fun).


check_hero_equips(Uid) ->
	List = fun_item_api:get_entourage_items(Uid),
	[check_hero_equips2(Uid, Rec) || Rec <- List],
	ok.


check_hero_equips2(Uid, #item{id = HeroId, equip_list = EquipList}) ->
	Fun = fun(EquipId) ->
		case fun_item_api:get_item_by_id2(Uid, EquipId) of
			[] ->
				?send(get(sid), "check_data_error"), 
				?ERROR("hero ~p has equip ~p, but not find equip in bag!", [HeroId, EquipId]);
			_  -> skip
		end
	end,
	[Fun(Id) || Id <- EquipList].
