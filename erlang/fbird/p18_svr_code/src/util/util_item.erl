%% @doc 与物品相关的一些方法
-module (util_item).
-include("common.hrl").
-export ([
	init_equip_rand_prop/2, add_log_way_to_items/2, get_item_lv/1, 
	check_item_cost_by_fun/3, get_item_name_with_color/1, get_item_rec_and_sort/2
]).


%% 根据颜色获取随机属性条数
get_random_prop_num(?COLOR_WHITE) -> 0; 
get_random_prop_num(?COLOR_GREEN) -> 1;
get_random_prop_num(?COLOR_BLUE) -> 2;
get_random_prop_num(?COLOR_PURPLE) -> 3;
get_random_prop_num(?COLOR_ORANGE) -> 4;
get_random_prop_num(?COLOR_RED) -> 4.


%% 根据物品类型获取根据物品名字以及根据物品品质获取物品颜色，这个颜色用于改变物品颜色
get_item_name_with_color(Type) ->
	ItemName = util_lang:get_item_name(Type),
	#st_item_type{color=Quailty} = data_item:get_data(Type),
	Color = data_item_quality:get_data(Quailty),
	"<color=#" ++ Color ++ ">" ++ ItemName ++ "</color>".

%% 根据颜色和属性等级获取初始时装备的随机属性id
init_equip_rand_prop(Color, PropLv) ->
	PropIdList = data_equ_config:get_prop_ids_by_lv(PropLv),
	init_equip_rand_prop2(PropIdList, get_random_prop_num(Color), [], []).


init_equip_rand_prop2(PropIdList, Num, AccId, AccType) when Num > 0 -> 
	{PropId, LeftList} = util_list:rand_taken(PropIdList),
	{PropType, _Val} = data_equ_config:get_prop(PropId),
	case lists:member(PropType, AccType) of
		true -> 
			init_equip_rand_prop2(LeftList, Num, AccId, AccType);
		false ->
			init_equip_rand_prop2(LeftList, Num - 1, [PropId | AccId], [PropType | AccType])
	end;
init_equip_rand_prop2(_PropIdList, _Num, AccId, _AccType) -> AccId.


%% 把物品日志添加到Items里面tuple元素的最前面
add_log_way_to_items(Way, Items) -> 
	[list_to_tuple([Way | tuple_to_list(T)]) || T <- Items].


get_item_lv(Type) ->
	#st_item_type{req_lev = Lv} = data_item:get_data(Type),
	Lv.


%% 获取物品record和sort
get_item_rec_and_sort(Uid, ItemId) ->
	case fun_item_api:get_item_by_id2(Uid, ItemId) of
		[Rec = #item{type = Type}] -> 
			{Rec, fun_item_api:get_item_sort(Type)};
		_ -> 
			{undefined, undefined}
	end.

%% 检查消耗是否匹配，如果不匹配则返回：fase，匹配则返回：{[{CostItemId, 数量}], LeftProvideItemRecList}
%% ProvideItemRecList:[#item{}]，提供的用于消耗的物品列表数据
%% NeedList:[NeedTuple]，注意NeedTuple里的消耗数量不能为0，如果为0，需要在传进来时过滤掉
%% CostFun:比较时用的方法：fun(ItemRec, NeedTuple) 需要返回值为：
%%		no_match:不匹配
%%		{used, LeftNum}:完成匹配消耗，ItemRec还剩下几个或者不剩
%%		{used_out, NeedTuple2}:完成匹配，ItemRec都消耗没有了，还有的剩余要继续消耗
check_item_cost_by_fun(ProvideItemRecList, NeedList, CostFun) ->
	check_item_cost_by_fun2(ProvideItemRecList, NeedList, CostFun, []).

check_item_cost_by_fun2(ProvideItemRecList, [NeedTuple | Rest], CostFun, AccCost) -> 
	case check_item_cost_by_fun3(ProvideItemRecList, NeedTuple, CostFun, [], []) of
		{[], _} -> false;
		{Cost, LeftProvideItemRecList} -> 
			check_item_cost_by_fun2(LeftProvideItemRecList, Rest, CostFun, Cost ++ AccCost)
	end;
check_item_cost_by_fun2(ProvideItemRecList, [], _CostFun, AccCost) ->
	{AccCost, ProvideItemRecList}.


check_item_cost_by_fun3([ItemRec = #item{id = Id} | Rest], NeedTuple, CostFun, Acc, LeftAcc) -> 
	case CostFun(ItemRec, NeedTuple) of
		no_match -> %% 不匹配
			check_item_cost_by_fun3(Rest, NeedTuple, CostFun, Acc, [ItemRec | LeftAcc]);
		{used, LeftNum} -> %% 完成匹配消耗，ItemRec还剩下几个或者不剩
			case LeftNum of
				0 -> LeftAcc2 = LeftAcc;
				_ -> LeftAcc2 = [ItemRec#item{num = LeftNum} | LeftAcc]
			end,
			{[{{item_id, Id}, ItemRec#item.num - LeftNum} | Acc], LeftAcc2 ++ Rest};
		{used_out, NeedTuple2} -> %% 完成匹配，ItemRec都消耗没有了，还有的剩余要继续消耗
			Acc2 = [{{item_id, Id}, ItemRec#item.num} | Acc],
			check_item_cost_by_fun3(Rest, NeedTuple2, CostFun, Acc2, LeftAcc)
	end;
check_item_cost_by_fun3([], _NeedTuple, _CostFun, Acc, LeftAcc) -> 
	{Acc, LeftAcc}.

