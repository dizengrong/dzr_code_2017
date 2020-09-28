-module(scene_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([start/0]).
-export([add/6]).

%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start() ->
    ?MODULE:start_link().

init([]) ->
    % Children = {scene, {scene, start_link, []}, temporary, 2000, worker, [scene]},
    RestartStrategy = {one_for_one, 3, 100000},
    % RestartStrategy = {simple_one_for_one, 10, 10},
    {ok, {RestartStrategy, []}}.
   
%% add(Key,UsrInfoList,NeedUsrInfo,Scene,SceneData) ->
%% add(Key,UsrInfoList,Scene,SceneData) ->
%% 	add(Key, UsrInfoList, Scene, SceneData,[]).
add(Key,UsrInfoList,{Scene,MaxWire},SceneData,ActivityDropItem,OpenSvrTime) ->
    supervisor:start_child(?MODULE, [{Key,UsrInfoList,Scene,MaxWire,SceneData,ActivityDropItem,OpenSvrTime}]).
