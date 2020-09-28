%% @doc 烈焰鸟SDK登陆
-module (mod_sdk_lyn).
-include("common.hrl").
-export([lyn_auth/6]).


lyn_auth(ClientState, JsStr, Type, Line, Log_Package, Seq) ->
	?debug("lyn_auth~p",[{JsStr,Type,Line, Log_Package,Seq}]),
	case rfc4627:decode(JsStr) of
		{ok, JsonObj, _Reminder} ->
			{obj, KvList} = JsonObj,
			F = fun(Key) -> lists:keymember(Key, 1, KvList) end,
			case lists:all(F, ["SourceID", "UserID", "UserName", "DeviceID", "DeviceNo", "Token"]) of
				true ->
					{"SourceID", SourceID} = lists:keyfind("SourceID", 1, KvList),
					{"UserID", UserID} = lists:keyfind("UserID", 1, KvList),
					{"UserName", UserName} = lists:keyfind("UserName", 1, KvList),
					{"DeviceID", DeviceID} = lists:keyfind("DeviceID", 1, KvList),
					{"DeviceNo", DeviceNo} = lists:keyfind("DeviceNo", 1, KvList),
					{"Token", Token} = lists:keyfind("Token", 1, KvList),
					
					Args = {Line,Type,SourceID,UserID,Log_Package,Seq},
					case fun_login_token:check_zero(util:to_list(UserID)) of
						true ->
							Ret = fun_plat_interface_lyn:auth(
									util:to_list(SourceID), 
									util:to_list(DeviceID), 
								 	util:to_list(DeviceNo),
								 	util:to_list(UserID), 
								 	util:to_list(UserName), 
								 	util:to_list(Token)
								),
							auth_reply(ClientState, Ret, Args);
						_ ->
							case fun_login_token:check({util:to_list(SourceID),util:to_list(UserID),util:to_list(DeviceID)}) of
								true ->
									Ret = fun_plat_interface_lyn:auth(
											util:to_list(SourceID), 
											util:to_list(DeviceID),
											util:to_list(DeviceNo), 
										 	util:to_list(UserID), 
										 	util:to_list(UserName), 
										 	util:to_list(Token)
										 ),
									auth_reply(ClientState, Ret, Args);
								_ ->
									%%模拟token验证通过后的执行
									{PlatformID,UsrCenterData} = fun_login_token:get_data({util:to_list(SourceID),util:to_list(UserID),util:to_list(DeviceID)}),
									on_auth_succ(ClientState#client_state.socket,Seq,util:to_integer(SourceID),[{"data", UsrCenterData}]),
									Account = util:to_list(PlatformID),
									fun_plat_interface_lyn:no_token_report(util:to_list(PlatformID)),
									net_tcp_client:do_normal_login(ClientState,Account,Account,Seq,PlatformID,util:to_integer(SourceID),"")
							end
					end;
				_ ->
					?error_report(ClientState#client_state.socket,"args_not_true"),
					net_tcp_client:do_terminate(lyn_auth_failed, ClientState),
					{stop, normal, ClientState}
			end;
		_R ->
			?error_report(ClientState#client_state.socket,"args_not_true"),
			net_tcp_client:do_terminate(lyn_auth_failed, ClientState),
			{stop, normal, ClientState}
	end.


auth_reply(ClientState, Reply, Args) -> 
	case Reply of
		{error, Reason} -> 
			net_tcp_client:do_terminate(Reason, ClientState),
			{stop, normal, ClientState};
		{ok, {_StatusCode, _Headers, Body}} ->
			auth_reply2(ClientState, Body, Args)
	end.


auth_reply2(ClientState, Data, {_Line, Type, SourceID, _UserID, _Log_Package, Seq}) ->
	DataList = string:tokens(util:to_list(Data), "|"),
	Result= lists:nth(1, DataList),	
	case Result of
		"1" ->
			LynUserId = lists:nth(2, DataList),
			PlatformID = lists:nth(5, DataList),
			
			%%此处尴尬
			%%此参数后台用于区别IOS和Android,可能传空,导致解析出来的列表没有空
			DeviceToken= if
							 erlang:length(DataList) == 7 -> lists:nth(6, DataList);
							 true -> ""
						 end,
			?debug("lyn_auth_callback_success,Data=~p,DataList=~w,PlatformID=~p",[Data,DataList,PlatformID]), 
			on_auth_succ(ClientState#client_state.socket, Seq,Type,[{"data", Data}]),
			%% 2019-0312:现在直接使用PlatformID作为账号了，不在像以前那样拼接一个:"lynid_"了
			Account = PlatformID,
			Ret = net_tcp_client:do_normal_login(ClientState,Account,Account,Seq,util:to_integer(PlatformID),util:to_integer(SourceID),DeviceToken),
			
			%%更新token验证时间
			if
				erlang:length(DataList) == 7 ->
					DeviceID=lists:nth(7, DataList),%%设备ID
					fun_login_token:update({util:to_list(LynUserId),util:to_list(DeviceID),util:to_integer(PlatformID),Data});
				erlang:length(DataList) == 6 ->
					DeviceID=lists:nth(6, DataList),%%设备ID
					fun_login_token:update({util:to_list(LynUserId),util:to_list(DeviceID),util:to_integer(PlatformID),Data});
				true -> skip
			end,
			Ret;
		_ ->
			%%?debug("lyn auth failed,errorcode=~p,msg=~s,now=~p", [Result,Data,util:unixtime()]),
			?log_error("lyn auth failed,errorcode=~p,msg=~s,now=~p", [Result,Data,util:unixtime()]),
			on_auth_fail(ClientState#client_state.socket, Seq, util:to_list(Data)),
			?error_report(ClientState#client_state.socket,"sdk_auth_fail"),
			net_tcp_client:do_terminate("lyn auth failed", ClientState),
			{stop, normal, ClientState}
	end.


on_auth_succ(Socket, Seq, PlatformType, KvList) ->
	Fun = fun({K, V})->
			case is_list(V) of
				true ->
					{K, util:to_binary(V)};
				_ ->
					{K, V}
			end
		  end,
		JsDataAdd=lists:map(Fun, KvList),
	JsObj = {obj, [{"platform_type", PlatformType}, {"data",{obj,JsDataAdd }}]},
	Data = rfc4627:encode(JsObj),
	Pt = #pt_login_auth_succ{jsondata=Data},
	net_tcp_client:send_packet(Socket,proto:pack(Pt, Seq)).

on_auth_fail(Socket, Seq, Str) ->
	Pt=#pt_sdk_auth_failed{data=Str},
	net_tcp_client:send_packet(Socket,proto:pack(Pt, Seq)).