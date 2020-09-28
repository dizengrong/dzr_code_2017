%%%-----------------------------------
%%% @Module  : util
%%% @Description: 
%%%-----------------------------------
-module(util).
-export([
        log/5,to_binary/1,f2s/1,to_integer/1,to_atom/1,list_to_atom2/1,to_list/1,to_number/1,
		show/5,unixtime/0,longunixtime/0,get_need_sec/2,check_new_day/1,check_today/1,check_new_day_three/1,
		date/0,date/1,md5/1,rand/2,rand_float/0,abs/1,ceil/1,floor/1,sleep/1,sleep/2,get_list/2,
        implode/2,implode/3,explode/2,explode/3,for/3,for/4,string_to_term/1,bitstring_to_term/1,
        term_to_string/1,unix_to_localtime/1,get_index_of/2,term_to_bitstring/1,map/2,get_bit/2,
		set_bit/3,escape_uri/1,unescape_string/1,unescape_other/1,timestamp/1,test_call/2,fun_call/2,
		key_max/2,key_min/2,gen_ip_list/1,gen_ip_list/2,range/2,sample/2,get_tomorrow_date/0,get_tomorrow_date/1,
		get_relative_day/1,unixtime_to_relative_day/2,relative_day_to_unixtime/2,is_in_time/2,gregorian_seconds_to_unixtime/1,
		random_by_weight/1,intersection/1,intersection/2,log_condition/3,debug_condition/3,eval/2,gen_order_id/0,
		max/2,min/2,get_data_para_num/1,int_list_keyfind/2,list_to_string/2,get_unixtime_date/0,string_list_to_integer_list/2,
		to_string/1,to_string/2,get_name_by_uid/1,get_sid_by_uid/1,get_lev_by_uid/1,get_prof_by_uid/1,get_usr_online/1,
		get_camp_by_uid/1,get_item_bind/1,get_item_color/1,get_item_super/1,get_paragon_level_by_uid/1,
		get_uid_by_name/1,check_lev/2,get_values/2,get_last_logout_time_by_uid/1,get_create_usr_time/1,get_achieve_lev_by_uid/1,
		integration_list/1,integration_list/2,get_usr_scene/1,get_last_login_time_by_uid/1,check_str/1,get_relative_day/2,
		get_data_text/1,string_parse/1,eval_ex/1,box/2,get_relative_weekend_seconds/0,get_relative_week/1,
		
		list_filter_operate/2,is_open_server_third_day/1,is_open_server_second_day/1,
		datetime_to_timestamp/1,get_camp_name/1,get_platfrom_str/1,debug_scene/3,reload/1,format_lang/2,hex2int/1		
    ]).

-include("common.hrl").

-define(SECONDS_FROM_0_TO_1970, 62167248000).
%% -define(SECONDS_FROM_0_TO_1970, calendar:datetime_to_gregorian_seconds({{1970,1,1}, {8,0,0}})).
-define(SECONDS_PER_DAY, 86400).
get_name_by_uid(Uid)->
	case db:dirty_get(usr, Uid) of
		[Usr|_]->
			util:to_list(Usr#usr.name);
		_->""
	end.
%% List
implode(_S, [])->
	[<<>>];
implode(S, L) when is_list(L) ->
    implode(S, L, []).
implode(_S, [H], NList) ->
    lists:reverse([thing_to_list(H) | NList]);
implode(S, [H | T], NList) ->
    L = [thing_to_list(H) | NList],
    implode(S, T, [S | L]).

%% ->
explode(S, B)->
    re:split(B, S, [{return, list}]).
explode(S, B, int) ->
    [list_to_integer(Str) || Str <- explode(S, B), length(Str) > 0].

thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X)   -> float_to_list(X);
thing_to_list(X) when is_atom(X)    -> atom_to_list(X);
thing_to_list(X) when is_binary(X)  -> binary_to_list(X);
thing_to_list(X) when is_list(X)    -> X.

%% 
log(T, F, A, Mod, Line) ->
    {ok, Fl} = file:open("logs/error_log.txt", [write, append]),
    Format = list_to_binary("#" ++ T ++" ~s[~w:~w] " ++ F ++ "\r\n~n"),
    {{Y, M, D},{H, I, S}} = erlang:localtime(),
    Date = list_to_binary([integer_to_list(Y),"-", integer_to_list(M), "-", integer_to_list(D), " ", integer_to_list(H), ":", integer_to_list(I), ":", integer_to_list(S)]),
    io:format(Fl, unicode:characters_to_list(Format), [Date, Mod, Line] ++ A),
	file:close(Fl).    
