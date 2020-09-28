%% -*- coding: latin-1 -*-
-module(fun_entourage).
-include("common.hrl").
-export([handle/1]).
-export([req_entourage_illustration/3, req_re_entourage_combat/3, req_attr_info/4]).
-export([request_entourage_info/4,req_entourage_combat/5]).
-export([req_entourage_create/5]).
-export([get_battle_entourage/1,get_pos/2,get_entourage_battle_data/2]).
-export([get_base_prop/2,get_lev_prop/2,get_grade_prop/2,get_star_prop/2,get_skill_prop/2]).
-export([is_battle/2]).
-export([entourage_die/3]).
-export([entourage_prop_upgrade_data/1]).
-export([on_entourage_battle_change/3]).
-export([get_entourage/2]).
-export([update_all_on_battle_hero_property/1,update_hero_illustration/3]).


-define(NONE_BATTLE, 0). %% 未出战
-define(BATTLE,      1). %% 出战
-define(ARENA,       2). %% 竞技场

-define(CREATE_COMBAT,      0). %% 出战
-define(CREATE_REVIVE,      1). %% 复活

%% ================================= 数据接口 ==================================
get_entourage(Uid, EntourageId) ->
	case mod_role_tab:lookup(Uid, {item, EntourageId}) of
		[] -> undefined;
		[Rec] -> Rec
	end.

%% ================================= 数据接口 ==================================
%% =============================================================================

%% return: [{ItemId, Type, Pos}]
get_battle_entourage(Uid) ->
	{List, _} = mod_entourage_data:get_entourage_data(Uid, ?MAIN_SCENE),
	List.

set_battle_entourage(Uid, List, ShenqiId) ->
	fun_shenqi:load_shenqi(Uid, ShenqiId),
	mod_entourage_data:set_entourage_data(Uid, List, ShenqiId, ?MAIN_SCENE).

%% =================Handle to Agent====================
handle({entourage_die, _Uid, Eid, _Now}) ->
	Pt = #pt_entourage_die{id=Eid},
	?send(get(sid), proto:pack(Pt));

handle({notify_client_on_battle_heros, OnBattleType, Seq}) ->
	mod_entourage_data:send_on_scene_heros(get(uid), get(sid), Seq, OnBattleType);

handle({begin_entourage_create, OnBattleType, Seq,ItemId,CreateType}) -> 
	do_req_create_entourage(OnBattleType, Seq,ItemId,CreateType);
%% =================Handle to Agent====================

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).


%% 请求英雄的战力和属性
req_attr_info(Uid, Sid, Seq, EId) ->
	case get_entourage(Uid, EId) of
		undefined -> ?ERROR("cannot find hero:~p", [EId]);
		_ -> 
			Property = fun_agent_property:get_final_property(Uid, EId),
			Fighting = fun_agent_property:get_fighting(EId),
			Pt = #pt_hero_attr_info{
				eid      = EId,
				attrs    = util_pt:make_attr_pt(Property),
				fighting = Fighting
			},
			?send(Sid, proto:pack(Pt, Seq))
	end.


request_entourage_info(Uid, Sid, Seq, ItemId) ->
	send_entourage_info_to_client(Uid, Sid, Seq, ItemId).

req_entourage_combat(_Uid, Sid, Seq, [], _) ->
	?error_report(Sid, "error_at_least_on_battle_one", Seq);
req_entourage_combat(Uid, Sid, Seq, List, ShenqiId) when length(List) =< ?MAX_ENTOURAGE ->
	case get(stage_battle) of
		true -> skip;
		_ ->
			NewList = util_entourage:make_entourage_list(Uid, List),
			set_battle_entourage(Uid, NewList, ShenqiId),
			OldList = get_battle_entourage(Uid),
			fun_usr_misc:set_misc_data(Uid, last_called_hero, NewList),
			%% 将改变的数据发送给前端
			SendList = find_changed_list(OldList, NewList),
			fun_item:send_items_to_sid(Uid, Sid, [fun_item_api:get_item_by_id(Uid, ItemId1) || ItemId1 <- SendList], Seq),
			fun_agent:handle_to_scene(mod_scene_entourage, {cancel_entourage,Uid}),
			fun_entourage_zhenfa:reset_zhenfa(NewList),
			mod_entourage_data:send_on_battle_heros(Uid, Sid, Seq, ?MAIN_SCENE),
			ok
	end;
