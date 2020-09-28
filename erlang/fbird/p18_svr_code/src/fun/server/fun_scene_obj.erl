-module(fun_scene_obj).
-include("common.hrl").

-export([init/0]).
-export([add_scene_item/2,add_monster/2,add_usr/2,add_robot/2,add_entourage/2,add_model/2,remove_obj/1,get_spirit_client_type/1,get_spirit_hp/1,get_spirit_mp/1]).
-export([get_obj/1,get_obj/2,update/1,get_all/0,get_il/0,get_rl/0,get_ml/0,get_ul/0,get_el/0,get_all_ids/0,get_all_ids/1,get_modell/0,
		 agent_msg_by_uid/2,scenemng_msg/1]).
-export([get_item_spc_data/2,put_item_spc_data/3]).
-export([get_robot_spc_data/2,put_robot_spc_data/3]).
-export([get_monster_spc_data/2,put_monster_spc_data/3]).
-export([get_usr_spc_data/2,put_usr_spc_data/3]).
-export([get_entourage_spc_data/2,put_entourage_spc_data/3]).
-export([send_all_usr/1,send_all_usr/2,send_cell_all_usr/2,send_cell_all_usr/3]).
-export([get_obj_id/0,update_obj_id/1]).
-export([get_pace_speed/1,get_move_speed/1,get_monster_die/1,get_monster_die/2]).
-export([check_kick/3,on_pet_leave/2,on_pet_enter/2]).
-export([is_obj_bt/1,is_obj_yz/1,is_obj_wd/1,is_obj_jz/1]).
-export([send_all_agent/1,agent_msg/2,make_see_obj/1,make_see_objs/7]).
-export([send_continue_move/2,make_continue_move/1,agentmng_msg/2,agentmngs_msg/1,put_camp/2]).


init()->
	put(scene_oids,[]),
	ok.

get_obj_id() ->
	case get(sys_object) of
		undefined -> 0;
		Key -> put(sys_object,Key + 1),Key
	end.
update_obj_id(Id)->
	case get(sys_object) of
		undefined -> ok;
		Key -> 
			if
				Id >= Key ->put(sys_object,Id + 1);
				true -> ok
			end
	end.

add_scene_item(SpiritData,SceneItemData) when erlang:is_record(SpiritData, scene_spirit_ex) andalso erlang:is_record(SceneItemData, scene_item_ex)-> 
	Spirit = SpiritData#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = SceneItemData},
	add_obj(Spirit).
add_monster(SpiritData,MonsterData) when erlang:is_record(SpiritData, scene_spirit_ex) andalso erlang:is_record(MonsterData, scene_monster_ex)-> 
	Spirit = SpiritData#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = MonsterData},
	add_obj(Spirit). 
add_usr(SpiritData,UsrData) when erlang:is_record(SpiritData, scene_spirit_ex) andalso erlang:is_record(UsrData, scene_usr_ex)->
	Spirit = SpiritData#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = UsrData},
	add_obj(Spirit).
add_robot(SpiritData,RobotData) when erlang:is_record(SpiritData, scene_spirit_ex) andalso erlang:is_record(RobotData, scene_robot_ex)-> 
	Spirit = SpiritData#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = RobotData},
	add_obj(Spirit).
add_entourage(SpiritData,EntourageData) when erlang:is_record(SpiritData, scene_spirit_ex) andalso erlang:is_record(EntourageData, scene_entourage_ex)-> 
	Spirit = SpiritData#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = EntourageData},
	add_obj(Spirit).
add_model(SpiritData,ModelData) when erlang:is_record(SpiritData, scene_spirit_ex) andalso erlang:is_record(ModelData, scene_model_ex)-> 
	Spirit = SpiritData#scene_spirit_ex{sort = ?SPIRIT_SORT_MODEL,data = ModelData},
	add_obj(Spirit).


add_obj_ids(ID) -> 
	Oids1 = get(scene_oids),
	case lists:member(ID, Oids1) of
		false ->
			put(scene_oids, [ID|Oids1]);
		_ ->
			ok
	end,
	ok.

remove_obj_ids(ID) ->  
	Oids1 = get(scene_oids),
	put(scene_oids, replace_list_operate(Oids1, [ID])).


