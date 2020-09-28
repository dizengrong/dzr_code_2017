%% -*- coding: latin-1 -*-
-module(mod_scene_entourage).
-include("common.hrl").
-export([handle/1, cacl_zhenfa_add_damage/3, kill_all_heros/1, all_hero_add_buff/2]).

%% =================Handle to Scene====================
handle({create_entourage,Uid,Sid,Seq,EntourageInfo,Battle,EntourageSkill,PassiveSkillList,LeftHpRate}) ->
	case util_scene:scene_type(get(scene)) of
		?SCENE_SORT_ARENA -> skip;
		_ ->
			%%玩家有佣兵的话，先删
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				UsrObj=#scene_spirit_ex{data= #scene_usr_ex{battle_entourage = EL}} ->
					Eid = EntourageInfo#item.id + ?ETRG_OFF,
					%% 是否刷新英雄数据
					fun_scene_obj:remove_obj(Eid),
					%%创建佣兵
					{Spirit, Entourage} = make_hero_data(EntourageInfo, Battle, EntourageSkill, PassiveSkillList, UsrObj, LeftHpRate),
					fun_scene_obj:add_entourage(Spirit, Entourage),
					%%发送给前端
					Pt = #pt_entourage_create_model{
						oid          = Eid,
						cur_hp       = Spirit#scene_spirit_ex.hp,
						hp           = Battle#battle_property.hpLimit,
						cur_mp       = Spirit#scene_spirit_ex.mp,
						mp           = Battle#battle_property.mpLimit,
						item_id      = EntourageInfo#item.id,
						star         = EntourageInfo#item.star,
						played_state = 1
					},
					case lists:member(Eid, EL) of
						true -> skip;
						_ ->
							%%修改玩家记录的佣兵
							NewEL = [Eid | EL],
							fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(UsrObj, battle_entourage, lists:sublist(NewEL, ?MAX_ENTOURAGE)))
					end,
					?send(Sid,proto:pack(Pt, Seq));
				_ -> skip
			end
	end;

handle({create_single_entourage,Uid,Sid,Seq,EntourageInfo,Battle,EntourageSkill,PassiveSkillList,LeftHpRate}) ->
	case util_scene:scene_type(get(scene)) of
		?SCENE_SORT_ARENA -> skip;
		_ ->
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				UsrObj = #scene_spirit_ex{data= #scene_usr_ex{battle_entourage = EL}} ->
					Eid = EntourageInfo#item.id + ?ETRG_OFF,
					case lists:member(Eid, EL) of
						true ->
							fun_scene_obj:remove_obj(Eid),
							{Spirit, Entourage} = make_hero_data(EntourageInfo, Battle, EntourageSkill, PassiveSkillList, UsrObj, LeftHpRate),
							fun_scene_obj:add_entourage(Spirit, Entourage),
							%%发送给前端
							Pt = #pt_entourage_create_model{
								oid          = Eid,
								cur_hp       = Spirit#scene_spirit_ex.hp,
								hp           = Battle#battle_property.hpLimit,
								mp           = Battle#battle_property.mpLimit,
								cur_mp       = Spirit#scene_spirit_ex.mp,
								item_id      = EntourageInfo#item.id,
								star         = EntourageInfo#item.star,
								played_state = 1
							},
							?send(Sid,proto:pack(Pt, Seq));
						_ -> skip
					end;
				_ -> skip
			end
	end;

handle({scene_battle_change,List}) ->
	Fun = fun({ItemId, NewBattle}) -> 
		Eid = ItemId + ?ETRG_OFF,
		case fun_scene_obj:get_obj(Eid, ?SPIRIT_SORT_ENTOURAGE) of
			Entourage = #scene_spirit_ex{buff_property=BuffAttrs} -> 
				Entourage2 = Entourage#scene_spirit_ex{
					base_property = NewBattle,
					final_property = mod_entourage_property:scene_cal_final_property(NewBattle, BuffAttrs)
				},
				fun_scene_obj:update(Entourage2);
			_ -> skip
		end
	end,
	_ = [Fun(T) || T <- List];