req_entourage_combat(Uid, _Sid, _Seq, List, _ShenqiId) -> 
	?log_error("~p usr:~p cheat :~p", [?MODULE, Uid, List]).


find_changed_list(OldList, NewList) ->
	S1 = sets:from_list([Id ||{Id, _, _} <- OldList]),
	S2 = sets:from_list([Id ||{Id, _, _} <- NewList]),
	sets:to_list(sets:subtract(S1, S2)) ++ sets:to_list(sets:subtract(S2, S1)).


req_re_entourage_combat(Uid, _Sid, Seq) ->
	fun_agent:handle_to_scene(mod_scene_entourage, {set_on_battle_heros,Uid,Seq}),
	ok.

req_entourage_create(Uid,_Sid,Seq,ItemId,CreateType) ->
	fun_agent:handle_to_scene(mod_scene_entourage, {begin_entourage_create,Uid,Seq,ItemId,CreateType}),
	ok.

do_req_create_entourage(OnBattleType, Seq,ItemId,CreateType) ->
	Uid = get(uid),
	{OnBattleList, _} = mod_entourage_data:get_entourage_data(Uid, OnBattleType),
	case lists:keyfind(ItemId, 1, OnBattleList) of
		{ItemId, Etype, _} -> 
			case OnBattleType of
				?ON_BATTLE_EXPEDITION ->
					case mod_hero_expedition:get_left_hp_rate(Uid, ItemId) of
						LeftRate when LeftRate > 0 -> 
							do_req_create_entourage2(Uid,Seq,ItemId,CreateType,Etype,LeftRate);
						_ -> 
							?ERROR("This hero is die, cannot on battle!")
					end;
				_ ->
					do_req_create_entourage2(Uid,Seq,ItemId,CreateType,Etype)
			end;
		_ -> skip
	end.

do_req_create_entourage2(Uid,Seq,ItemId,CreateType,Etype) ->
	do_req_create_entourage2(Uid,Seq,ItemId,CreateType,Etype, 10000).
do_req_create_entourage2(Uid,Seq,ItemId,CreateType,Etype, LeftRate) ->
	Sid = get(sid),
	case fun_item_api:get_item_by_id(Uid, ItemId) of
		Entourage = #item{} ->
			Battle = fun_agent_property:get_on_battle_final_property(Uid, ItemId),
			SkillList = get_entourage_skill(Uid, ItemId, Etype),
			PassiveSkill = get_entourage_passive_skill(Uid, ItemId, Etype),
			case CreateType of
				?CREATE_COMBAT -> 
					fun_agent:handle_to_scene(mod_scene_entourage, {create_entourage,Uid,Sid,Seq,Entourage,Battle,SkillList,PassiveSkill,LeftRate});
				?CREATE_REVIVE -> 
					fun_agent:handle_to_scene(mod_scene_entourage, {create_single_entourage,Uid,Sid,Seq,Entourage,Battle,SkillList,PassiveSkill,LeftRate});
				_ -> skip
			end;
		_ -> skip
	end.

send_entourage_info_to_client(Uid, Sid, Seq, ItemId) ->
	case fun_item_api:get_item_by_id(Uid, ItemId) of
		#item{type = Type, lev = Lev, star = Star} ->
			case data_entourage:get_data(Type) of
				#st_entourage_config{} ->
					FunBattle = fun({PropertyId,PropertyVal}) ->
						#pt_public_property_list{propertyId=PropertyId,propertyVal=PropertyVal}
					end,
					PropList = get_entourage_prop(Uid, ItemId),
					Fighting = get_entourage_gs(ItemId),
					Pt =#pt_entourage_info_new{
						type          = Type,
						lev           = Lev,
						star          = Star,
						fighting      = Fighting,
						property_list = lists:map(FunBattle, PropList)
					},
					?send(Sid,proto:pack(Pt,Seq));
				_ -> skip
			end;
		_ -> skip
	end.

