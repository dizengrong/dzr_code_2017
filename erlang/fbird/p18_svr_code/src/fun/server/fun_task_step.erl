%%功能预告模块
-module(fun_task_step).

-include("common.hrl").

-export([req_info/3, req_reward/4, check_count/4, init_task_step/1, check_rank/5]).
-export([gm_set_step/3]).

-define(INIT_TYPE_NUM,0).
-define(SORT_LIST,[1]).

%%数据处理
get_data(Uid, Sort) ->
	Sort1 = get_sort(Sort),
	{Step, _} = fun_usr_misc:get_misc_data(Uid, Sort1),
	if Step == 0 -> 
			Step1 = Step + 1,
			{{Type,_},_} = data_storyReward_config:get_data(Sort, Step1),
			Num = fun_step_count:init_step_data(Sort, Type, Uid),
			fun_usr_misc:set_misc_data(Uid, Sort1, {Step1, Num}),
			fun_usr_misc:get_misc_data(Uid, Sort1);
	   true -> fun_usr_misc:get_misc_data(Uid, Sort1)
	end.

set_data(Uid, Sort, Val) ->
	Sort1 = get_sort(Sort),
	fun_usr_misc:set_misc_data(Uid, Sort1, Val).


%%进行检测
check_update_count(Uid, Sid, Type, Num, Sort) ->
	{Step, _} = get_data(Uid, Sort),
	case Step > data_storyReward_config:max_step(Sort) of
		true -> TaskType = 0, NeedNum = 0;
		_ -> {{TaskType ,NeedNum}, _} = data_storyReward_config:get_data(Sort, Step)
	end,
	% ?debug("Type:~p, TaskType:~p",[Type, TaskType]),
	case Type == TaskType of
		true -> 
			case Type >= 24 andalso Type =< 31 of
				true -> 
					NeedNum1 = fun_step_count:get_rank_num(Type),
					?debug("Num:~p, NeedNum1:~p",[Num, NeedNum1]),
					check2(Uid, Sid, Num, NeedNum1, Step, Sort);
				_ -> 
					check(Uid, Sid, Num, NeedNum, Step, Sort)
			end;
		_ -> skip
	end.

check_add_count(Uid, Sid, Type, Num, Sort) ->
	{Step, CurrNum} = get_data(Uid, Sort),
	case Step > data_storyReward_config:max_step(Sort) of
		true -> TaskType = 0, NeedNum = 0;
		_ -> {{TaskType ,NeedNum}, _} = data_storyReward_config:get_data(Sort, Step)
	end,
	Num1 = CurrNum + Num,
	case Type == TaskType of
		true -> check(Uid, Sid, Num1, NeedNum, Step, Sort);
		_ -> skip
	end.
	
