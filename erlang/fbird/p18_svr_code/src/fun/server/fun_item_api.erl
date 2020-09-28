%% @doc 新的物品接口
-module (fun_item_api).
-include("common.hrl").
-export ([check_and_add_items/4, check_and_add_items/6, check_and_add_items/7, add_items/4]).
-export ([make_item_get_pt/1,make_item_get_pt/2,make_item_get_pt/3]).
-export ([items_multiply/2, filter_item_by_type/2]).
-export ([get_free_pos_num/1,get_free_artifact_pos_num/1]).
-export ([make_item_pt_list/1, get_entourage_items/1]).
-export ([send_show_fetched_reward/4,send_show_fetched_reward/5,send_show_fetched_reward/6]).
-export ([get_all_items/1, get_item_by_id/2, get_item_by_id2/2, get_item_sort/1, get_item_lev/2, update_item/2, filter_items/2, get_default_star/1]).


%% 更新玩家的物品
update_item(Uid, Rec) -> 
	mod_role_tab:insert(Uid, Rec).

filter_item_by_type(Uid, Type) ->
	Items = get_all_items(Uid),
	Fun   = fun(Item) -> Item#item.type == Type end,
	lists:filter(Fun, Items).

filter_item_by_sort(Uid, Sort) ->
	Items = get_all_items(Uid),
	Fun   = fun(Item) -> get_item_sort(Item#item.type) == Sort end,
	lists:filter(Fun, Items).

filter_item_by_sort_list(Uid, SortList) ->
	Items = get_all_items(Uid),
	Fun   = fun(Item) -> lists:member(get_item_sort(Item#item.type), SortList) end,
	lists:filter(Fun, Items).


%% 过滤出需要的物品，如果FilterFun(ItemRec)返回true
filter_items(Uid, FilterFun) ->
	ItemKeys = mod_role_tab:lookup(Uid, item),
	Fun = fun(Key, Acc) -> 
		Item = hd(mod_role_tab:lookup(Uid, {item, Key})),
		case FilterFun(Item) of
			true -> [Item | Acc];
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], ItemKeys).


get_all_items(Uid) ->
	ItemKeys = mod_role_tab:lookup(Uid, item),
	[hd(mod_role_tab:lookup(Uid, {item, Key})) || Key <- ItemKeys].


%% 返回的是列表：Rec
get_item_by_id(Uid, ItemID) ->
	hd(mod_role_tab:lookup(Uid, {item, ItemID})).

%% 返回的是列表：[]|[Rec]
get_item_by_id2(Uid, ItemID) ->
	mod_role_tab:lookup(Uid, {item, ItemID}).

get_entourage_items(Uid) ->
	filter_item_by_sort(Uid, ?ITEM_TYPE_ENTOURAGE).

get_artifact_items(Uid) ->
	filter_item_by_sort(Uid, ?ITEM_TYPE_ARTIFACT).

get_rune_items(Uid) ->
	filter_item_by_sort_list(Uid, ?FUWEN_ALL_POS).

get_item_sort(Type) ->
	#st_item_type{sort = Sort} = data_item:get_data(Type),
	Sort.

get_item_lev(Uid, ItemId) ->
	case mod_role_tab:lookup(Uid, {item, ItemId}) of
		[#item{lev = Lev}] -> Lev;
		_ -> 0
	end.

get_default_star(Type) ->
	case data_item:get_data(Type) of
		#st_item_type{default_star = Star} -> Star;
		_ -> 0
	end.

%% 该方法同check_and_add_items，只不过使用Args来传递参数，即为它的一个封装而已，但是调用方便了
%% Args:#api_item_args{}
%% 注意:#api_item_args.add和#api_item_args.spend里不用传物品日志Way了
add_items(Uid, Sid, Seq, Args) ->
	Way = Args#api_item_args.way,
	SuccCallBack = Args#api_item_args.succ_fun,
	FailCallBack = Args#api_item_args.fail_fun,
	SendErrorTip = Args#api_item_args.send_error_tips,
	AddItems = [list_to_tuple([Way | tuple_to_list(Tuple)])  || Tuple <- Args#api_item_args.add],
	SpendItems = [list_to_tuple([Way | tuple_to_list(Tuple)])  || Tuple <- Args#api_item_args.spend],
	check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, FailCallBack, SendErrorTip, Seq).


%% 检测并增加物品（在失败时会通知客户端）
%% 先会扣除SpendItems，然后在增加AddItems
% AddItems格式如下:
% [{Way, Type}]
% [{Way, Type, Num}]
% [{Way, Type, Num, Color}]
% [{Way, Type, Num, Color, Bind}]
% [{Way, Type, Num, Color, Bind, ExtraData}]
% 其中当Type参数为{item_id, ItemID}时表示加一个已存在item表中的世界物品
% Bind::boolean()

% ExtraData为一个列表([{key, Value}])，用来设置物品的一些其他数据，目前支持：
% 		{strengthen_lev, Lev}:设置强化等级
% 		{special_lv, Lev}:设置神装、圣装
% 		{get_from, GetFrom}:设置来源
% 		{pos, Pos}:设置位置
% 		{random_prop, {P1, P2, P3, P4}}:设置装备的随机属性

% SpendItems(消耗物品列表)格式:(注意下面两种方式不能同时并存传递进来的！)
% 		[{Way, Type, Num}]:根据type来消耗物品
% 		[{Way, {item_id, ItemId}, Num}]:根据item_id来消耗物品
% SuccCallBack:
%		如果这个参数为一个is_function(SuccCallBack, 0)，则在成功后会回调
%		如果这个参数为一个is_function(SuccCallBack, 2)，则在成功后会回调
%  		参数1:NewAddItemRecList 参数2: ModifyItemRecList
% 		不需要则可以填:undefined
% FailCallBack:
%		如果这个参数为一个is_function(FailCallBack, 0)，则在失败后会回调
% 		不需要则可以填:undefined
% SendErrorTip:
% 		是否发送错误提示
check_and_add_items(Uid, Sid, SpendItems, AddItems) ->
	check_and_add_items(Uid, Sid, SpendItems, AddItems, undefined, undefined).
check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, FailCallBack) ->
	check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, FailCallBack, true).
check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, FailCallBack, SendErrorTip) ->
	check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, FailCallBack, SendErrorTip, 0).