% send_entourage_scene_info_to_client(Uid, Sid, Seq, BattleList) ->
% 	FunBattle = fun({PropertyId,PropertyVal}) ->
% 		#pt_public_property_list{propertyId=PropertyId,propertyVal=PropertyVal}
% 	end,
% 	FunSkill = fun({SkillType,_}) ->
% 		#pt_public_skill_list{skillId=SkillType}
% 	end,
% 	Fun = fun({ItemId, Etype, _}) ->
% 		PropList = get_entourage_prop(Uid, ItemId),
% 		SkillList = get_entourage_skill(Uid, ItemId, Etype),
% 		#pt_public_entourage_list{
% 			id            = ItemId,
% 			lev           = fun_item_api:get_item_lev(Uid, ItemId),
% 			property_list = lists:map(FunBattle, PropList),
% 			skill_list    = lists:map(FunSkill, SkillList)
% 		}
% 	end,
% 	Pt = #pt_entourage_list_new{entourage_list = lists:map(Fun, BattleList)},
% 	?send(Sid,proto:pack(Pt,Seq)).

is_battle(Uid,ItemId) ->
	case lists:keyfind(ItemId, 1, get_battle_entourage(Uid)) of
		{ItemId, _, _} -> ?BATTLE;
		_ ->
			case fun_arena:has_in_guard(Uid,ItemId) of
				true -> ?ARENA;
				_ -> ?NONE_BATTLE
			end
	end. 

get_pos(Uid, ItemId) ->
	case lists:keyfind(ItemId, 1, get_battle_entourage(Uid)) of
		{ItemId, _, Pos} -> Pos;
		_ -> 0
	end.


entourage_die(Uid, Eid, Now) -> 
	IsRealRole = Uid > ?UID_OFF,
	case IsRealRole of
		true -> 
			AgentHid = fun_scene_obj:get_usr_spc_data(fun_scene_obj:get_obj(Uid), hid),
			mod_msg:handle_to_agent(AgentHid, ?MODULE, {entourage_die, Uid, Eid, Now});
		_ -> skip
	end,
	EIdList2 = case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{data = #scene_usr_ex{battle_entourage = EIdList}} -> 
			EIdList;
		#scene_spirit_ex{data = #scene_robot_ex{battle_entourage = EIdList}} -> 
			EIdList
	end,

	Fun = fun(HeroId) -> 
		case fun_scene_obj:get_obj(HeroId) of
			#scene_spirit_ex{die = false} -> true;
			_ -> false
		end
	end,
	List = lists:filter(Fun, EIdList2),
	case get(scene) of
		?PK_SCENE_ID -> fun_scene_arena:entourage_die(Uid);
		?SCENE_SORT_HERO_EXPEDITION -> fun_scene_hero_expedition:entourage_die(Uid, Eid);
		_ -> skip
	end,
	% ?DBG({Uid, IsRealRole}),
	% ?DBG(length(List)),
	case List of
		[] ->
			St = data_scene_config:get_scene(get(scene)),
			case St#st_scene_config.sort of
				?SCENE_SORT_MAIN -> fun_scene_main:stage_lose(Uid);
				?SCENE_SORT_ACTIVITY_COPY -> fun_scene_activity_copy:on_all_hero_die(Uid);
				?SCENE_SORT_HERO_EXPEDITION -> fun_scene_hero_expedition:on_all_hero_die(Uid);
				_ -> skip
			end;
		_ -> skip
	end.

%% 基础属性
get_base_prop(Uid, ItemId) ->
	#item{type = Etype} = fun_item_api:get_item_by_id(Uid, ItemId),
	#st_entourage_config{basePropList = BaseProp} = data_entourage:get_data(Etype),
	BaseProp.

%% 等级属性
get_lev_prop(Uid, EntourageId) -> 
	#item{type = Etype, lev = Lv} = get_entourage(Uid, EntourageId),
	#st_entourage_config{profession = Prof} = data_entourage:get_data(Etype),
	data_entourage_ex:get_lv_attr(Lv, Prof).

%% 品级属性
get_grade_prop(Uid, EntourageId) -> 
	#item{break = Grade} = get_entourage(Uid, EntourageId),
	data_entourage_ex:get_grade_attr(Grade).

%% 星级属性
get_star_prop(Uid, EntourageId) -> 
	#item{star = Star} = get_entourage(Uid, EntourageId),
	data_entourage_ex:get_star_attr(Star).

%% 技能属性
get_skill_prop(Uid, EntourageId) ->
	#item{type = Etype, break = Grade, star = Star} = get_entourage(Uid, EntourageId),
	case data_entourage_skill:get_data(Etype, Grade, Star) of
		#st_entourage_skill{prop = Props} ->
			Props;
		_ -> []
	end.


entourage_prop_upgrade_data(PropList)->
	Fun = fun({Val,Base},Prop1)->
		fun_property:property_add_data(Prop1, Val, Base)
	end,
	lists:foldr(Fun, #battle_property{}, PropList).

get_entourage_prop(Uid, ItemId) ->
	BattleProperty = fun_agent_property:get_final_property(Uid, ItemId),
	fun_property:property_get_data_by_type(BattleProperty).

get_entourage_gs(ItemId) ->
	fun_agent_property:get_fighting(ItemId).

get_entourage_skill(Uid, ItemId, Etype) ->
	#item{break = Break, star = Star} = fun_item_api:get_item_by_id(Uid, ItemId),
	case data_entourage_skill:get_data(Etype, Break, Star) of
		#st_entourage_skill{skill = SkillList} -> SkillList;
		_ -> []
	end.

get_entourage_passive_skill(Uid, ItemId, Etype) ->
	#item{break = Break, star = Star} = fun_item_api:get_item_by_id(Uid, ItemId),
	case data_entourage_skill:get_data(Etype, Break, Star) of
		#st_entourage_skill{passive_skill = SkillList} ->
			[{Type, Lev, data_passive_skill:get_probability(Type)} || {Type, Lev} <- SkillList];
		_ -> []
	end.

get_entourage_battle_data(0,_) -> [];
get_entourage_battle_data(Uid, EntourageList) ->
	Fun = fun({ItemId, Etype, Pos}, Acc) ->
		case fun_item_api:get_item_by_id(Uid, ItemId) of
			Entourage = #item{type = Etype} ->
				Battle = mod_entourage_property:get_entourage_prop(Uid, ItemId),
				SkillList = get_entourage_skill(Uid, ItemId, Etype),
				[{Entourage, Battle, SkillList, [], Pos} | Acc];
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], EntourageList).

