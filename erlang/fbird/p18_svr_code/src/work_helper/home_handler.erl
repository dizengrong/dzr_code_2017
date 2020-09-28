%% -*- coding: utf-8 -*-
-module (home_handler).
-compile(export_all).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) -> 
	Dict = [],
	{ok, Reply} = page_home:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	{ok, Req2, State}.


terminate(_Reason, _Req, _State) ->
	ok.