check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, FailCallBack, SendErrorTip, Seq) ->
	% ?debug("check_and_add_items,Uid=~p,AddItems=~p",[Uid, AddItems]),
	AddItems2 = normalize_items(AddItems),
	AddItems3 = merge_normalized_items(AddItems2),
	% ?debug("AddItems3:~p", [AddItems3]),
	ItemRecList = get_all_items(Uid),
	case check_and_add_items2(Uid, ItemRecList, SpendItems, AddItems3) of
		{error, Reason} ->
			SendErrorTip andalso ?error_report(Sid, Reason, Seq),
			?_IF(is_function(FailCallBack, 0), FailCallBack(), ok);
		{error, Reason, ReasonData} ->
			SendErrorTip andalso ?error_report(Sid, Reason, Seq, ReasonData),
			?_IF(is_function(FailCallBack, 0), FailCallBack(), ok);
		{ok, ModifyItemRecList, NewAddItemRecList, AddResourcesList} ->
			SpendItems2 = [T || T = {_Way, _T, N} <- SpendItems, N /= 0],
			del_spend_items(Uid, Sid, SpendItems2), %% 这个方法会合并改变的物品，然后只会发一个物品改变协议给前端

			[fun_resoure:add_resoure(Uid, T, N, Way) || {Way, T, N, _, _, _} <- AddResourcesList],
			[mod_role_tab:insert(Uid, I) || I <- ModifyItemRecList],
			NewAddItemRecList2 = lists:flatten([mod_role_tab:insert(Uid, I) || I <- NewAddItemRecList]),

			fun_item:send_items_to_sid(Uid, Sid, ModifyItemRecList ++ NewAddItemRecList2),
			on_add_item_event(Uid, Sid, [{T, N, W} || {W, T, N, _, _, _} <- AddItems3], SpendItems),
			% [on_auto_use_item(Uid, Sid, I) || I <- NewAddItemRecList2],
			if
				is_function(SuccCallBack, 0) -> SuccCallBack();
				is_function(SuccCallBack, 2) -> SuccCallBack(NewAddItemRecList2, ModifyItemRecList);
				true -> skip
			end
	end.

