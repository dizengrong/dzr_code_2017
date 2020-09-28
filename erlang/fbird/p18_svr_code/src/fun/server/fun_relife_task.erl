%% 转生任务
-module(fun_relife_task).
-include("common.hrl").
-export([req_relife_task/3]).
-export([is_task_finished/2]).
-export([handle_relife/4,init_relife_task/1,gm_init_relife_task/1,get_skill_num/2]).

%%数据操作
get_data_time(Uid) ->
	fun_usr_misc:get_misc_data(Uid, relife_time).

get_data(Uid) ->
	fun_usr_misc:get_misc_data(Uid, relife_task).

set_data(Uid, Val) ->
	fun_usr_misc:set_misc_data(Uid, relife_task, Val).

gm_init_relife_task(Uid) ->
	Time = get_data_time(Uid),
	case Time < data_relife_task:max_time() of
		true ->
			List = [gm_get_init_data(Uid, Id) || Id <- data_relife_task:select_id_by_time(Time+1)],
			set_data(Uid, List);
		_ -> skip
	end.

gm_get_init_data(Uid, Id) ->
	{_, Type, TaskNumList} = data_relife_task:get_data(Id),
	TaskNum = get_task_num(TaskNumList),
	Type1 = fun_step_count:transform_re_type(Type),
	List = get_data(Uid),
	case lists:keyfind(Type1, 1, List) of
		{Type1, Num1, _} -> 
			% ?debug("Id1=~p",[Id]),
			case Num1 >= TaskNum of
				true -> Num = TaskNum;
				_ -> Num = Num1
			end,
			Status = get_init_status1(Uid, Type1, Id, Num);
		_ -> 
			case fun_step_count:init_step_data(0,Type,Uid) >= TaskNum of
				true -> 
					Num = TaskNum;
				_ -> 
					Num = fun_step_count:init_step_data(0,Type,Uid)
			end,
			% ?debug("Id2=~p",[Id]),
			Status = get_init_status(Uid, Type1, Id)
	end,
	{Type1,Num,Status}.

init_relife_task(Uid) ->
	Time = get_data_time(Uid),
	case Time < data_relife_task:max_time() of
		true ->
			List = [get_init_data(Uid, Id) || Id <- data_relife_task:select_id_by_time(Time+1)],
			set_data(Uid, List);
		_ -> skip
	end.

get_init_data(Uid, Id) ->
	{_, Type, TaskNumList} = data_relife_task:get_data(Id),
	TaskNum = get_task_num(TaskNumList),
	Type1 = fun_step_count:transform_re_type(Type),
	case fun_step_count:init_step_data(0,Type,Uid) >= TaskNum of
		true -> Num = TaskNum;
		_ -> Num = fun_step_count:init_step_data(0,Type,Uid)
	end,
	{Type1,Num,get_init_status(Uid, Type1, Id)}.

is_task_finished(Uid, Type) ->
	List = get_data(Uid),
	case lists:keyfind(Type, 1, List) of
		{Type, _, Status} when Status == 1 -> true;
		_ -> false
	end.

req_relife_task(Uid, Sid, Seq) -> send_info_to_client(Uid, Sid, Seq).

check_task(Type1, Type2, Time1, Time2) ->
	if Type1 == Type2 andalso Time1 == Time2 -> true;
		true -> false
	end.

get_init_status(Uid, Type, Id) ->
	Type1 = fun_step_count:transform_type(Type),
	Num = fun_step_count:init_step_data(0, Type1, Uid),
	Time = get_data_time(Uid),
	case Time >= 0 andalso Time < data_relife_task:max_time() of
		true ->
			case data_relife_task:get_data(Id) of
				{TaskTime, TaskType, TaskNumList} -> 
					TaskNum = get_task_num(TaskNumList),
					case check_task(Type1, TaskType, Time+1, TaskTime) of
						true -> 
							case Num >= TaskNum of
								true -> 1;	
								_ -> 0
							end;
						_ -> 0
					end;
				_ -> 0
			end;
		_ -> 0
	end.

get_init_status1(Uid, Type, Id, Num) ->
	Type1 = fun_step_count:transform_type(Type),
	Time = get_data_time(Uid),
	case Time >= 0 andalso Time < data_relife_task:max_time() of
		true ->
			case data_relife_task:get_data(Id) of
				{TaskTime, TaskType, TaskNumList} -> 
					TaskNum = get_task_num(TaskNumList),
					% ?debug("Type:~p,TaskNum1:~p",[Type1,TaskNum]),
					case check_task(Type1, TaskType, Time+1, TaskTime) of
						true -> 
							List = get_data(Uid),
							case lists:keyfind(Type, 1, List) of
								{Type, _, _} ->
									case Num < TaskNum of
										true -> 0;	
										_ -> 1
									end;
								_ -> 0
							end;
						_ -> 0
					end;
				_ -> 0
			end;
		_ -> 0
	end.

relife_update_count(Uid, Sid, Type, Num) ->
	Time = get_data_time(Uid),
	Type1 = fun_step_count:transform_type(Type),
	Id = data_relife_task:get_id(Time+1,Type1),
	% ?debug("Id:~p",[Id]),
	% ?debug("Type1:~p",[Type1]),
	case Time >= 0 andalso Time < data_relife_task:max_time() of
		true ->
			case data_relife_task:get_data(Id) of
				{TaskTime, TaskType, TaskNumList} -> 
					case check_task(Type1, TaskType, Time+1, TaskTime) of
						true -> 
							TaskNum = get_task_num(TaskNumList),
							handle_relife_help(Uid, Sid, Type, Num, TaskNum);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

