%%%-------------------------------------------------------------------
%% @doc fs_watcher top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(fs_watcher_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
	Children = [{filewatcher_inotify,
                  {filewatcher_inotify, start_link, []},
                  permanent, 5000, worker, [filewatcher_inotify]},
                {rsync_watchdog,
                  {rsync_watchdog, start_link, []},
                  permanent, 5000, worker, [rsync_watchdog]}
               ],
    RestartStrategy = {one_for_one, 5, 10},
    {ok, {RestartStrategy, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
