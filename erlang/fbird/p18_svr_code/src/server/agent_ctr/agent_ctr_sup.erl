-module(agent_ctr_sup).
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
    AgentCtr = {agent_ctr, {agent_ctr, start_link, []}, permanent, 5000, worker, [agent_ctr]},
    AgentSup = {agent_sup, {agent_sup, start_link, []}, permanent, 5000, supervisor, [agent_sup]},
    SvrList = [	
        ?COMMON_SERVER_SPEC(mod_ets_service, [mod_ets_service, true, 6*60*1000]),
        ?COMMON_SERVER_SPEC(mod_account_service, [mod_account_service, false]),
        ?COMMON_SERVER_SPEC(mod_rank_service, [mod_rank_service, true, 60 * 1000]),
        ?COMMON_SERVER_SPEC(mod_cross_client, [mod_cross_client, false]),
        ?COMMON_SERVER_SPEC(mod_mail_new, [mod_mail_new, false]),
        % ?COMMON_SERVER_SPEC(mod_activity_service, [mod_activity_service, true, tick_loop]),
		?COMMON_SERVER_SPEC(mod_server_manage, [mod_server_manage, false]),
        ?COMMON_SERVER_SPEC(fun_gm_activity_ex, [fun_gm_activity_ex, true, tick_loop]),
        % ?COMMON_SERVER_SPEC(fun_family, [fun_family, true, tick_loop]),
        ?COMMON_SERVER_SPEC(fun_mining_service, [fun_mining_service, true, tick_loop]),
        ?COMMON_SERVER_SPEC(fun_http_server, [fun_http_server, true, tick_loop]),
        ?COMMON_SERVER_SPEC(fun_relation_srv, [fun_relation_srv, true, tick_loop]),
        ?COMMON_SERVER_SPEC(mod_trace_role, [mod_trace_role, true, 60 * 1000]),
        ?COMMON_SERVER_SPEC(mod_hero_expedition, [mod_hero_expedition, 5 * 1000]),
		{http_client, {world_svr, start_link,[http_client,fun_http_client]}, permanent, 5000, worker, [world_svr]},
		{agent_mng, 	{world_svr,start_link,[agent_mng,fun_agent_mng]},permanent, 5000, worker, [world_svr]},			   			   
		% {guild_mng, 	{world_svr,start_link,[guild_mng,fun_guild_mng]},permanent, 5000, worker, [world_svr]},
        {chat_server, {world_svr,start_link,[chat_server,fun_chat_server]},permanent, 5000, worker, [world_svr]},
        ?SUPERVISOR_SPEC(net_tcp_sup, [])
	],
    RestartStrategy = {one_for_one, 3, 100000},
	{ok, {RestartStrategy, [AgentCtr, AgentSup | SvrList]}}.