add_obj(Spirit = #scene_spirit_ex{id = ID}) ->
	remove_obj(ID),

	Spirit1 = on_enter(Spirit),
	put({scene_obj,ID},Spirit1),
	add_obj_ids(ID),

	Spirit1.

remove_obj(ID)->
	case get({scene_obj,ID}) of
		Obj = #scene_spirit_ex{sort = Sort, pos = Pos} ->
			fun_scene_map:leave_cell(ID, Obj#scene_spirit_ex.map_cell),
			on_leave(Obj),
			erlang:erase({scene_obj,ID}),
			remove_obj_ids(ID),
			case Sort of
				?SPIRIT_SORT_MONSTER -> 
					{X, _, Z} = Pos,
					mod_scene_monster:remove_in_pos_monster(trunc(X) , trunc(Z) , ID);
				_ -> skip
			end,
			ok;
		_ -> 
			% ?log_warning("remove_obj not find ID = ~p",[ID]),
			no			
	end.

replace_list_operate(L1,L2) ->
	%%L1 -- L2.
	Set = gb_sets:from_list(L2),   
	[E || E <- L1, not gb_sets:is_element(E, Set)].

send_continue_move(#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}},SeeObjs) ->
	Fun = fun(SeeObj) -> 
				  case make_continue_move(SeeObj) of
					  no -> skip;
					  Pt -> ?send(Sid,Pt)
				  end
		  end,
	[Fun(SeeObj)|| SeeObj <-SeeObjs].

make_continue_move(Obj) ->
	case Obj#scene_spirit_ex.move_data of
		#move_data{to_pos = Pos2,next = Next} ->
			TargetSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
			Path= [Obj#scene_spirit_ex.pos,Pos2] ++ Next,
			FunPath = fun({PX,PY,PZ}) ->
				#pt_public_point3{
					x = PX,
					y = PY,
					z = PZ
				}
			end,
			NPath = lists:map(FunPath, Path),
			Pt = #pt_scene_move{
				oid        = Obj#scene_spirit_ex.id,
				obj_sort   = TargetSort,
				dir        = Obj#scene_spirit_ex.dir,
				point_list = NPath
			},
			proto:pack(Pt);
		_ -> no
	end.

make_see_obj(Object = #scene_spirit_ex{id = _Uid,pos={X,Y,Z},sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{equip_list=_Equip_list,pet_list=_Pets}}) ->
	ObjBattle = Object#scene_spirit_ex.final_property,
	Ptu = #pt_public_scene_ply{pid = Object#scene_spirit_ex.id,
								   name = util:to_list(Object#scene_spirit_ex.name),
								   prof = Object#scene_spirit_ex.data#scene_usr_ex.prof,
								   level = Object#scene_spirit_ex.data#scene_usr_ex.lev,
								   dir = Object#scene_spirit_ex.dir,
								   x = X,
								   y = Y,
								   z = Z,
								   camp = Object#scene_spirit_ex.camp,
								   hp = Object#scene_spirit_ex.hp,
								   max_hp = ObjBattle#battle_property.hpLimit,
								   mp = Object#scene_spirit_ex.mp,
								   max_mp = ObjBattle#battle_property.mpLimit,
								   team_id = Object#scene_spirit_ex.data#scene_usr_ex.team_id,
								   team_leader = Object#scene_spirit_ex.data#scene_usr_ex.team_leader,
								   fighting = Object#scene_spirit_ex.data#scene_usr_ex.fighting,
								   military = Object#scene_spirit_ex.data#scene_usr_ex.military_lev,
								   guildName = Object#scene_spirit_ex.data#scene_usr_ex.guild_name,
								   vip_lev = Object#scene_spirit_ex.data#scene_usr_ex.vip,
								   model_clothes=Object#scene_spirit_ex.data#scene_usr_ex.model_clothes,
								   paragon_level=Object#scene_spirit_ex.data#scene_usr_ex.paragon_level,
								   camp_leader = Object#scene_spirit_ex.data#scene_usr_ex.camp_leader,
								   title=Object#scene_spirit_ex.data#scene_usr_ex.title_id,
								   relife = Object#scene_spirit_ex.data#scene_usr_ex.relife
								  },
	Pt = #pt_scene_add{ply_list = [Ptu]},
	proto:pack(Pt);
make_see_obj(Object = #scene_spirit_ex{pos={X,Y,Z},sort = ?SPIRIT_SORT_ROBOT,final_property=Battle,data = #scene_robot_ex{shenqi_skill={ShenqiId, ShenqiStar, ShenqiLev}}}) ->
	% ?debug("ShenqiId = ~p",[ShenqiId]),
	Ptu = #pt_public_scene_ply{
		pid = Object#scene_spirit_ex.id,
		name = util:to_list(Object#scene_spirit_ex.name),
		prof = Object#scene_spirit_ex.data#scene_robot_ex.prof,
		level = Object#scene_spirit_ex.data#scene_robot_ex.lev,
		paragon_level = Object#scene_spirit_ex.data#scene_robot_ex.paragon_level,
		dir = Object#scene_spirit_ex.dir,
		shenqi_id = ShenqiId,
		shenqi_star = ShenqiStar,
		shenqi_lev = ShenqiLev,
		x = X,
		y = Y,
		z = Z,
		camp = Object#scene_spirit_ex.camp,
		hp = Object#scene_spirit_ex.hp,
		max_hp = Battle#battle_property.hpLimit,
		mp = Object#scene_spirit_ex.mp,
		max_mp = Battle#battle_property.mpLimit,
		team_id = 0,
		team_leader = 0,
		fighting = Object#scene_spirit_ex.data#scene_robot_ex.fighting,
		ride_state = 0,
		ride_type = 0,
		currskin = 0,
		military = Object#scene_spirit_ex.data#scene_robot_ex.military_lev,
		guildName = Object#scene_spirit_ex.data#scene_robot_ex.guild_name
	},
	Pt = #pt_scene_add{ply_list = [Ptu], usr_equip_list = [], pets = []},
	proto:pack(Pt);
%% 	?debug("SPIRIT_SORT_USR on_enter send data = ~p,uid = ~p",[Data,Object#scene_spirit_ex.id]),

make_see_obj(#scene_spirit_ex{id=_ID,sort = ?SPIRIT_SORT_ITEM,data=#scene_item_ex{send_client=false}}) -> skip;
make_see_obj(Object = #scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM}) ->
	{X,Y,Z} = Object#scene_spirit_ex.pos,
	Ptm = #pt_public_scene_item{iid = Object#scene_spirit_ex.id,
								   type = Object#scene_spirit_ex.id-?OBJ_OFF,
								   dir = Object#scene_spirit_ex.dir,
								   x = X,
								   y = Y,
								   z = Z,
								   camp = Object#scene_spirit_ex.camp
								  },
	Pt = #pt_scene_add{item_list = [Ptm]},	
	proto:pack(Pt);
make_see_obj(#scene_spirit_ex{id=_ID,sort = ?SPIRIT_SORT_MONSTER,data=#scene_monster_ex{send_client=false}}) -> skip;
make_see_obj(Object = #scene_spirit_ex{name=Name,sort = ?SPIRIT_SORT_MONSTER,final_property=Battle,data=MonsterData}) ->
	{X,Y,Z} = Object#scene_spirit_ex.pos,
	Ptm = #pt_public_scene_monster{mid = Object#scene_spirit_ex.id,
									  type = MonsterData#scene_monster_ex.type,
									  dir = Object#scene_spirit_ex.dir,
									  x = X,
									  y = Y,
									  z = Z,
									  camp = Object#scene_spirit_ex.camp,
									  hp = Object#scene_spirit_ex.hp,
									  max_hp = Battle#battle_property.hpLimit,
									  mp = Object#scene_spirit_ex.mp,
									  max_mp = Battle#battle_property.mpLimit,
									  ownerID = check_sort(MonsterData#scene_monster_ex.type, MonsterData#scene_monster_ex.first_killer),
									  name=Name,
									  master=MonsterData#scene_monster_ex.master,
									  scale=MonsterData#scene_monster_ex.scale
									 },
	Pt = #pt_scene_add{monster_list = [Ptm]},
	proto:pack(Pt);
make_see_obj(Object = #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,final_property=Battle,data=EntourageData}) ->
	{X,Y,Z} = Object#scene_spirit_ex.pos,
	OwnerName = case fun_scene_obj:get_obj(EntourageData#scene_entourage_ex.owner_id) of
		#scene_spirit_ex{name = UsrName} -> util:to_list(UsrName);
		_ -> ""
	end,
	% ?debug("Dir = ~p",[Object#scene_spirit_ex.dir]),
	Ptm = #pt_public_scene_entourage{
		eid = Object#scene_spirit_ex.id,
		type = EntourageData#scene_entourage_ex.type,
		level = EntourageData#scene_entourage_ex.lev,
		star = EntourageData#scene_entourage_ex.star,
		dir = Object#scene_spirit_ex.dir,
		x = X,
		y = Y,
		z = Z,
		camp = Object#scene_spirit_ex.camp,
		hp = Object#scene_spirit_ex.hp,
		max_hp = Battle#battle_property.hpLimit,
		mp = Object#scene_spirit_ex.mp,
		max_mp = Battle#battle_property.mpLimit,
		owner = EntourageData#scene_entourage_ex.owner_id,
		owner_name = OwnerName
	},
	Pt = #pt_scene_add{entourage_list = [Ptm]},
	% ?debug("Pt = ~p",[Pt16]),
	proto:pack(Pt);
make_see_obj(Object = #scene_spirit_ex{id=ID,pos={X,Y,Z},dir=Dir,camp=Camp,sort=?SPIRIT_SORT_MODEL,data=#scene_model_ex{model_sort=ModelSort,model_clothes=ModelClothes,equip_list=Equips,prof=Prof}}) ->
	FunModelEquip = fun(Type,Ret) ->
						Ptme=#pt_public_id_list{id = Type},
						Ret ++ [Ptme]
					end,
	ModelEquipData=lists:foldl(FunModelEquip, [], Equips),
	IsCampModel=if
					ModelSort == 1 -> 1;
					true -> 0
				end,
	Ptmod=#pt_public_camp_model_list{pid = ID,
										   name = util:to_list(Object#scene_spirit_ex.name),
										   prof = Prof,
										   dir = Dir,
										   x = X,
										   y = Y,
										   z = Z,
										   camp = Camp,
										   equips = ModelEquipData,
										   model_clothes=ModelClothes,
										   is_camp_model=IsCampModel
										  },
	Pt = #pt_scene_add{models = [Ptmod]},
	proto:pack(Pt);
make_see_obj(_) -> skip.

check_sort(_Type,_Owner)-> 0.

make_see_objs(Obj,UL,RL,ML,IL,EL,ModL) ->
	Uid=Obj#scene_spirit_ex.id,	
	FunUsr = fun(Usr=#scene_spirit_ex{final_property=Battle,die=Die}) ->
		{UX,UY,UZ} = Usr#scene_spirit_ex.pos,
		DieSort = if 
			Die == true -> 1;
			true -> 0
		end,
		#pt_public_scene_ply{
			pid = Usr#scene_spirit_ex.id,
			name = util:to_list(Usr#scene_spirit_ex.name),
			prof = Usr#scene_spirit_ex.data#scene_usr_ex.prof,
			level = Usr#scene_spirit_ex.data#scene_usr_ex.lev,
			dir = Usr#scene_spirit_ex.dir,
			x = UX,
			y = UY,
			z = UZ,
			camp = Usr#scene_spirit_ex.camp,
			hp = Usr#scene_spirit_ex.hp,
			max_hp = Battle#battle_property.hpLimit,
			mp = Usr#scene_spirit_ex.mp,
			max_mp = Battle#battle_property.mpLimit,
			team_id = Usr#scene_spirit_ex.data#scene_usr_ex.team_id,
			team_leader = Usr#scene_spirit_ex.data#scene_usr_ex.team_leader,
			is_die = DieSort,
			fighting = Usr#scene_spirit_ex.data#scene_usr_ex.fighting,
			ride_state = Usr#scene_spirit_ex.data#scene_usr_ex.ride#usr_rides.ride_state,
			ride_type = Usr#scene_spirit_ex.data#scene_usr_ex.ride#usr_rides.type,
			currskin = Usr#scene_spirit_ex.data#scene_usr_ex.ride#usr_rides.currskin,
			military = Usr#scene_spirit_ex.data#scene_usr_ex.military_lev,
			guildName = Usr#scene_spirit_ex.data#scene_usr_ex.guild_name,
			vip_lev = Usr#scene_spirit_ex.data#scene_usr_ex.vip,
			model_clothes=Usr#scene_spirit_ex.data#scene_usr_ex.model_clothes,
			paragon_level=Usr#scene_spirit_ex.data#scene_usr_ex.paragon_level,
			camp_leader =Usr#scene_spirit_ex.data#scene_usr_ex.camp_leader,
			title=Usr#scene_spirit_ex.data#scene_usr_ex.title_id,
			relife = Usr#scene_spirit_ex.data#scene_usr_ex.relife
		}
	end,
	UL1 = lists:map(FunUsr, UL),
	FunRobot = fun(Robot=#scene_spirit_ex{final_property=Battle,die=Die}) ->
		{UX,UY,UZ} = Robot#scene_spirit_ex.pos,
		DieSort = if 
			Die == true -> 1;
			true -> 0
		end,
		#pt_public_scene_ply{
			pid = Robot#scene_spirit_ex.id,
			name = util:to_list(Robot#scene_spirit_ex.name),
			prof = Robot#scene_spirit_ex.data#scene_robot_ex.prof,
			level = Robot#scene_spirit_ex.data#scene_robot_ex.lev,
			paragon_level = Robot#scene_spirit_ex.data#scene_robot_ex.paragon_level,
			dir = Robot#scene_spirit_ex.dir,
			x = UX,
			y = UY,
			z = UZ,
			camp = Robot#scene_spirit_ex.camp,
			hp = Robot#scene_spirit_ex.hp,
			max_hp = Battle#battle_property.hpLimit,
			mp = Robot#scene_spirit_ex.mp,
			max_mp = Battle#battle_property.mpLimit,
			is_die = DieSort,
			fighting = Robot#scene_spirit_ex.data#scene_robot_ex.fighting,
			military = Robot#scene_spirit_ex.data#scene_robot_ex.military_lev,
			guildName = Robot#scene_spirit_ex.data#scene_robot_ex.guild_name
		}
	end,
	UL2 = lists:map(FunRobot, RL),
	Pt1 = #pt_scene_add{ply_list = UL1 ++ UL2}, 			
	FunItem= fun(Item) ->
		{X,Y,Z} = Item#scene_spirit_ex.pos,
		#pt_public_scene_item{
			iid = Item#scene_spirit_ex.id,
			type = Item#scene_spirit_ex.id-?OBJ_OFF,
			dir = Item#scene_spirit_ex.dir,
			x = X,
			y = Y,
			z = Z,
			camp = Item#scene_spirit_ex.camp
		}
	end,
	FunFilter=fun(#scene_spirit_ex{data=#scene_item_ex{send_client=SendClient}}) -> SendClient end,
	NIL=lists:filter(FunFilter, IL),
	IL1 = lists:map(FunItem, NIL),
	Pt2 = Pt1#pt_scene_add{item_list = IL1},
	FunMonster= fun(Monster=#scene_spirit_ex{name=Name,final_property=Battle,data=MonsterData}) ->
		{X,Y,Z} = Monster#scene_spirit_ex.pos,
		#pt_public_scene_monster{
			mid = Monster#scene_spirit_ex.id,
			type = MonsterData#scene_monster_ex.type,
			dir = Monster#scene_spirit_ex.dir,
			x = X,
			y = Y,
			z = Z,
			camp = Monster#scene_spirit_ex.camp,
			hp = Monster#scene_spirit_ex.hp,
			max_hp = Battle#battle_property.hpLimit,
			mp = Monster#scene_spirit_ex.mp,
			max_mp = Battle#battle_property.mpLimit,
			ownerID = check_sort(MonsterData#scene_monster_ex.type, MonsterData#scene_monster_ex.first_killer),
			master = MonsterData#scene_monster_ex.master,
			name=Name,
			scale=MonsterData#scene_monster_ex.scale
		}
	end,
	FunFilterMon=fun(#scene_spirit_ex{data=#scene_monster_ex{send_client=SendClient}}) -> SendClient end,
	NML=lists:filter(FunFilterMon, ML),
	ML1 = lists:map(FunMonster, NML),
	Pt3 = Pt2#pt_scene_add{monster_list = ML1},
	FunEntourage= fun(Entourage=#scene_spirit_ex{final_property=Battle,data=EntourageData}) ->
		{X,Y,Z} = Entourage#scene_spirit_ex.pos,
		OwnerName = case fun_scene_obj:get_obj(EntourageData#scene_entourage_ex.owner_id) of
			#scene_spirit_ex{name = UsrName} -> UsrName;
			_ -> ""
		end,
		#pt_public_scene_entourage{
			eid = Entourage#scene_spirit_ex.id,
			type = EntourageData#scene_entourage_ex.type,
			level = EntourageData#scene_entourage_ex.lev,
			star = EntourageData#scene_entourage_ex.star,
			dir = Entourage#scene_spirit_ex.dir,
			x = X,
			y = Y,
			z = Z,
			camp = Entourage#scene_spirit_ex.camp,
			hp = Entourage#scene_spirit_ex.hp,
			max_hp = Battle#battle_property.hpLimit,
			mp = Entourage#scene_spirit_ex.mp,
			max_mp = Battle#battle_property.mpLimit,
			owner = EntourageData#scene_entourage_ex.owner_id,
			owner_name = OwnerName
		}
	end,
	FunEntourageFilter=fun(#scene_spirit_ex{data=#scene_entourage_ex{owner_id=Owner}}) -> Owner =/= Uid end,
	NEL=lists:filter(FunEntourageFilter, EL),
	EL1 = lists:map(FunEntourage, NEL),
	Pt4 = Pt3#pt_scene_add{entourage_list = EL1},
	FunU = fun(#scene_spirit_ex{id = OUid,data=#scene_usr_ex{equip_list=EquipList}}) ->	
		Fun1 = fun(EquipID)->
			#pt_public_usr_equip_list{equip_id = EquipID,uid = OUid}
		end,
		lists:map(Fun1, EquipList)
	end,
	Equip_list1 = lists:map(FunU, UL),
	FunR = fun(#scene_spirit_ex{id = RUid,data=#scene_robot_ex{equip_list=EquipList}}) ->	
		Fun2 = fun(EquipID)->
			#pt_public_usr_equip_list{equip_id = EquipID,uid = RUid}
		end,
		lists:map(Fun2, EquipList)
	end,
	Equip_list2 = lists:map(FunR, RL),
	Pt5 = Pt4#pt_scene_add{usr_equip_list = lists:flatten(Equip_list1++Equip_list2)},
	FunModelEquip = fun(Type,Ret) ->
		Ptme = #pt_public_id_list{id = Type},
		Ret ++ [Ptme]
	end,	
	FunModel=fun(Model=#scene_spirit_ex{pos={X,Y,Z},dir=Dir,camp=Camp,data=#scene_model_ex{model_sort=ModelSort,model_clothes=ModelClothes,prof=Prof,equip_list=Equips}}, RetModel) ->
		IsCampModel = if
			ModelSort == 1 -> 1;
			true -> 0
		end,
		ModelEquipData=lists:foldl(FunModelEquip, [], Equips),
		Ptmod=#pt_public_camp_model_list{
			pid = Model#scene_spirit_ex.id,
			name = util:to_list(Model#scene_spirit_ex.name),
			prof = Prof,
			dir = Dir,
			x = X,
			y = Y,
			z = Z,
			camp = Camp,
			equips = ModelEquipData,
			model_clothes = ModelClothes,
			is_camp_model = IsCampModel
		},
		RetModel ++ [Ptmod]
	end,	
	ModelData=lists:foldl(FunModel, [], ModL),
	Pt6=Pt5#pt_scene_add{models = ModelData},
	Pt6.
	
on_enter(Object = #scene_spirit_ex{id = Oid,sort = Sort})->
	% ?debug("on_enter,Object = ~p",[Object]),
	case get({scene_oids,Sort}) of
		SortOids when erlang:is_list(SortOids) -> put({scene_oids,Sort}, [Oid|SortOids]);
		_ -> put({scene_oids,Sort},[Oid])
	end,
	case fun_scene_map:process_cell(Object) of
		{ok,NewCell} -> Object#scene_spirit_ex{map_cell = NewCell};
		_ -> Object
	end.

on_leave(#scene_spirit_ex{id=Oid,sort = ?SPIRIT_SORT_ITEM,data=#scene_item_ex{send_client=false}}) ->
	case get({scene_oids,?SPIRIT_SORT_ITEM}) of
		SortOids when erlang:is_list(SortOids) -> put({scene_oids,?SPIRIT_SORT_ITEM},replace_list_operate(SortOids,[Oid]));			
		_ -> put({scene_oids,?SPIRIT_SORT_ITEM},[])
	end,
	skip;
on_leave(#scene_spirit_ex{id=Oid,sort = ?SPIRIT_SORT_MONSTER,data=#scene_monster_ex{send_client=false}}) ->
	case get({scene_oids,?SPIRIT_SORT_MONSTER}) of
		SortOids when erlang:is_list(SortOids) -> put({scene_oids,?SPIRIT_SORT_MONSTER},replace_list_operate(SortOids,[Oid]));
		_ -> put({scene_oids,?SPIRIT_SORT_MONSTER},[])
	end,
	skip;
on_leave(#scene_spirit_ex{id=Oid,sort = ?SPIRIT_SORT_ENTOURAGE,data=#scene_entourage_ex{owner_id=OwnerId}}) ->
	case get({scene_oids,?SPIRIT_SORT_ENTOURAGE}) of
		SortOids when erlang:is_list(SortOids) -> put({scene_oids,?SPIRIT_SORT_ENTOURAGE},replace_list_operate(SortOids,[Oid]));
		_ -> put({scene_oids,?SPIRIT_SORT_ENTOURAGE},[])
	end,
	Pt = #pt_scene_dec{oid = Oid},
	Data = proto:pack(Pt),
	send_all_usr(Data,OwnerId);
on_leave(#scene_spirit_ex{id = Oid,sort = Sort}) ->
	case get({scene_oids,Sort}) of
		SortOids when erlang:is_list(SortOids) -> put({scene_oids,Sort},replace_list_operate(SortOids,[Oid]));
		_ -> put({scene_oids,Sort},[])
	end,
	Pt = #pt_scene_dec{oid = Oid},
	Data = proto:pack(Pt),
	send_all_usr(Data,Oid);
on_leave(_)-> skip.

on_pet_enter(Uid,PetList) ->	
	FunPet =fun({PetID,PetType}) ->
		#pt_public_pet_list{
			uid = Uid,
			pet_id = PetID+?PET_OFF,
			pet_type = PetType
		}																			   
	end,				   
	PetDatas=lists:map(FunPet, PetList),
	Pt = #pt_scene_add{pets = PetDatas},	
	Data = proto:pack(Pt),
	
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{map_cell = Cell} -> fun_scene_map:send_to_all_cell_usr(Cell, Data, 0);
		_ -> skip
	end.
on_pet_leave(Uid,PetID) ->
	Pt = #pt_scene_dec{oid = PetID+?PET_OFF},
	Data = proto:pack(Pt),	
	
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{map_cell = Cell} -> fun_scene_map:send_to_all_cell_usr(Cell, Data, 0);
		_ -> skip
	end.	

get_obj(ID) ->
	case get({scene_obj,ID}) of
		Obj = #scene_spirit_ex{} -> Obj;
		_ -> no
	end.


get_obj(ID,Sort) ->
	case get_obj(ID) of
		Obj = #scene_spirit_ex{sort = Sort} -> Obj;
		_ -> no
	end.
update(Spirit = #scene_spirit_ex{id = ID, sort = Sort}) ->
	%% 如果出错了，让错误直接暴露出来 
	#scene_spirit_ex{pos = OldPos} = get({scene_obj,ID}),
	put({scene_obj,ID},Spirit),
	case Sort of
		?SPIRIT_SORT_MONSTER ->
			mod_scene_monster:on_monster_pos_change(ID, OldPos, Spirit#scene_spirit_ex.pos);
		% ?SPIRIT_SORT_ENTOURAGE ->
		% 	?DBG(Spirit);
		_ -> skip
	end,
	Spirit.

get_all_ids() -> 
	get(scene_oids).

get_all_ids(Sort) -> 
	case get({scene_oids,Sort}) of
		Oids when erlang:is_list(Oids) -> Oids;
		_ -> []
	end.

get_all() -> 
	AllOids = get_all_ids(),
	[get_obj(Oid) ||Oid <- AllOids].

%%机器人部分
get_rl() ->
	All = get_all(),
	F = fun(Obj) -> is_robot(Obj) end,
	lists:filter(F, All).

is_robot(ID) when erlang:is_integer(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT} -> true;
		_ -> false
	end;
is_robot(#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT}) -> true;
is_robot(_) -> false.
get_robot_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = #scene_robot_ex{ai_module = Data}},ai_module) -> Data;
get_robot_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = #scene_robot_ex{ai_data = Data}},ai_data) -> Data;
get_robot_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = #scene_robot_ex{ai_time = Data}},ai_time) -> Data;
get_robot_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = #scene_robot_ex{battle_entourage = Data}},battle_entourage) -> Data;
get_robot_spc_data(_,_) -> no.
put_robot_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = Robot},ai_data,Data) -> Spirit#scene_spirit_ex{data = Robot#scene_robot_ex{ai_data = Data}};
put_robot_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = Robot},ai_time,Data) -> Spirit#scene_spirit_ex{data = Robot#scene_robot_ex{ai_time = Data}};
put_robot_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT,data = Robot},battle_entourage,Data) -> Spirit#scene_spirit_ex{data = Robot#scene_robot_ex{battle_entourage = Data}};
put_robot_spc_data(_,_,_) -> no.

%% 模型
get_modell() ->
	All = get_all(),
	F = fun(Obj) -> is_model(Obj) end,
	lists:filter(F, All).

is_model(ID) when erlang:is_integer(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_MODEL} -> true;
		_ -> false
	end;
is_model(#scene_spirit_ex{sort = ?SPIRIT_SORT_MODEL}) -> true;
is_model(_) -> false.

%%佣兵部分
get_el() ->
	All = get_all(),
	F = fun(Obj) -> is_entourage(Obj) end,
	lists:filter(F, All).

is_entourage(ID) when erlang:is_integer(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE} -> true;
		_ -> false
	end;
is_entourage(#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE}) -> true;
is_entourage(_) -> false.
get_entourage_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{type = Data}},type) -> Data;
get_entourage_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{target = Data}},target) -> Data;
get_entourage_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{owner_id = Data}},owner_id) -> Data;
get_entourage_spc_data(_,_) -> no.
put_entourage_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = Entourage},target,Data) -> Spirit#scene_spirit_ex{data = Entourage#scene_entourage_ex{target = Data}};
put_entourage_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = Entourage},ai_time,Data) -> Spirit#scene_spirit_ex{data = Entourage#scene_entourage_ex{ai_time = Data}};
put_entourage_spc_data(_,_,_) -> no.

%% 场景物品部分
get_il() ->
	All = get_all(),
	F = fun(Obj) -> is_item(Obj) end,
	lists:filter(F, All).

is_item(ID) when erlang:is_integer(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM} -> true;
		_ -> false
	end;
is_item(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM}) -> true;
is_item(_) -> false.
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{type = Data}},type) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{high = Data}},high) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{width = Data}},width) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{create_time = Data}},create_time) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{all_time = Data}},all_time) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{action = Data}},action) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{del = Data}},del) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{ontime_check = Data}},ontime_check) -> Data;
get_item_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = #scene_item_ex{trigger_list = Data}},trigger_list) -> Data;
get_item_spc_data(_,_) -> no.
put_item_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = SceneItem},all_time,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_item_ex{all_time = Data}};
put_item_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = SceneItem},del,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_item_ex{del = Data}};
put_item_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = SceneItem},ontime_check,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_item_ex{ontime_check = Data}};
put_item_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM,data = SceneItem},trigger_list,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_item_ex{trigger_list = Data}};
put_item_spc_data(_,_,_) -> no.

