%% @doc 英雄相关的一些方法
-module (util_entourage).
-include("common.hrl").

-export([
	make_entourage_list/2,
	get_max_lv/1
]).

%% 处理英雄列表，输入{Id, Pos}返回{Id, Etype, Pos}
make_entourage_list(Uid, EntourageList) ->
	Lv = util:get_lev_by_uid(Uid),
	Fun = fun({ItemId, Pos},Acc) ->
		IsAlreadyOnBattled = lists:keymember(ItemId, 1, Acc),
		OpenLv = data_entourage:get_pos_open_lv(Pos),
		if 
			IsAlreadyOnBattled -> Acc;
			Lv < OpenLv -> Acc;
			true -> 
				case fun_item_api:get_item_by_id(Uid, ItemId) of
					#item{type = Type} ->
						case fun_item_api:get_item_sort(Type) of
							?ITEM_TYPE_ENTOURAGE -> 
								[{ItemId, Type, Pos} | Acc];
							_ -> Acc
						end;
					_ -> Acc
				end
		end
	end,
	lists:foldl(Fun, [], EntourageList).

%% 获取当前英雄可以升的最大等级
get_max_lv(#item{type = EntourageType, break = Break, star = Star}) ->
	#st_entourage_config{max_grade = MaxGrade} = data_entourage:get_data(EntourageType),
	if 
		Break < MaxGrade ->
			data_entourage_ex:get_grade_lv_limit(Break);
		true -> 
			MaxLv1 = data_entourage_ex:get_grade_lv_limit(MaxGrade),
			MaxLv2 = data_entourage_ex:get_star_lv_limit(Star),
			max(MaxLv1, MaxLv2)
	end.


