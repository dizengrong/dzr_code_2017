%% 系统活动全局模块
-module(fun_system_activity).
-include("common.hrl").
-export([check_time/1,init/1]).
-export([req_system_act_info/3]).
-export([find_open_activity/1,send_info_to_client/5]).
-export([check_time_help/2,on_activity_status_change/2]).

%% 活动与对应的模块设置
%% 通过回调的方式来实现gm活动，统一处理公共的东西 
get_system_act_module(?SYSTEM_LIMIT_BOSS) 	 	-> 	system_activity_limitboss;
get_system_act_module(?SYSTEM_DOUBLE_REWARD)	-> 	system_double_reward;
get_system_act_module(?SYSTEM_UNCHARTER_WATER)  -> 	system_uncharter_water;
get_system_act_module(?SYSTEM_MELLEBOSS) 		-> 	system_melleboss;
get_system_act_module(?SYSTEM_ARENA) 			-> 	system_arena.

init(Now) ->
	[init(Now, ActType) || ActType <- ?ALL_SYSTEM_ACT].
init(Now, ActType) ->
	Status = case check_time_help(Now, ActType) of
		open -> ?ACT_OPEN;
		_ -> ?ACT_CLOSE
	end,
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec);
				_ -> skip
			end
	end.

check_time(Now) ->
	[check_time(Now, ActType) || ActType <- ?ALL_SYSTEM_ACT].
check_time(Now, ActType) ->
	NewNow = Now + 300,
	Status = case check_time_help(Now, ActType) of
		open -> ?ACT_OPEN;
		_ -> ?ACT_CLOSE
	end,
	Status1 = case check_time_help(NewNow, ActType) of
		open -> ?ACT_OPEN;
		_ -> ?ACT_CLOSE
	end,
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> skip;
		[#system_activity{act_status=OldStatus}] ->
			case Status1 /= OldStatus andalso Status1 == ?ACT_OPEN of
				true ->
					on_activity_data_change(ActType);
				_ -> skip
			end,
			case Status /= OldStatus of
				true ->
					on_activity_status_change(ActType, Status);
				_ -> skip
			end
	end.

check_time_help(Now, ActType) ->
	{_, {Hour, Min, _}} = util_time:seconds_to_datetime(Now),
	case data_activity:get_data(ActType) of
		#st_activity{time=ActTime} ->
			Fun = fun({Start,End},Acc) ->
				case util_time:check_activity(Start,End,Hour,Min) of
					true -> [open | Acc];
					false -> Acc
				end
			end,
			List = lists:foldl(Fun, [], ActTime),
			case lists:member(open, List) of
				true -> open;
				_ -> close
			end;
		_ -> error
	end.

req_system_act_info(Uid, Sid, Seq) ->
	send_info_list_to_client(Uid, Sid, Seq).

send_info_list_to_client(_Uid, Sid, Seq) ->
	Pt = #pt_all_system_activity{
		list = [make_act_pt(ActType) || ActType <- ?ALL_SYSTEM_ACT]
	},
	?send(Sid, proto:pack(Pt, Seq)).

make_act_pt(ActType) ->
	Status = case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> ?ACT_CLOSE;
		[#system_activity{act_status=OldStatus}] -> OldStatus
	end,
	#pt_public_system_activity_info{id=ActType,status=Status}.

on_activity_status_change(ActType, Status) ->
	Module = get_system_act_module(ActType),
	?log_warning("system activity status change ~p", [{ActType, Status}]),
	case Status of
		?ACT_OPEN -> Module:on_act_open(ActType, Status);
		?ACT_CLOSE -> Module:on_act_close(ActType, Status)
	end.

on_activity_data_change(ActType) ->
	Module = get_system_act_module(ActType),
	Module:on_act_change(ActType).

send_info_to_client(_Uid, Sid, ActType, Status, Seq) ->
	Pt = #pt_system_activity{id = ActType, status = Status},
	?send(Sid, proto:pack(Pt, Seq)).

find_open_activity(ActType) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> {error, "no_actiyity"};
		[Rec = #system_activity{act_status=Status}] ->
			case Status of
				?ACT_OPEN -> {ok, Rec};
				_ -> {error, "act_close"}
			end
	end.