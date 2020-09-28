-module (mod_scene_monster).
-include ("common.hrl").
-export ([create_monster/3, create_monster/4]).
-export ([kill_all_monster/0, handle/1]).
-export ([on_monster_pos_change/3, remove_in_pos_monster/3, has_other_monster_in_pos/3]).

create_monster(0, _Pos, _Difficulty) -> skip;
create_monster(Type, Pos, Difficulty) ->
	create_monster(Type, Pos, 90, Difficulty).

create_monster(0, _Pos, _Dir, _Difficulty) -> skip;
create_monster(Type, Pos, Dir, Difficulty) ->
	ID  = fun_scene_obj:get_obj_id(),
	CurHp = 0,
	create_monster_help(ID,Type,Pos,Dir,CurHp,0,0,0,Difficulty).


create_monster_help(ID,Type,Pos,Dir,CurHp,ReflushID,ConItemID,Master,Difficulty) ->
	case data_monster:get_monster(Type) of		
		#st_monster_config{level = Lev, ai = Ai, name = Name, rank_level = RankLev, sex = Sex, race = Race, profession = Profession} ->
			Moudle = util:to_atom("ai_" ++ util:to_list(Ai)),
			Point =tool_vect:to_map_point(Pos),
			NPos = case fun_scene_map:check_point(Point) of
				{true,_,YPoint} -> tool_vect:to_point(YPoint);
				_ -> no
			end,		 
			case NPos of
				 no -> ?log_warning("add monster in wrong position,scene=~p,Id=~p,Type=~p,Pos=~w", [get(scene),ID,Type,Pos]);
				 _ ->
					AiData = Moudle:init(get(scene),ID,Type,NPos,Dir),
					case Difficulty of
						#st_dungeon_dificulty{} ->
							Lev2 = Lev * Difficulty#st_dungeon_dificulty.levPower,
							Battle = fun_property:get_monster_property_by_difficulty(Type, Difficulty);
						_ when is_list(Difficulty) -> %% 这种是加指定的属性值的 
							Lev2 = Lev,
							Battle = fun_property:get_monster_property_by_addition_attr(Type, Difficulty);
						_ ->
							Difficulty2 = #st_dungeon_dificulty{},
							Lev2 = Lev * Difficulty2#st_dungeon_dificulty.levPower,
							Battle = fun_property:get_monster_property_by_difficulty(Type, Difficulty2)
					end,
					Hp = get_hp_by_rate(Battle,CurHp),
					Mp = util:ceil(Battle#battle_property.mpLimit*data_entourage_features:get_init_mp(Profession)/10000),
					SendClient = case RankLev of
						?SCENE_SYSTEM_MONSTER -> false;
						_ -> true
					end,
					NameInfo = case fun_scene_obj:get_obj(Master, ?SPIRIT_SORT_USR) of
						#scene_spirit_ex{name=UName} -> lists:concat([Name,"[",util:to_list(UName),"]"]);
						_ -> Name
					end,
					Obj = #scene_spirit_ex{
						id = ID, dir=Dir, camp=?CAMP_MONSTER_DEFAULT, speed=60, name=NameInfo, 
						pos=NPos,hp=Hp,mp=Mp,final_property=Battle
					},
					ObjData = #scene_monster_ex{
						lev=Lev2,master=Master,type=Type,max_hp=Hp,
						sex = Sex,race = Race,profession = Profession,
						ai_module=Moudle,ai_data=AiData,partrol_point=Pos,
						con_scene_item=ConItemID,reflush_pos_id=ReflushID,send_client=SendClient
					},
					fun_scene_obj:add_monster(Obj, ObjData),
					{X, _, Z} = NPos,
					add_in_pos_monster(trunc(X), trunc(Z), ID),
					{ok, ID, Type}		 
			end;
		_ -> 
		 	?ERROR("create monster error Type:~p not exists",[Type]),skip
	end.


get_hp_by_rate(Battle,CurHp) ->
	MaxHp = Battle#battle_property.hpLimit,
	case CurHp of
		null -> MaxHp;
		0 -> MaxHp;
		Hp1 -> util:ceil(min(Hp1, MaxHp))							
	end.


%% 杀死场景内的所有怪物，这个要异步延迟执行，不能立马移除场景怪物对象的
kill_all_monster() ->
	CurrentList = fun_scene_obj:get_all_ids(?SPIRIT_SORT_MONSTER),
	util_misc:msg_handle_cast(self(), ?MODULE, {kill_all_monster, CurrentList}).


handle({kill_all_monster, MonsterOidList}) ->
	Fun = fun(Oid) ->
		case fun_scene_obj:get_obj(Oid) of
			#scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER} ->
				fun_scene_obj:remove_obj(Oid);
			_ -> skip
		end	
	end,
	_ = [Fun(M) || M <- MonsterOidList].

%% =============================================================================
%% ============================ 怪物所在位置索引处理 =============================
on_monster_pos_change(Oid, OldPos, NewPos) -> 
	{X1, _, Z1} = OldPos,
	{X2, _, Z2} = NewPos,
	XInt1 = trunc(X1), 
	ZInt1 = trunc(Z1), 
	XInt2 = trunc(X2), 
	ZInt2 = trunc(Z2),
	case XInt1 =/= XInt2 orelse ZInt1 =/= ZInt2 of
		true -> 
			remove_in_pos_monster(XInt1, ZInt1, Oid),
			add_in_pos_monster(XInt2, ZInt2, Oid);
		_ -> skip
	end.

remove_in_pos_monster(XInt, ZInt, Oid) ->
	Key = {pos_monsters, XInt, ZInt},
	case get(Key) of
		undefined -> 
			?WARNING("monster ~p not in pos index(~p, ~p)", [Oid, XInt, ZInt]);
		List -> 
			put(Key, lists:delete(Oid, List))
	end.

add_in_pos_monster(XInt, ZInt, Oid) ->
	Key = {pos_monsters, XInt, ZInt},
	case get(Key) of
		undefined -> 
			put(Key, [Oid]);
		List -> 
			put(Key, [Oid | List])
	end.

has_other_monster_in_pos(SelfOid, X, Z) -> 
	XInt = trunc(X), 
	ZInt = trunc(Z), 
	case get({pos_monsters, XInt, ZInt}) of 
		[Oid | _] when Oid /= SelfOid -> {true, Oid};
		_ -> false
	end. 