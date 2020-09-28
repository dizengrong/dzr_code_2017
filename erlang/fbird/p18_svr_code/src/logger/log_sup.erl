%% Author: Administrator
%% Created: 2012-1-31
%% Description: TODO: Add description to log_app
-module(log_sup).
-include ("common.hrl").

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local,?MODULE}, ?MODULE, []).


init([]) ->
	List = [
	],
	{ok, {{one_for_one, 3, 10}, List}}.
	


