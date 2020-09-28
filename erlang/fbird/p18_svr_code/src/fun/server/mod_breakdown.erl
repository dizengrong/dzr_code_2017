%% P18分解模块
-module(mod_breakdown).
-include("common.hrl").
-export([req_break/5]).

-define(BREAK_ENTOURAGE , 1). %%分解英雄
-define(BREAK_ARTIFACT  , 2). %%分解神器
-define(BREAK_RUNE      , 3). %%分解符文

req_break(Uid, Sid, BreakType, ItemList, Seq) ->
	case check_break(Uid, ItemList, BreakType) of
		{ok, SpendItems, AddItems} ->
			Succ = fun() ->
				case BreakType of
					?BREAK_ENTOURAGE -> fun_count:on_count_event(Uid, Sid, ?TASK_HERO_DECOMPOSE, 0, length(SpendItems));
					?BREAK_ARTIFACT -> fun_count:on_count_event(Uid, Sid, ?TASK_ARTIFACT_DECOMPOSE, 0, length(SpendItems));
					?BREAK_RUNE -> fun_count:on_count_event(Uid, Sid, ?TASK_RUNE_DECOMPOSE, 0, length(SpendItems));
					_ -> skip
				end,
				Pt = #pt_break_succ{type = BreakType},
				?send(Sid, proto:pack(Pt, Seq)),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_BREAK_DOWN,
				spend    = SpendItems,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		{error, Reason} -> ?error_report(Sid, Reason, Seq)
	end.

check_break(Uid, ItemList, BreakType) ->
	Fun = fun(ItemId) ->
		case fun_item_api:get_item_by_id(Uid, ItemId) of
			#item{type = ItemType} ->
				Sort = fun_item_api:get_item_sort(ItemType),
				case BreakType of
					?BREAK_ENTOURAGE -> Sort == ?ITEM_TYPE_ENTOURAGE;
					?BREAK_ARTIFACT -> Sort == ?ITEM_TYPE_ARTIFACT;
					?BREAK_RUNE -> lists:member(Sort, ?FUWEN_ALL_POS);
					_ -> false
				end;
			_ -> false
		end
	end,
	NewList = lists:filter(Fun, ItemList),
	case BreakType of
		?BREAK_ENTOURAGE -> make_entourage_break(Uid, NewList, [], []);
		?BREAK_ARTIFACT -> make_artifact_break(Uid, NewList, [], []);
		?BREAK_RUNE -> make_rune_break(Uid, NewList, [], []);
		_ -> {error, "check_data_error"}
	end.

make_entourage_break(_Uid, [], Acc1, Acc2) -> {ok, Acc1, Acc2};
make_entourage_break(Uid, [ItemId | Rest], Acc1, Acc2) ->
	#item{star = Star, break = Break, lev = Lev} = fun_item_api:get_item_by_id(Uid, ItemId),
	StarAdd = data_breakdown:get_entourage_data(Star),
	BreakAdd = [{T, util:floor(N * 0.5)} || {T, N} <- make_entourage_breakadd_help(Break, [])],
	List1 = util_list:add_and_merge_list(StarAdd, BreakAdd, 1, 2),
	LevAdd = [{T, util:floor(N * 0.5)} || {T, N} <- make_entourage_levadd_help(Lev, [])],
	NewList = util_list:add_and_merge_list(List1, LevAdd, 1, 2),
	make_entourage_break(Uid, Rest, [{{item_id, ItemId}, 1} | Acc1], util_list:add_and_merge_list(NewList, Acc2, 1, 2)).

make_entourage_breakadd_help(0, Acc) -> Acc;
make_entourage_breakadd_help(Break, Acc) ->
	make_entourage_breakadd_help(Break - 1, Acc ++ data_entourage_ex:get_lv_grade_cost(Break - 1)).

make_entourage_levadd_help(1, Acc) -> Acc;
make_entourage_levadd_help(Lev, Acc) ->
	make_entourage_levadd_help(Lev - 1, Acc ++ data_entourage_ex:get_lv_up_cost(Lev - 1)).

make_artifact_break(_Uid, [], Acc1, Acc2) -> {ok, Acc1, Acc2};
make_artifact_break(Uid, [ItemId | Rest], Acc1, Acc2) ->
	#item{star = Star, lev = Lev} = fun_item_api:get_item_by_id(Uid, ItemId),
	StarAdd = data_breakdown:get_artifact_data(Star),
	LevAdd = [{T, util:floor(N * 0.5)} || {T, N} <- make_artifact_levadd_help(Lev, [])],
	NewList = util_list:add_and_merge_list(StarAdd, LevAdd, 1, 2),
	make_artifact_break(Uid, Rest, [{{item_id, ItemId}, 1} | Acc1], util_list:add_and_merge_list(NewList, Acc2, 1, 2)).

make_artifact_levadd_help(1, Acc) -> Acc;
make_artifact_levadd_help(Lev, Acc) ->
	make_artifact_levadd_help(Lev - 1, Acc ++ data_shenqi:get_lv_up_cost(Lev - 1)).

make_rune_break(_Uid, [], Acc1, Acc2) -> {ok, Acc1, Acc2};
make_rune_break(Uid, [ItemId | Rest], Acc1, Acc2) ->
	#item{type = Type, lev = Lev} = fun_item_api:get_item_by_id(Uid, ItemId),
	#st_item_type{color = Color, default_star = Star} = data_item:get_data(Type),
	CostNum = data_fuwen:get_strength_cost(Color, Star),
	NewList = [{?RESOUCE_FUWEN, CostNum * (Lev - 1) + data_fuwen:get_recycle_gain(Color, Star)}],
	make_rune_break(Uid, Rest, [{{item_id, ItemId}, 1} | Acc1], util_list:add_and_merge_list(NewList, Acc2, 1, 2)).