relife_add_count(Uid, Sid, Type, Num) ->
	Time = get_data_time(Uid),
	List = get_data(Uid),
	case lists:keyfind(Type, 1, List) of
		false -> CurrNum = 0;
		{_, CurrNum, _} -> CurrNum;
		_ -> CurrNum = 0
	end,
	Type1 = fun_step_count:transform_type(Type),
	Id = data_relife_task:get_id(Time+1,Type1),
	case Time >= 0 andalso Time < data_relife_task:max_time() of
		true ->
			case data_relife_task:get_data(Id) of
				{TaskTime, TaskType, TaskNumList} -> 
					case check_task(Type1, TaskType, Time+1, TaskTime) of
						true -> 
							TaskNum = get_task_num(TaskNumList),
							handle_relife_help(Uid, Sid, Type, CurrNum+Num, TaskNum);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

handle_relife_help(Uid, Sid, Type, Num, TaskNum) ->
	List = get_data(Uid),
	case lists:keyfind(Type, 1, List) of
		{Type, _, _} ->
			case Num < TaskNum of
				true ->
					Status = 0,
					NewTuple = {Type, util:min(TaskNum, Num), Status},
					% ?debug("NewTuple:~p",[NewTuple]),
					handle_relife_data(Uid, Sid, Type, List, NewTuple);
				_ ->
					Status = 1,
					NewTuple = {Type, util:min(TaskNum, Num), Status},
					% ?debug("NewTuple:~p",[NewTuple]),
					handle_relife_data(Uid, Sid, Type, List, NewTuple)
			end;
		_ -> skip
	end.

handle_relife_data(Uid, Sid, Type, List, NewTuple) ->
	NewList = lists:keystore(Type, 1, List, NewTuple),
	% ?debug("NewList:~p",[NewList]),
	set_data(Uid, NewList),
	send_info_to_client(Uid, Sid).

send_info_to_client(Uid, Sid) ->
	send_info_to_client(Uid, Sid, 0).
send_info_to_client(Uid, Sid, Seq) ->
	List = get_data(Uid),
	% ?debug("List:~p",[List]),
	Time = get_data_time(Uid),
	Pt = #pt_relife_task_info{
		time = Time,
		relife_task_info = make_task_pt(Uid, Time+1, List, [])
	},
	?send(Sid, proto:pack(Pt, Seq)),
	ok.

make_task_pt(_Uid, _Time, [], Acc) -> Acc;
make_task_pt(Uid, Time, [{Type, Num, Status} | Rest], Acc) ->
	Type1 = fun_step_count:transform_type(Type),
	case data_relife_task:get_id(Time, Type1) of
		0 ->
			make_task_pt(Uid, Time, Rest, Acc);
		Id ->
			Pt = #pt_public_relife_task_info{
				task_id = Id,
				task_num = Num,
				task_status = Status
			},
			make_task_pt(Uid, Time, Rest, [Pt | Acc])
	end.

handle_relife(pass_military_boss, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, pass_military_boss, Num);
handle_relife(pass_copy, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, pass_copy, Num);
handle_relife(ch_lev, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, ch_lev, Num);
handle_relife(eqp_lev, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, eqp_lev, Num);
handle_relife(ride_lev, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, ride_lev, Num);
handle_relife(max_gem_lv, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, max_gem_lv, Num);
handle_relife(purple_hero, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, purple_hero, Num);
handle_relife(orange_hero, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, orange_hero, Num);
handle_relife(two_skill_lev, Uid, Sid, _Num) ->
	relife_update_count(Uid, Sid, two_skill_lev, get_skill_num(Uid,two_skill_lev));
handle_relife(three_skill_lev, Uid, Sid, _Num) ->
	relife_update_count(Uid, Sid, three_skill_lev, get_skill_num(Uid,three_skill_lev));
handle_relife(four_skill_lev, Uid, Sid, _Num) ->
	relife_update_count(Uid, Sid, four_skill_lev, get_skill_num(Uid,four_skill_lev));
handle_relife(quick_fight, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, quick_fight, Num);
handle_relife(equip_compose, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, equip_compose, Num);
handle_relife(enter_pk, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, enter_pk, Num);






handle_relife(hero_lev, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, hero_lev, Num);
handle_relife(hero_skill_lev, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, hero_skill_lev, Num);
handle_relife(arena_rank, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, arena_rank, Num);
handle_relife(skill_lev, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, skill_lev, Num);
handle_relife(purple_eqp, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, purple_eqp, Num);
handle_relife(orange_eqp, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, orange_eqp, Num);
handle_relife(fighting, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, fighting, Num);
handle_relife(two_star_hero, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, two_star_hero, Num);
handle_relife(all_star, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, all_star, Num);
handle_relife(shenqi_up, Uid, Sid, Num) ->
	relife_update_count(Uid, Sid, shenqi_up, Num);



handle_relife(add_friend, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, add_friend, Num);
handle_relife(break_eqp, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, break_eqp, Num);
handle_relife(enter_geo, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, enter_geo, Num);
handle_relife(recycle_eqp, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, recycle_eqp, Num);
handle_relife(gem_up, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, gem_up, Num);
handle_relife(monsters, Uid, Sid, Num) ->
	relife_add_count(Uid, Sid, monsters, Num).

get_skill_num(Uid, Type) ->
	Type1 = fun_step_count:transform_type(Type),
	case Type1 >= 36 andalso Type1 =< 38 of
		true -> 
			Time = fun_usr_misc:get_misc_data(Uid, relife_time),
			Id = data_relife_task:get_id(Time + 1, Type1),
			case data_relife_task:get_data(Id) of
				{_, _, List} -> fun_learn_skill:get_skill_lv_num(Uid, hd(List));
				_ -> 0
			end;
		_ -> 0
	end.

get_task_num(List) -> lists:last(List). 