%% 怪物部分
get_ml() ->
	All = get_all(),
	F = fun(Obj) -> is_monster(Obj) end,
	lists:filter(F, All).
is_monster(ID) when erlang:is_integer(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER} -> true;
		_ -> false
	end;
is_monster(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER}) -> true;
is_monster(_) -> false.
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{type = Data}},type) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{max_hp = Data}},max_hp) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{ai_module = Data}},ai_module) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{ai_data = Data}},ai_data) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{ai_time = Data}},ai_time) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{ontime_start = Data}},ontime_start) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{ontime_check = Data}},ontime_check) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{ontime_off = Data}},ontime_off) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{script = Data}},script) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{allow_control = Data}},allow_control) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{partrol_point = Data}},partrol_point) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{still_partrol_point = Data}},still_partrol_point) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{owner = Data}},owner) -> Data;
get_monster_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = #scene_monster_ex{last_killer = Data}},last_killer) -> Data;
get_monster_spc_data(_,_) -> no.
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},ai_data,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{ai_data = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},ai_time,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{ai_time = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},ontime_start,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{ontime_start = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},ontime_check,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{ontime_check = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},ontime_off,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{ontime_off = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},allow_control,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{allow_control = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},partrol_point,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{partrol_point = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},still_partrol_point,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{still_partrol_point = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},owner,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{owner = Data}};
put_monster_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data = SceneItem},last_killer,Data) -> Spirit#scene_spirit_ex{data = SceneItem#scene_monster_ex{last_killer = Data}};
put_monster_spc_data(_,_,_) -> no.