show(T, F, A, Mod, Line) ->
     Format = list_to_binary("#" ++ T ++" ~s[~w:~w] " ++ F ++ "\r\n~n"),
    {{Y, M, D},{H, I, S}} = erlang:localtime(),
    Date = list_to_binary([integer_to_list(Y),"-", integer_to_list(M), "-", integer_to_list(D), " ", integer_to_list(H), ":", integer_to_list(I), ":", integer_to_list(S)]),
    io:format(unicode:characters_to_list(Format), [Date, Mod, Line] ++ A).

%%获取年月日时分秒
get_unixtime_date()->
	{{Year, Month, Day}, {Hour, Minite, Second}} = calendar:local_time(),
	{Year, Month, Day,Hour, Minite, Second}.


%% unix
unixtime() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.

longunixtime() ->
    {M, S, Ms} = os:timestamp(),
    M * 1000000000 + S*1000 + Ms div 1000.

date() -> unix_to_localtime(unixtime()).
date(Type)->
	{{Year,Mon,Day},{Hour,Min,Sec}}=unix_to_localtime(unixtime()),
	case Type of
		all ->
			(Year*10000000000)+(Mon*100000000)+(Day*1000000)+(Hour*10000)+(Min*100)+Sec;
		year->
			Year;
		yearmonday->
			Year*10000 + Mon*100 +Day;
		_->
			{{Year,Mon,Day},{Hour,Min,Sec}}
	end.

unix_to_localtime(UnixTime) when is_integer(UnixTime) ->
	MegaSecs = UnixTime div 1000000,
	Secs = UnixTime rem 1000000,
	calendar:now_to_local_time({MegaSecs, Secs, 0}).
timestamp(UnixTime) when is_integer(UnixTime)->
	{{Y,M,D},{H,Min,S}}=unix_to_localtime(UnixTime),
	integer_to_list(Y) ++ "-"  ++ integer_to_list(M) ++ "-" ++
	integer_to_list(D) ++ "  " ++ integer_to_list(H) ++ ":" ++ 
	integer_to_list(Min) ++ ":"  ++ integer_to_list(S).

%% 获取当前时间到下一�Hour:Min:00 的相对秒�
get_need_sec(Hour,Min) ->
	{Day,_} = calendar:local_time(),
	Secs = calendar:datetime_to_gregorian_seconds({Day,{Hour, Min, 0}}),
	CurSecs = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	if
		CurSecs > Secs -> ?SECONDS_PER_DAY + Secs - CurSecs;
		true -> Secs - CurSecs
	end.

%% 获取当前时间相对�010.1.1 Hour:00:00 的相对天�
get_relative_day(Hour) when is_integer(Hour)->
	unixtime_to_relative_day(unixtime(), Hour). 

%% 获取当前传入时间相对�010.1.1 Hour:00:00 的相对天�
get_relative_day(Time,Hour) when is_integer(Hour)->
	unixtime_to_relative_day(Time, Hour).

%% 获取当前时间相对�010年第一个DayofWeek Hour:00:00 的相对周�
%% 此接口有问题,取星�就错�AndyLee
%% get_relative_week(DayofWeek, Hour) when is_integer(Hour) andalso is_integer(DayofWeek) andalso (DayofWeek >= 1 andalso DayofWeek =< 7) ->
%% 	Day = (1 + 7 - calendar:day_of_the_week(2010, 1, 1) + DayofWeek) rem 7,
%% 	{RelativeDay, {_Hour, _Min, _Sec}} = calendar:time_difference({{2010,1,Day}, {Hour, 0, 0}}, calendar:local_time()),
%% 	RelativeDay div 7.

%%任意获取一个星期一(2017/1/2)作为参考标�计算传入时间距离固定的参考时间的周数
get_relative_week(Local_Time) ->
	{RelativeDay, _} = calendar:time_difference({{2017,1,2}, {0, 0, 0}}, Local_Time),
	RelativeDay div 7.

%% 获取当前时间相对本周末的秒数
get_relative_weekend_seconds() ->	
	{{Y,M,D},_} = calendar:local_time(),
	T=calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	T1=calendar:datetime_to_gregorian_seconds({{Y,M,D}, {23, 59, 59}}),	
	WeekDay=calendar:day_of_the_week(Y,M,D),
	T_Diff=T1-T,
	DiffDay=7-WeekDay,
	DiffDay*?ONE_DAY_SECONDS + T_Diff.

unixtime_to_relative_day(Timestamp, Hour) ->
	{Day, {_Hour, _Min, _Sec}} = calendar:time_difference({{2010,1,1}, {Hour, 0, 0}}, unix_to_localtime(Timestamp)), 
	Day.


