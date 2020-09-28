%% @doc 新的场景接口
-module (mod_scene_api).
-include("common.hrl").
-export ([req_enter_scene/2, req_enter_scene/3, req_enter_scene/4, handle_enter_scene/6]).
-export ([handle/1, process_scene_pt/5, process_agent_pt/4, handle_scene_msg/1]).
-export ([enter_worldboss/4, enter_pk_scene/3, enter_stage/3, enter_godchallenge/5,enter_godbless/5]).
-export ([enter_guildworldboss/3, enter_melee/3]).
-export ([enter_guild_boss/4,enter_ringsoul_graveyard/5,enter_demon_square/5]).
-export ([enter_tower/5, enter_activity_copy/5, enter_hero_expedition/5]).
-export ([send_scene_end/1]).

% -export ([req_enter_city/3]).


-define (TASK_ID_CHANGE_SCENE, 10).  %% 达到这个任务后每次登陆时都进入关卡


%% agent 消息
handle(enter_stage) -> 
	enter_stage(get(uid), get(sid), 0);
handle({enter_pk_scene,Uid,UsrInfoList,SceneData}) -> 
	mod_scene_api:enter_pk_scene(Uid,UsrInfoList,SceneData);
handle({req_enter_scene, UsrInfoList, Scene}) ->
	req_enter_scene(UsrInfoList, Scene);
handle({req_enter_scene, UsrInfoList, Scene, NameArg}) ->
	req_enter_scene(UsrInfoList, Scene, NameArg).


