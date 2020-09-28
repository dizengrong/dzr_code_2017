%% @doc 场景cell模块
-module (fun_scene_cell).
-include("common.hrl").
-export ([collect_see_cells/1, get_see_cells/1]).
-export ([get_cell_object_ids/1, set_cell_object_ids/2, del_cell_object_ids/2, add_cell_object_ids/2]).
-export ([get_object_ids_by_cells/1]).


%% 获取这个cell可以看到的cell列表
get_see_cells(Cell) -> 
	case erlang:get({cell, Cell}) of
		undefined -> 
			List = collect_see_cells(Cell),
			erlang:put({cell, Cell}, List),
			List;
		List -> List
	end.


%% 获取这个cell里的对象id列表
get_cell_object_ids(Cell) -> 
	case erlang:get({cell_object_ids, Cell}) of
		undefined -> [];
		List -> List
	end.


set_cell_object_ids(Cell, List) -> 
	erlang:put({cell_object_ids, Cell}, List).


%% 将对象id添加到这个cell里
add_cell_object_ids(Cell, Oid) -> 
	List = get_cell_object_ids(Cell),
	case lists:member(Oid, List) of
		false -> set_cell_object_ids(Cell, [Oid | List]);
		_     -> skip
	end.


del_cell_object_ids(Cell, Oid) -> 
	List = get_cell_object_ids(Cell),
	set_cell_object_ids(Cell, lists:delete(Oid, List)).


get_object_ids_by_cells(Cells) ->
	List = [get_cell_object_ids(Cell) || Cell <- Cells],
	lists:append(List).


collect_see_cells({CellX,CellY}) ->
	if
		CellX > 0 -> 
			if
				CellY > 0 -> 
					[{CellX - 1,CellY + 1},{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX - 1,CellY},{CellX,CellY},{CellX + 1,CellY},
					 {CellX - 1,CellY - 1},{CellX,CellY - 1},{CellX + 1,CellY - 1}];
				CellY == 0 -> 
					[{CellX - 1,CellY + 1},{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX - 1,CellY},{CellX,CellY},{CellX + 1,CellY}];
				true -> []
			end;
		CellX == 0 -> 
			if
				CellY > 0 -> 
					[{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX,CellY},{CellX + 1,CellY},
					 {CellX,CellY - 1},{CellX + 1,CellY - 1}];
				CellY == 0 -> 
					[{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX,CellY},{CellX + 1,CellY}];
				true -> []
			end;
		true -> []
	end;
collect_see_cells(_) -> [].

