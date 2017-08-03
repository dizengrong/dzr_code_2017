%% @author dzr
%% @doc 时间处理方法
-module(util_time).
-export([unixtime/0, longunixtime/0, get_today_date/0]).
-export([weekday/0, weekday/1, seconds_to_datetime/1, week_number/1]).
-export([datetime_to_seconds/1, is_same_day/2, add_days/2, diff_date/2]).
-export([date_to_string/1, time_to_date_string/1]).

-define(GREGORIAN_INTERVIAL_TIME, calendar:datetime_to_gregorian_seconds({{1970,1,1}, {8,0,0}})).

%% unix
unixtime() ->
    {M, S, _} = erlang:now(),
    M * 1000000 + S.

longunixtime() ->
    {M, S, Ms} = erlang:now(),
    M * 1000000000 + S*1000 + Ms div 1000.

week_number(Seconds) when is_integer(Seconds) ->
    {Date, _} =seconds_to_datetime(Seconds),
    week_number(Date);
week_number(Date) when is_tuple(Date) ->
    {_, Num} = calendar:iso_week_number(Date),
    Num.

%%今天星期几
weekday() ->
    {Date, _} = calendar:local_time(),
    weekday(Date).

weekday(Seconds) when is_integer(Seconds)  ->
    {Date, _} =seconds_to_datetime(Seconds),
    weekday(Date);
weekday(Date) when is_tuple(Date) ->
    calendar:day_of_the_week(Date).

%% 返回：{Date, Time}
seconds_to_datetime(MTime)->
    calendar:gregorian_seconds_to_datetime(?GREGORIAN_INTERVIAL_TIME + MTime).

%% 参数Datetime为{Date, Time}
datetime_to_seconds(Datetime)->
    calendar:datetime_to_gregorian_seconds(Datetime) - ?GREGORIAN_INTERVIAL_TIME.

%% 判断俩个时间戳是否是同一天, 是则返回true, 否则返回false
is_same_day(Now1, Now2) ->
    {{YY1, MM1, DD1}, _} = seconds_to_datetime(Now1),
    {{YY2, MM2, DD2}, _} = seconds_to_datetime(Now2),
    (YY1 == YY2 andalso MM1 == MM2 andalso DD1 == DD2).

%% 获取今天的日期
get_today_date() ->
	{Date, _} = calendar:local_time(),
	Date.

%% 增加日期，TheDate可以为{Date, Time}，也可以就是一个Date
add_days(TheDate, Diff) when is_integer(Diff) andalso is_tuple(TheDate) ->
    case TheDate of
        {Date, Time} ->            
            GregDate2 = calendar:date_to_gregorian_days(Date)+Diff,
            {calendar:gregorian_days_to_date(GregDate2), Time};
        _ ->
            GregDate2 = calendar:date_to_gregorian_days(TheDate)+Diff,
            calendar:gregorian_days_to_date(GregDate2)
    end.

%% 计算两个日期的天数差，参数都为:date()
diff_date(Date1, Date2) ->
    erlang:abs( calendar:date_to_gregorian_days(Date1) - calendar:date_to_gregorian_days(Date2) ).


%% Time:date()|{date(), time()}|seconds
time_to_date_string(Time)->
    if
        is_integer(Time) -> 
            {{Y,M,D}, _} = seconds_to_datetime(Time);
        true -> 
            case Time of
                {Y,M,D} -> ok;
                {{Y,M,D}, _} -> ok
            end
    end,
    io_lib:format("~w-~w-~w",[Y,M,D]).


date_to_string(Date)->
    case Date of
        {Y,M,D} -> 
            io_lib:format("~w-~w-~w",[Y,M,D]);
        {{Y,M,D}, {HH,MM,SS}} -> 
            lists:flatten( io_lib:format("~w-~w-~w ~w:~w:~w",[Y,M,D,HH,MM,SS]) )
    end.