%% 玩家部分
get_ul() ->
	All = get_all(),
	F = fun(Obj) -> is_usr(Obj) end,
	lists:filter(F, All).
is_usr(ID) when erlang:is_integer(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{sort = ?SPIRIT_SORT_USR} -> true;
		_ -> false
	end;
is_usr(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR}) -> true;
is_usr(_) -> false.
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{hid = Data}},hid) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{sid = Data}},sid) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{prof = Data}},prof) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{lev = Data}},lev) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{guild_name = Data}},guild_name) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{mount = Data}},mount) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{mount_level = Data}},mount_level) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{hate_per = Data}},hate_per) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{interrupt_effects = Data}},interrupt_effects) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{mp = Data}},mp) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{pk_lev = Data}},pk_lev) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{titlie = Data}},titlie) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{usr_equ = Data}},usr_equ) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{used_skill = Data}},used_skill) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{box = Data}},box) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{target = Data}},target) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{allow_control = Data}},allow_control) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{vip = Data}},vip) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{usr_state = Data}},usr_state) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{military_lev = Data}},military_lev) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{denation = Data}},denation) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{battle_entourage = Data}},battle_entourage) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{skill_list = Data}},skill_list) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{task_list = Data}},task_list) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{drop_drums_time = Data}},drop_drums_time) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{pet_list = Data}},pet_list) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{backpack_is_full = Data}},backpack_is_full) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{revive_times = Data}},revive_times) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{equip_list = Data}},equip_list) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{paragon_level = Data}},paragon_level) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{model_clothes = Data}},model_clothes) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{penta_kill = Data}},penta_kill) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{penta_kill_time = Data}},penta_kill_time) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{demage_list = Data}},demage_list) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{fatigue= Data}},fatigue) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{monster_list= Data}},monster_list) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{camp_leader= Data}},camp_leader) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{guild_id= Data}},guild_id) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{barrier_id= Data}},barrier_id) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{relife= Data}},relife) -> Data;
get_usr_spc_data(#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{worldboss_inspire= Data}},worldboss_inspire) -> Data;

get_usr_spc_data(_,_) -> no.

put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},prof,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{prof = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},lev,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{lev = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},guild_name,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{guild_name = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},mount,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{mount = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},mount_level,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{mount_level = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},hate_per,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{hate_per = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},interrupt_effects,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{interrupt_effects = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},mp,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{mp = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},pk_lev,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{pk_lev = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},titlie,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{titlie = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},usr_equ,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{usr_equ = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},used_skill,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{used_skill = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},box,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{box = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},target,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{target = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},allow_control,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{allow_control = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},vip,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{vip = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},usr_state,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{usr_state = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},military_lev,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{military_lev = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},denation,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{denation = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},battle_entourage,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{battle_entourage = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},skill_list,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{skill_list = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},task_list,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{task_list = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},drop_drums_time,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{drop_drums_time = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},fighting,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{fighting = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},pet_list,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{pet_list = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},backpack_is_full,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{backpack_is_full = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},revive_times,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{revive_times = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},equip_list,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{equip_list = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},paragon_level,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{paragon_level = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},model_clothes,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{model_clothes = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},penta_kill,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{penta_kill = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},penta_kill_time,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{penta_kill_time = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},demage_list,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{demage_list = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},fatigue,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{fatigue = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},monster_list,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{monster_list = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},camp_leader,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{camp_leader = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},guild_id,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{guild_id = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},barrier_id,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{barrier_id = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},relife,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{relife = Data}};
put_usr_spc_data(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = Usr},worldboss_inspire,Data) -> Spirit#scene_spirit_ex{data = Usr#scene_usr_ex{worldboss_inspire = Data}};
put_usr_spc_data(_,_,_) -> no.