relative_day_to_unixtime(Day, Hour)  when is_integer(Day) andalso is_integer(Hour)->
	BaseTime = calendar:datetime_to_gregorian_seconds({{2010,1,1}, {Hour, 0, 0}}),
	Day * ?SECONDS_PER_DAY + BaseTime - ?SECONDS_FROM_0_TO_1970.

get_tomorrow_date() ->
	get_tomorrow_date(calendar:local_time()).

get_tomorrow_date(DateTime) ->
	Secs = calendar:datetime_to_gregorian_seconds(DateTime) + ?SECONDS_PER_DAY,
	calendar:gregorian_seconds_to_datetime(Secs).

gregorian_seconds_to_unixtime(Secs) ->
	Secs - ?SECONDS_FROM_0_TO_1970.


%% 判断当前时间是否在StartHour:StartMin到EndHour:EndMin这个时间段中
is_in_time({StartHour, StartMin}, {EndHour, EndMin}) when StartHour < EndHour orelse (StartHour == EndHour andalso StartMin < EndMin)->
	Now = {Date,_} = calendar:local_time(),
	CurSecs = calendar:datetime_to_gregorian_seconds(Now),
	StartSecs = calendar:datetime_to_gregorian_seconds({Date,{StartHour, StartMin, 0}}),
	if
		CurSecs >= StartSecs ->
			EndSecs = calendar:datetime_to_gregorian_seconds({Date,{EndHour, EndMin, 0}}),
			CurSecs =< EndSecs;
		true -> false
	end;
is_in_time(_,_)->false.

get_camp_name(2) -> util:get_data_text(152);
get_camp_name(3) -> util:get_data_text(153);
get_camp_name(_Camp) -> "".

%% 超过一�
check_new_day(Time) ->
	Now=util:unixtime(),
	{{_,_,CurrDay},_}=util:unix_to_localtime(Now),
	{{_,_,Day},_}=util:unix_to_localtime(Time),	
	if						
		CurrDay =/= Day andalso Now > Time -> true;	
		true ->	false
	end.

check_today(Time) ->
	CurrDays=get_relative_day(0),
	OldDays=unixtime_to_relative_day(Time, 0),
	if
		CurrDays == OldDays -> true;
		true -> false
	end.	

check_new_day_three(Time) ->
	CurrDays=get_relative_day(3),
	OldDays=unixtime_to_relative_day(Time, 3),
	if
		CurrDays > OldDays -> true;
		true -> false
	end.
%% 	Now=util:unixtime(),
%% 	{Date,_}=util:unix_to_localtime(Time),
%% 	CurrSecs=calendar:datetime_to_gregorian_seconds(util:unix_to_localtime(Now)),
%% 	ThreeSecs=calendar:datetime_to_gregorian_seconds({Date, {3, 0, 0}}),
%% 	%%NewThreeSecs=gregorian_seconds_to_unixtime(ThreeSecs),
%% 	NewDayThree=ThreeSecs + ?ONE_DAY_SECONDS,
%% 	if
%% 		CurrSecs >= NewDayThree -> true;
%% 		true -> false
%% 	end.	

%% HEXmd5
md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).


%%
ceil(N) ->
    T = trunc(N),
    case N == T of
        false -> 1 + T;
        _  -> T
    end.

%%
floor(X) ->
    T = trunc(X),
    case (X < T) of
        false -> T;
        _ -> T - 1
    end.

abs(X) when X < 0 -> -1 * X;
abs(X) -> X.

 sleep(T) ->
    receive
    after T -> ok
    end.

 sleep(T, F) ->
    receive
    after T -> F()
    end.

get_list([], _) ->
    [];
get_list(X, F) ->
    F(X).

%% for
for(I,Max,_F) when I > Max ->skip;
for(Max, Max, F) ->
    F(Max);
for(I, Max, F)   ->
    F(I),
    for(I+1, Max, F).

%% for
%% @return {ok, State}
for(I,Max,_F,State) when I > Max ->{ok, State};
for(Max, Min, _F, State) when Min<Max -> {ok, State};
for(Max, Max, F, State) -> F(Max, State);
for(I, Max, F, State)   -> {ok, NewState} = F(I, State), for(I+1, Max, F, NewState).

%% termtermstringe.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~p", [Term]))).

%% termtermbitstringe.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~p", [Term])).

%% termstringterme.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> throw({string_is_not_erl_term, String})
            end;
        _Error ->
            throw({string_is_not_erl_term, String})
    end.

%% termbitstringterme.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).


%%All To int
to_integer(Msg) when is_integer(Msg) -> 
    Msg;
to_integer(Msg) when is_binary(Msg) ->
	Msg2 = binary_to_list(Msg),
    list_to_integer(Msg2);
