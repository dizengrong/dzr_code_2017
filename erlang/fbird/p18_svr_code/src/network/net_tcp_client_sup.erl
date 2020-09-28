%% @doc 网络tcp客户端监控者
-module(net_tcp_client_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child ={net_tcp_client, 
            {net_tcp_client, start_link, []},
            temporary, 30000, worker,
            [net_tcp_client]},
    {ok,{{simple_one_for_one,10,10}, [Child]}}.