process_scene_pt(pt_scene_fly_by_fly_point_c004,Seq,Pt,Sid,Uid) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos = {AtX, _, AtZ}, data=#scene_usr_ex{lev=Lev,hid=AgentHid}} -> 
			FlyPointID = Pt#pt_scene_fly_by_fly_point.fly_point_id,
			case data_fly_point_config:get_fly_point(FlyPointID) of
				#st_fly_point_config{scene = FromeScene, x=X, z=Z, sort = targetscene,targetScene= ToScene, target_pos={ToX,ToY,ToZ},needLv=NeedLv} ->
					CurrentScene = get(scene),
					if 
						abs(AtX - X) > 3 orelse abs(AtZ - Z) > 3 -> 
							?DEBUG("usr ~p position not near fly point:~p", [Uid, FlyPointID]);
						FromeScene /= CurrentScene -> 
							?ERROR("usr want enter a map with a wrong scene fly point:~p", [FlyPointID]);
						Lev >= NeedLv ->
							Msg = {req_enter_scene, [{Uid,Seq,{ToX,ToY,ToZ},#ply_scene_data{sid = Sid}}], ToScene},
							fun_scene:on_save_pos(Uid),
							util_misc:msg_handle_cast(AgentHid, ?MODULE, Msg);
					   true->
					   		?DEBUG("lv or stone gs not matched")
					end;
				#st_fly_point_config{sort = currscene,target_pos={ToX,ToY,ToZ},needLv=NeedLv} ->
					if 
						Lev >= NeedLv ->
							%%瞬移时间为0
							NSort=fun_scene_obj:get_spirit_client_type(Uid),
							TransPt=#pt_scene_transform{
													  oid = Uid,
													  obj_sort = NSort,
													  type = 0,
													  time = 0,
													  x = ToX,
													  y = ToY,
													  z = ToZ
													 },
							Data=proto:pack(TransPt),
							fun_scene_obj:send_all_usr(Data);								
						true -> skip	
					end;
				_ ->skip	
			end;
		_ -> skip
	end;

%%位面请求
process_scene_pt(pt_req_fly_planes_d320,Seq,Pt,_Sid,Uid) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			Scene = get(scene),
			PlanesID=Pt#pt_req_fly_planes.id,
			case data_dungeons_config:get_dungeons(PlanesID) of
				#st_dungeons_config{dungenScene = FromScene} when Scene == FromScene ->
					{Scene, Pos} = util_scene:stage_enter_data(PlanesID),
					Tag = ?_IF(Scene == FromScene, PlanesID, 0),
					Msg = {req_enter_scene, [{Uid,Seq,Pos,{planes_id,Tag}}], Scene, {main_scene, Uid, PlanesID}},
					util_misc:msg_handle_cast(AgentHid, ?MODULE, Msg);
				_ -> 
					?ERROR("usr ~p request fly PlanesID:~p, but not find", [Uid, PlanesID])
			end;
		_ -> skip
	end.

process_agent_pt(pt_load_scene_finish_b005,Seq,_Pt,Sid) ->
	case get(fly_scene_id) of
		?UNDEFINED -> error;
		Line -> 
			case get(fly_scene_type) of
				?UNDEFINED -> error;
				SceneType->
					erlang:erase(fly_scene_id),
					erlang:erase(fly_scene_type),
					ScenePid = erlang:erase(fly_scene_pid),
					handle_enter_scene(get(uid), Sid, Seq, SceneType, Line, ScenePid)
			end
	end;
process_agent_pt(pt_usr_enter_scene_b003,Seq,_Pt,Sid) -> 
	%% 登陆时进入场景的处理
	Uid = get(uid),
	login_enter_scene(Uid, Sid, Seq).


handle_scene_msg({req_enter_copy_scene,Uid,Seq,SceneID}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		#scene_spirit_ex{data = #scene_usr_ex{hid = AgentPid,sid=Sid}} ->		
			case data_scene_config:get_scene(SceneID) of
				#st_scene_config{sort = ?SCENE_SORT_COPY,points = PointList} -> 
					fun_scene:on_save_pos(Uid),%%准备进入副本就保存当前位
					Msg = {req_enter_scene, [{Uid,Seq,hd(PointList),#ply_scene_data{sid = Sid}}], SceneID, {user_copy, Uid, SceneID}},
					util_misc:msg_handle_cast(AgentPid, ?MODULE, Msg);
				_ -> skip					
			end;
		_ -> skip
	end.


login_enter_scene(Uid, Sid, Seq) ->
	case can_reenter_last_scene(Uid) of
		{true, Scene, LastPos} -> 
			req_enter_scene([{Uid,Seq,LastPos,#ply_scene_data{sid = Sid}}], Scene);
		_ -> 
			enter_stage(Uid, Sid, Seq)
	end.


%% 断线重连到上次进入场景的位置在这里，根据场景类型来添加
can_reenter_last_scene(Uid) ->
	case db:dirty_get(usr, Uid) of
		[#usr{last_logout_time = LastLogoutTime, save_pos = {MapName, LastScene, LastPos}}] -> 
			case util_scene:scene_type(LastScene) of
				?SCENE_SORT_MELLEBOSS -> 
					case agent:agent_now() > LastLogoutTime + 30 of
						true -> false;
						_ -> 
							case whereis(MapName) of
								undefined -> false;
								_ -> {true, LastScene, LastPos}
							end
					end;
				_ -> false
			end;
		_ -> false
	end.

enter_stage(Uid, _Sid, Seq) -> 
	ToSceneLev = mod_scene_lev:get_curr_scene_lv(Uid),
	enter_stage(Uid, _Sid, Seq, ToSceneLev).
enter_stage(Uid, Sid, Seq, ToSceneLev) ->
	SceneLev = mod_scene_lev:get_curr_scene_lv(Uid),
	SceneLev2 = if
		ToSceneLev == 0 -> SceneLev;
		ToSceneLev > SceneLev -> SceneLev;
		true -> ToSceneLev
	end,
	{Scene, Pos} = util_scene:stage_enter_data(SceneLev2),
	req_enter_scene([{Uid,Seq,Pos,#ply_scene_data{sid=Sid}}], Scene, {main_scene, Uid, SceneLev2}, {SceneLev2, undefined}).

enter_worldboss(Uid, Sid, Seq, Scene) ->
	SceneKey = {worldboss, Uid},
	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(Scene),#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey).

enter_pk_scene(Uid, UsrInfoList, SceneData) ->
	SceneKey = {scene_key, Uid},
	req_enter_scene(UsrInfoList, ?PK_SCENE_ID, SceneKey, SceneData).

% req_enter_city(Uid, _Sid, Seq) ->
% 	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(?MY_CITY),#ply_scene_data{sid = Sid}}],
% 	req_enter_scene(UsrInfoList, ?MY_CITY).

enter_godchallenge(Uid, Sid, Seq, Scene, SceneData) ->
	SceneKey = {scene_key, Uid},
	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(Scene),#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey, SceneData).

enter_godbless(Uid, Sid, Seq, Scene, SceneData) ->
	SceneKey = {scene_key, Uid},
	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(Scene),#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey, SceneData).

enter_ringsoul_graveyard(Uid, Sid, Seq, Scene, SceneData) ->
	SceneKey = {scene_key, Uid},
	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(Scene),#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey, SceneData).

enter_demon_square(Uid, Sid, Seq, Scene, SceneData) ->
	SceneKey = {scene_key, Uid},
	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(Scene),#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey, SceneData).

enter_guildworldboss(Uid, Sid, Seq) ->
	Scene=util_scene:get_guildworldboss_scene(),
	Pos=util_scene:scene_in_pos(Scene),
	UsrInfoList = [{Uid,Seq,Pos,#ply_scene_data{sid = Sid}}],	
	req_enter_scene(UsrInfoList, Scene).

enter_guild_boss(Uid, Sid, Seq, {Scene, BossID, MonsterType, CurrHp, BossPos}) ->
	Pos=util_scene:scene_in_pos(Scene),
	UsrInfoList = [{Uid,Seq,Pos,#ply_scene_data{sid = Sid}}],	
	req_enter_scene(UsrInfoList, Scene, undefined, {BossID, MonsterType, CurrHp, BossPos}).

enter_melee(Uid, Sid, Seq) -> 
	Scene       = data_melee:get_scene(),
	Pos         = data_melee:get_angel_enter_pos(),
	UsrInfoList = [{Uid,Seq,Pos,#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene).

enter_tower(Uid, Sid, Seq, Scene, Tower) ->
	SceneKey    = {scene_key, Uid},
	Pos         = util_scene:scene_in_pos(Scene),
	UsrInfoList = [{Uid,Seq,Pos,#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey, {tower, Tower}).


enter_activity_copy(Uid, Sid, Seq, CopyId, Scene) ->
	SceneKey = {scene_key, Uid},
	UsrInfoList = [{Uid,Seq,util_scene:scene_in_pos(Scene),#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey, CopyId).

enter_hero_expedition(Uid, Sid, Seq, Scene, InScenePos) ->
	SceneKey = {scene_key, Uid},
	UsrInfoList = [{Uid,Seq,InScenePos,#ply_scene_data{sid = Sid}}],
	req_enter_scene(UsrInfoList, Scene, SceneKey).


%% 这个接口不能在场景进程中调用
%% UsrInfoList: [{Uid,Seq,Pos,#ply_scene_data{}}]
req_enter_scene(UsrInfoList, Scene) -> 
	req_enter_scene(UsrInfoList, Scene, undefined).
req_enter_scene(UsrInfoList, Scene, SceneKey) -> 
	req_enter_scene(UsrInfoList, Scene, SceneKey, undefined).
%% SceneData: 传给场景的数据，场景创建时需要的数据可以通过这里传
req_enter_scene(UsrInfoList, Scene, SceneKey, SceneData) ->
	case mod_scene_manager:enter_get_line(Scene, SceneKey) of
		no_line -> 
			req_enter_scene2(UsrInfoList, Scene, SceneKey, SceneData);
		{ok, Line, Pid} -> 
			req_enter_scene_help(Pid, Scene, Line, UsrInfoList)
	end,
	ok.


req_enter_scene2(UsrInfoList, Scene, SceneKey, SceneData) ->
	case mod_scene_manager:sync_create_scene(Scene, SceneKey, UsrInfoList, SceneData) of
		{ok, Pid, Line2} -> 
			req_enter_scene_help(Pid, Scene, Line2, UsrInfoList);
		{error, Reason} ->
			?ERROR("create scene failed when enter scene:~w", [Reason])
	end.


req_enter_scene_help(ScenePid, Scene, Line, UsrInfoList) ->
	case get(agent_now) of
		Now when is_integer(Now)  -> %% 验证是玩家进程里调用进入场景接口的
			case get(last_enter_scene_time) of
				undefined -> 
					put(last_enter_scene_time, Now),
					req_enter_scene_help2(ScenePid, Scene, Line, UsrInfoList);
				LastTime when Now - LastTime >= 3 -> %% 这里时间验证，防止前端同时发多次进入场景的请求
					put(last_enter_scene_time, Now),
					req_enter_scene_help2(ScenePid, Scene, Line, UsrInfoList);
				_ -> 
					?WARNING("client request one more times to enter scene")
			end;
		_ -> 
			?ERROR("server request enter scene but not in agent process")
	end.

req_enter_scene_help2(ScenePid, Scene, Line, UsrInfoList) ->
	Fun = fun({Uid,Seq,Pos,PlyData}) ->
		case db:dirty_get(ply, Uid) of
			[Ply = #ply{sid = Sid,scene_hid = SceneHid}] when SceneHid == ScenePid ->
				case util_scene:get_scene_sort(Scene) of
					?SCENE_SORT_MAIN ->
						case is_pid(SceneHid) of
							true -> 
								gen_server:cast(SceneHid, {agent_out, scene_out, Uid});
							_ -> 
								put(no_last_scene,true)
						end,
						db:dirty_put(Ply#ply{scene_hid=0,scene_idx = 0,scene_id=0}),
						notify_client_start_fly(Sid,Uid,Seq,Line,{Scene,Pos},PlyData,ScenePid);
					_ ->
						ok %% 存在的这样情况，不做任何处理
				end;
			[Ply = #ply{sid = Sid,scene_hid = SceneHid}] ->
				case is_pid(SceneHid) of
					true -> 
						gen_server:cast(SceneHid, {agent_out, scene_out, Uid});
					_ -> 
						put(no_last_scene,true)
				end,
				db:dirty_put(Ply#ply{scene_hid=0,scene_idx = 0,scene_id=0}),
				notify_client_start_fly(Sid,Uid,Seq,Line,{Scene,Pos},PlyData,ScenePid);
			_ ->
				?ERROR("player enter scene but no ply record")
		end
	end,
	_ = [Fun(D) || D <- UsrInfoList].


notify_client_start_fly(Sid,_Uid,Seq,SceneLineId,{Scene,Pos},PlyData,ScenePid) ->
	{X,Y,Z} = Pos,
	put(fly_scene_id,SceneLineId),
	put(fly_scene_pos,Pos),
	put(fly_scene_type,Scene),
	put(fly_scene_pid,ScenePid),
	Planes_ID = case PlyData of  
		{planes_id,PlanesID}->PlanesID;
		_ -> 0
	end,
	Pt = #pt_req_load_scene{
		scene     = Scene,
		x         = X,
		y         = Y,
		z         = Z,
		% dir       = Dir,
		is_planes = Planes_ID
	},
	?send(Sid,proto:pack(Pt, Seq)),
	ok.


handle_enter_scene(Uid, Sid, Seq, Scene, Line, ScenePid) ->
	[Usr] = db:dirty_get(usr,Uid),
	UsrSkillList       = fun_agent:get_usr_skills(Uid),
	BackpackIsFull     = false,
	Fighting           = 100,
	LoginDataSet = #login_data_set{
		isfull               = BackpackIsFull,
		fighting             = Fighting,
		scene_type           = Scene,
		pet_list             = [],
		skill_list           = UsrSkillList
	},
	put(backpack_state,BackpackIsFull),
	Login=case  get(no_last_scene) of  
			  true-> erase(no_last_scene),true;
			  _->false
	      end,
	BattleProp = #battle_property{hpLimit = 100},
	Hp_limit = BattleProp#battle_property.hpLimit,
	EnterSceneData = #enter_scene_data{
		usr          = Usr,
		a_hid        = self(),
		pos          = get(fly_scene_pos),
		pro          = BattleProp,
		% last_buffs   = Buffs,
		login        = Login,
		curr_members = erase(curr_members)
	},
	gen_server:cast(agent_mng,{usr_in_scene,Uid,Line,Scene,ScenePid,1,Fighting,Hp_limit}),
	gen_server:cast(ScenePid, {usr_enter_scene, Uid,Sid,Seq,LoginDataSet,EnterSceneData}).

send_scene_end(Uid) ->
	case get(scene_end) of
		undefined -> skip;
		Val ->
			case fun_scene_obj:get_obj(Uid) of
				#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} -> 
					Pt = #pt_scene_end{
						time = Val - util_time:unixtime()
					},
					?send(Sid,proto:pack(Pt));
				_ -> skip
			end
	end.