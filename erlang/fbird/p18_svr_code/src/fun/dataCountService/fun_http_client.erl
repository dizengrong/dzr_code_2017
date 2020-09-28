-module(fun_http_client).
-include("common.hrl").
-export([stop/0,do_info/1,do_init/0,do_close/0,do_msg/1,do_call/1,do_time/1,async_http_request/3]).

stop() ->
	gen_server:call(http_client, finish_report, infinity).


do_init()->
	erlang:process_flag(min_heap_size, 1024*1024),
	erlang:process_flag(min_bin_vheap_size, 512*1024),
	application:start(ssl),
	application:start(inets),
	put(report_list, []),
	ok.

do_info({http, Msg}) ->
	async_http_response(Msg); 
do_info(_) ->ok.

do_msg({get_cdkey_info,{Uid,Aid,SvrId,Key,Hid}})-> fun_httpc_request:send_to_background(get_cdkey_info, {Uid,Aid,SvrId,Key}, fun_httpc_request, data_call_back, {get_cdkey_info,Hid});
do_msg({update_cdkey_use,{Uid,Aid,SvrId,Key,_Hid}})-> fun_httpc_request:send_to_background(update_cdkey_use, {Uid,Aid,SvrId,Key});
do_msg({get_versions})-> 
	fun_httpc_request:send_to_background(get_versions, {}, fun_version, get_versions_call_back, {});
do_msg({handle_msg,Module,Msg}) -> Module:handle(Msg);
%% 上报消息
do_msg({Mark,Data}) when Mark == usr_register -> 
	fun_httpc_request:send_to_background(Mark,Data);

do_msg({Mark,Data}) -> 
	put(report_list, [{Mark,Data} | get(report_list)]),
	ok;

do_msg(_Msg) -> 
	?log_error("Msg = ~p",[_Msg]).


do_close()	->ok.


do_call(finish_report) -> 
	List = get(report_list),
	?INFO("Left ~p reports need reporting...", [length(List)]),
	[fun_httpc_request:send_to_background(Mark,Data) || {Mark,Data} <- lists:reverse(List)],
	?INFO("report finished"),
	ok;
do_call(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.


do_time(Time)->
	Now = Time div 1000,
	{_Date, {_Hour, Min, _}} = util_time:seconds_to_datetime(Now),
	case get(http_client_minute) of
		Min -> skip;
		_ ->
			put(http_client_minute, Min),
			do_minute_loop(Now)
	end,
	try
		do_report()
	catch 
	 	E:R -> ?EXCEPTION_LOG(E, R, do_report, [])
	end,
	10*1000.	


do_report() ->
	List = get(report_list),
	Left = do_report_help(lists:reverse(List), 1),
	put(report_list, lists:reverse(Left)),
	ok.


do_report_help([], _Num) -> 
	[]; 
do_report_help([{Mark,Data} | Rest], Num) when Num =< 400 -> 
	fun_httpc_request:send_to_background(Mark,Data),
	do_report_help(Rest, Num + 1);
do_report_help(Left, _Num) -> 
	Left.

	
do_minute_loop(Now) ->
	?TRY_CATCH(fun() -> fun_push_notify:do_minute_loop(Now) end, E2, R2),
	ok.

async_http_request(Method, Request, {Module, Cb_func, Cb_args}) ->
	fun_http:async_http_request(Method, Request, {Module, Cb_func, Cb_args}).
		 
async_http_response(Response) ->
	fun_http:async_http_response(Response).
