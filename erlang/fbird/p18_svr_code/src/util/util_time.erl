%% @doc 时间处理方法
-module(util_time).
-export([unixtime/0, longunixtime/0, get_today_date/0, local_time/0]).
-export([weekday/0, weekday/1, seconds_to_datetime/1, week_number/1]).
-export([datetime_to_seconds/1, is_same_day/2, add_days/2, diff_date/2]).
-export([time_to_string/1, time_to_full_string/1, time_to_file_string/1, local_time_file_str/0]).
-export([get_date_num/0,diff_date_by_datetime/2,get_now_time/0]).
-export([next_day_zero_clock/0, next_day_zero_left_secs/0, next_week_zero_clock_left_secs/0]).
-export([seconds_to_now_tuple/1]).
-export([seconds_to_datetime2/1, datetime_to_seconds2/1, diff_secs_by_time/2,diff_secs_time/1,diff_secs_time/3]).
-export([one_day_seconds/0,one_week_seconds/0]).

one_day_seconds() -> 24 * 3600.
one_week_seconds() -> 7 * 24 * 3600.

%% unix
unixtime() ->
    {M, S, _} = erlang:timestamp(),
    M * 1000000 + S.


longunixtime() ->
    {A, B, C} = erlang:timestamp(),
    A * 1000000000 + B*1000 + trunc(C/1000).


local_time() ->
    calendar:local_time().


seconds_to_now_tuple(S) ->
    A = S div 1000000,
    B = S rem 1000000,
    {A, B, 0}.


%% 隔天零点时刻(秒数)
next_day_zero_clock() ->
    24*3600 + unixtime() - calendar:time_to_seconds(erlang:time()).


%% 离下一个零点时刻的剩余秒数
next_day_zero_left_secs() -> 
    24*3600 - calendar:time_to_seconds(erlang:time()).


%% 离星期七零点剩余秒数
next_week_zero_clock_left_secs() ->
    {Date, Time} = calendar:local_time(),
    (7 - weekday(Date)) *24*3600 +   24*3600 - calendar:time_to_seconds(Time).


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

%% 参数可以为时间戳或者Date
weekday(Seconds) when is_integer(Seconds)  ->
    {Date, _} = seconds_to_datetime(Seconds),
    weekday(Date);
weekday(Date) when is_tuple(Date) ->
    calendar:day_of_the_week(Date).


%% 返回：{Date, Time}
seconds_to_datetime(Seconds)-> 
    calendar:gregorian_seconds_to_datetime(server_config:get_conf(timezone_secs) + Seconds).


%% 无时区配置的计算 返回：{Date, Time}
seconds_to_datetime2(Seconds)->
    NowTuple = seconds_to_now_tuple(Seconds),
    calendar:now_to_local_time(NowTuple).


%% 参数Datetime为{Date, Time}
datetime_to_seconds(DT) ->
    calendar:datetime_to_gregorian_seconds(DT) - server_config:get_conf(timezone_secs).


%% 无时区配置的计算 参数Datetime为{Date, Time}
datetime_to_seconds2(DT) ->
    NowSeconds = unixtime(),
    DT2 = calendar:local_time(),
    S1  = calendar:datetime_to_gregorian_seconds(DT),
    S2  = calendar:datetime_to_gregorian_seconds(DT2),
    S1 - S2 + NowSeconds.


%% 判断俩个时间戳是否是同一天, 是则返回true, 否则返回false
is_same_day(Now1, Now2) ->
    {{YY1, MM1, DD1}, _} = seconds_to_datetime(Now1),
    {{YY2, MM2, DD2}, _} = seconds_to_datetime(Now2),
    (YY1 == YY2 andalso MM1 == MM2 andalso DD1 == DD2).


%% 获取今天的日期
get_today_date() ->
	{Date, _} = calendar:local_time(),
	Date.


%% 获取今天是几号
get_date_num() ->
    {{_, _, D}, _} = calendar:local_time(),
    D.

%% 获取现在的时间
get_now_time() ->
    {_, T} = calendar:local_time(),
    T.

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
diff_date(D1, D2) ->
    D = calendar:date_to_gregorian_days(D1) - calendar:date_to_gregorian_days(D2),
    erlang:abs(D).


%% 计算两个时间戳的天数差
diff_date_by_datetime(DateTime1, DateTime2) ->
    {Date1, _} = seconds_to_datetime(DateTime1),
    {Date2, _} = seconds_to_datetime(DateTime2),
    diff_date(Date1,Date2).


%% 计算两个时间的秒数差 T1 T2:{Hour, Minute, Second}
diff_secs_by_time(T1, T2) -> 
    calendar:time_to_seconds(T1) - calendar:time_to_seconds(T2).


%% Time:date()|{date(), time()}|seconds
time_to_string(Time)->
    if
        is_integer(Time) -> 
            {{Y,M,D}, _} = seconds_to_datetime(Time);
        true -> 
            case Time of
                {Y,M,D} -> ok;
                {{Y,M,D}, _} -> ok
            end
    end,
    util_str:format_string("~w-~w-~w",[Y,M,D]).


%% Time:date()|{date(), time()}|seconds
time_to_full_string(Time) ->
    if
        is_integer(Time) -> 
            {{Y,M,D}, {HH,MM,S}} = seconds_to_datetime(Time);
        true -> 
            case Time of
                {Y,M,D} ->
                    {HH,MM,S} = {0, 0, 0}, 
                    ok;
                {{Y,M,D}, {HH,MM,S}} -> ok
            end
    end,
    util_str:format_string("~w-~w-~w ~w:~w:~w",[Y,M,D,HH,MM,S]).


%% 用于文件命名用的时间字符串
%% Time:date()|{date(), time()}|seconds
time_to_file_string(Time) -> 
    if
        is_integer(Time) -> 
            {{Y,M,D}, {HH,MM,S}} = seconds_to_datetime(Time);
        true -> 
            case Time of
                {Y,M,D} ->
                    {HH,MM,S} = {0, 0, 0}, 
                    ok;
                {{Y,M,D}, {HH,MM,S}} -> ok
            end
    end,
    util_str:format_string("~w_~2.2.0w_~2.2.0w_~2.2.0w_~2.2.0w_~2.2.0w",[Y,M,D,HH,MM,S]).


%% 使用本地时间作为文件命名用的时间字符串
local_time_file_str() ->
    {{Y,M,D}, {HH,MM,S}} = calendar:local_time(),
    util_str:format_string("~w_~2.2.0w_~2.2.0w_~2.2.0w_~2.2.0w_~2.2.0w",[Y,M,D,HH,MM,S]).


%% 计算距离当前时间差T:{Hour, Minute, Second}
%% DecSecs:指定时间前多少秒
%% IncSecs:指定时间后多少秒
diff_secs_time(T) ->
    diff_secs_time(T,0,0).
diff_secs_time(T,DecSecs,IncSecs) ->  
    Now = {Date,_} = calendar:local_time(),
    Secs = calendar:datetime_to_gregorian_seconds(Now),
    TSecs = calendar:datetime_to_gregorian_seconds({Date,T}),
    DisSecs = TSecs - DecSecs - Secs + IncSecs,
    if
        DisSecs < 0 -> DisSecs + 86400;
        true -> DisSecs
    end.

