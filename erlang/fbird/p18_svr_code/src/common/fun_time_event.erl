%% @author dzr
%% @doc 时间事件处理
-module(fun_time_event).
-include("common.hrl").

-export([do_agent_day_zero_clock/1]).
-export([do_world_zero_clock/1]).
% -export([do_agent_day_three_clock/1]).


%% 来自agent进程的玩家每天零点时间事件（包括隔天登陆也会调用这个）
do_agent_day_zero_clock(_Uid) ->
	ok.

%% 来自agent进程的玩家每天凌晨三点时间事件（包括隔天登陆也会调用这个）
% do_agent_day_three_clock(_Uid) ->
% 	ok.

%% 来自世界agentmng进程的世界每天零点时间事件
do_world_zero_clock(Now)->
	fun_guild:del_all_guild_stone_info(),
	% fun_guild_boss:refresh_data(),
	fun_recent_chat:do_expire(Now),
	fun_maze:send_ranklist(Now),
	fun_gm_activity_ex:refresh_global_data(),
	ok.