on_add_item_event(Uid, Sid, AddItemList, SpendItems) ->
	[on_add_item_event2(Uid, Sid, Item) || Item <- AddItemList],
	AddItemList2 = [{Type, Num} || {Type, Num, _From} <- AddItemList, is_integer(Type)],
	case AddItemList of
		[{_Type, _Num, From} | _] -> 
			report_item_ex(Uid, make_report_item_str(AddItemList2), 1, From);
		_ -> skip
	end,

	SpendItems2 = [{Type, -Num} || {_From, Type, Num} <- SpendItems, is_integer(Type)],
	case SpendItems of
		[{From2, _, _} | _] -> 
			report_item_ex(Uid, make_report_item_str(SpendItems2), -1, From2);
		_ -> skip
	end,
	[on_spend_item_event(Uid, Sid, Type, -Num) || {Type, Num} <- SpendItems2],
	ok.

on_spend_item_event(_Uid, _Sid, _Type, _Num) -> 
	% fun_resoure:check_resouce(Type) orelse fun_count:on_count_event(Uid, Sid, ?TASK_COST_ITEM, Type, Num),
	ok.

%% 注意金币和钻石有单独的上报的，这里只上报物品的
make_report_item_str(List) ->
	make_report_item_str(List, "").
make_report_item_str([{Type, _Num} | Rest], Acc) when Type == ?RESOUCE_COPPER_NUM orelse 
													  Type == ?RESOUCE_COIN_NUM orelse
													  Type == ?RESOUCE_EXP_NUM orelse
													  Type == ?RESOUCE_BINDING_COIN_NUM ->
	make_report_item_str(Rest, Acc);
make_report_item_str([{Type, Num} | Rest], Acc) ->
	case data_item:get_data(Type) of
		#st_item_type{} -> 
			Acc2 = [lists:concat([Type, ":", Num]) | Acc], 
			make_report_item_str(Rest, Acc2);
		_ -> make_report_item_str(Rest, Acc)
	end;
make_report_item_str([], Acc) -> 
	string:join(Acc, "|").

on_add_item_event2(_Uid, _Sid, {_Type, _Num, _Way}) -> 
	% fun_resoure:check_resouce(Type) orelse fun_count:process_count_event(acquire_item, {0,Type,Num}, Uid, Sid),
	ok.


del_spend_items(Uid, Sid, SpendItems) -> 
	Pred = fun({_Way, T, _N}) -> 
		case T of
			{item_id, _ItemId} -> true;
			_ -> false
		end
	end,
	{DelByIdList, DelByTypeLis} = lists:partition(Pred, SpendItems),
	DelByIdList /= [] andalso del_items_by_ids_without_check(Uid, Sid, DelByIdList),
	DelByTypeLis /= [] andalso del_items_by_types_without_check(Uid, Sid, DelByTypeLis),
	SpendItems /= [] andalso fun_item:send_backpack_is_full_bank(Uid),
	ok.