send_cell_all_usr(#scene_spirit_ex{map_cell = Cell},Data) ->
	fun_scene_map:send_to_all_cell_usr(Cell, Data, 0).
send_cell_all_usr(#scene_spirit_ex{map_cell = Cell},Data,SendPid) ->
	fun_scene_map:send_to_all_cell_usr(Cell, Data, SendPid).

send_all_usr(Data)->send_all_usr(Data,-1).
send_all_usr(Data,SendPid)->
	Fun= fun(Oid) ->
		case get_obj(Oid) of
			#scene_spirit_ex{id = Oid, data = #scene_usr_ex{sid = Sid}} when Oid /= SendPid -> 
				?send(Sid,Data);
			_ -> skip
		end
	end,
	_ = [Fun(Oid) || Oid <- get_all_ids()].

agent_msg_by_uid(Uid,Msg)->
	case get_obj(Uid, ?SPIRIT_SORT_USR) of  
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}}-> agent_msg(AgentHid,Msg); %%gen_server:cast(Hid, Msg);
		_->skip
	end.


agent_msg(AgentHid,Msg) -> 
	case get(global) of
		scene -> gen_server:cast({global,global_server},{to_agent,AgentHid,Msg});
		_ ->  gen_server:cast(AgentHid, Msg)
	end.