handle({cancel_entourage,Uid}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{data= #scene_usr_ex{battle_entourage = EL}} ->
			Fun = fun(Eid) ->
				fun_scene_obj:remove_obj(Eid)
			end,
			lists:foreach(Fun, EL),
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, battle_entourage, []));
		_ -> skip
	end;

handle({add_all_hero_buff, Uid, BuffType}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data = #scene_usr_ex{battle_entourage=EntourageList}} ->
			Fun = fun(EntourageOid) ->
				case fun_scene_obj:get_obj(EntourageOid, ?SPIRIT_SORT_ENTOURAGE) of
					EntourageObj = #scene_spirit_ex{die=false} ->
						fun_scene_obj:update(fun_scene_buff:add_buff(EntourageObj, BuffType, Uid)),
						ok;
						% put(scene_123, {EntourageOid, BuffType}),
						% ?debug("Obj = ~p",[Obj]);
					_ -> skip
				end
			end,
			lists:foreach(Fun, EntourageList);
		_ -> skip
	end;

handle({set_on_battle_heros, Uid, Seq}) ->
	handle({cancel_entourage,Uid}),
	OnBattleType = get_on_battle_type_by_scene_type(),
	#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} = fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR),
	util_misc:msg_handle_cast(AgentHid, fun_entourage, {notify_client_on_battle_heros, OnBattleType, Seq}),
	ok;

handle({begin_entourage_create,Uid,Seq,ItemId,CreateType}) ->
	OnBattleType = get_on_battle_type_by_scene_type(),
	#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} = fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR),
	util_misc:msg_handle_cast(AgentHid, fun_entourage, {begin_entourage_create, OnBattleType, Seq,ItemId,CreateType}),
	ok;

handle({scene_hero_prop_change, Uid, ChangeType, HeroItemId, NewVal}) -> 
	HeroOid = HeroItemId + ?ETRG_OFF,
	case fun_scene_obj:get_obj(HeroOid) of
		Obj = #scene_spirit_ex{} -> 
			Obj2 = do_scene_hero_prop_change(Obj, ChangeType, NewVal),
			fun_scene_obj:update(Obj2),
			Pt = #pt_scene_hero_prop_change{
				type = ChangeType,
				val = NewVal
			},
			#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} = fun_scene_obj:get_obj(Uid),
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end;
%% =================Handle to Scene====================

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