check_count(pass_copy, Uid, Sid, Num) -> [check_count(pass_copy, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(ch_lev, Uid, Sid, Num) -> [check_count(ch_lev, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(eqp_lev, Uid, Sid, Num) -> [check_count(eqp_lev, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(hero_lev, Uid, Sid, Num) -> [check_count(hero_lev, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(skill_lev, Uid, Sid, Num) -> [check_count(skill_lev, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(purple_eqp, Uid, Sid, Num) -> [check_count(purple_eqp, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(orange_eqp, Uid, Sid, Num) -> [check_count(orange_eqp, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(ride_lev, Uid, Sid, Num) -> [check_count(ride_lev, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(two_star_hero, Uid, Sid, Num) -> [check_count(two_star_hero, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(all_star, Uid, Sid, Num) -> [check_count(all_star, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(add_friend, Uid, Sid, Num) -> [check_count(add_friend, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(break_eqp, Uid, Sid, Num) -> [check_count(break_eqp, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(enter_geo, Uid, Sid, Num) -> [check_count(enter_geo, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(pass_pk, Uid, Sid, Num) -> [check_count(pass_pk, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(recycle_eqp, Uid, Sid, Num) -> [check_count(recycle_eqp, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(equip_compose, Uid, Sid, Num) -> [check_count(equip_compose, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(gem_up, Uid, Sid, Num) -> [check_count(gem_up, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(shenqi_up, Uid, Sid, Num) -> [check_count(shenqi_up, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(fighting, Uid, Sid, Num) -> [check_count(fighting, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(hero_skill_lev, Uid, Sid, Num) -> [check_count(hero_skill_lev, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(max_gem_lv, Uid, Sid, Num) -> [check_count(max_gem_lv, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(quick_fight, Uid, Sid, Num) -> [check_count(quick_fight, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank, Uid, Sid, Num) -> [check_count(arena_rank, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_8, Uid, Sid, Num) -> [check_count(arena_rank_8, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_7, Uid, Sid, Num) -> [check_count(arena_rank_7, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_6, Uid, Sid, Num) -> [check_count(arena_rank_6, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_5, Uid, Sid, Num) -> [check_count(arena_rank_5, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_4, Uid, Sid, Num) -> [check_count(arena_rank_4, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_3, Uid, Sid, Num) -> [check_count(arena_rank_3, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_2, Uid, Sid, Num) -> [check_count(arena_rank_2, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(arena_rank_1, Uid, Sid, Num) -> [check_count(arena_rank_1, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST];
check_count(monsters, Uid, Sid, Num) -> [check_count(monsters, Uid, Sid, Num, Sort) || Sort <- ?SORT_LIST].

check_count(pass_copy, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(pass_copy), Num, Sort);
check_count(arena_rank_8, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_8), Num, Sort);
check_count(arena_rank_7, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_7), Num, Sort);
check_count(arena_rank_6, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_6), Num, Sort);
check_count(arena_rank_5, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_5), Num, Sort);
check_count(arena_rank_4, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_4), Num, Sort);
check_count(arena_rank_3, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_3), Num, Sort);
check_count(arena_rank_2, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_2), Num, Sort);
check_count(arena_rank_1, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank_1), Num, Sort);
check_count(ch_lev, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(ch_lev), Num, Sort);
check_count(eqp_lev, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(eqp_lev), Num, Sort);
check_count(max_gem_lv, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(max_gem_lv), Num, Sort);
check_count(hero_lev, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(hero_lev), Num, Sort);
check_count(hero_skill_lev, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(hero_skill_lev), Num, Sort);
check_count(arena_rank, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(arena_rank), Num, Sort);
check_count(skill_lev, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(skill_lev), Num, Sort);
check_count(purple_eqp, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(purple_eqp), Num, Sort);
check_count(orange_eqp, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(orange_eqp), Num, Sort);
check_count(ride_lev, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(ride_lev), Num, Sort);
check_count(fighting, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(fighting), Num, Sort);
check_count(two_star_hero, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(two_star_hero), Num, Sort);
check_count(all_star, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(all_star), Num, Sort);
check_count(shenqi_up, Uid, Sid, Num, Sort) ->
	check_update_count(Uid, Sid, fun_step_count:transform_type(shenqi_up), Num, Sort);
check_count(add_friend, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(add_friend), Num, Sort);
check_count(break_eqp, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(break_eqp), Num, Sort);
check_count(enter_geo, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(enter_geo), Num, Sort);
check_count(quick_fight, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(quick_fight), Num, Sort);
check_count(pass_pk, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(pass_pk), Num, Sort);
check_count(recycle_eqp, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(recycle_eqp), Num, Sort);
check_count(equip_compose, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(equip_compose), Num, Sort);
check_count(gem_up, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(gem_up), Num, Sort);
check_count(monsters, Uid, Sid, Num, Sort) ->
	check_add_count(Uid, Sid, fun_step_count:transform_type(monsters), Num, Sort).

%%请求领取状态
req_info(Uid, Sid, Seq)->
	[req_info(Uid, Sid, Seq, Sort) || Sort <- ?SORT_LIST].

req_info(Uid, Sid, Seq, Sort) ->
	{Step, Num} = get_data(Uid, Sort),
	% ?debug("Step=~p",[Step]),
	case Step > data_storyReward_config:max_step(Sort) of
		true -> 
			Status = 2, 
			Number = 0;
		_ -> 
			{{Type,_},_} = data_storyReward_config:get_data(Sort, Step),
			%?debug("Type=~p",[Type]),
			case Num of
				0 -> Num1 = fun_step_count:init_step_data(Sort, Type, Uid);
				_ -> Num1 = Num
			end,
			case check_update_count(Uid, Sid, Type, Num1, Sort) of
						{true, Number} -> Status = 1;
		 				{false, Number} -> Status = 0
			end
	end,
	%?debug("Number=~p",[Number]),
	Pt = #pt_task_step_info{step = Step, num = Number, status = Status, sort = Sort},
	% ?debug("Ptm=~p",[Ptm]),
	?send(Sid, proto:pack(Pt, Seq)).
	

%%请求领奖
req_reward(Uid, Sid, Seq, Sort)->
	case lists:member(Sort, ?SORT_LIST) of
		true -> 
			{CurrStep, Num} = get_data(Uid, Sort),
			{{Type,_},Reward} = data_storyReward_config:get_data(Sort, CurrStep),
			% ?debug("Type=~p",[Type]),
			case check_update_count(Uid, Sid, Type, Num, Sort) of
				{true,_} -> 
					Fun = fun({Type1, Num1}) -> {?ITEM_WAY_TASK_STEP, Type1, Num1}	end,
					Items = lists:map(Fun, Reward),
					NewStep = CurrStep + 1,
					MaxStep = data_storyReward_config:max_step(Sort),
					if NewStep =< MaxStep ->
						{{NewType,_},_} = data_storyReward_config:get_data(Sort, NewStep);
						true -> NewType = ?INIT_TYPE_NUM
					end,
					SuccCallBack = fun() ->
						set_data(Uid, Sort, {NewStep,fun_step_count:init_step_data(Sort, NewType, Uid)}),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Reward),
						req_info(Uid, Sid, Seq, Sort),
						fun_dataCount_update:task_step(Uid, Sort, CurrStep)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], Items, SuccCallBack, undefined);
				_ -> skip	
			end;
		_ ->
			?log_error("usr ~p send wrong sort:~p", [get(uid), Sort])
	end.


check(Uid, Sid, Num, NeedNum, Step, Sort) ->
	case Num >= NeedNum of
		true -> 
			Needs = NeedNum,
			Status = 1,
			set_data(Uid, Sort, {Step, Needs}),
			Pt = #pt_task_step_info{step = Step, num = Needs, status = Status, sort = Sort},
			?send(Sid, proto:pack(Pt)),
			{true, Needs};
		_ -> 
			Needs = Num,
			Status = 0,
			set_data(Uid, Sort, {Step, Needs}),
			Pt = #pt_task_step_info{step = Step, num = Needs, status = Status, sort = Sort},
			?send(Sid, proto:pack(Pt)),
			{false, Needs}
	end.

check2(Uid, Sid, Num, NeedNum, Step, Sort) ->
	% ?debug("Num:~p, NeedNum:~p",[Num, NeedNum]),
	case Num =< NeedNum of
		true -> 
			Needs = 1,
			Status = 1,
			set_data(Uid, Sort, {Step, Needs}),
			Pt = #pt_task_step_info{step = Step, num = Needs, status = Status, sort = Sort},
			?send(Sid, proto:pack(Pt)),
			{true, Needs};
		_ -> 
			Needs = 0,
			Status = 0,
			set_data(Uid, Sort, {Step, Needs}),
			Pt = #pt_task_step_info{step = Step, num = Needs, status = Status, sort = Sort},
			?send(Sid, proto:pack(Pt)),
			{false, Needs}
	end.

check_rank(Uid, Type, Num, NeedNum, Sort) ->
	% ?debug("Num=~p",[Num]),
	{Step, _} = get_data(Uid, Sort),
	case Step > data_storyReward_config:max_step(Sort) of
		true -> TaskType = 0, NeedNum1 = 0;
		_ -> 
			{{TaskType ,_}, _} = data_storyReward_config:get_data(Sort, Step),
			NeedNum1 = NeedNum
	end,
	case Type == TaskType of
		true -> check_rank2(Num, NeedNum1);
		_ -> skip
	end.

check_rank2(Num, NeedNum) ->
	case Num =< NeedNum of
		true -> 1;
		_ -> 0
	end.

init_task_step(Uid) -> 
	fun_herald:init_step(Uid),
	[init_task_step(Uid, Sort) || Sort <- ?SORT_LIST].

init_task_step(Uid, Sort) ->
	{Step, _} = get_data(Uid, Sort),
	if 
		Step == 0 -> 
			Step1 = Step + 1,
			{{Type,_},_} = data_storyReward_config:get_data(Sort, Step1),
			Num = fun_step_count:init_step_data(Sort, Type, Uid),
			set_data(Uid, Sort, {Step1, Num});
		true -> skip
	end.

gm_set_step(Uid, Sid, Step) ->
	Sort = 1,
	case catch data_storyReward_config:get_data(Sort, Step) of
		{{Type,_},_} -> 
			Num = fun_step_count:init_step_data(Sort, Type, Uid),
			set_data(Uid, Sort, {Step, Num}),
			req_info(Uid, Sid, 0);
		_ -> 
			skip
	end.


get_sort(Sort) ->
	case Sort of
		1 -> task_step_n;
		2 -> task_step_h
	end.
