%% @doc 
-module(service_handler).
-include("common.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
	?INFO("Req:~p", [Req]),
	Bindings = cowboy_req:get(bindings, Req),
	Req2 = case lists:keyfind(req_action, 1, Bindings) of
		false -> 
			reply_server_error(Req, "rout config error");
		<<"register">> ->
			do_register(Req);
		Action ->
			reply_server_error(Req, io_lib:format("action not handled:~p", [Action]))
	end,
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

reply_server_error(Req, Reason) ->
	{ok, Req2} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/plain">>}
	], Reason, Req),
	Req2.

do_register(Req) ->
	{ok, Req2} = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/plain">>}
	], "todo", Req),
	Req2.
