%% @doc 服务器维护工具
-module (sm_tool).
-include ("common.hrl").
-export ([exe_fun/1, eval/1]).


eval(S) ->
    {ok,Scanned,_} = erl_scan:string(util:to_list(S)),
    {ok,Parsed} = erl_parse:parse_exprs(Scanned),
    {value, Value,_} = erl_eval:exprs(Parsed, []),
    Value.


%% 在指定的节点里执行一个方法，使用如下：
%% 可选参数格式:是一个列表，最终使用erlang:apply(Mod, Fun, Args)来执行
% 	server_ctrl.bat exe_fun 远程节点key 模块名|eval 方法 可选参数
% 	server_ctrl.bat exe_fun agent sm_tool eval "Fun = fun() -> erlang:system_info(scheduler_id) end, Fun()."
% 	server_ctrl.bat exe_fun agent main info
% 	server_ctrl.bat exe_fun agent util_time min_for_date {2019,1,1} {2019,3,3}
% 	server_ctrl.bat exe_fun agent util_misc list_2_atom \"abc\"
exe_fun(Args) -> 
	case Args of
		[_, NodeKey0, Mod0, Fun0 | RestArgs] -> 
			NodeKey = util_misc:list_2_atom(NodeKey0),
			Mod = util_misc:list_2_atom(Mod0),
			Fun = util_misc:list_2_atom(Fun0),
			case start_node(NodeKey) of
				{ok, NodeName} ->
					exe_fun_help(NodeName, Mod, Fun, RestArgs);
				{error, Reason} ->
					io:format("exe_fun failed:~s~n", [Reason])
			end;
		_ ->
			io:format("usage:~n\texe_fun NodeKey, Mod, Fun Args", [])
	end,
	init:stop().


start_node(NodeKey) ->
	DebugNode = util_server:get_node_name(debug),
	case net_kernel:start([DebugNode]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(DebugNode, Cookie),
			NodeName = util_server:get_node_name(NodeKey),
			case net_adm:ping(NodeName) of
				pong -> {ok, NodeName};
				_ -> 
					{error, util_str:format_string("ping node:~p failed", [NodeName])}
			end;
		_ ->
			{error, "start stop node failed!"}
	end.


exe_fun_help(NodeName, sm_tool, eval, Args) -> 
	Ret = rpc:call(NodeName, sm_tool, eval, Args, infinity),
	io:format("~nexecute sm_tool:eval(\"~s\") = ~p~n", Args ++ [Ret]),
	Ret;
exe_fun_help(NodeName, Mod, Fun, Args) -> 
	case Args of
		[] -> 
			Ret = rpc:call(NodeName, erlang, apply, [Mod, Fun, []], infinity),
			io:format("~nexecute ~p:~p() = ~p~n", [Mod, Fun, Ret]),
			Ret;
		_ ->
			Args2 = util_str:str_to_term("[" ++ string:join(Args, ",") ++ "]"),
			Ret = rpc:call(NodeName, erlang, apply, [Mod, Fun, Args2], infinity),
			ArgsFormat = string:join(["~p" || _ <- lists:seq(1, length(Args2))], ", "),
			io:format("execute ~p:~p(" ++ ArgsFormat ++ ") = ~p~n~n", [Mod, Fun | Args2] ++ [Ret]),
			Ret
	end.

