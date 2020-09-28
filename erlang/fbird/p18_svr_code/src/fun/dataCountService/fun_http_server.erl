-module(fun_http_server).
-include("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([do_notice/1]).

init() -> 
	ssl:start(),
	start_listen(),
	ok.

start_listen() ->
	inets:start(),
	{ok, Pid} = inets:start(httpd, ?HTTPD_LISTEN_SET),
	put(httpserver,Pid),
	init_id(),
	ok.


handle_call({all_notice,Start,End,Frequency,Text})->
	Id=get_id(),
	put({notice, Id}, #notice_data{id=Id,startTime=Start,endTime=End,frequency=Frequency,text=Text}),
	Now = util_time:unixtime(),
	DiffSecs = ?_IF(Start > Now, Start - Now, Frequency),
	srv_loop:add_callback(DiffSecs, ?MODULE, do_notice, Id),
	Id;	
handle_call(Request) -> 
	?ERROR("unhandled request:~p", [Request]),
	no_reply.


handle_msg({rescind_notice,Id}) -> 	
	erase({notice, Id});

handle_msg(Msg) ->
	?ERROR("unhandled msg:~p", [Msg]),
	ok.


terminate() ->
	case get(httpserver) of  
		Pid when erlang:is_pid(Pid)->
			inets:stop(httpd, Pid);
		_ ->
			skip
	end,
	ok.


do_loop(_Now) -> 
	ok.


do_notice(Id) -> 
	case get({notice, Id}) of
		#notice_data{id=Id,endTime=End,frequency=Frequency,text=Text} ->
			Now = util_time:unixtime(),
			case Now =< End of
				true -> 
					send_notice(Text),
					case Now + Frequency =< End of
						true -> 
							srv_loop:add_callback(Frequency, ?MODULE, do_notice, Id);
						_ -> 
							erase({notice, Id}),
							skip
					end;
				_ -> 
					erase({notice, Id})
			end;
		_ -> erase({notice, Id})
	end.


send_notice(Text)-> 
	fun_chat:agentmng_chat(system,{["264",Text],gm}).


init_id()->
	put(notice_id,1).
get_id()->
	Id=get(notice_id),
	put(notice_id,Id+1),
	Id.