agentmng_msg(AgentHid,Msg) -> 
	case get(global) of
		scene -> gen_server:cast({global,global_server},{to_agentmng,AgentHid,Msg});
		_ ->  gen_server:cast({global,agent_mng}, Msg)
	end.
agentmngs_msg(Msg) -> 
	UL = fun_scene_obj:get_ul(),
	Hids = lists:map(fun(Obj) -> 
							 case Obj of
								 #scene_spirit_ex{data = #scene_usr_ex{hid = AgentHid}} -> AgentHid;
								 _ -> no
							 end
					 end, UL),
	case get(global) of
		scene -> gen_server:cast({global,global_server},{to_agentmngs,Hids,Msg});
		_ ->  gen_server:cast({global,agent_mng}, Msg)
	end.
scenemng_msg(Msg) -> 
	case get(global) of
		scene -> skip;
		_ ->  gen_server:cast({global,scene_mng}, Msg)
	end.
send_all_agent(Msg)->
	UL = get_ul(),
	[agent_msg(get_usr_spc_data(Object,hid) ,Msg)|| Object <- UL].

get_spirit_client_type(ID) -> 
	case get_obj(ID) of
		#scene_spirit_ex{sort=Sort} -> 
			util_scene:server_obj_type_2_client_type(Sort);
		_ -> ?SPIRIT_CLIENT_TYPE_NULL
	end.

