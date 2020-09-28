%% @doc 跨服节点的server模块
-module (mod_cross_server).
-include("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export ([get_group/1, get_node/1, get_server_nodes_by_group/1, get_server_name/1]).
-export ([send_enter_scene_request/4, send_pt_to_all_group_onlines_users/2]).
-export ([send_msg_to_server/3,get_all_group/0,send_msg_to_group/3]).

-define (FETCH_GROUP_INTERVAL, 3*60*1000).	%% 获取跨服分组的时间间隔


-record (r_nodes, {
	server_id,  %% 游戏服serverid
	node,		%% 游戏服节点名
	group,		%% 功能分组编号
	name = "undefined" 		%% 游戏服名称
}).

get_all_group() ->
	List = ets:tab2list(ets_nodes),
	Fun=fun(#r_nodes{group=Group},Acc) ->
			case lists:member(Group,Acc) of
				true ->Acc;
				_ ->[Group|Acc]	
			end
		end,
	lists:foldl(Fun,[],List).

get_group(ServerId) ->
	case ets:lookup(ets_nodes, ServerId) of
		[] -> %% 没有分组时，就默认都进0分组
			0;
		[#r_nodes{group = GroupId}] ->
			GroupId
	end.

get_node(ServerId) ->
	case ets:lookup(ets_nodes, ServerId) of
		[] -> %% 没有分组时，就默认都进0分组
			undefined;
		[#r_nodes{node = Node}] ->
			Node
	end.


get_server_name(ServerId) ->
	case ets:lookup(ets_nodes, ServerId) of
		[] -> 
			"undefined";
		[#r_nodes{name = ServerName}] ->
			ServerName
	end.


%% 根据分组获取其下所有的游戏服的节点
get_server_nodes_by_group(Group) ->
	ServerNodes  = ets:select(ets_nodes, [{#r_nodes{_ = '_', node = '$1', group = '$2'}, [{'==', '$2', Group}], ['$1']}]),
	lists:flatten(ServerNodes).


send_enter_scene_request(ScenePid, Scene, Line, UsrInfoList) ->
	[{_Uid, _Seq, _Pos, #ply_scene_data{agent_pid=AgentPid}}] = UsrInfoList,
	Msg = {enter_scene_request_from_cross, ScenePid, Scene, Line, UsrInfoList},
	util_misc:msg_handle_cast(AgentPid, mod_scene_api, Msg).


%% 将协议发送到所属组的游戏服里的在线玩家
send_pt_to_all_group_onlines_users(GroupId, Pt) -> 
	ServerNodes = get_server_nodes_by_group(GroupId),
	MsgKey = send_pt_to_all_group_onlines_users,
	[gen_server:cast({mod_cross_client,Node}, {msg_from_cross,MsgKey,Pt}) || Node <- ServerNodes, Node /= undefined],
	ok.


%% 将消息发送给游戏服的mod_cross_client进程
send_msg_to_server(ServerId, MsgKey, MsgData) -> 
	case get_node(ServerId) of
		undefined -> 
			?ERROR("Not find game server:~p, when send msgkey:~p, data:~p", [ServerId, MsgKey, MsgData]);
		Node ->
			gen_server:cast({mod_cross_client,Node}, {msg_from_cross,MsgKey, MsgData})
	end.


%% 将消息发送给所在分组的游戏服里的mod_cross_client进程
send_msg_to_group(Group, MsgKey, MsgData) -> 
	ServerNodes = get_server_nodes_by_group(Group),
	[gen_server:cast({mod_cross_client,Node}, {msg_from_cross,MsgKey,MsgData}) || Node <- ServerNodes, Node /= undefined],
	ok.


init() -> 
	net_kernel:monitor_nodes(true),
	ets:new(ets_nodes, [named_table, set, public, {keypos, #r_nodes.server_id}]),
	erlang:send_after(6000, self(), fetch_server_names),
	case ?DEBUG_MODE of
		true -> 
			case server_config:get_conf(test_cross_group) of
				CrossGroupList when is_list(CrossGroupList) -> 
					[insert_group_datas(GroupId, ServerIdList) || {GroupId, ServerIdList} <- CrossGroupList];
				_ ->
					% skip 
					erlang:send_after(5000, self(), fetch_cross_group)
			end;
		_ -> 
			erlang:send_after(5000, self(), fetch_cross_group)
	end,
	ok.


handle_call(Request) -> 
	?ERROR("unhandled request:~p", [Request]),
	no_reply.


handle_msg({{get_other_role_info, TargetUid}, ServerId, _Uid, _Sid, Seq, AgentPid}) -> 
	RefId = erlang:make_ref(),
	put(RefId, {ServerId, AgentPid, Seq}),
	MsgKey = get_role_info,
	MsgData = {TargetUid, RefId},
	send_msg_to_server(ServerId, MsgKey, MsgData);

handle_msg({{reply_get_role_info, RefId, RoleInfo}, _, _Uid, _Sid, _, _}) -> 
	case erlang:erase(RefId) of
		{_ServerId, AgentPid, Seq} ->
			gen_server:cast(AgentPid, {reply_get_role_info, RoleInfo, Seq});
		_ -> skip
	end;

handle_msg(fetch_server_names) ->
	Url = server_config:get_conf(sdk),
	Url2 = util_str:format_string("~s/GetGMInfo?Get=svr-no-name-ip", [Url]),
	case fun_http:sync_request(get, {Url2, []}) of
		{error, Reason} -> 
			?ERROR("Fetch server names failed:~p", [Reason]);
		{ok, {{_HttpVersion, StatusCode, _}, _Headers, Body}} when StatusCode == 200 ->
			case catch parse_fetch_server_names_reply(Body) of
				{'EXIT', Reason} -> 
					?ERROR("Fetch server names failed:~p", [Reason]);
				{error, Reason} ->
					?ERROR("Fetch server names failed:~p", [Reason]);
				{ok, ServerNameList} ->
					[insert_server_name(ServerId, Name) || {ServerId, Name} <- ServerNameList]
			end;
		{ok, {{_HttpVersion, StatusCode, _}, _Headers, Body}} ->
			?ERROR("Fetch cross group failed, StatusCode:~p, Body:~p", [StatusCode, Body])
	end,
	erlang:send_after(5*60*1000, self(), fetch_server_names);

%% 获取跨服分组，因为不知道到底在什么时候获取这个，所以定时来获取
handle_msg(fetch_cross_group) ->
	Url = server_config:get_conf(sdk),
	ServerId = server_config:get_conf(serverid),
	Url2 = util_str:format_string("~s/GetGMInfo?Get=cross-server&SvrNo=~p", [Url, ServerId]),
	case fun_http:sync_request(get, {Url2, []}) of
		{error, Reason} -> 
			?ERROR("Fetch cross group failed:~p", [Reason]);
		{ok, {{_HttpVersion, StatusCode, _}, _Headers, Body}} when StatusCode == 200 ->
			case catch parse_fetch_request_reply(Body) of
				{'EXIT', Reason} -> 
					?ERROR("Fetch cross group failed:~p", [Reason]);
				{error, Reason} ->
					?ERROR("Fetch cross group failed:~p", [Reason]);
				{ok, CrossGroupList} ->
					[insert_group_datas(GroupId, ServerIdList) || {GroupId, ServerIdList} <- CrossGroupList]
			end;
		{ok, {{_HttpVersion, StatusCode, _}, _Headers, Body}} ->
			?ERROR("Fetch cross group failed, StatusCode:~p, Body:~p", [StatusCode, Body])
	end,
	erlang:send_after(?FETCH_GROUP_INTERVAL, self(), fetch_cross_group);

handle_msg({nodeup, Node}) -> 
	?INFO("Node up:~p", [Node]),
	case util_server:is_game_server_node_format(Node) of
		true -> 
			ServerId = util_server:parse_server_id_by_node(Node),
			case ets:lookup(ets_nodes, ServerId) of
				[] -> 
					case ?DEBUG_MODE of
						true -> 
							ets:insert(ets_nodes, #r_nodes{server_id = ServerId, node = Node, name = util:to_list(Node)});
						_ -> 
							ets:insert(ets_nodes, #r_nodes{server_id = ServerId, node = Node})
					end;
				[Rec] -> 
					case ?DEBUG_MODE of
						true -> 
							ets:insert(ets_nodes, Rec#r_nodes{node = Node, name = util:to_list(Node)});
						_ -> 
							ets:insert(ets_nodes, Rec#r_nodes{node = Node})
					end,
					mod_cross_guildbattle:game_svr_connect_action(Rec#r_nodes.group,Rec#r_nodes.server_id)
			end;
		_ -> 
			skip
	end,
	ok;

handle_msg({nodedown, Node}) -> 
	?INFO("Node down:~p", [Node]),
	case util_server:is_game_server_node_format(Node) of
		true -> 
			ServerId = util_server:parse_server_id_by_node(Node),
			case ets:lookup(ets_nodes, ServerId) of
				[] -> skip;
				[Rec] -> 
					ets:insert(ets_nodes, Rec#r_nodes{node = undefined})
			end;
		_ -> 
			skip
	end;

handle_msg(Msg) ->
	?ERROR("unhandled msg:~p", [Msg]),
	ok.


terminate() ->
	ok.


do_loop(_Now) ->
	ok.


parse_fetch_server_names_reply(Body) ->
	case rfc4627:decode(Body) of
		{ok,{obj,Datas},_} -> 
			{_, RetCode} = lists:keyfind("code", 1, Datas),
			{_, RetMsg} = lists:keyfind("msg", 1, Datas),
			case RetCode of
				0 -> 
					{_, Json} = lists:keyfind("data", 1, Datas),
					Fun = fun({obj, Info})->
						{_,Name}=lists:keyfind("name", 1, Info),
						{_,ServerId}=lists:keyfind("svr_no", 1, Info),
						{ServerId, Name}
				    end,
				    {ok, [Fun(T) || T <- Json]};
				_ -> 
					{error, RetMsg}
			end;
		_ -> 
			{error, util_str:format_string("Parese Body failed:~p", [Body])}
	end.


parse_fetch_request_reply(Body) ->
	case rfc4627:decode(Body) of
		{ok,{obj,Datas},_} -> 
			{_, RetCode} = lists:keyfind("code", 1, Datas),
			{_, RetMsg} = lists:keyfind("msg", 1, Datas),
			case RetCode of
				0 -> 
					{_, CrossGroupJson} = lists:keyfind("data", 1, Datas),
					Fun = fun({obj, Info})->
						{_,GroupId}=lists:keyfind("group_id", 1, Info),
						{_,ServerIdList}=lists:keyfind("svr_no", 1, Info),
						{util:to_integer(GroupId), ServerIdList}
				    end,
				    CrossGroup2 = [Fun(T) || T <- CrossGroupJson],
				    {ok, CrossGroup2};
				_ -> 
					{error, RetMsg}
			end;
		_ -> 
			{error, util_str:format_string("Parese Body failed:~p", [Body])}
	end.


%% CrossGroup:[{GroupId,ServerId}]
%% return:[{GroupId,[ServerId]}]
% regroup_reply_data(CrossGroup) -> 
% 	regroup_reply_data(CrossGroup, []).

% regroup_reply_data([{GroupId, ServerId} | Rest], Acc) -> 
% 	Acc2 = case lists:keyfind(GroupId, 1, Acc) of
% 		false -> 
% 			[{GroupId, []} | Acc];
% 		{_, ServerIdList} -> 
% 			lists:keystore(GroupId, 1, Acc, {GroupId, [ServerId | ServerIdList]})
% 	end, 
% 	regroup_reply_data(Rest, Acc2);
% regroup_reply_data([], Acc) -> Acc.


%% CrossGroup:[{GroupId,ServerId}]
insert_group_datas(GroupId, ServerIdList) -> 
	Fun = fun(ServerId) ->
		case ets:lookup(ets_nodes, ServerId) of
			[] -> 
				ets:insert(ets_nodes, #r_nodes{server_id = ServerId, group = GroupId});
			[Rec] -> 
				ets:insert(ets_nodes, Rec#r_nodes{group = GroupId})
		end
	end,
	[Fun(T) || T <- ServerIdList],
	ok.

insert_server_name(ServerId, Name) ->
	case ets:lookup(ets_nodes, ServerId) of
		[] -> 
			ets:insert(ets_nodes, #r_nodes{server_id = ServerId, name = Name});
		[Rec] -> 
			ets:insert(ets_nodes, Rec#r_nodes{name = Name})
	end.
