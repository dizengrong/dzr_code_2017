%% 抽奖模块，和抽奖相关的都可放里面
-module(fun_draw).
-include("common.hrl").
-export([send_draw_info_to_client/3]).
-export([req_energy_draw/3]).
-export([req_draw/5, req_summon_draw/5]).
-export([box/1,box/2]).

-define(DRAW_ONE, 1).

%% =============================================================================
get_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_draw) of
		[] -> #t_draw{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	mod_role_tab:insert(Rec#t_draw.uid, Rec).

%% =============================================================================

req_summon_draw(Uid, Sid, DrawType, DrawTimes, Seq) ->
	case data_summon_door:get_data(DrawType) of
		0 -> skip;
		BoxId ->
			SpendItems = [{100004, DrawTimes}],
			ItemList = summon_help(BoxId, DrawTimes, 0, []),
			AddItems = [{ItemType, ItemNum, [{strengthen_lev, ItemVal}]} || {ItemType, ItemNum, ItemVal} <- ItemList],
			Succ = fun() ->
				mod_draw_record:add_record(Uid, make_record_list(ItemList), ?SUMMON_DOOR),
				fun_count:on_count_event(Uid, Sid, ?TASK_SUMMON_DOOR, 0, DrawTimes),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, ItemList)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_SUMMON_DOOR,
				spend    = SpendItems,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

summon_help(_BoxId, DrawTimes, _Acc1, Acc2) when DrawTimes =< 0 -> Acc2;
summon_help(_BoxId, DrawTimes, DrawTimes, Acc2) -> Acc2;
summon_help(BoxId, DrawTimes, Acc1, Acc2) ->
	NewAcc = util_list:add_and_merge_list(box(BoxId), Acc2, 1, 2),
	summon_help(BoxId, DrawTimes, Acc1 + 1, NewAcc).

box(BoxId) ->
	box(BoxId,true).
box(BoxId,IsMerge) ->
	DropList = fun_scene_drop_item:drop_box(BoxId),
	case IsMerge of
		true -> util_list:add_and_merge_list([], DropList, 1, 2);
		_ -> DropList
	end.

req_draw(Uid, Sid, DrawType, DrawTimes, Seq) ->
	case check_draw(Uid, DrawType, DrawTimes) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, Cost, BoxId, NewRec} ->
			ItemList = box(BoxId, false),
			AddItems = [{ItemType, ItemNum, [{strengthen_lev, ItemVal}]} || {ItemType, ItemNum, ItemVal} <- ItemList],
			Succ = fun() ->
				set_data(NewRec),
				RecordType = case DrawType of
					1 -> ?LOW_DRAW;
					2 -> ?HIGH_DRAW;
					3 -> ?FRIENDSHIP_DRAW
				end,
				case RecordType of
					?LOW_DRAW -> fun_count:on_count_event(Uid, Sid, ?TASK_LOW_DRAW, 0, DrawTimes);
					?HIGH_DRAW -> fun_count:on_count_event(Uid, Sid, ?TASK_HIGH_DRAW, 0, DrawTimes);
					_ -> skip
				end,
				mod_draw_record:add_record(Uid, make_record_list(ItemList), RecordType),
				send_draw_result(Sid, DrawType, ItemList, Seq),
				send_draw_info_to_client(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_DRAW,
				spend    = Cost,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

req_energy_draw(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	{Energy, Box} = data_draw:get_energe_data(),
	if
		Rec#t_draw.energy >= Energy ->
			ItemList = box(Box, false),
			AddItems = [{ItemType, ItemNum, [{strengthen_lev, ItemVal}]} || {ItemType, ItemNum, ItemVal} <- ItemList],
			Succ = fun() ->
				NewRec = Rec#t_draw{energy = Rec#t_draw.energy - Energy},
				set_data(NewRec),
				send_draw_info_to_client(Uid, Sid, Seq),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_ENERGY_DRAW, ItemList)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_ENERGY_DRAW,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		true -> skip
	end.

check_draw(Uid, DrawType, DrawTimes) ->
	case data_draw:get_data(DrawType) of
		#st_draw_config{one_cost = OneCost, ten_cost = TenCost, first = FirstBox, one_box = OneBox, ten_box = TenBox, one_energy = OneEnergy, ten_energy = TenEnergy, cd = CD} ->
			Rec = get_data(Uid),
			List = Rec#t_draw.draw_record,
			Now = agent:agent_now(),
			if
				CD == 0 andalso DrawTimes == ?DRAW_ONE ->
					NewRec = Rec#t_draw{energy = Rec#t_draw.energy + OneEnergy},
					{ok, OneCost, OneBox, NewRec};
				DrawTimes == ?DRAW_ONE ->
					case lists:keyfind(DrawType, 1, List) of
						{DrawType, FreeTime} ->
							if
								Now >= FreeTime ->
									NewList = lists:keystore(DrawType, 1, List, {DrawType, Now + CD * 60}),
									NewRec = Rec#t_draw{energy = Rec#t_draw.energy + OneEnergy, draw_record = NewList},
									{ok, [], OneBox, NewRec};
								true ->
									NewRec = Rec#t_draw{energy = Rec#t_draw.energy + OneEnergy},
									{ok, OneCost, OneBox, NewRec}
							end;
						_ ->
							Box = if
								FirstBox == 0 -> OneBox;
								true -> FirstBox
							end,
							NewList = [{DrawType, Now + CD * 60} | List],
							NewRec = Rec#t_draw{energy = Rec#t_draw.energy + OneEnergy, draw_record = NewList},
							{ok, [], Box, NewRec}
					end;
				true ->
					NewRec = Rec#t_draw{energy = Rec#t_draw.energy + TenEnergy},
					{ok, TenCost, TenBox, NewRec}
			end;
		_ -> {error, "check_data_error"}
	end.

send_draw_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_draw_info{
		energy = Rec#t_draw.energy,
		list   = [#pt_public_draw_list{draw_type = DrawType, free_time = FreeTime} || {DrawType, FreeTime} <- Rec#t_draw.draw_record]
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_draw_result(Sid, DrawType, ItemList, Seq) ->
	Pt = #pt_draw_result{
		draw_type = DrawType,
		rewards   = fun_item_api:make_item_pt_list(ItemList)
	},
	?send(Sid, proto:pack(Pt, Seq)).

make_record_list(ItemList) ->
	Fun = fun({T, _, V}) ->
		if
			V >= 5 -> true;
			V == 0 ->
				case fun_item_api:get_default_star(T) >= 5 of
					true -> true;
					_ -> false
				end;
			true -> false
		end
	end,
	lists:filter(Fun, ItemList).