-module(work_helper_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/[:req_action]", helper_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8081}], [
		{env, [{dispatch, Dispatch}]}
	]),
	work_helper_sup:start_link().

stop(_State) ->
	ok.
