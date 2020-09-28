%% @doc 跨服节点
-module(cross_srv_app).
-behaviour(application).
-include("common.hrl").
-export([start/2, stop/1]).

start(_StartType, _StartArgs) -> 
	NodeName = util_server:get_node_name(?CROSS_NODE_KEY),  
    case net_kernel:start([NodeName]) of
		{ok, _Pid} -> 
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
    		%% mnesia必须先于其他功能启动
			mnesia_manager:start(?START_MNESIA_FOR_CROSSSERVER),
    		do_start();
    	_ -> 
    		skip
    end.


stop(_State) ->    
    ok.

do_start()-> 
	pre_load_scene_scripts(),
    case cross_srv_sup:start_link() of
        {ok, Pid} -> {ok, Pid};
        Other -> {error, Other}    
    end.


pre_load_scene_scripts() ->
	Fun = fun(Scene) ->
		#st_scene_config{script_scene=ScriptScene} = data_scene_config:get_scene(Scene),
		ScriptScene2 = util:to_atom("scene_config_" ++ util:to_list(ScriptScene)),
		?_IF(ScriptScene2 /= no, code:ensure_loaded(ScriptScene2), skip)
	end, 
	[Fun(S) || S <- data_scene_config:get_all()],
	ok.


