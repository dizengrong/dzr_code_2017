-module(rsync_service_app).
-behaviour(application).

-export([start/0, start/2]).
-export([stop/1]).

start() -> 
	start(undefind, undefind).
start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/[:req_action]", service_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
		{env, [{dispatch, Dispatch}]}
	]),
	rsync_service_sup:start_link().

stop(_State) ->
	ok.
