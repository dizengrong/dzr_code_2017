%% -*- coding: latin-1 -*-
%% @doc 属性模块
%% todo:以后改为全部动态计算，不在缓存每个模块的属性
-module(fun_agent_property).
-include("common.hrl").
-export([
	init_property_bank/2,add_prop/3,
	send_update_base/2,get_final_property/2,
	all_module_property/2,get_fighting/1,add_prop_when_change_equip/5,
	get_attr_gs/1,get_on_battle_final_property/2,add_prop_when_change_fuwen_equip/4,
	update_all_cached_hero_prop/2, update_all_cached_hero_prop/3
]).

-define (ALL_HERO_PROP_CLASS, [
	{prop_class_base, "基础属性"},
	{prop_class_lev, "等级属性"},
	{prop_class_grade, "品级属性"},
	{prop_class_star, "星级属性"},
	{prop_class_skill, "技能属性"},
	{prop_class_item, "装备属性"},
	{prop_class_item_suit, "装备套装属性"},
	{prop_class_fuwen, "符文装备属性"},
	{prop_class_guild_tec, "公会科技属性"}
]).

% -define (ALL_GS_CLASS, [
% 	gs_class_skill,
% 	gs_class_inscription
% ]).

% -define (ALL_EQUIP_CLASS,[
% 	prop_class_item,
% 	prop_class_item_suit
% ]).

