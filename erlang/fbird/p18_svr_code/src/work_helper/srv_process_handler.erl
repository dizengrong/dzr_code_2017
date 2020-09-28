%% -*- coding: utf-8 -*-
%% @doc 系统服务进程处理
-module (srv_process_handler).
-include("common.hrl").
-compile(export_all).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.


handle(Req, State) -> 
	Bindings = cowboy_req:get(bindings, Req),
	Req2 = case lists:keyfind(pid, 1, Bindings) of
		false -> 
			show_all_process(Req);
		{_, Pid0} ->
			Pid = list_to_pid(binary_to_list(Pid0)),
			show_process_dict(Req, Pid)
	end,
	
	{ok, Req2, State}.

	
terminate(_Reason, _Req, _State) ->
	ok.


show_all_process(Req) ->
	Children = supervisor:which_children(agent_ctr_sup) ++ supervisor:which_children(scene_ctr_sup),
	Children2 = [{RegName, util_str:term_to_str(Pid)} || {RegName, Pid, _, _} <- Children],
	Dict = [
		{"processes", Children2}
	],
	{ok, Reply} = page_srv_processes:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


show_process_dict(Req, Process) ->
	Dict = onlines_handler:get_process_info_dict(Process),
	{ok, Reply} = tpl_process_info:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.
