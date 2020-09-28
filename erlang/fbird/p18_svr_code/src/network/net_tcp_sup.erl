%% @doc 网络模块监控者
-module(net_tcp_sup).
-include ("common.hrl").
-behaviour(supervisor).

-export([start_link/0, start_acceptor/1, stop_acceptors/0]).

-export([init/1]).

-define(SERVER, ?MODULE).
-define(ACCEPTOR_NUM, 10).


start_link() ->
	{ok,Pid} = supervisor:start_link({local, ?SERVER}, ?MODULE, []),
	{ok, Pid}.


init([]) ->
	Children = [
		{net_tcp_listener, {net_tcp_listener, start_link, []}, transient, 100, worker, [net_tcp_listener]},
		{net_tcp_client_sup, {net_tcp_client_sup, start_link, []}, permanent, infinity, supervisor, [net_tcp_client_sup]}
	],
	{ok, {{one_for_one,10,10}, Children}}.


%% @doc tcp监听成功后启动acceptor
start_acceptor(LSock) ->
	_ = [start_acceptor_help(LSock, Index) || Index <- lists:seq(1, ?ACCEPTOR_NUM)].

start_acceptor_help(LSock, Index) ->
	Name = list_to_atom("net_tcp_acceptor_" ++ integer_to_list(Index)),
	Acceptor  = {Name, {net_tcp_acceptor, start_link, [LSock]}, transient, brutal_kill, worker, [net_tcp_acceptor]},
	{ok, APid} = supervisor:start_child(?SERVER, Acceptor),
    APid ! {event, start}.


stop_acceptors() -> 
	Fun = fun({ChildId, _, Type, _}) ->
		Type == worker andalso supervisor:terminate_child(?SERVER, ChildId)
	end,
	List = supervisor:which_children(?SERVER),
	[Fun(T) || T <- List].