%%登录处理
init_property_bank(Uid, EntourageId) ->
	BattleProperty = recacl_property(Uid, EntourageId, true),
	FinalProperty = cacl_final_property(BattleProperty),
	put({battle_prop, EntourageId}, BattleProperty),
	init_gs(EntourageId, FinalProperty),
	FinalProperty1 = fun_property:property_add(FinalProperty, #battle_property{gs = get_fighting(EntourageId)}),	%%	新增战力属性,不在属性模块里面,而是通过计算获取的
	mod_entourage_property:set_entourage_prop(EntourageId, FinalProperty1),
	put({final_battle_prop, EntourageId}, FinalProperty1),
	FinalProperty1.

%% 重算属性，返回:#battle_property{}
recacl_property(Uid, EntourageId, SetProp) ->
	Fun = fun({Class, _}, Acc) -> 
		Props = prop_class(Uid, EntourageId, Class),
		SetProp andalso set_prop_class(EntourageId, Class, Props),
		fun_property:property_add(Acc, Props)
	end,
	lists:foldl(Fun, #battle_property{}, ?ALL_HERO_PROP_CLASS).


%% 计算最终的属性
cacl_final_property(Rec) ->
	Rec#battle_property{
		atk            = Rec#battle_property.atk + util:floor(Rec#battle_property.atk_percent * Rec#battle_property.atk / 10000),
		hpLimit        = Rec#battle_property.hpLimit + util:floor(Rec#battle_property.hp_percent * Rec#battle_property.hpLimit / 10000),
		mpLimit        = Rec#battle_property.mpLimit + util:floor(Rec#battle_property.mp_percent * Rec#battle_property.mpLimit / 10000),
		realdmg        = Rec#battle_property.realdmg + util:floor(Rec#battle_property.realdmg_percent * Rec#battle_property.realdmg / 10000),
		dmgdown        = Rec#battle_property.dmgdown + util:floor(Rec#battle_property.dmgdown_percent * Rec#battle_property.dmgdown / 10000),
		defignore      = Rec#battle_property.defignore + util:floor(Rec#battle_property.defignore_percent * Rec#battle_property.defignore / 10000),
		def            = Rec#battle_property.def + util:floor(Rec#battle_property.def_percent * Rec#battle_property.def / 10000),
		cri            = Rec#battle_property.cri + util:floor(Rec#battle_property.cri_percent * Rec#battle_property.cri / 10000),
		cridown        = Rec#battle_property.cridown + util:floor(Rec#battle_property.cridown_percent * Rec#battle_property.cridown / 10000),
		hit            = Rec#battle_property.hit + util:floor(Rec#battle_property.hit_percent * Rec#battle_property.hit / 10000),
		dod            = Rec#battle_property.dod + util:floor(Rec#battle_property.dod_percent * Rec#battle_property.dod / 10000),
		cridmg         = Rec#battle_property.cridmg + util:floor(Rec#battle_property.cridmg_percent * Rec#battle_property.cridmg / 10000),
		toughness      = Rec#battle_property.toughness + util:floor(Rec#battle_property.toughness_percent * Rec#battle_property.toughness / 10000),
		blockrate      = Rec#battle_property.blockrate + util:floor(Rec#battle_property.blockrate_percent * Rec#battle_property.blockrate / 10000),
		breakdef       = Rec#battle_property.breakdef + util:floor(Rec#battle_property.breakdef_percent * Rec#battle_property.breakdef / 10000),
		breakdefrate   = Rec#battle_property.breakdefrate + util:floor(Rec#battle_property.breakdefrate_percent * Rec#battle_property.breakdefrate / 10000),
		blockdmgrate   = Rec#battle_property.blockdmgrate + util:floor(Rec#battle_property.blockdmgrate_percent * Rec#battle_property.blockdmgrate / 10000),
		dmgrate        = Rec#battle_property.dmgrate + util:floor(Rec#battle_property.dmgrate_percent * Rec#battle_property.dmgrate / 10000),
		dmgdownrate    = Rec#battle_property.dmgdownrate + util:floor(Rec#battle_property.dmgdownrate_percent * Rec#battle_property.dmgdownrate / 10000),
		contorlrate    = Rec#battle_property.contorlrate + util:floor(Rec#battle_property.contorlrate_percent * Rec#battle_property.contorlrate / 10000),
		contorldefrate = Rec#battle_property.contorldefrate + util:floor(Rec#battle_property.contorldefrate_percent * Rec#battle_property.contorldefrate / 10000),
		movespd        = Rec#battle_property.movespd + util:floor(Rec#battle_property.movespd_percent * Rec#battle_property.movespd / 10000),
		limitdmg       = Rec#battle_property.limitdmg + util:floor(Rec#battle_property.limitdmg_percent * Rec#battle_property.limitdmg / 10000)
	}.

all_module_property(Uid, EntourageId) ->
	Fun = fun(Class, ClassDesc) -> 
		{ClassDesc, get_prop_class(Uid, EntourageId, Class)}
	end,
	[Fun(Class, ClassDesc) || {Class, ClassDesc} <- ?ALL_HERO_PROP_CLASS].


prop_class(Uid, EntourageId, prop_class_guild_tec) ->
	fun_property:to_property_rec(mod_guild_technology:get_add_attr(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_fuwen) ->
	fun_property:to_property_rec(mod_fuwen_equip:get_loaded_equips_attr(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_base) ->
	fun_property:to_property_rec(fun_entourage:get_base_prop(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_lev) ->
	fun_property:to_property_rec(fun_entourage:get_lev_prop(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_grade) ->
	fun_property:to_property_rec(fun_entourage:get_grade_prop(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_star) ->
	fun_property:to_property_rec(fun_entourage:get_star_prop(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_skill) ->
	fun_property:to_property_rec(fun_entourage:get_skill_prop(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_item) -> 
	fun_property:to_property_rec(mod_entourage_equipment:get_equip_prop(Uid, EntourageId));
prop_class(Uid, EntourageId, prop_class_item_suit) -> 
	fun_property:to_property_rec(mod_entourage_equipment:get_equip_suit_prop(Uid, EntourageId)).

set_prop_class(EntourageId, PropClass, Props) ->
	case get({prop_list, EntourageId}) of
		undefined -> put({prop_list, EntourageId}, #{PropClass => Props});
		PropMaps -> put({prop_list, EntourageId}, maps:put(PropClass, Props, PropMaps))
	end.
get_prop_class(Uid, EntourageId, PropClass) ->
	case get({prop_list, EntourageId}) of
		undefined ->
			init_property_bank(Uid, EntourageId),
			get_prop_class(Uid, EntourageId, PropClass);
		PropMaps -> maps:get(PropClass, PropMaps, #battle_property{})
	end.

init_gs(EntourageId, FinalProperty) -> 
	Attrs = fun_property:property_get_data_by_type(FinalProperty),
	set_fighting(EntourageId, get_attr_gs(Attrs)).

update_gs_by_attr(EntourageId, DiffProps)->
	Gs = get_attr_gs(DiffProps) + get_fighting(EntourageId),
	set_fighting(EntourageId, Gs),
	ok.

get_attr_gs(Attrs) ->
	Fun = fun({ValId,Val},Acc)->
		Multi = data_prop:get_data(ValId),
		Val * Multi + Acc
	end,
	lists:foldl(Fun, 0, Attrs).


%%获取总属性（非最终属性）
get_total_property(Uid, EntourageId) ->
	case get({battle_prop,EntourageId}) of
		undefined -> 
			init_property_bank(Uid, EntourageId),
			get({battle_prop,EntourageId});
		Battle -> Battle
	end.
	
%%获取最终属性
get_final_property(Uid, EntourageId) ->
	case get({final_battle_prop,EntourageId}) of
		undefined -> init_property_bank(Uid, EntourageId);
		Battle -> Battle
	end.

%%获取战力 
get_fighting(EntourageId) ->
	case ?DEBUG_MODE of
		true -> get({battle_fighting, EntourageId}) + util_misc:get_process_dict(gm_fighting,0);
		_ -> get({battle_fighting, EntourageId})
	end.
set_fighting(EntourageId, Gs) ->
	put({battle_fighting, EntourageId}, Gs).
	
%%这个只更新玩家的属性（不含资源更新，资源更新有单独的协议）
send_update_base(Uid,PropList)->
	Fun=fun({ProID,ProVal}) ->
		Sort = fun_property:get_property_sort(ProID),
		#pt_public_property{data=ProVal,sort=Sort,type=ProID}
	end,		
	PropList1=lists:map(Fun, PropList),
	Pt = #pt_update_base{property_list=PropList1,uid=Uid},
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] -> 
			?send(Sid,proto:pack(Pt));
		_ -> skip
	end.

%% 有些属性类别是一更新，就给所有的英雄加属性的，因此要更新所有已计算了属性的英雄
%% SpecialProf:all(所有职业都更新)，传职业1,2,3,4则只更新指定职业的英雄
update_all_cached_hero_prop(Uid, PropClass) ->
	update_all_cached_hero_prop(Uid, PropClass, all).
update_all_cached_hero_prop(Uid, PropClass, SpecialProf) ->
	Heros = fun_item_api:get_entourage_items(Uid),
	Fun = fun(#item{id = EntourageId, type = Type}) ->
		#st_entourage_config{profession = Prof} = data_entourage:get_data(Type),
		case get({prop_list, EntourageId}) of
			undefined -> skip;
			_ -> 
				case SpecialProf == all orelse SpecialProf == Prof of
					true -> 
						add_prop(Uid, EntourageId, PropClass, false);
					_ -> skip
				end
		end
	end,
	[Fun(I) || I <- Heros],
	ok.

%% 装备属性的差异计算不经过这个方法处理！
add_prop(Uid, EntourageId, PropClass) -> 
	add_prop(Uid, EntourageId, PropClass, true).
add_prop(Uid, EntourageId, PropClass, SendPt) -> 
	NewProps = prop_class(Uid, EntourageId, PropClass),
	OldProps = get_prop_class(Uid, EntourageId, PropClass),
	set_prop_class(EntourageId, PropClass, NewProps),
	DiffProps = fun_property:property_minus(NewProps, OldProps),
	add_prop_help(Uid, EntourageId, PropClass, DiffProps, SendPt).

%% 英雄穿戴装备改变属性差异计算
add_prop_when_change_equip(Uid, EntourageId, EType, LoadedItem, UnloadItem) -> 
	AddAttr = case LoadedItem of
		undefined -> #battle_property{};
		_ -> fun_property:to_property_rec(mod_entourage_equipment:cacl_equip_attr(Uid, EType, LoadedItem))
	end,
	MinusAttr = case UnloadItem of
		undefined -> #battle_property{};
		_ -> fun_property:to_property_rec(mod_entourage_equipment:cacl_equip_attr(Uid, EType, UnloadItem))
	end,
	PropClass = prop_class_item,
	DiffProps = fun_property:property_minus(AddAttr, MinusAttr),
	OldProps = get_prop_class(Uid, EntourageId, PropClass),
	NewProps = fun_property:property_add(OldProps, DiffProps),
	set_prop_class(EntourageId, PropClass, NewProps),
	add_prop_help(Uid, EntourageId, PropClass, DiffProps, true).


add_prop_when_change_fuwen_equip(Uid, EntourageId, LoadedItem, UnloadItem) -> 
	AddAttr = case LoadedItem of
		undefined -> #battle_property{};
		_ -> fun_property:to_property_rec(mod_fuwen_equip:cacl_equip_attr(LoadedItem))
	end,
	MinusAttr = case UnloadItem of
		undefined -> #battle_property{};
		_ -> fun_property:to_property_rec(mod_fuwen_equip:cacl_equip_attr(UnloadItem))
	end,
	PropClass = prop_class_fuwen,
	DiffProps = fun_property:property_minus(AddAttr, MinusAttr),
	OldProps = get_prop_class(Uid, EntourageId, PropClass),
	NewProps = fun_property:property_add(OldProps, DiffProps),
	set_prop_class(EntourageId, PropClass, NewProps),
	add_prop_help(Uid, EntourageId, PropClass, DiffProps, true).


add_prop_help(Uid, EntourageId, PropClass, DiffProps, SendPt) ->
	DiffList = [{P, Val} || {P, Val} <- fun_property:property_get_data_by_type(DiffProps), Val /=0],
	case DiffList of
		[] -> skip;
		_  -> 
			TotalProps = get({battle_prop,EntourageId}),
			NewTotalProps = fun_property:property_add(TotalProps, DiffProps),
			NewTotalFinalProps = cacl_final_property(NewTotalProps),
			put({battle_prop,EntourageId}, NewTotalProps), 
			OldFinalProps = get({final_battle_prop, EntourageId}), 
			DiffList2 = cacl_new_diff_property_list(DiffList, NewTotalFinalProps, OldFinalProps),
			update_gs_by_attr(EntourageId, DiffList2),
			NewTotalFinalProps1 = fun_property:property_add(NewTotalFinalProps, #battle_property{gs = get_fighting(EntourageId)}),
			put({final_battle_prop, EntourageId}, NewTotalFinalProps1),
			mod_entourage_property:set_entourage_prop(EntourageId, NewTotalFinalProps1),
			fun_entourage:on_entourage_battle_change(Uid, get(sid), EntourageId),
			SendPt andalso send_prop_diff_to_client(get(sid), DiffList2),
			?DEBUG_MODE andalso test_property_is_right(Uid, EntourageId, PropClass, NewTotalProps)
	end,
	ok.

%% 因为存在百分比属性，因此需要重新算差异属性列表
cacl_new_diff_property_list(DiffList, NewProps, OldProps) ->
	List = [
		{?PROPERTY_ATK, NewProps#battle_property.atk - OldProps#battle_property.atk},
		{?PROPERTY_HPLIMIT, NewProps#battle_property.hpLimit - OldProps#battle_property.hpLimit},
		{?PROPERTY_MPLIMIT, NewProps#battle_property.mpLimit - OldProps#battle_property.mpLimit},
		{?PROPERTY_REALDMG, NewProps#battle_property.realdmg - OldProps#battle_property.realdmg},
		{?PROPERTY_DMGDOWN, NewProps#battle_property.dmgdown - OldProps#battle_property.dmgdown},
		{?PROPERTY_DEFIGNORE, NewProps#battle_property.defignore - OldProps#battle_property.defignore},
		{?PROPERTY_DEF, NewProps#battle_property.def - OldProps#battle_property.def},
		{?PROPERTY_CRI, NewProps#battle_property.cri - OldProps#battle_property.cri},
		{?PROPERTY_CRIDOWN, NewProps#battle_property.cridown - OldProps#battle_property.cridown},
		{?PROPERTY_HIT, NewProps#battle_property.hit - OldProps#battle_property.hit},
		{?PROPERTY_DOD, NewProps#battle_property.dod - OldProps#battle_property.dod},
		{?PROPERTY_CRIDMG, NewProps#battle_property.cridmg - OldProps#battle_property.cridmg},
		{?PROPERTY_TOUGHNESS, NewProps#battle_property.toughness - OldProps#battle_property.toughness},
		{?PROPERTY_BLOCKRATE, NewProps#battle_property.blockrate - OldProps#battle_property.blockrate},
		{?PROPERTY_BREAKDEF, NewProps#battle_property.breakdef - OldProps#battle_property.breakdef},
		{?PROPERTY_BREAKDEFRATE, NewProps#battle_property.breakdefrate - OldProps#battle_property.breakdefrate},
		{?PROPERTY_BLOCKDMGRATE, NewProps#battle_property.blockdmgrate - OldProps#battle_property.blockdmgrate},
		{?PROPERTY_DMGRATE, NewProps#battle_property.dmgrate - OldProps#battle_property.dmgrate},
		{?PROPERTY_DMGDOWNRATE, NewProps#battle_property.dmgdownrate - OldProps#battle_property.dmgdownrate},
		{?PROPERTY_CONTORLRATE, NewProps#battle_property.contorlrate - OldProps#battle_property.contorlrate},
		{?PROPERTY_CONTORLDEFRATE, NewProps#battle_property.contorldefrate - OldProps#battle_property.contorldefrate},
		{?PROPERTY_MOVESPD, NewProps#battle_property.movespd - OldProps#battle_property.movespd},
		{?PROPERTY_LIMITDMG, NewProps#battle_property.limitdmg - OldProps#battle_property.limitdmg}
	], 
	cacl_new_diff_property_list2(DiffList, List).

cacl_new_diff_property_list2(DiffList, [{AttrId, Val} | Rest]) -> 
	DiffList2 = case Val of
		0 -> DiffList;
		_ -> lists:keystore(AttrId, 1, DiffList, {AttrId, Val})
	end,
	cacl_new_diff_property_list2(DiffList2, Rest);
cacl_new_diff_property_list2(DiffList, []) -> DiffList. 


test_property_is_right(Uid, EntourageId, PropClass, NewTotalProps) ->
	RightTotalProps = recacl_property(Uid, EntourageId, false),
	case NewTotalProps of
		RightTotalProps -> ok;
		_ -> 
			Format = "diff calc property is not right:~n\tPropClass:~p~n\tdiff result:~p~n\tright result:~p",
			?ERROR(Format, [PropClass, NewTotalProps, RightTotalProps]),
			?error_report(get(sid), "test_property_wrong")
	end.


%% 获取上阵英雄的最终属性
get_on_battle_final_property(Uid, EntourageId) ->
	%% 算上阵法属性
	TotalProps = get_total_property(Uid, EntourageId),
	Fun1 = fun(ZhenfaId, Acc) -> 
		fun_property:add_attrs_to_property(Acc, data_zhenfa:get_zhenfa_attr(ZhenfaId))
	end,
	TotalProps2 = lists:foldl(Fun1, TotalProps, fun_entourage_zhenfa:get_actived_zhenfa(Uid)),
	%% 算上神器属性
	TotalProps3 = fun_property:add_attrs_to_property(TotalProps2, fun_shenqi:get_shenqi_attrs(Uid)),
	cacl_final_property(TotalProps3).

send_prop_diff_to_client(Sid, DiffList) ->
	Fun = fun({Type, Val}, Acc) ->
		case lists:member(Type, ?BASE_PROPERTY_LIST) of
			true -> [#pt_public_property_list{propertyId  = Type, propertyVal = Val} | Acc];
			_ -> Acc
		end
	end,
	Pt = #pt_entourage_property{property_list = lists:foldl(Fun, [], DiffList)},
	?send(Sid, proto:pack(Pt)).