to_integer(Msg) when is_list(Msg) -> 
    list_to_integer(Msg);
to_integer(Msg) when is_float(Msg) -> 
    round(Msg);
to_integer(_Msg) ->
    throw({cannot_convert_to_integer, _Msg}).

%% @doc convert other type to binary
to_binary(Msg) when is_binary(Msg) -> 
    Msg;
to_binary(Msg) when is_atom(Msg) ->
	list_to_binary(atom_to_list(Msg));
to_binary(Msg) when is_list(Msg) -> 
	list_to_binary(Msg);
to_binary(Msg) when is_integer(Msg) -> 
	list_to_binary(integer_to_list(Msg));
to_binary(Msg) when is_float(Msg) -> 
	list_to_binary(f2s(Msg));
to_binary(Msg) when is_tuple(Msg) ->
	list_to_binary(tuple_to_list(Msg));
to_binary(_Msg) ->
    throw({cannot_convert_to_binary, _Msg}).

%% @doc convert other type to atom
to_atom(Msg) when is_atom(Msg) -> 
	Msg;
to_atom(Msg) when is_binary(Msg) -> 
	util:list_to_atom2(binary_to_list(Msg));
to_atom(Msg) when is_list(Msg) -> 
    util:list_to_atom2(Msg);
to_atom(_Msg) -> 
    throw({cannot_convert_to_atom, _Msg}).

list_to_atom2(List) when is_list(List) ->
	case catch(list_to_existing_atom(List)) of
		{'EXIT', _} -> erlang:list_to_atom(List);
		Atom when is_atom(Atom) -> Atom
	end.

%% @doc convert other type to list
to_list(Msg) when is_list(Msg) -> 
    Msg;
to_list(Msg) when is_atom(Msg) -> 
    atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> 
    binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) -> 
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> 
    f2s(Msg);
to_list(Msg) when is_tuple(Msg) ->
	tuple_to_list(Msg);
to_list(_Msg) ->
    throw({cannot_convert_to_list, _Msg}).

to_number(Msg) when is_list(Msg) ->	
	case (catch list_to_integer(Msg)) of		
		Value when is_integer(Value) -> Value;		
		_ ->list_to_float(Msg)	
	end;
to_number(Msg) when is_integer(Msg) ->
	Msg;
to_number(Msg) when is_float(Msg) ->
	Msg;
to_number(Msg) when is_binary(Msg) ->
	to_number(binary_to_list(Msg)).		
		
%% @doc convert float to string,  f2s(1.5678) -> 1.57
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.6f", [F]),
	A.

len_pos( X,[ H|T ] ) when X =:=H -> length(T)+1;
len_pos( X,[ H|T ] ) when X =/=H -> len_pos( X,T ).
	
get_index_of( X, List ) ->
	NewList = lists:reverse( List ),
	Index = len_pos( X,NewList ),
	Index.


to_string(AtomList)  when is_list(AtomList) ->
    to_string(AtomList,"");
to_string(_)  ->
    {error,error_type}.

to_string([], R) -> R;
to_string([H|T], R)  when is_atom(H) ->
    to_string(T,atom_to_list(H) ++ R);
to_string([H|T], R)  when is_list(H) ->
    to_string(T,H ++ R);
to_string(_, _)  ->
    {error,error_type}.

string_list_to_integer_list(String,[]) when is_list(String) ->
	[to_number(S) || S <- String];
%% 	case String of
%% 		[H|T]->
%% 			string_list_to_integer_list(T ,[to_number(H)]);
%% 		_->[]
%% 	end;
string_list_to_integer_list(String,R) when is_list(String) ->
	String2 = String ++ R,
	[to_number(S) || S <- String2];	
%% 	case String of
%% 		[H|T]->
%% 			%%string_list_to_integer_list(T,lists:append(R ,[to_number(H)]));
%% 			string_list_to_integer_list(T,[to_number(H)|R]);
%% 		_->R
%% 	end.
string_list_to_integer_list(_String,R)->R.

list_to_string(List,[])->
	case List of
		[H|T]->
			list_to_string(T,integer_to_list(H));
		_->""
	end;
list_to_string(List,R)->
	case List of
		[H|T]->
			%%list_to_string(T,R ++ "," ++ integer_to_list(H));
			list_to_string(T, integer_to_list(H)++","++R);
		_->R
	end.
-spec map(fun((D) -> [R]), [D]) -> [R].
map(F, [H|T]) ->
    lists:append([F(H),map(F, T)]);
map(F, []) when is_function(F, 1) -> [].

% start from 1...
get_bit(Int, Pos) ->
	Index = Pos - 1,
	case Int band (1 bsl Index) of
		0 -> 0;
		_ -> 1
	end.

