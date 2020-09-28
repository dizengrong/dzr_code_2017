%% 后台活动——大航海
-module(system_uncharter_water).
-include("common.hrl").
-export([on_act_open/2,on_act_close/2,on_act_change/1]).
-export([on_act_open_help/1]).
-export([to_global/1]).
-export([send_ranklist/1]).

on_act_open(ActType, Status) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[] -> db:insert(#system_activity{act_type=ActType,act_status=Status});
		[Rec = #system_activity{act_status=OldStatus}] ->
			case Status /= OldStatus of
				true ->
					EndTime = set_sailing_end_time(ActType),
					to_global({active_open, EndTime}),
					NewRec = Rec#system_activity{act_status=Status},
					db:dirty_put(NewRec),
					erlang:start_timer(5000, self(), {?MODULE, on_act_open_help, {ActType, Status}});
				_ -> skip
			end
	end.

on_act_open_help({ActType, Status}) ->
	List = db:dirty_match(ply, #ply{_ = '_'}),
	mod_msg:handle_to_chat_server({send_system_speaker, [integer_to_list(753)]}),
	erlang:start_timer(1800000, self(), {?MODULE, send_ranklist, ActType}),
	[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List].

send_ranklist(ActType) ->
	case db:dirty_get(system_activity, ActType, #system_activity.act_type) of
		[#system_activity{act_status=?ACT_OPEN}] ->
			[send_ranklist_help(Uid, Sid) || #ply{uid = Uid, sid = Sid} <- db:dirty_match(ply, #ply{_='_'})],
			erlang:start_timer(1800000, self(), {?MODULE, send_ranklist, ActType});
		_ -> skip
	end.

send_ranklist_help(Uid, Sid) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, _, GuildId} -> to_global({get_ranklist, Uid, Sid, GuildId});
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
					[fun_system_activity:send_info_to_client(Uid, Sid, ActType, Status, 0) || #ply{uid = Uid, sid = Sid} <- List];
				_ -> skip
			end
	end.

on_act_change(ActType) ->
	?log_error("clean guild sailing point data in local"),
	to_global({clean_data, ActType}),
	[db:dirty_del(guild_sailing, Id) || Id <- db:dirty_all_keys(guild_sailing)],
	ok.

to_global(Msg) ->
	Msg2 = {fun_global_uncharter_water, Msg},
	gen_server:cast({global, global_client_ggb}, {to_global, Msg2}).

set_sailing_end_time(ActType) ->
	case data_activity:get_data(ActType) of
		#st_activity{time = Time} ->
			{_,EndTime} = lists:last(Time),
			HH = EndTime div 100,
			MM = EndTime rem 100,
			Now = util_time:unixtime(),
			{Date, _} = util_time:seconds_to_datetime(Now),
			NewTime = util_time:datetime_to_seconds({Date, {HH, MM, 0}}),
			fun_agent_mng:set_global_value(sailing_end_time, NewTime - 1800),
			NewTime;
		_ -> util_time:unixtime()
	end.