%% 英雄基本属性改变事件
on_entourage_battle_change(Uid, _Sid, EntourageId) ->
	case lists:keyfind(EntourageId, 1, get_battle_entourage(Uid)) of
		false -> skip;
		_ ->  
			FinalBattle = fun_agent_property:get_on_battle_final_property(Uid, EntourageId),
			fun_agent:handle_to_scene(mod_scene_entourage, {scene_battle_change,[{EntourageId,FinalBattle}]})
	end.

update_all_on_battle_hero_property(Uid) -> 
	Fun = fun({EId, _, _}) ->
		{EId, fun_agent_property:get_on_battle_final_property(Uid, EId)}
	end,
	List = [Fun(T) || T <- get_battle_entourage(Uid)],
	fun_agent:handle_to_scene(mod_scene_entourage, {scene_battle_change,List}).

req_entourage_illustration(Uid, Sid, Seq) ->
	send_illustration_to_client(Uid, Sid, Seq).

update_hero_illustration(Uid, Type, Star) ->
	case data_entourage_illustration:get_data(Type, Star) of
		0 -> skip;
		_ ->
			List = fun_usr_misc:get_misc_data(Uid, hero_illustration),
			Fun = fun({Type1, _}) ->
				if
					Type == Type1 -> true;
					true -> false
				end
			end,
			List1 = lists:filter(Fun, List),
			case lists:keyfind(Star, 2, List1) of
				false ->
					NewList = [{Type, Star} | List],
					fun_usr_misc:set_misc_data(Uid, hero_illustration, NewList);
				_ -> skip
			end
	end.

send_illustration_to_client(Uid, Sid, Seq) ->
	List = fun_usr_misc:get_misc_data(Uid, hero_illustration),
	Fun = fun({Etype,Star}) ->
		#pt_public_illustration_info{
			type = Etype,
			star = Star
		}
	end,
	Pt = #pt_hero_illustration{
		hero_illustration_list = lists:map(Fun, List)
	},
	?send(Sid, proto:pack(Pt, Seq)).

% %% 发送当前的出战列表
% send_on_battle_heros(Uid, Sid, Seq) ->
% 	List = util_pt:make_on_battle_pt(get_battle_entourage(Uid)),
% 	Pt = #pt_on_battle_heros{heros = List},
% 	?send(Sid, proto:pack(Pt, Seq)).