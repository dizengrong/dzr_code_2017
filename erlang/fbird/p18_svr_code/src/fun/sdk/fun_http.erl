-module(fun_http).

-include("common.hrl").

-export([async_http_request/3, async_http_response/1]).
-export([make_url/2, urlencode/1]).

async_http_request(Method, Request, {Module, Cb_func, Cb_args}) ->
	case httpc:request(Method, Request, [{timeout, 5000}], [{sync, false}, {receiver, self()}]) of
		{ok, RequestId} when erlang:is_reference(RequestId) ->
			case get(http_request_info) of
				L when erlang:is_list(L) ->
					RequestInfoList = L;
				_ ->
					RequestInfoList = []
			end,
			put(http_request_info, lists:keystore(RequestId, 1, RequestInfoList, {RequestId, {Module, Cb_func, Cb_args}})),
			% ?debug("http request,method=~p,~s", [Method, request_to_string(Request)]),
			{ok, RequestId};
		{error, Reason} ->
			?log_warning("http request error, reason=~w", [Reason]),
			error;
		Other -> 
			?log_warning("unknown ret,value=~w", [Other]),
			error
	end.

async_http_response(Response) ->
	case Response of
		{RequestId, ResponseData} ->
			RequestInfoList = case get(http_request_info) of
				L when is_list(L) -> L;
				_ -> []
			end,
			case lists:keyfind(RequestId, 1, RequestInfoList) of
				{RequestId, {Module, Cb_func, Cb_args}} ->
					put(http_request_info, lists:keydelete(RequestId, 1, RequestInfoList)),
					try
						case ResponseData of
							{StatusLine, _Headers, Body} -> Module:Cb_func({StatusLine, Body}, Cb_args);
							{error, Reason} -> Module:Cb_func({error,Reason}, Cb_args);
							_Other -> ?log_warning("async_http_response callback error,response=~p", [Response])
						end
					catch E:R -> ?log_error("async_http_response callback error,E=~p,R=~p,stack=~p", [E,R,erlang:get_stacktrace()])
					end;
				_ ->
					% ?log_warning("invalid http request,request_id=~p", [RequestId]),
					skip
			end;
		
		Other ->
			?log_warning("http response error,response=~p", [Other])
	end.

	
% request_to_string(Request) ->
% 	case Request of
% 		{Url, _} ->
% 			io_lib:format("url=~s", [Url]);
% 		{Url, _, _, Data} ->
% 			io_lib:format("url=~s,data=~s", [Url, Data])
% 	end.


%% Url="http://www.abc.com/xxxx"
%% KvList=[{"a","1"},{"b","xx"}]
make_url(Url, KvList) ->
	Url ++ "?" ++ urlencode(KvList).

urlencode(KvList) when is_list(KvList) ->
	lists:flatten(string:join(lists:map(fun({K,V})-> io_lib:format("~s=~s", [to_str(K),to_str(V)]) end, KvList),
				 "&")).

					

to_str(V) when is_list(V) -> http_uri:encode(V);
to_str(V) when is_binary(V) -> http_uri:encode(util:to_list(V));
to_str(V) -> util:to_list(V).