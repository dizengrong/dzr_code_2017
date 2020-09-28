-module(agent_ctr_app).
-behaviour(application).
-include("common.hrl").
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->  
	NodeName = util_server:get_node_name(?PLAYER_NODE_KEY),  
    case net_kernel:start([NodeName]) of
		{ok, _Pid} ->
			Cookie = server_config:get_conf(cookie),
			erlang:set_cookie(NodeName, Cookie),
			mod_job_manager:init(),
    		%% mnesia必须先于其他功能启动
			mnesia_manager:start(?START_MNESIA_FOR_GAMESERVER),
			init_tab(),

		    {ok, SupPid} = agent_ctr_sup:start_link(),
	    	{ok, SupPid};
		_ ->
			?ERROR("start node:~p failed!!!", [NodeName]),
			init:stop(),
			false
	end.


stop(_State) ->    
    ok.


%% 启动服务后需要初始化的数据
init_tab() -> 
	case db_api:size(opening_server_time) == 0 of
		true -> 
			Rec = #opening_server_time{
				time                = util:unixtime(),
				day_time            = util:get_relative_day(?AUTO_REFRESH_TIME),
				guild_ranklist_time = util:get_relative_day(?AUTO_REFRESH_TIME),
				draw_astrict        = 2
			},
			db_api:dirty_write(Rec);
		_ -> skip
	end,
	ok.

