-module(scene_ctr_app).
-behaviour(application).
-include("common.hrl").
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->    
    do_start().

stop(_State) ->    
    ok.

do_start()-> 
	pre_load_scene_scripts(),
    case scene_ctr_sup:start_link() of      
        {ok, Pid} ->      {ok, Pid};      
        Other ->          {error, Other}    
    end.


pre_load_scene_scripts() ->
	Fun = fun(Scene) ->
		#st_scene_config{script_scene=ScriptScene} = data_scene_config:get_scene(Scene),
		ScriptScene2 = util:to_atom("scene_config_" ++ util:to_list(ScriptScene)),
		?_IF(ScriptScene2 /= no, code:ensure_loaded(ScriptScene2), skip)
	end, 
	[Fun(S) || S <- data_scene_config:get_all()],
	ok.


