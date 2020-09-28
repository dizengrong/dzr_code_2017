%% -*- coding: latin-1 -*-
-module(fun_http_rpc_lyn).

-include("common.hrl").

-export([pay/3,gm_pay/3,test/0]).
-define(GIFTBAGTRAIN, "b468d9387ta874f18l2o4e5j273935dy").
verify_pay_data(KvList) ->
	case util:get_values(["OrderNo","OutPayNo","UserID","ServerNo","RoleID","ProductID","PayType","Money","PMoney","PayTime","Sign"], KvList) of
		[OrderNo,OutPayNo,UserID,ServerNo,RoleID,ProductID,PayType,Money,PMoney,PayTime,Sign] ->
			ValueList = [OrderNo,OutPayNo,UserID,ServerNo,RoleID,ProductID,PayType,Money,PMoney,PayTime],
			SignData1 = fun_plat_interface_lyn:sign_pay(ValueList),
			case string:equal(SignData1, util:to_list(Sign)) of
				true -> true;
				_ -> false
			end;
		_ -> false
	end.

handle_request(F) ->
	try
		F()
	catch
		E:R -> ?log_trace("handle request error,exctype=~p,excvalue=~p,stacktrace=~p", [E, R, erlang:get_stacktrace()])
	end.



pay(Sid, Env, In) ->
	?log_trace("pay,{Sid, Env, In}=~p",[{Sid, Env, In}]),
	F = fun() ->
			{remote_addr, Ip} = lists:keyfind(remote_addr, 1, Env),
			KvList = httpd:parse_query(In),
			RetCode = 
			case verify_pay_data(KvList) of
				true ->
					{_, OrderId} = lists:keyfind("OutPayNo", 1, KvList),
%% 					{"OutPayNo", GameOrderId} = lists:keyfind("OutPayNo", 1, KvList),
%% 					{"UserID", LynId} = lists:keyfind("UserID", 1, KvList),
%% 					{"ServerNo", ServerGroupId} = lists:keyfind("ServerNo", 1, KvList),
					%{"PayType", Flag} = lists:keyfind("PayType", 1, KvList),
					{_, Amount} = lists:keyfind("Money", 1, KvList),
					{_, RoleId} = lists:keyfind("RoleID", 1, KvList),
%% 					{_, ProductID} = lists:keyfind("ProductID", 1, KvList),
					%{"PMoney", Flag} = lists:keyfind("PMoney", 1, KvList),
					%{"PayTime", Flag} = lists:keyfind("PayTime", 1, KvList),
					{_, SourceId} = lists:keyfind("sourceId", 1, KvList),	
					gen_server:cast({global,agent_mng}, {order_pay_complete,{OrderId,util:to_integer(SourceId),Amount,util:to_integer(RoleId)}}),
					1;
				_R ->
					?log_warning("verify sign failed,_R = ~p,ip=~s,query_str=~s", [_R,Ip, In]),
					1004
			end,
			Ret = io_lib:format("~p|~p", [RetCode, util:unixtime()]),
			mod_esi:deliver(Sid, Ret)
		end,
	handle_request(F).

verify_gm_pay_data(KvList) ->
	case util:get_values(["roleId","payType","money","platform","sign"], KvList) of
		[RoleID,PayType,Money,Platform,Sign] ->
			ValueList = [RoleID,PayType,Money,Platform],
			SignData1 = fun_plat_interface_lyn:sign_pay(ValueList),
			case string:equal(SignData1, util:to_list(Sign)) of
				true -> true;
				_ -> false
			end;
		_ -> false
	end.

%%平台给工会充值(特别制作)
%%http://192.168.1.186:9100/rpc/fun_http_rpc_lyn:gm_pay?roleId=123&payType=1&money=222&platform=122
gm_pay(Sid, Env, In) ->
	?log_trace("gm_pay,{Sid, Env, In}=~p",[{Sid, Env, In}]),
	F = fun() ->
			{remote_addr, Ip} = lists:keyfind(remote_addr, 1, Env),
			KvList = httpd:parse_query(In),
			case verify_gm_pay_data(KvList) of
				true ->
					{_, RoleID} = lists:keyfind("roleId", 1, KvList),
					{_, PayType} = lists:keyfind("payType", 1, KvList),
					{_, Money} = lists:keyfind("money", 1, KvList),
					{_, Platform} = lists:keyfind("platform", 1, KvList),	
					gen_server:cast({global,agent_mng}, {order_gm_pay_complete,{util:to_integer(RoleID),util:to_integer(PayType),util:to_integer(Money),util:to_integer(Platform)}}),
					mod_esi:deliver(Sid, rfc4627:encode({obj, [{"state",1},{"msg",util:to_binary("成功")}]}));
				_R ->
					?log_warning("verify sign failed,_R = ~p,ip=~s,query_str=~s", [_R,Ip, In]),
					mod_esi:deliver(Sid, rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("失败")}]}))
			end
		end,
	handle_request(F).

%% accountId	string	用户id
%% kaId	string	礼包id
%% serverId	string	服务器编号
%% roleId	string	角色id
%% sign	string	签名
test()->
	util:md5("accountId=1,kaId=101,roleId=1,serverId=1:b468d9387ta874f18l2o4e5j273935dy").
%%礼包直通车
%%http://127.0.0.1:9100/rpc/fun_http_rpc_lyn:gift_bag_train?accountId=202f188797c5be10ef5245b1e4d70126109&kaId=113&serverId=5011&roleId=7&sign=4d0491e536e91f1a9947697d1cf5edad
%%http://127.0.0.1:9100/rpc/fun_http_rpc_lyn:gift_bag_train?accountId=202f188797c5be10ef5245b1e4d70126109&kaId=113&serverId=5011&roleId=234135&sign=a9226176d7e29f014b6f0d85a4e97146