-module(fun_plat_interface_lyn).
-include("common.hrl").

-export([gen_order/3,verify_order/1,remove_order/1]).
%% -define(GAMEID, "7").
%% -define(GAMEKEY, "E961FC2174FEF0BB03CD749667F1D4FB").
-define(GAMEID, "10").
-define(GAMEKEY, "YQEC43YDK4L00HNOD81H7HENDE2WXRJ7").

-export([auth/7,sign_pay/1]).
-export([http_request_cb/2]).

http_request(Url, {Module, Cb_func, Cb_args}) ->
	case lists:member({Cb_func, 2}, Module:module_info(exports)) of
		false ->
			erlang:error(invalid_callback);
		_ ->
			fun_http:async_http_request(get, {Url, []}, {?MODULE, http_request_cb, {Module, Cb_func, Cb_args}})
	end.


http_request_cb({{_HttpVersion, StatusCode, Desc}, Body}, {Module, Cb_func, Cb_args}) ->
	case StatusCode of
		200 ->
			Module:Cb_func(Body, Cb_args);
		_R ->
			?log_warning("http response error,code=~p,desc=~p", [StatusCode,Desc])
	end;
http_request_cb({error, Reason}, _) ->
	?log_warning("http response error,reason=~p",[Reason]).
	%Module:Cb_func(false, Cb_args).

sign_pay(ValueList) ->
	F = fun(V, Ret) -> Ret ++ util:to_list(V) end,
	%%Str = lists:foldl(F, "", ValueList) ++ ?GAMEKEY,
	GameKey=db:get_all_config(gamekey),
	Str = lists:foldl(F, "", ValueList) ++ GameKey,
	string:to_upper(util:md5(Str)).

sign_auth_new(SourceId, DeviceId, DeviceNo, UserId, UserName, QQ, Mobile, Email, TimeStamp, Token) ->
	%%Str = ?GAMEID ++ SourceId ++ DeviceId ++ DeviceNo ++ UserId ++ UserName ++ QQ ++ Mobile ++ Email ++ util:to_list(TimeStamp) ++ Token ++ ?GAMEKEY,
	GameID=db:get_all_config(gameid),
	GameKey=db:get_all_config(gamekey),	
	Str = GameID ++ SourceId ++ DeviceId ++ DeviceNo ++ UserId ++ UserName ++ QQ ++ Mobile ++ Email ++ util:to_list(TimeStamp) ++ Token ++ GameKey,
	string:to_upper(util:md5(Str)).

auth(CBInfo, SourceId, DeviceId, DeviceNo, UserId, UserName,Token) ->
	QQ = "",
	Mobile = "",
	Email = "",
	Time = util:unixtime(),
	Sign = sign_auth_new(SourceId, DeviceId, DeviceNo, UserId, UserName, QQ, Mobile, Email, Time, Token), 

    Adder=db:get_all_config(sdk),
	GameID=db:get_all_config(gameid),
	Url = lists:flatten(io_lib:format(Adder++"/Api/CheckToken?GameID=~s&SourceID=~s&DeviceID=~s&DeviceNo=~s&UserID=~s&UserName=~s&QQ=~s&Mobile=~s&EMail=~s&Times=~p&Token=~s&Sign=~s",
				[GameID, SourceId, DeviceId, DeviceNo, UserId, http_uri:encode(UserName), QQ, Mobile, Email, Time, util:escape_uri(Token), Sign])),
	http_request(Url, CBInfo).




gen_order(Uid, Type, Price) ->
	OrderId = util:gen_order_id(),
	OrderInfo =
	case get(ch_order_info) of
		undefined -> dict:new();
		Dict -> Dict
	end,
	put(ch_order_info, dict:store(OrderId, {Uid,Type,Price}, OrderInfo)),
	OrderId.

verify_order(OrderId) ->
	case get(ch_order_info) of
		undefined -> error;
		Dict ->
			case dict:find(OrderId, Dict) of
				{ok, {Uid,Type,Price}} ->{Uid,Type,Price};
				_ -> 
					?log_trace("verify_order false,OrderId = ~p,Dict = ~p",[OrderId,Dict]),
					error
			end
	end.

remove_order(OrderId) ->
	case get(ch_order_info) of
		undefined -> skip;
		Dict -> put(ch_order_info, dict:erase(OrderId, Dict))
	end.