% start from 1...
set_bit(Int, Pos, 1) ->
	Index = Pos - 1,
	Int bor (1 bsl Index);
set_bit(Int, Pos, 0) ->
	Index = Pos - 1,
	Int band (bnot (1 bsl Index)).

rand_float() -> rand:uniform(1000000) /1000000.
rand(Same, Same)-> Same;
rand(Min, Max) ->
	if 
		Max > Min->	rand:uniform(Max - (Min - 1)) + (Min - 1);
		Max < Min->	rand:uniform(Min - (Max - 1)) + (Max - 1)
	end.

%% url_encode(Data) ->
%%     url_encode(Data,"").
%% 
%% url_encode([],Acc) ->
%%     Acc;
%% 
%% url_encode([{Key,Value}|R],"") ->
%%     url_encode(R, edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value));
%% url_encode([{Key,Value}|R],Acc) ->
%%     url_encode(R, Acc ++ "&" ++ edoc_lib:escape_uri(Key) ++ "=" ++ edoc_lib:escape_uri(Value)).

escape_uri(S) when is_list(S) ->
%%     escape_uri(unicode:characters_to_binary(S));
	escape_uri(list_to_binary(S));
escape_uri(<<C:8, Cs/binary>>) when C >= $a, C =< $z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $A, C =< $Z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $0, C =< $9 ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $. ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $- ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $_ ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) ->
    escape_byte(C) ++ escape_uri(Cs);
escape_uri(<<>>) ->
    "".

escape_byte(C) ->
    "%" ++ hex_octet(C).

hex_octet(N) when N =< 9 ->
    [$0 + N];
hex_octet(N) when N > 15 ->
    hex_octet(N bsr 4) ++ hex_octet(N band 15);
hex_octet(N) ->
    [N - 10 + $A].


%% Converts '%3c' to \<
unescape_other(Str) ->
	unescape_other(Str, []).
unescape_other([], Acc) ->   
   	lists:reverse(Acc);
unescape_other([$%, H1, H2 |T], Acc) ->
    I1 = hex2int(H1),
    I2 = hex2int(H2),
    I = I1 * 16 + I2,
	unescape_other(T, [I, $\ |Acc]);
unescape_other([H|T], Acc) ->
    unescape_other(T, [H|Acc]).

unescape_string(Str) ->
	unescape_string(Str, []).
unescape_string([], Acc) ->   
   	lists:reverse(Acc);
unescape_string([$%, H1, H2 |T], Acc) ->
    I1 = hex2int(H1),
    I2 = hex2int(H2),
    I = I1 * 16 + I2,
	unescape_string(T, [I|Acc]);
unescape_string([H|T], Acc) ->
    unescape_string(T, [H|Acc]).


fun_call(_Num,_N) -> ok.
test_call(_Num,_N)-> ok.

hex2int(H) when H >= $a -> 10 + H - $a;
hex2int(H) when H >= $A -> 10 + H -$A;
hex2int(H) ->  H - $0.

%% key_max([], KeyPos) -> Tuple | {}
key_max(List, KeyPos) ->
	key_max(List, KeyPos, {}).

key_max([], _KeyPos, Ret) ->
	Ret;
key_max([H|T], KeyPos, {}) ->
	key_max(T, KeyPos, H);
key_max([H|T], KeyPos, Ret) ->
	case element(KeyPos, H) > element(KeyPos, Ret) of
	?TRUE -> key_max(T, KeyPos, H);
	?FALSE -> key_max(T, KeyPos, Ret)
	end.

%% key_min([], KeyPos) -> Tuple | {}
key_min(List, KeyPos) ->
	key_min(List, KeyPos, {}).

key_min([], _KeyPos, Ret) ->
	Ret;
key_min([H|T], KeyPos, {}) ->
	key_min(T, KeyPos, H);
key_min([H|T], KeyPos, Ret) ->
	case element(KeyPos, H) < element(KeyPos, Ret) of
	?TRUE -> key_min(T, KeyPos, H);
	?FALSE -> key_min(T, KeyPos, Ret)
	end.


%% range(Min, Max) -> [Min,Min+1,Min+2,...,Max]
range(Min, Max) when Min>=0,Max>=Min->
	range(Min, Max, []).
range(Min, Min, L)->
	[Min|L];
range(_, 0, L)->
	L;
range(Min, Max, L)->
	range(Min, Max-1, [Max|L]).

%% gen_ip_list("1.2.3.4/30") -> IpList
gen_ip_list(CidrIp) when erlang:is_list(CidrIp)->
	[A,B,C,D,MaskBits] = string:tokens(CidrIp, "./"),
	gen_ip_list({list_to_integer(A), list_to_integer(B), list_to_integer(C), list_to_integer(D)}, list_to_integer(MaskBits)).
	
