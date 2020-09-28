-module (util_scene).
-include("common.hrl").
-export ([
	scene_type/1, scene_in_pos/1, stage_enter_data/1, get_stage_pos/2,
	scene_name/1, send_scene_time_len/2,get_guildworldboss_scene/0,
	send_pt_2_all_usr/1,send_pt_2_guild_usr/2,
	get_stage_move_pos/2, get_stage_monster_pos/2,
	get_stage_index/1,
	get_scene_sort/1,
	get_point/2,
	server_obj_type_2_client_type/1,
	send_defender_zhenfa/2
]).


scene_type(SceneId) ->
	#st_scene_config{sort = SceneType} = data_scene_config:get_scene(SceneId),
	SceneType.


scene_in_pos(Scene) ->
	#st_scene_config{points = PointList} = data_scene_config:get_scene(Scene),
	hd(PointList).

scene_name(Scene) ->
	util_lang:get_scene_name(Scene).


stage_enter_data(Stage) ->
	#st_dungeons_config{dungenScene = Scene} = data_dungeons_config:get_dungeons(Stage),
	{Scene, get_stage_pos(Scene, get_stage_index(Stage))}.

get_stage_index(Stage) ->
	(Stage - 1) * 3 + 1.

get_stage_pos(Scene, Index1) ->
	#st_scene_config{coordinate = List} = data_scene_config:get_scene(Scene),
	Index = case Index1 rem length(List) of
		0 -> length(List);
		_ -> Index1 rem length(List)
	end,
	{X, Z} = lists:nth(Index, List),
	{X, 0, Z}.

get_stage_move_pos(Scene, Index1) ->
	#st_scene_config{coordinate=List} = data_scene_config:get_scene(Scene),
	Index = case Index1 rem length(List) of
		0 -> length(List);
		_ -> Index1 rem length(List)
	end,
	{X, Z} = lists:nth(Index, List),
	{X, 0, Z}.

get_stage_monster_pos(Scene, Index1) ->
	#st_scene_config{mcoordinate=List} = data_scene_config:get_scene(Scene),
	Index = case Index1 rem length(List) of
		0 -> length(List);
		_ -> Index1 rem length(List)
	end,
	{X, Z} = lists:nth(Index, List),
	{X, 0, Z}.

get_guildworldboss_scene() ->
	data_guildworldboss:get_scene().


% get_damage_inc(Uid) ->
% 	case data_scene_config:get_scene(get(scene)) of
% 		#st_scene_config{sort = ?SCENE_SORT_GUILDDMGBOSS} ->
% 			fun_scene_guildworldboss:get_damage_inc(Uid);
% 		_ -> 1			
% 	end.	

send_scene_time_len(Sid, Len) ->
	Pt=#pt_copy_exist_time{time_len = Len},
	?send(Sid, proto:pack(Pt)).


%% 发送协议消息给场景内的所有玩家
send_pt_2_all_usr(Pt) -> 
	Fun = fun(Uid) -> 
		case fun_scene_obj:get_obj(Uid) of
			#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} ->
				?send(Sid, Pt);
			_ -> skip
		end 
	end,
	lists:foreach(Fun, fun_scene_obj:get_all_ids(?SPIRIT_SORT_USR)).

%% 发送协议消息给场景内的所有玩家
send_pt_2_guild_usr(GuildID,Pt) -> 
	Fun = fun(Uid) -> 
		case fun_scene_obj:get_obj(Uid) of
			#scene_spirit_ex{data = #scene_usr_ex{guild_id=Guild,sid = Sid}} ->
				 if
					 GuildID == Guild -> ?send(Sid, Pt);
					 true -> skip						 
				 end;				
			_ -> skip
		end 
	end,
	lists:foreach(Fun, fun_scene_obj:get_all_ids(?SPIRIT_SORT_USR)).

get_scene_sort(Scene) ->
	case data_scene_config:get_scene(Scene) of
		#st_scene_config{sort = Sort} -> Sort;
		_ -> ""
	end.

get_point({X1,_,Z1}, {X2,Y2,Z2}) ->
	LX = abs(X1 - X2),
	LZ = abs(Z1 - Z2),
	A = math:sqrt(math:pow(LX, 2) +  math:pow(LZ, 2)),
	Sin = LX / A,
	Cos = LZ / A,
	X3 = if
		X2 > X1 -> X2 + 3 * Sin;
		X2 < X1 -> X2 - 3 * Sin;
		true -> X2
	end,
	Z3 = if
		Z2 > Z1 -> Z2 + 3 * Cos;
		Z2 < Z1 -> Z2 - 3 * Cos;
		true -> Z2
	end,
	Sin1 = if
		X2 >= X1 -> Sin;
		true -> -Sin
	end,
	Cos1 = if
		Z2 >= Z1 -> Cos;
		true -> -Cos
	end,
	[{X2 + 1.5 * Cos1, Y2, Z2 + 1.5 * Sin1},{X2 - 1.5 * Cos1, Y2, Z2 - 1.5 * Sin1},{X3 + 3 * Cos1, Y2, Z3 + 3 * Sin1},{X3, Y2, Z3},{X3 - 3 * Cos1, Y2, Z3 - 3 * Sin1}].


%% 服务端的obj类型映射为客户端类型 
server_obj_type_2_client_type(?SPIRIT_SORT_USR) -> ?SPIRIT_CLIENT_TYPE_USR;
server_obj_type_2_client_type(?SPIRIT_SORT_MONSTER) -> ?SPIRIT_CLIENT_TYPE_MONSTER;
server_obj_type_2_client_type(?SPIRIT_SORT_ITEM) -> ?SPIRIT_CLIENT_TYPE_DROP_ITEM;
server_obj_type_2_client_type(?SPIRIT_SORT_NPC) -> ?SPIRIT_CLIENT_TYPE_NPC;
server_obj_type_2_client_type(?SPIRIT_SORT_ENTOURAGE) -> ?SPIRIT_CLIENT_TYPE_ENTOURAGE;
server_obj_type_2_client_type(?SPIRIT_SORT_MODEL) -> ?SPIRIT_CLIENT_TYPE_MODEL;
server_obj_type_2_client_type(?SPIRIT_SORT_ROBOT) -> ?SPIRIT_CLIENT_TYPE_USR.


send_defender_zhenfa(Uid, EntourageList) ->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} ->
			{RaceZhenfa, ProfZhenfa} = fun_entourage_zhenfa:get_entourage_zhenfa(EntourageList),
			Pt = #pt_defender_zhenfa{
				race_zhenfa = RaceZhenfa,
				prof_zhenfa = ProfZhenfa
			},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

