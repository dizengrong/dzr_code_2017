%% @doc 连接跨服节点的客户端模块
-module (mod_cross_client).
-include("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export ([send_thunder_msg/6]).

-define (FETCH_CROSS_NODE_INTERVAL, 60*1000).	%% 获取跨服节点的时间间隔

% get_all_cross_nodes() ->
% 	List = lists:seq(?CROSS_NODE_SERVER_ID_MIN, ?CROSS_NODE_SERVER_ID_MAX),
% 	[util_server:get_node_name(?CROSS_NODE_KEY, ServerId) || ServerId <- List].


set_allow_connected_nodes(CrossNode) -> 
	Nodes = [
		util_server:get_node_name(remshell), 
		util_server:get_node_name(debug)
	],
	net_kernel:allow(Nodes ++ [CrossNode]),
	ok.


%% 发送消息到跨服节点的mod_cross_thunderboss进程
send_thunder_msg(Msg, ServerId, Uid, Sid, Seq, AgentPid) ->
	?MODULE ! {router_msg, mod_cross_thunderboss, Msg, ServerId, Uid, Sid, Seq, AgentPid}.


init() ->
	net_kernel:monitor_nodes(true),
	put(cross_node_connect_status, false),
	case ?DEBUG_MODE of
		true -> 
			case server_config:get_conf(test_cross_node) of
				CrossNode when is_atom(CrossNode) ->
					put(cross_node, CrossNode),
					erlang:send_after(1000, self(), connect_cross_node);
				_ ->
					skip 
					% erlang:send_after(5000, self(), fetch_cross_node)
			end;
		_ -> 
			erlang:send_after(5000, self(), fetch_cross_node)
	end,
	ok.


handle_call(Request) -> 
	?ERROR("unhandled request:~p", [Request]),
	no_reply.


handle_msg({router_msg, PidInCross, Msg, ServerId, Uid, Sid, Seq, AgentPid}) -> 
	case get(cross_node_connect_status) of
		false -> 
			?error_report(Sid, "error_cross_node_not_ready", Seq),
			?ERROR("error_cross_node_not_ready when router msg:~p", [{PidInCross, Msg, Uid, Sid, Seq, AgentPid}]);
		_ -> 
			CrossNode = get(cross_node),
			gen_server:cast({PidInCross, CrossNode}, {Msg, ServerId, Uid, Sid, Seq, AgentPid})
	end;

handle_msg({msg_from_cross, MsgKey, MsgData}) ->
	case MsgKey of
		send_pt_to_all_group_onlines_users ->  
			util_pt:send_pt_2_online_users(MsgData);
		send_thunderboss_reward ->
			mod_cross_thunderboss:do_send_reward_in_game_server(MsgData);
		_ ->
			?ERROR("unhandled cross msg:~p", [{MsgKey, MsgData}])
	end;

%% 初始化获取要连接的跨服节点
handle_msg(fetch_cross_node) ->
	Url = server_config:get_conf(sdk),
	ServerId = server_config:get_conf(serverid),
	Url2 = util_str:format_string("~s/GetGMInfo?Get=cross-server&SvrNo=~p", [Url, ServerId]),
	case fun_http:sync_request(get, {Url2, []}) of
		{error, Reason} -> 
			?ERROR("Fetch cross node failed:~p", [Reason]),
			erlang:send_after(?FETCH_CROSS_NODE_INTERVAL, self(), fetch_cross_node);
		{ok, {{_HttpVersion, StatusCode, _}, _Headers, Body}} when StatusCode == 200 ->
			case catch parse_fetch_request_reply(Body) of
				{'EXIT', Reason} -> 
					?ERROR("Fetch cross node failed:~p", [Reason]),
					erlang:send_after(?FETCH_CROSS_NODE_INTERVAL, self(), fetch_cross_node);
				{error, Reason} ->
					?ERROR("Fetch cross node failed:~p", [Reason]),
					erlang:send_after(?FETCH_CROSS_NODE_INTERVAL, self(), fetch_cross_node);
				{ok, CrossNode} ->
					put(cross_node, CrossNode),
					erlang:send_after(1000, self(), connect_cross_node)
			end;
		{ok, {{_HttpVersion, StatusCode, _}, _Headers, Body}} ->
			?ERROR("Fetch cross node failed, StatusCode:~p, Body:~p", [StatusCode, Body]),
			erlang:send_after(?FETCH_CROSS_NODE_INTERVAL, self(), fetch_cross_node)
	end;

%% 连接跨服节点
handle_msg(connect_cross_node) ->
	connect_cross_node(get(cross_node));

handle_msg({nodeup, Node}) -> 
	?INFO("Node up:~p", [Node]);

handle_msg({nodedown, Node}) -> 
	?INFO("Node down:~p", [Node]),
	case get(cross_node) == Node of
		true -> 
			put(cross_node_connect_status, false),
			?INFO("Cross node:~p is down! prepare to reconnecting...", [Node]),
			erlang:send_after(3000, self(), connect_cross_node);
		_ -> 
			skip
	end,
	ok;

handle_msg({sync_beam_to_cross_node, Module}) -> 
	case ?DEBUG_MODE andalso server_config:get_conf(test_cross_node) of
		CrossNode when is_atom(CrossNode) -> 
			{mod_server_manage, CrossNode} ! {reload_modules, [Module]};
		_ -> skip
	end;

handle_msg(Msg) ->
	?ERROR("unhandled msg:~p", [Msg]),
	ok.


terminate() ->
	ok.


do_loop(_Now) ->
	ok.


parse_fetch_request_reply(Body) ->
	case rfc4627:decode(Body) of
		{ok,{obj,Datas},[]}-> 
			{_, RetCode} = lists:keyfind("code", 1, Datas),
			{_, RetMsg} = lists:keyfind("msg", 1, Datas),
			case RetCode of
				0 -> 
					{_, CrossNode0} = lists:keyfind("cross_node_name", 1, Datas),
					CrossNode = util:to_list(CrossNode0),
					CrossNode2 = string:strip(CrossNode),
					case length(CrossNode2) > 10 of
						true ->  
							{ok, util:list_to_atom2(CrossNode)};
						_ -> 
							{error, util_str:format_string("cross node config not right:~p", [CrossNode2])}
					end;
				_ -> 
					{error, RetMsg}
			end;
		_ -> 
			{error, util_str:format_string("Parese Body failed:~p", [Body])}
	end.


connect_cross_node(CrossNode) ->
	set_allow_connected_nodes(CrossNode),
	case net_kernel:connect_node(CrossNode) of
		true -> 
			?INFO("Connected to cross node:~p", [CrossNode]),
			put(cross_node_connect_status, true),
			ok;
		_ -> 
			?WARNING("Cannot connect to cross node:~p, retry...", [CrossNode]),
			erlang:send_after(10000, self(), connect_cross_node)
	end.


