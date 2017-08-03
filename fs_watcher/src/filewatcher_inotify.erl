%% @doc Watch for changed files using inotifywait.
%%      https://github.com/rvoicilas/inotify-tools/wiki


-module(filewatcher_inotify).
-include("common.hrl").
-author("Arjan Scherpenisse <arjan@scherpenisse.net>").

-behaviour(gen_server).

%% gen_server exports
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).

-record(state, {port, executable, timers=[]}).

%% interface functions
-export([
    is_installed/0
]).


%%====================================================================
%% API
%%====================================================================
%% @doc Starts the server
-spec start_link() -> {ok, pid()} | ignore | {error, term()}.
start_link() ->
    case os:find_executable("inotifywait") of
        false ->
            {error, "inotifywait not found"};
        Executable ->
            gen_server:start_link({local, ?MODULE}, ?MODULE, [Executable], [])
    end.

-spec is_installed() -> boolean().
is_installed() ->
    os:find_executable("inotifywait") =/= false.

%%====================================================================
%% gen_server callbacks
%%====================================================================

%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore               |
%%                     {stop, Reason}
%% @doc Initiates the server.
init([Executable]) ->
    process_flag(trap_exit, true),
    State = #state{executable=Executable},
    kill_old_inotifywait(),
    rsync_handler:init_exclude_pattern(),
    {ok, State, 0}.


%% @doc Trap unknown calls
handle_call(Message, _From, State) ->
    {stop, {unknown_call, Message}, State}.


%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @doc Trap unknown casts
handle_cast(Message, State) ->
    {stop, {unknown_cast, Message}, State}.


%% @doc Reading a line from the inotifywait program. Sets a timer to
%% prevent duplicate file changed message for the same filename
%% (e.g. if a editor saves a file twice for some reason).
handle_info({Port, {data, {eol, Line}}}, State=#state{port=Port}) ->
    ReOpts = [{capture, all_but_first, list}],
    case re:run(Line, "^(.+) (MODIFY|CREATE|DELETE|MODIFY,ISDIR) (.+)", ReOpts) of
        nomatch ->
            {noreply, State};
        {match, [Path, Verb, File]} ->
            Filename = filename:join(Path, File),
            case filewatcher_handler:file_blacklisted(Filename) of
                true -> 
                    ?INFO("exclude file: ~p", [Filename]);
                false ->
                    case get(last_change_timer) of
                        undefined ->
                            Timer = erlang:send_after(5000, self(), {filechange, Verb, Filename}),
                            put(last_change_timer, Timer);
                        _ -> ignore
                    end
            end,
            {noreply, State}
    end;

%% @doc Launch the actual filechanged notification
handle_info({filechange, Verb, Filename}, State) ->
    erase(last_change_timer),
    filewatcher_handler:file_changed(Verb, Filename),
    {noreply, State};

handle_info({Port,{exit_status,Status}}, State=#state{port=Port}) ->
    ?INFO("[inotify] inotify port closed with ~p, restarting in 5 seconds.", [Status]),
    erlang:send_after(5000, self(), timeout),
    {noreply, State#state{port=undefined}};

handle_info({'EXIT', Port, _}, State=#state{port=Port}) ->
    ?INFO("[inotify] inotify port closed, restarting in 5 seconds.~n"),
    erlang:send_after(5000, self(), timeout),
    {noreply, State#state{port=undefined}};

handle_info(timeout, #state{port=undefined} = State) ->
    {noreply, start_inotify(State)};
handle_info(timeout, State) -> 
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

%% @spec terminate(Reason, State) -> void()
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
terminate(_Reason, #state{port=undefined}) ->
    ok;
terminate(_Reason, #state{port=Port}) ->
    catch erlang:port_close(Port),
    kill_old_inotifywait(),
    ok.

%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @doc Convert process state when code is changed
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%====================================================================
%% support functions
%%====================================================================

start_inotify(State=#state{executable=Executable}) ->
    Dirs = setting:watch_dirs(),
    Args = ["-q",  "-m", "-r" |  Dirs],
    Port = erlang:open_port({spawn_executable, Executable}, [{args, Args}, {line, 10240}, exit_status]),
    ?INFO("Starting inotify file monitor, Port:~p, dirs:~p~n", [Port, Dirs]),
    State#state{port=Port}.

kill_old_inotifywait() ->
    ok.
    % os:cmd("killall inotifywait").

% verb("MOVED_TO") -> moved_to;
% verb("CREATE") -> create;
% verb("MODIFY") -> modify;
% verb("MODIFY,ISDIR") -> modify;
% verb("DELETE") -> delete.