gen_ip_list(Ip, MaskBits) ->
	{A, B, C, D} = Ip,
	{M1, M2, M3, M4} = cidr_netmask(MaskBits),
	NetworkAddr = {A band M1, B band M2, C band M3, D band M4},
	BroadcastAddr = {A bor ((bnot M1) band 16#ff), B bor ((bnot M2) band 16#ff), C bor ((bnot M3) band 16#ff), D bor ((bnot M4) band 16#ff)},
	gen_ip_list_by_range(NetworkAddr,BroadcastAddr).
	
gen_ip_list_by_range(NetworkAddr, BroadcastAddr) ->
	{Na1, Na2, Na3, Na4} = NetworkAddr,
	{Ba1, Ba2, Ba3, Ba4} = BroadcastAddr,

	F3 = fun(V) ->
			lists:map(fun(_V)->erlang:list_to_tuple(V++[_V]) end, range(Na4, Ba4))
		end,
	
	F2 = fun(V) ->
			List = lists:map(fun(_V)->V++[_V] end, range(Na3, Ba3)),
			lists:map(F3, List)
		end,

	F1 = fun(V) ->
			List = lists:map(fun(_V)->[V,_V] end, range(Na2, Ba2)),
			lists:map(F2, List)
		 end,
	lists:flatten(lists:map(F1, range(Na1, Ba1))).
		
cidr_netmask(Bits) when is_integer(Bits) andalso Bits =< 32 ->
    ZeroBits = 8 - (Bits rem 8),
    Last = (16#ff bsr ZeroBits) bsl ZeroBits,
    
    case (Bits div 8) of
        0 ->
            {(255 band Last), 0, 0, 0};
        1 ->
            {255, (255 band Last), 0, 0};
        2 ->
            {255, 255, (255 band Last), 0};
        3 ->
            {255, 255, 255, (255 band Last)};
        4 ->
            {255, 255, 255, 255}
    end.

sample(List, N) when erlang:is_list(List) andalso erlang:is_integer(N) ->
	if 
		N < 0 orelse length(List) < N ->
			erlang:error(badarg);
		true ->
			sample(List, N, [])
	end.
sample(_List, N, RetList) when N =< 0 ->
	RetList;
sample(List, N, RetList) ->
  	Len = length(List),
	Index = rand:uniform(Len),
	{L1, L2} = lists:split(Index, List),
	{L3, [Elem]} = lists:split(length(L1) - 1, L1),
	sample(L2++L3, N-1, [Elem|RetList]).

random_by_weight(List) ->
	F = fun({_Data, Weight}, Total) ->
			Total + Weight
		end,
	TotalWeight = lists:foldl(F, 0, List),
	random_by_weight(List, rand:uniform() * TotalWeight, 0).

random_by_weight([{Data, Weight}|Next], R, Total) ->
	if 
		R =< Weight + Total ->
			Data;
		true ->
			random_by_weight(Next, R, Total + Weight)
	end;
random_by_weight([], _R, _Total) ->
	erlang:error(badarg).

intersection(L1, L2) ->
	lists:filter(fun(Elem)->lists:member(Elem, L1) end, L2).
intersection([L1,L2|Rest]) ->
	intersection1(intersection(L1,L2),Rest);
intersection([L]) -> L.

intersection1(L1, [L2|Rest]) ->
	intersection1(intersection(L1,L2), Rest);
intersection1(L, []) -> L.
	
log_condition(Param,Condition,Log)->
	if
		Param==Condition -> ?log_error("~p --------------- ~n ",[Log]);
		true -> skip
	end.
debug_condition(Param,Condition,_Log)->
	if
		Param==Condition -> ?log_error("~p --------------- ~n ",[_Log]);
		true -> skip
	end.
	
eval(S,Environ) ->
    {ok,Scanned,_} = erl_scan:string(S),
    {ok,Parsed} = erl_parse:parse_exprs(Scanned),
    erl_eval:exprs(Parsed,Environ).

eval_ex(S) ->
    {ok,Scanned,_} = erl_scan:string(S++"."),
    {ok,Parsed} = erl_parse:parse_exprs(Scanned),
    {value, Value,_} = erl_eval:exprs(Parsed,orddict:new()),
	Value.

%%获取常亮表数值
get_data_para_num(Id)->
	data_para:get_data(Id).

gen_order_id() ->
	% server_id(1-3bytes) + timestamp(13bytes) + index(1-3bytes)
	GroupId = db:get_all_config(serverid),
	Idx = 
	case get(order_id_idx) of
		N when erlang:is_integer(N) -> N;
		_ -> 0
	end,
	put(order_id_idx,Idx+1),
	string:join([util:to_list(GroupId), util:to_list(unixtime()), util:to_list(Idx rem 1000)], "").

int_list_keyfind(ID,List)->
	List -- [ID] == List.

max(A,B) when A > B -> A;
max(_A,B)  -> B.

min(A,B) when A < B -> A;
min(_A,B)  -> B.

get_sid_by_uid(Uid)->
	case db:dirty_get(ply, Uid) of
		[Ply|_]->
			Ply#ply.sid;
		_->0
	end.
get_lev_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[Usr|_]->
			Usr#usr.lev;
		_->0
	end.
get_last_logout_time_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[#usr{last_logout_time=LastLogoutTime,last_login_time=LastLoginTime}|_]->
			if LastLogoutTime == 0->
				   LastLoginTime;
			   true->LastLogoutTime
			end;
		_->0
	end.
get_last_login_time_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[#usr{last_logout_time=LastLogoutTime,last_login_time=LastLoginTime}|_]->
			if LastLogoutTime >= LastLoginTime->LastLogoutTime;
			   true->LastLoginTime
			end;
		_->0
	end.
get_prof_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[Usr|_]->
			Usr#usr.prof;
		_->0
	end.
get_camp_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[Usr|_]->
			Usr#usr.camp;
		_->0
	end.
get_usr_online(Uid)->
	case db:dirty_get(ply, Uid) of
		[_Ply|_]->?STATE_ONLINE;
		_P->?STATE_OFFLINE
	end.
get_usr_scene(Uid)->
	case db:dirty_get(ply, Uid) of
		[#ply{scene_type=SceneType}|_]->SceneType;
		_P->0
	end.
get_item_bind(ItemType)->
	case data_item:get_data(ItemType) of
		#st_item_type{bind=Bind}->
			if Bind == 1 ->1;
			   true->0
			end;
		_->0
	end.
get_item_color(ItemType)->
	case data_item:get_data(ItemType) of
		#st_item_type{color=Color}-> Color;
		_->1
	end.	
get_item_super(ItemType)->
	case data_item:get_data(ItemType) of
		#st_item_type{max=Max}->
			case Max of
				1->false;
				_->true
			end;
		_->false
	end.

get_paragon_level_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[Usr|_]->
			Usr#usr.paragon_level;
		_->0
	end.

get_achieve_lev_by_uid(Uid)->
	case db:get_usr(Uid,?TRUE) of
		[Usr|_]->
			Usr#usr.achieve_lev;
		_->0
	end.
get_uid_by_name(Name)->
	case db:get_usr_by_name(Name) of
		[#usr{id=Uid}]->Uid;
		_->0
	end.

check_lev(Uid,NeedLev) ->	
	case  db:get_usr(Uid,?TRUE) of
		[#usr{lev=Lev,paragon_level=PLev} |_]->
			MaxLev = data_update_lev:max_lev(),
			if
				NeedLev > MaxLev ->	PLev >= (NeedLev-MaxLev);
				true ->	Lev >= NeedLev
			end;			
		_ -> false
	end.
get_create_usr_time(Uid)->
	case  db:get_usr(Uid,?TRUE) of
		[#usr{create_time=CreateTime}|_]->CreateTime;
		_->0
	end.
get_values(KeyList, KvList) ->
	get_values(KeyList, KvList, []).
get_values([K|Rest], List, Ret) ->
	case lists:keyfind(K, 1, List) of
		{K, V} -> get_values(Rest, List, [V|Ret]);
		_ -> false
	end;

get_values([], _, Ret) -> lists:reverse(Ret).

integration_list(List)->
	Fun = fun({Id,Num},Acc)->
				  case lists:keyfind(Id, 1, Acc) of
					  {Id,OldNum}->
						  lists:keyreplace(Id, 1, Acc, {Id,OldNum+Num});												
					  _ ->
						  %%lists:append(Acc, [{Id,Num}])
						  [{Id,Num}|Acc]		 	
				  end
		  end,
	lists:foldl(Fun, [], List).
integration_list(List1,List2) ->
	Fun=fun({Id,Num,Bind},Acc) ->
			  case lists:keyfind(Id, 1, Acc) of
				  {Id,OldNum,Bind}->
					  lists:keyreplace(Id, 1, Acc, {Id,OldNum+Num,Bind});
				  _->
					  [{Id,Num,Bind}|Acc]
			  end				
		end,
	lists:foldl(Fun, List2, List1).

check_str(Content) when is_binary(Content) ->
	check_str(binary_to_list(Content));
check_str(Content)->
	if
		length(Content)==0 -> false;
		true ->
			String = util_lang:cant_words(),
			UnicodeStr = xmerl_ucs:from_utf8(Content),
			lists:all(fun(Char) -> string:chr(UnicodeStr, Char) == 0 end, String)
	end.

get_data_text(Id)-> 
	util_lang:get_text_str(Id).


string_parse(Str)->
	Len = length(Str),
	F = fun(Start, AccList) ->
				Element = string:substr(Str, Start, 1),
				[Element | AccList]
		end,
	lists:foldr(F, [], lists:seq(1, Len)).

%% [util:935] ----------_R=["2","0","1","7","-","0","1","-","0","4"," ","1",
%%     "5",":","1","4",":","3","7"]
%%2017-01-04 15:14:37 {Year,Mon,Day},{Hour,Min,Sec}
%% string_data(Str)->
%% 	case string_parse(Str) of
%% 		[SYear1,SYear2,SYear3,SYear4,_,SMon1,SMon2,_,SDay1,SDay2,_,SHour1,SHour2,_,SMin1,SMin2,_,SSec1,SSec2]->
%% 			Year = to_integer(SYear1++SYear2++SYear3++SYear4),
%% 			Mon = to_integer(SMon1++SMon2),
%% 			Day = to_integer(SDay1++SDay2),
%% 			Hour = to_integer(SHour1++SHour2),
%% 			Min = to_integer(SMin1++SMin2),
%% 			Sec = to_integer(SSec1++SSec2),
%% 			calendar:datetime_to_gregorian_seconds({{Year,Mon,Day}, {Hour,Min,Sec}})-?SECONDS_FROM_0_TO_1970;
%% 		_R->?debug("----------_R=~p",[_R]),0
%% 	end.
box(BoxId,Prof)->
	case fun_scene_drop_item:drop_box(BoxId, Prof) of
		DropList when is_list(DropList) ->
			Fun = fun({ItemType,ItemNum,_,_},Acc)->
						  %%lists:append(Acc, [{ItemType,ItemNum}])
						  [{ItemType,ItemNum}|Acc]
				  end,
			lists:foldl(Fun, [], DropList);
		_->[]
	end.


%% 	L1 -- L2.
list_filter_operate(L1,L2) ->
	Set = gb_sets:from_list(L2),   
	[E || E <- L1, not gb_sets:is_element(E, Set)].

%%开服第三天以后
is_open_server_third_day(OpenServerTime) ->
	Now=util:unixtime(),
	{Date,_}=util:unix_to_localtime(OpenServerTime),
	OpenServerSecs = calendar:datetime_to_gregorian_seconds(util:unix_to_localtime(OpenServerTime)),
	StartSecs=calendar:datetime_to_gregorian_seconds({Date, {0, 0, 0}}),
	Sec = StartSecs - OpenServerSecs,
	if
		Now >= OpenServerTime + ?ONE_DAY_SECONDS*2 + Sec ->	true;
		true -> false	
	end.
is_open_server_second_day(OpenServerTime) ->
	Now=util:unixtime(),
	{Date,_}=util:unix_to_localtime(OpenServerTime),
	OpenServerSecs = calendar:datetime_to_gregorian_seconds(util:unix_to_localtime(OpenServerTime)),
	StartSecs=calendar:datetime_to_gregorian_seconds({Date, {0, 0, 0}}),
	Sec = StartSecs - OpenServerSecs,
	if
		Now >= OpenServerTime + ?ONE_DAY_SECONDS + Sec ->	true;
		true -> false	
	end.

get_platfrom_str(DeviceToken) ->
	Len=erlang:length(util:to_list(DeviceToken)),
	if
		Len > 0 ->	"IOS";		
		true -> "ANDROID"
	end.

datetime_to_timestamp(DateTime) ->
    calendar:datetime_to_gregorian_seconds(DateTime) -
       calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}}).

debug_scene(SceneType, MsgDesc,[])->
	Scene=get(scene),
	if
		Scene == SceneType->	
			?debug("~p",[MsgDesc]);
		true -> skip
	end,
	ok;
debug_scene(SceneType, MsgDesc,MsgData)->
	Scene=get(scene),
	if
		Scene == SceneType->	
			?debug(MsgDesc,MsgData);
		true -> skip
	end,
	ok.

reload(Module) ->
    code:purge(Module),
    case code:load_file(Module) of
        {module, Module} ->
            ?log_error("Reloading ~p ... ok.", [Module]),
            reload;
        {error, Reason} ->
            ?log_error("Reloading module:~p fail: ~p.", [Module, Reason]),
            error
    end.

format_lang(Message,Argument) when is_list(Argument)-> 
    lists:flatten(io_lib:format(Message,Argument) ).

