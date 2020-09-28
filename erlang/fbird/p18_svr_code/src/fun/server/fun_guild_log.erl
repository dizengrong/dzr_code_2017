%% @doc 公会日志
-module (fun_guild_log).
-include("common.hrl").
-export ([add_log/2, get_log/1, del_data/1]).
%% for test 
-export ([test_fill_log/1]).

%% =============================================================================
get_data(GuildId) ->
	case db_api:dirty_read(t_guild_event_log, GuildId) of
		[] -> #t_guild_event_log{guild_id = GuildId, log_queue = queue:new()};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	db_api:dirty_write(Rec).

del_data(GuildId) ->
	db_api:dirty_delete(t_guild_event_log, GuildId).
%% =============================================================================

add_log(GuildId, List) ->
	Rec = get_data(GuildId),
	Q = Rec#t_guild_event_log.log_queue,
	Fun = fun({Time,Type,Uid,TUid}, AccQ) ->
		Log = #{uid => Uid, be_uid => TUid, type => Type, time => Time},
		queue:in_r(Log, AccQ)
	end,
	NewQ = lists:foldl(Fun, Q, List),
	set_data(Rec#t_guild_event_log{log_queue = remove_old_date_log(NewQ)}).

remove_old_date_log(Q) -> 
	remove_old_date_log(Q, util_time:unixtime()).

remove_old_date_log(Q, Now) -> 
	case queue:peek_r(Q) of
		{value, #{time := LogTime}} ->
			case util_time:diff_date_by_datetime(Now, LogTime) > 1 of
				true -> 
					{_, Left} = queue:out_r(Q),
					remove_old_date_log(Left, Now);
				_ -> 
					Q
			end;
		_ -> Q
	end.


get_log(GuildId) ->
	Rec = get_data(GuildId),
	queue:to_list(Rec#t_guild_event_log.log_queue).


%% =================================== test ==================================== 
test_fill_log(GuildId) ->
	% Rec = get_data(GuildId),
	% set_data(Rec#t_guild_event_log{log_queue = queue:from_list(List)}).
	List = [
		{util:unixtime() - 24*3600,?SUCCESS_GUILD_CREATE,1110000000001,0},
		{util_time:unixtime() - 24*3600,?SUCCESS_KICK_GUILD,1110000000001,1110000000002},
		{util_time:unixtime() - 3600, ?SUCCESS_GUILD_CHANGE_NAME, 1110000000001, 0},
		{util_time:unixtime() - 2400,?SUCCESS_GUILD_JION,1110000000002,1110000000001},
		{util_time:unixtime() - 600,?SUCCESS_QUIT_GUILD,1110000000002,0},
		{util_time:unixtime(),?SUCCESS_GUILD_DISMISS,1110000000001,0}
	],
	add_log(GuildId, List).

