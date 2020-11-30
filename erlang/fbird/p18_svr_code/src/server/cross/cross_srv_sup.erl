-module(cross_srv_sup).
-include ("common.hrl").
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([start/0]).

%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start() ->
    ?MODULE:start_link().

init([]) ->
	ServerList = [
		{scene_sup, {scene_sup, start_link, []}, permanent, 5000, supervisor, [scene_sup]},
        ?COMMON_SERVER_SPEC(mod_server_manage, [mod_server_manage, false]),
        ?COMMON_SERVER_SPEC(mod_scene_manager, [mod_scene_manager, true, 30*1000]),
        ?COMMON_SERVER_SPEC(mod_cross_thunderboss, [mod_cross_thunderboss, true, 30*1000]),
        ?COMMON_SERVER_SPEC(mod_cross_server, [mod_cross_server, true, 30*1000])
    ],
    RestartStrategy = {one_for_one, 3, 100000},
	{ok, {RestartStrategy, ServerList}}.

