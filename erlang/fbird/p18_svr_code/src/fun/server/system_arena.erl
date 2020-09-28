%% 后台活动——竞技场
-module(system_arena).
-include("common.hrl").
-export([on_act_open/2,on_act_close/2,on_act_change/1]).
-export([on_act_open_help/1]).

on_act_open(ActType, Status) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec),
					List = db:dirty_match(ply, #ply{_ = '_'}),
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List],
					erlang:start_timer(util:get_data_para_num(1237)*1000, self(), {?MODULE, on_act_open_help, ActType});
				_ -> skip
			end
	end.

on_act_open_help(ActType) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[#system_activity{act_status = ?ACT_OPEN}] ->
			fun_arena_new:on_daily_season_start(),
			erlang:start_timer(util:get_data_para_num(1237)*1000, self(), {?MODULE, on_act_open_help, ActType});
		_ -> skip
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
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List],
					erlang:start_timer(120000, self(), {fun_arena_new, on_daily_season_end});
				_ -> skip
			end
	end.

on_act_change(_ActType) -> skip.