do_scene_hero_prop_change(Obj = #scene_spirit_ex{data = Detail}, ChangeType, NewVal) -> 
	Detail2 = case ChangeType of
		?HERO_STAR_CHANGE ->
			Detail#scene_entourage_ex{star = NewVal}
	end,
	Obj#scene_spirit_ex{data = Detail2}.


%% 根据场景类型获取要上阵的英雄的类型
get_on_battle_type_by_scene_type() ->
	OnBattleType = case util_scene:scene_type(get(scene)) of
		?SCENE_SORT_HERO_EXPEDITION -> ?ON_BATTLE_EXPEDITION;
		?SCENE_SORT_MAIN -> ?MAIN_SCENE;
		?SCENE_SORT_ACTIVITY_COPY -> ?ON_BATTLE_ACT_COPY
	end,
	OnBattleType.

make_hero_data(EntourageInfo, Battle, EntourageSkill, PassiveSkillList, UsrObj, LeftHpRate) ->
	Eid  = EntourageInfo#item.id + ?ETRG_OFF,
	Type = EntourageInfo#item.type,
	St   = data_entourage:get_data(Type),
	Prof = St#st_entourage_config.profession,
	Mp   = util:ceil(Battle#battle_property.mpLimit*data_entourage_features:get_init_mp(Prof)/10000),
	Spirit = #scene_spirit_ex{
		id                 = Eid,
		dir                = UsrObj#scene_spirit_ex.dir,
		camp               = UsrObj#scene_spirit_ex.camp, 
		speed              = 60,
		pos                = UsrObj#scene_spirit_ex.pos,
		hp                 = util:floor((Battle#battle_property.hpLimit)*LeftHpRate/10000),
		mp                 = Mp,
		base_property      = Battle,
		final_property     = Battle,
		passive_skill_data = PassiveSkillList
	},
	Entourage = #scene_entourage_ex{
		type       = Type,
		lev        = EntourageInfo#item.lev,
		sex        = St#st_entourage_config.sex,
		race       = St#st_entourage_config.race,
		profession = St#st_entourage_config.profession,
		star       = EntourageInfo#item.star,
		skills     = EntourageSkill,
		owner_id   = UsrObj#scene_spirit_ex.id
	},
	{Spirit, Entourage}.


%% 计算阵法伤害加成
cacl_zhenfa_add_damage(#scene_spirit_ex{data = #scene_entourage_ex{type = Etype1}}, 
					   #scene_spirit_ex{data = #scene_entourage_ex{type = Etype2}}, Damage) ->
	#st_entourage_config{race = Race1} = data_entourage:get_data(Etype1),
	#st_entourage_config{race = Race2} = data_entourage:get_data(Etype2),
	case data_zhenfa:race_restraint_damage(Race1, Race2) of
		undefined -> Damage;
		AddRate -> util:floor(Damage * (1 + AddRate /10000))
	end;
cacl_zhenfa_add_damage(_, _, Damage) -> 
	Damage.


kill_all_heros(Oid) ->
	EIdList2 = case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{data = #scene_usr_ex{battle_entourage = EIdList}} -> 
			EIdList;
		#scene_spirit_ex{data = #scene_robot_ex{battle_entourage = EIdList}} -> 
			EIdList
	end,
	[fun_scene_obj:remove_obj(Id) || Id <- EIdList2],
	fun_scene_obj:remove_obj(Oid),
	ok.


all_hero_add_buff(Oid, Buffs) ->
	case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{data = #scene_usr_ex{battle_entourage = OnBattleHeros}} -> 
			[hero_add_buff(Eid, Buffs) || Eid <- OnBattleHeros];
		#scene_spirit_ex{data = #scene_robot_ex{battle_entourage = OnBattleHeros}} -> 
			[hero_add_buff(Eid, Buffs) || Eid <- OnBattleHeros];
		_ -> 
			?WARNING("This obj ~p is not hero owner, should not call this method!", [Oid])
	end.


hero_add_buff(Eid, Buffs) ->
	case fun_scene_obj:get_obj(Eid) of
		Obj = #scene_spirit_ex{} -> 
			Fun = fun(Buff, Acc) ->
				fun_scene_buff:add_buff(Acc, Buff, Eid)
			end,
			Obj2 = lists:foldl(Fun, Obj, Buffs),
			fun_scene_obj:update(Obj2);
		_ -> 
			skip
	end.

% all_hero_add_buff_attr(Oid, AddBuffAttrs) -> 
% 	case fun_scene_obj:get_obj(Oid) of
% 		#scene_spirit_ex{data = #scene_usr_ex{battle_entourage = OnBattleHeros}} -> 
% 			[hero_add_buff_attr(Eid, AddBuffAttrs) || Eid <- OnBattleHeros];
% 		#scene_spirit_ex{data = #scene_robot_ex{battle_entourage = OnBattleHeros}} -> 
% 			[hero_add_buff_attr(Eid, AddBuffAttrs) || Eid <- OnBattleHeros];
% 		_ -> 
% 			?WARNING("This obj ~p is not hero owner, should not call this method!", [Oid])
% 	end.

% hero_add_buff_attr(Eid, AddBuffAttrs) ->
% 	case fun_scene_obj:get_obj(Eid) of
% 		#scene_spirit_ex{base_property = BaseProp, final_property = PropRec} -> 
% 			BuffAttrs = [fun_scene_buff:calc_buff_attrs_help(AttrId, Val, BaseProp) || {AttrId, Val} <- AddBuffAttrs],
% 			NewFinalProps = fun_property:add_attrs_to_property(PropRec, BuffAttrs),
% 			GetObj#scene_spirit_ex{
% 				final_property = NewFinalProps,
% 				buff_property = [{Type, BuffAttrs} | BuffPropList]
% 			};
% 	ok.