get_spirit_hp(#scene_spirit_ex{hp=CurrHp}) -> CurrHp;
get_spirit_hp(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{hp=CurrHp} -> CurrHp;
		_ -> 0
	end.

get_spirit_mp(#scene_spirit_ex{mp = CurrMp}) -> CurrMp;
get_spirit_mp(ID) ->
	case get_obj(ID) of
		#scene_spirit_ex{mp = CurrMp} -> CurrMp;
		_ -> 0
	end.

get_pace_speed(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR}) -> fun_scene:get_player_config_pace_speed(Spirit#scene_spirit_ex.data#scene_usr_ex.prof);
get_pace_speed(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER}) -> fun_scene:get_mon_config_pace_speed(Spirit#scene_spirit_ex.data#scene_monster_ex.type);
get_pace_speed(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE}) -> fun_scene:get_entourage_config_pace_speed(Spirit#scene_spirit_ex.data#scene_entourage_ex.type);
get_pace_speed(Spirit = #scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT}) -> fun_scene:get_player_config_pace_speed(Spirit#scene_spirit_ex.data#scene_robot_ex.prof);
get_pace_speed(_) -> 1.

get_move_speed(Spirit = #scene_spirit_ex{}) -> 
	ObjBattle = Spirit#scene_spirit_ex.final_property,
	if
		ObjBattle#battle_property.movespd < 1 -> 1;
		ObjBattle#battle_property.movespd > 1000 -> 1000;
		true -> ObjBattle#battle_property.movespd
	end;
get_move_speed(_) -> 100.

is_obj_bt(Obj) -> 
	Now = util:longunixtime(),
	case Obj#scene_spirit_ex.skill_data of
		#skill_data{start_time = StartTime,bt_start = Start, bt_time = Time} -> 
			if
				Now < StartTime + Start -> false;
				Now > StartTime + Start + Time -> false;
				true -> true
			end;
		_ -> false
	end.
is_obj_yz(Obj) -> 
	Now = util:longunixtime(),
	case Obj#scene_spirit_ex.skill_data of
		#skill_data{start_time = StartTime,yz_start = Start, yz_time = Time} -> 
			if
				Now < StartTime + Start -> false;
				Now > StartTime + Start + Time -> false;
				true -> true
			end;
		_ -> false
	end.
is_obj_wd(Obj) -> 
	Now = util:longunixtime(),
	case Obj#scene_spirit_ex.skill_data of
		#skill_data{start_time = StartTime,wd_start = Start, wd_time = Time} -> 
			if
				Now < StartTime + Start -> false;
				Now > StartTime + Start + Time -> false;
				true -> true
			end;
		_ -> false
	end.
is_obj_jz(Obj) ->
	Now = util:longunixtime(),
	case Obj#scene_spirit_ex.demage_data of
		#demage_data{start_time = Start, jz_time = Time} -> 
			if
				Now > Start + Time -> false;
				true -> true
			end;
		_ -> false
	end.

check_kick_by_buff(Obj) -> fun_scene_buff:can_be_kick(Obj#scene_spirit_ex.buffs).
	
check_kick(_Obj,?SKILL_KICK_NO,_) -> false;
check_kick(Obj,_KickType,{AtkStifle,LongSuffering}) ->
	CheckJZ=is_obj_jz(Obj),
	if
		CheckJZ == true -> false;
		true -> 
			case check_kick_by_buff(Obj) of %%考虑buff影响不能位移
				true -> false;
				_ ->
					CurrStifle=Obj#scene_spirit_ex.stifle,
					if
						CurrStifle + AtkStifle > LongSuffering -> true;  
						true -> false
					end
			end
	end.
get_monster_die(ID) ->
	case get_obj(ID,?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{die = false} -> false;
		_ -> true
	end.

get_monster_die(Data,1) -> get_monster_die(Data);
get_monster_die(_Data,_) -> ok.
%% 	F = fun(Monster) ->
%% 			case Monster of
%% 				#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER,data=#scene_monster_ex{type=Data}, die=true} -> true;
%% 				_ -> false
%% 			end
%% 		end,
%% 	case lists:any(F, get_ml()) of
%% 		true -> 0;
%% 		_ -> 1
%% 	end.

put_camp(Id, Camp) ->
	Obj = get_obj(Id, ?SPIRIT_SORT_USR),
	EL = get_usr_spc_data(Obj, battle_entourage),
	update(Obj#scene_spirit_ex{camp = Camp}),
	Fun = fun(Eid) ->
		case get_obj(Eid, ?SPIRIT_SORT_ENTOURAGE) of
			EObj = #scene_spirit_ex{} -> update(EObj#scene_spirit_ex{camp = Camp});
			_ -> skip
		end
	end,
	lists:foreach(Fun, EL),
	Pt = #pt_scene_change_camp{id=Id,new_camp=Camp},
	send_all_usr(proto:pack(Pt)).