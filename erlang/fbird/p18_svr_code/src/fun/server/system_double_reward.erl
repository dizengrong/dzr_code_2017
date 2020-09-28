%% 后台活动——限时boss
-module(system_double_reward).
-include("common.hrl").
-export([on_act_open/2,on_act_close/2,on_act_change/1]).
-export([is_double/1]).
% -export([get_rank_reward/1,delay_kick_all_usr/1]).

on_act_open(ActType, Status) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec),
					List = db:dirty_match(ply, #ply{_ = '_'}),
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List];
				_ -> skip
			end
	end.

on_act_close(ActType, Status) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec),
					List = db:dirty_match(ply, #ply{_ = '_'}),
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List];
				_ -> skip
			end
	end.

on_act_change(_ActType) -> ok.

is_double(List) ->
	case fun_system_activity:find_open_activity(?SYSTEM_DOUBLE_REWARD) of
		{ok,_} ->
			[{T, N*2, L} || {T,N,L} <- List];
		_ -> List
	end.