%% 以物品唯一id来直接删除，不需要再检查数量问题，这里不要上报日志，其他地方已处理了的
del_items_by_ids_without_check(Uid, Sid, DelByIdList) -> 
	Fun = fun({_Way, {item_id, ItemID}, Num}, Acc) -> 
		case get_item_by_id2(Uid, ItemID) of
			[ItemRec = #item{num=OwnNum}] -> 
				if 
					OwnNum =< Num ->
						NewItem = ItemRec#item{num=0},
						mod_role_tab:delete(Uid, NewItem),
						[{ItemID, 0} | Acc];
					true ->
						NewItem = ItemRec#item{num=OwnNum-Num},
						update_item(Uid, NewItem),
						[{ItemID, NewItem#item.num} | Acc]
				end;
			_ -> Acc
		end
	end,
	ChangedList = lists:foldl(Fun, [], DelByIdList),
	send_item_change_pt(Uid, Sid, ChangedList).


%% 以物品type来直接删除，不需要再检查数量问题，这里不要上报日志，其他地方已处理了的
del_items_by_types_without_check(Uid, Sid, DelByTypeLis) -> 
	Fun = fun({Way, Type, NUM}, Acc) -> 
		case fun_resoure:check_resouce(Type) of
			true->
				fun_resoure:del_resoure(Uid,Type,NUM,Way),
				Acc;
			_->
				del_item_by_type_new(Uid, Type, NUM) ++ Acc
		end
	end,
	ChangedList = lists:foldl(Fun, [], DelByTypeLis),
	send_item_change_pt(Uid, Sid, ChangedList).

del_item_by_type_new(Uid, Type, Num) -> 
	Items = filter_item_by_type(Uid, Type),
	del_item_by_type_new2(Uid, Items, Num, []).

del_item_by_type_new2(Uid, [ItemRec | Rest], LeftDelNum, AccChanges) when LeftDelNum > 0 -> 
	case ItemRec#item.num > LeftDelNum of
		true -> 
			NewItem=ItemRec#item{num=ItemRec#item.num - LeftDelNum},
			update_item(Uid, NewItem),
			[{ItemRec#item.id, NewItem#item.num} | AccChanges];
		_ -> 
			mod_role_tab:delete(Uid, ItemRec),
			AccChanges2 = [{ItemRec#item.id, 0} | AccChanges],
			del_item_by_type_new2(Uid, Rest, LeftDelNum - ItemRec#item.num, AccChanges2)
	end;
del_item_by_type_new2(_Uid, _, _LeftDelNum, AccChanges) -> 
	AccChanges.

send_item_change_pt(_Uid, _Sid, []) -> skip;
send_item_change_pt(_Uid, Sid, ChangedList) ->
	%% 注意：这个协议只有现有的位于背包里（包括隐藏背包）的东西改变了才能使用
	Fun = fun({Id, Num}) -> 
		#pt_public_two_int{
			data1  = Id,
			data2 = Num
		}
	end, 
	Pt = #pt_item_num_update{datas = [Fun(T) || T <- ChangedList]},
	?send(Sid,proto:pack(Pt, 0)).


report_item_ex(_Uid, "", _Num, _Way) -> skip;
report_item_ex(Uid, ItemStr, Num, Way) -> 
	Way > 0 andalso fun_dataCount_update:item_change(Uid, ItemStr, Num, Way).

% on_auto_use_item(Uid, Sid, ItemRec) ->
% 	% ?debug("ItemRec:~p", [ItemRec]),
% 	case data_item:get_data(ItemRec#item.type) of
% 		#st_item_type{sort=206} ->
% 			fun_item:use_item(Sid, Uid, ItemRec#item.id, ItemRec#item.num, 0);
% 		_ -> skip
% 	end.

%% 获取空的英雄格子
get_free_pos_num(Uid) ->
	Max = fun_item:get_entourage_pos_num(Uid),
	Used = length(get_entourage_items(Uid)),
	Max - Used.

%% 获取空的神器格子
get_free_artifact_pos_num(Uid) ->
	Max = fun_item:get_artifact_pos_num(Uid),
	Used = length(get_artifact_items(Uid)),
	Max - Used.

%% 获取空的符文格子
get_free_rune_pos_num(Uid) ->
	Max = fun_item:get_rune_pos_num(Uid),
	Used = length(get_rune_items(Uid)),
	Max - Used.

%% ItemRecList为玩家现有的物品列表
check_and_add_items2(Uid, ItemRecList, SpendItems, AddItems) ->
	case check_item_list(Uid, SpendItems) of
		true -> 
			LeftEnNum = get_free_pos_num(Uid),
			LeftArtiNum = get_free_artifact_pos_num(Uid),
			LeftRuneNum = get_free_rune_pos_num(Uid),
			check_and_add_items3(Uid, ItemRecList, AddItems, [], [], [], LeftEnNum, LeftArtiNum, LeftRuneNum);
		Ret -> 
			% ?debug("Ret:~p", [Ret]), 
			Ret 
	end.

check_and_add_items3(_, _ItemRecList, [], ModifyList, NewAddList, ResourcesList, _LeftEnNum, _LeftArtiNum, _LeftRuneNum) ->
	{ok, ModifyList, NewAddList, ResourcesList};
check_and_add_items3(Uid, ItemRecList, [Item | Rest], ModifyList, NewAddList, ResourcesList, LeftEnNum, LeftArtiNum, LeftRuneNum) ->
	{Way, Type, Num, Color, Bind, ExtraData} = Item,
	case fun_resoure:check_resouce(Type) of
		true ->
			ResourcesList2 = [Item | ResourcesList],
			check_and_add_items3(Uid, ItemRecList, Rest, ModifyList, NewAddList, ResourcesList2, LeftEnNum, LeftArtiNum, LeftRuneNum);
		_ ->
			FunUpdateModify = fun(Rec = #item{id = Id}, Acc) ->
				lists:keystore(Id, #item.id, Acc, Rec)
			end,
			%% 首先堆叠，然后再创建新的物品
			case overlap_item(ItemRecList, Type, Num, Color, Bind, ExtraData) of
				{0, ModifyList2, ItemRecList2} -> %% 堆叠加入已有的物品中
					ModifyList3 = lists:foldl(FunUpdateModify, ModifyList, ModifyList2),
					% ModifyList3 = ModifyList2 ++ ModifyList,
					check_and_add_items3(Uid, ItemRecList2, Rest, ModifyList3, NewAddList, ResourcesList, LeftEnNum, LeftArtiNum, LeftRuneNum);
				{LeftNum, ModifyList2, ItemRecList2} -> %% 要创建新的物品，消耗格子
					case add_new_item(Uid, Way, Type, LeftNum, Color, Bind, ExtraData, LeftEnNum, LeftArtiNum, LeftRuneNum) of
						false -> {error, "bag_full_old"};
						{LeftEnNum2, LeftArtiNum2, LeftRuneNum2, NewItemList} ->
							% ModifyList3 = ModifyList2 ++ ModifyList,
							ModifyList3 = lists:foldl(FunUpdateModify, ModifyList, ModifyList2),
							NewAddList2 = NewItemList ++ NewAddList,
							check_and_add_items3(Uid, ItemRecList2, Rest, ModifyList3, NewAddList2, ResourcesList, LeftEnNum2, LeftArtiNum2, LeftRuneNum2)
					end
			end
	end.

check_item_list(Uid, SpendItems) ->
	SpendItems2 = merge_spend_items(SpendItems),
	check_item_list2(Uid, SpendItems2).

check_item_list2(_Uid, []) -> true;
check_item_list2(Uid, [{_Way, Type, Num} | Rest]) -> 
	case is_integer(Type) andalso is_cannot_spend_by_type(Type) of
		true -> 
			throw({error_spend_item, util_str:format_string("Type:~p cannot spend by type!!!", [Type])});
		_ -> skip
	end, 

	case check_item_num(Uid, Type, Num) of
		true -> check_item_list2(Uid, Rest);
		false -> {error, "not_enough_item", [util_item:get_item_name_with_color(Type)]}
	end.

is_cannot_spend_by_type(Type) -> 
	%% 目前神器和英雄无法通过Type来扣除，因为使用的和没使用的神器和英雄无法区分，
	%% 直接这样扣可能导致数据错乱
	case data_item:get_data(Type) of
		#st_item_type{sort = ?ITEM_TYPE_ENTOURAGE} -> true;
		#st_item_type{sort = ?ITEM_TYPE_ARTIFACT} -> true;
		_ -> false
	end.


merge_spend_items(NormalizeItems) ->
	merge_spend_items2(NormalizeItems, []).

merge_spend_items2([], Acc) -> Acc;
merge_spend_items2([T | Rest], Acc) ->
	Acc2 = merge_spend_items3(T, Acc, []),
	merge_spend_items2(Rest, Acc2).

merge_spend_items3(T1, [], Acc) -> [T1 | Acc];
merge_spend_items3(T1, [T2 | Rest], Acc) ->
	{Way1, Type1, Num1} = T1,
	{Way2, Type2, Num2} = T2,
	case Way1 == Way2 andalso Type1 == Type2 of
		true -> 
			T3 = {Way1, Type1, Num1 + Num2},
			[T3 | Rest ++ Acc];
		_ -> 
			merge_spend_items3(T1, Rest, [T2 | Acc])
	end.

check_item_num(Uid,Type,Num) ->
	if 
		Num >= 0 ->
			case Type of
				{item_id, ItemId} ->
					case fun_item_api:get_item_by_id(Uid, ItemId) of
						#item{} -> true;
						_ -> false
					end;
				_ ->
					case fun_resoure:check_resouce(Type) of
						true -> fun_resoure:check_resouce_num(Uid,Type,Num);
						false ->
							Items = fun_item_api:filter_item_by_type(Uid, Type),
							lists:foldl(fun(#item{num=A,owner=Owner},ADD)-> A - Owner + ADD end, 0, Items) >= Num
					end
			end;
		true -> false
	end.

%% 堆叠物品
overlap_item(ItemRecList, Type, Num, Color, Bind, ExtraData) -> 
	Color2 = case fun_item:check_equipment(Type) of
		true  -> Color;
		false -> util:get_item_color(Type)
	end,
	case ExtraData of
		[] -> overlap_item2(ItemRecList, Type, Num, Color2, Bind, [], []);
		[{get_from, _}] -> overlap_item2(ItemRecList, Type, Num, Color2, Bind, [], []);
		[{strengthen_lev, _}] -> overlap_item2(ItemRecList, Type, Num, Color2, Bind, [], []);
		_  -> {Num, [], ItemRecList}
	end.
overlap_item2([], _Type, Num, _Color, _Bind, AccModifyList, AccList) ->
	{Num, AccModifyList, AccList};
overlap_item2([ItemRec | Rest], Type, Num, Color, Bind, AccModifyList, AccList) ->
	Bind2 = bind_2_int(Bind),
	case ItemRec of
		#item{type = Type, color = Color, bind = Bind2, num = CurNum} ->
			#st_item_type{max = MaxNum} = data_item:get_data(Type),
			OverlapNum = min(MaxNum - CurNum, Num),
			if
				OverlapNum =< 0 -> %% 这个已有的物品不能再堆叠了
					overlap_item2(Rest, Type, Num, Color, Bind, AccModifyList, [ItemRec | AccList]);
				OverlapNum >= Num -> %% 这个已有的物品可以完全容下新加的数量
					ItemRec2 = ItemRec#item{num = Num + CurNum},
					{0, [ItemRec2 | AccModifyList], [ItemRec2 | AccList] ++ Rest};
				true -> %% 0 < OverlapNum < Num 只能容下部分
					ItemRec2 = ItemRec#item{num = OverlapNum + CurNum},
					LeftNum = Num - OverlapNum,
					AccModifyList2 = [ItemRec2 | AccModifyList],
					AccList2 = [ItemRec2 | AccList],
					overlap_item2(Rest, Type, LeftNum, Color, Bind, AccModifyList2, AccList2)
			end;
		_ -> 
			overlap_item2(Rest, Type, Num, Color, Bind, AccModifyList, [ItemRec | AccList])
	end.

add_new_item(Uid, Way, Type, Num, Color, Bind, ExtraData, LeftEnNum, LeftArtiNum, LeftRuneNum) ->
	add_new_item(Uid, Way, Type, Num, Color, Bind, ExtraData, LeftEnNum, LeftArtiNum, LeftRuneNum, []).
add_new_item(_Uid, _Way, _Type, Num, _Color, _Bind, _ExtraData, LeftEnNum, LeftArtiNum, LeftRuneNum, Acc) when Num =< 0 -> 
	{LeftEnNum, LeftArtiNum, LeftRuneNum, Acc};
add_new_item(Uid, Way, Type, Num, Color, Bind, ExtraData, LeftEnNum, LeftArtiNum, LeftRuneNum, Acc) ->
	Sort = get_item_sort(Type),
	IsRune = lists:member(Sort, ?FUWEN_ALL_POS),
	if
		Sort == ?ITEM_TYPE_ENTOURAGE andalso LeftEnNum =< 0 -> false;
		Sort == ?ITEM_TYPE_ARTIFACT andalso LeftArtiNum =< 0 -> false;
		IsRune andalso LeftRuneNum =< 0 -> false;
		true ->
			#st_item_type{max = MaxNum} = data_item:get_data(Type),
			{Rest1, Rest2, Rest3} = if
				Sort == ?ITEM_TYPE_ENTOURAGE -> {LeftEnNum - 1, LeftArtiNum, LeftRuneNum};
				Sort == ?ITEM_TYPE_ARTIFACT -> {LeftEnNum, LeftArtiNum - 1, LeftRuneNum};
				IsRune -> {LeftEnNum, LeftArtiNum, LeftRuneNum - 1};
				true -> {LeftEnNum, LeftArtiNum, LeftRuneNum}
			end,
			case Num > MaxNum of
				true -> 
					ItemRec = make_new_item(Uid, Way, Type, MaxNum, Color, Bind, ExtraData),
					Acc2 = [ItemRec | Acc],
					LeftNum = Num - MaxNum,
					add_new_item(Uid, Way, Type, LeftNum, Color, Bind, ExtraData, Rest1, Rest2, Rest3, Acc2);
				false ->
					ItemRec = make_new_item(Uid, Way, Type, Num, Color, Bind, ExtraData),
					Acc2 = [ItemRec | Acc],
					{Rest1, Rest2, Rest3, Acc2}
			end
	end.

make_new_item(Uid, Way, Type, Num, Color, Bind, ExtraData) ->
	Now = util_time:unixtime(),
	Bind2 = bind_2_int(Bind),
	Sort = get_item_sort(Type),
	Val = make_new_item_extra_property(ExtraData, strengthen_lev, 0),
	Star1 = get_default_star(Type),
	{Lev, Star} = case Sort of
		?ITEM_TYPE_ENTOURAGE ->
			fun_entourage:update_hero_illustration(Uid, Type, Star1),
			{1, ?_IF(Val > 0, Val, Star1)};
		?ITEM_TYPE_ARTIFACT ->
			fun_shenqi:update_shenqi_illustration(Uid, Type, Star1),
			{1, ?_IF(Val > 0, Val, Star1)};
		_ -> 
			case lists:member(Sort, ?FUWEN_ALL_POS) of
				true -> 
					{0, get_default_star(Type)};
				_ -> 
					{Val, get_default_star(Type)}
			end
	end,
	case fun_item:check_equipment(Type) of
		true->
			#item{
				uid        = Uid,
				type       = Type,
				num        = Num,
				bind       = Bind2,
				get_way    = Way,
				get_time   = Now,
				color      = Color,
				lev 	   = Lev,
				star       = Star
			};
		_ -> 
			#item{
				uid        = Uid,
				type       = Type,
				num        = Num,
				bind       = Bind2,
				get_way    = Way,
				get_time   = Now,
				color      = Color,
				lev 	   = Lev,
				star       = Star
			}
	end.

make_new_item_extra_property(ExtraData, Key, Default) ->
	case lists:keyfind(Key, 1, ExtraData) of
		false -> Default;
		{_, Data} -> Data
	end.

%% 数据库中使用的bind值为整型，程序中则boolean型和整型并存了
bind_2_int(Bind) when is_integer(Bind) -> Bind;
bind_2_int(Bind) when is_boolean(Bind) -> ?_IF(Bind, ?BIND_YES, ?BIND_NO). 
bind_2_bool(Bind) when is_integer(Bind) -> 
	%% 如果调用代码传错了参数，比如将Color错传为Bind参数了，那这里的报错将阻断数据库的插入
	case Bind of
		?BIND_YES -> true;
		?BIND_NO  -> false
	end;
bind_2_bool(Bind) when is_boolean(Bind) -> Bind.

%% 格式化物品格式返回:[{Way, Type, Num, Color, Bind}]
normalize_items(Items) ->
	Fun = fun(I, Acc) ->
		case normalize_item(I) of
			I2 = {_Way, Type, Num, _Color, _Bind, _ExtraData} when Num > 0 ->  
				case data_item:get_data(Type) of
					#st_item_type{} -> [I2 | Acc];
					_ -> Acc
				end;
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], Items).

normalize_item({Way, Type}) -> 
	Color = util:get_item_color(Type),
	Bind  = util:get_item_bind(Type),
	{Way, Type, 1, Color, Bind, []};
normalize_item({Way, Type, Num}) -> 
	Color = util:get_item_color(Type),
	Bind  = util:get_item_bind(Type),
	{Way, Type, Num, Color, Bind, []};
normalize_item({Way, Type, Num, List}) when is_list(List) -> 
	Color = util:get_item_color(Type),
	Bind  = util:get_item_bind(Type),
	{Way, Type, Num, Color, Bind, List};
normalize_item({Way, Type, Num, Color}) -> 
	Bind = util:get_item_bind(Type),
	{Way, Type, Num, Color, Bind, []};
normalize_item({Way, Type, Num, Color, Bind}) -> 
	{Way, Type, Num, Color, bind_2_bool(Bind), []};
normalize_item({Way, Type, Num, Color, Bind, ExtraData}) -> 
	{Way, Type, Num, Color, bind_2_bool(Bind), ExtraData}.

%% 将同类别的道具相加
merge_normalized_items(NormalizeItems) ->
	merge_normalized_items2(NormalizeItems, []).

merge_normalized_items2([], Acc) -> Acc;
merge_normalized_items2([T | Rest], Acc) ->
	Acc2 = merge_normalized_items3(T, Acc, []),
	merge_normalized_items2(Rest, Acc2).

merge_normalized_items3(T1, [], Acc) -> [T1 | Acc];
merge_normalized_items3(T1, [T2 | Rest], Acc) ->
	{Way1, Type1, Num1, Color1, Bind1, ExtraData1} = T1,
	{Way2, Type2, Num2, Color2, Bind2, ExtraData2} = T2,
	case Way1 == Way2 andalso Type1 == Type2 andalso 
		 Color1 == Color2 andalso Bind1 == Bind2 andalso ExtraData1 == ExtraData2 of
		true -> 
			T3 = {Way1, Type1, Num1 + Num2, Color1, Bind1, ExtraData1},
			[T3 | Rest ++ Acc];
		_ -> 
			merge_normalized_items3(T1, Rest, [T2 | Acc])
	end.

make_item_pt_list([]) -> [];
make_item_pt_list(Items1) ->
	Fun = fun(Ret, Acc) ->
		case Ret of
			{T, N} -> [{T, N, get_default_star(T)} | Acc];
			{T, N, 0} -> [{T, N, get_default_star(T)} | Acc];
			{T, N, L} -> [{T, N, L} | Acc];
			_ -> Acc
		end
	end,
	Items = lists:foldl(Fun, [], Items1),
	[make_item_get_pt(ItemType, Num, Lev) || {ItemType, Num, Lev} <- Items].

make_item_get_pt({ItemType, Num}) ->
	make_item_get_pt(ItemType, Num, get_default_star(ItemType));
make_item_get_pt({ItemType, Num, Star}) ->
	make_item_get_pt(ItemType, Num, Star).
make_item_get_pt(ItemType, Num) ->
	make_item_get_pt(ItemType, Num, get_default_star(ItemType)).
make_item_get_pt(ItemType, Num, Star) ->
	#pt_public_item_list{
		item_id   = ItemType,
		item_num  = Num,
		item_star = Star
	}.

make_string_pt(Str) ->
	#pt_public_friend_name_list{name=util:to_list(Str)}.

%% 通用的获得奖励的展示通知
%% Items:[{item_type, item_num}]
send_show_fetched_reward(Uid, Sid, ShowType, Items) ->
	send_show_fetched_reward(Uid, Sid, ShowType, Items, []).
send_show_fetched_reward(Uid, Sid, ShowType, Items, StrList) ->
	send_show_fetched_reward(Uid, Sid, ShowType, Items, StrList, 0).
send_show_fetched_reward(_Uid, Sid, ShowType, Items1, StrList, Seq) ->
	Fun = fun(Ret, Acc) ->
		case Ret of
			{T, N} -> [{T, N, get_default_star(T)} | Acc];
			{T, N, 0} -> [{T, N, get_default_star(T)} | Acc];
			{T, N, L} -> [{T, N, L} | Acc];
			_ -> Acc
		end
	end,
	Items = lists:foldl(Fun, [], Items1),
	Pt = #pt_show_fetched_reward{
		show_type = [make_string_pt(Str) || Str <- StrList],
		type = ShowType, 
		rewards = [make_item_get_pt(I, N, L) || {I, N, L} <- Items]
	},
	?send(Sid, proto:pack(Pt, Seq)).

%% 讲物品乘以一个倍数
%% Items:[{ItemType, Num}]
items_multiply(Items, Times) ->
	[{ItemType, util:floor(Num*Times), Lev} || {ItemType, Num, Lev} <-  Items].