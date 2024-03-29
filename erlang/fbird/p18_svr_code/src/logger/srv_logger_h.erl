%%%----------------------------------------------------------------------
%%% srv_logger_h
%%% 
%%%
%%%----------------------------------------------------------------------

-module(srv_logger_h).
-include("common.hrl").

-behaviour(gen_event).

%% gen_event callbacks
-export([init/1, handle_event/2, handle_call/2, handle_info/2, terminate/2,code_change/3]).

-export([rotate_log/1]).

-record(state, {fd, file,date}).

%%%----------------------------------------------------------------------
%%% Callback functions from gen_event
%%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok, State}          |
%%          Other
%%----------------------------------------------------------------------
init(File) ->
    trunk_at_next_day(),
	{Date,_} = erlang:localtime(),
    case file:open(File, [append, raw]) of
	{ok, Fd} ->
	    {ok, #state{fd = Fd,date = Date, file = File}};
	Error ->
        io:format("Error:~p", [Error]),
	    Error
    end.

%%----------------------------------------------------------------------
%% Func: handle_event/2
%% Returns: {ok, State}                                |
%%          {swap_handler, Args1, State1, Mod2, Args2} |
%%          remove_handler                              
%%----------------------------------------------------------------------
handle_event(Event, State) ->
    write_event(State#state.fd, {erlang:localtime(), Event}),
    {ok, State}.

%%----------------------------------------------------------------------
%% Func: handle_call/2
%% Returns: {ok, Reply, State}                                |
%%          {swap_handler, Reply, Args1, State1, Mod2, Args2} |
%%          {remove_handler, Reply}                            
%%----------------------------------------------------------------------
handle_call(_Request, State) ->
    Reply = ok,
    {ok, Reply, State}.

%%----------------------------------------------------------------------
%% Func: handle_info/2
%% Returns: {ok, State}                                |
%%          {swap_handler, Args1, State1, Mod2, Args2} |
%%          remove_handler                              
%%----------------------------------------------------------------------
handle_info({'EXIT', _Fd, _Reason}, _State) ->
    remove_handler;

handle_info(trunk_file, State) ->
    File = util_server:get_log_filename(),
    trunk_at_next_day(),

    file:close(State#state.fd),
    % rotate_log(State#state.file),
    case file:open(File, [append, raw]) of
	{ok, Fd} ->
	    {ok, State#state{fd = Fd, file = File}};
	Error ->
	    Error
    end;

handle_info({emulator, GL, Chars}, State) ->
    write_event(State#state.fd, {erlang:localtime(), {emulator, GL, Chars}}),
    {ok, State};

handle_info(_Info, State) ->
    {ok, State}.

%%----------------------------------------------------------------------
%% Func: terminate/2
%% Purpose: Shutdown the server
%% Returns: any
%%----------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------

% Copied from erlang_logger_file_h.erl
write_event(Fd, {Time, {error, _GL, {Pid, Format, Args}}}) ->
    T = write_time(Time),
    case catch io_lib:format(add_node(Format,Pid), Args) of
	S when is_list(S) ->
	    file:write(Fd, io_lib:format(T ++ S, []));
	_ ->
	    F = add_node("ERROR: ~w - ~w~n", Pid),
	    file:write(Fd, io_lib:format(T ++ F, [Format,Args]))
    end;
write_event(Fd, {Time, {emulator, _GL, Chars}}) ->
    T = write_time(Time),
    case catch io_lib:format(Chars, []) of
	S when is_list(S) ->
	    file:write(Fd, io_lib:format(T ++ S, []));
	_ ->
	    file:write(Fd, io_lib:format(T ++ "ERROR: ~w ~n", [Chars]))
    end;
write_event(Fd, {Time, {info, _GL, {Pid, Info, _}}}) ->
    T = write_time(Time),
    file:write(Fd, io_lib:format(T ++ add_node("~w~n",Pid), [Info]));
write_event(Fd, {Time, {error_report, _GL, {Pid, std_error, Rep}}}) ->
    T = write_time(Time),
    S = format_report(Rep),
    file:write(Fd, io_lib:format(T ++ S ++ add_node("", Pid), []));
write_event(Fd, {Time, {info_report, _GL, {Pid, std_info, Rep}}}) ->
    T = write_time(Time, "INFO REPORT"),
    S = format_report(Rep),
    file:write(Fd, io_lib:format(T ++ S ++ add_node("", Pid), []));
write_event(Fd, {Time, {info_msg, _GL, {Pid, Format, Args}}}) ->
    T = write_time(Time, "INFO REPORT"),
    case catch io_lib:format(add_node(Format,Pid), Args) of
	S when is_list(S) ->
	    file:write(Fd, io_lib:format(T ++ S, []));
	_ ->
	    F = add_node("ERROR: ~w - ~w~n", Pid),
	    file:write(Fd, io_lib:format(T ++ F, [Format,Args]))
    end;
write_event(Fd, {Time, {warning_report, _GL, {Pid, std_warning, Rep}}}) ->
    T = write_time(Time, "WARNING REPORT"),
    S = format_report(Rep),
    file:write(Fd, io_lib:format(T ++ S ++ add_node("", Pid), []));
write_event(Fd, {Time, {warning_msg, _GL, {Pid, Format, Args}}}) ->
    T = write_time(Time, "WARNING REPORT"),
    case catch io_lib:format(add_node(Format,Pid), Args) of
	S when is_list(S) ->
	    file:write(Fd, io_lib:format(T ++ S, []));
	_ ->
	    F = add_node("ERROR: ~w - ~w~n", Pid),
	    file:write(Fd, io_lib:format(T ++ F, [Format,Args]))
    end;
write_event(_, _) ->
    ok.

format_report(Rep) when is_list(Rep) ->
    case string_p(Rep) of
	true ->
	    io_lib:format("~s~n",[Rep]);
	_ ->
	    format_rep(Rep)
    end;
format_report(Rep) ->
    io_lib:format("~w~n",[Rep]).

format_rep([{Tag,Data}|Rep]) ->
    io_lib:format("    ~w: ~w~n",[Tag,Data]) ++ format_rep(Rep);
format_rep([Other|Rep]) ->
    io_lib:format("    ~w~n",[Other]) ++ format_rep(Rep);
format_rep(_) ->
    [].

add_node(X, Pid) when is_atom(X) ->
    add_node(atom_to_list(X), Pid);
add_node(X, Pid) when node(Pid) /= node() ->
    lists:concat([X,"** at node ",node(Pid)," **~n"]);
add_node(X, _) ->
    X.

string_p([]) ->
    false;
string_p(Term) ->
    string_p1(Term).

string_p1([H|T]) when is_integer(H), H >= $\s, H < 255 ->
    string_p1(T);
string_p1([$\n|T]) -> string_p1(T);
string_p1([$\r|T]) -> string_p1(T);
string_p1([$\t|T]) -> string_p1(T);
string_p1([$\v|T]) -> string_p1(T);
string_p1([$\b|T]) -> string_p1(T);
string_p1([$\f|T]) -> string_p1(T);
string_p1([$\e|T]) -> string_p1(T);
string_p1([H|T]) when is_list(H) ->
    case string_p1(H) of
	true -> string_p1(T);
	_    -> false
    end;
string_p1([]) -> true;
string_p1(_) ->  false.

write_time(Time) -> write_time(Time, "ERROR REPORT").

write_time({{Y,Mo,D},{H,Mi,S}}, Type) ->
    io_lib:format("~n=~s==== ~w-~.2.0w-~.2.0w ~.2.0w:~.2.0w:~.2.0w ===~n",
		  [Type, Y, Mo, D, H, Mi, S]).

%% @doc Rename the log file if exists, to "*-old.log".
%% This is needed in systems when the file must be closed before rotation (Windows).
%% On most Unix-like system, the file can be renamed from the command line and
%% the log can directly be reopened.
%% @spec (Filename::string()) -> ok
rotate_log(Filename) ->
    case file:read_file_info(Filename) of
	{ok, _FileInfo} ->
	    RotationName = filename:rootname(Filename),
		file:rename(Filename, [RotationName, "-old.log"]),
	    ok;
	{error, _Reason} ->
	    ok
    end.


%%通知服务器在下一个整点刷新日志文件
trunk_at_next_day() ->
    {{_, _, _Day}, {H, I, S}} = erlang:localtime(),
    Time = ((24 - H) + (59 - I) * 60 + (59 - S) + 2) * 1000,
    erlang:send_after(Time, self(), trunk_file).          

