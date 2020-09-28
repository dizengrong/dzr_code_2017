%% @doc 游戏服管理、维护服务
-module (mod_server_manage).
-include_lib("kernel/include/file.hrl").
-include ("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).


init() -> 
	case ?DEBUG_MODE of
		true -> %% debug测试模式下才开放自动热更新
    		{ok, _TRef} = timer:send_interval(timer:seconds(1), do_check_and_reload),
    		put(last_check_time, erlang:localtime());
    	_ -> skip
    end,
	ok.


handle_call(Request) ->
	?ERROR("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.


handle_msg({reload_modules, ModuleList}) -> 
	%% 使用soft_purge，如果当时无法purge，则等待下次继续热更新
	case reload_modules(ModuleList) of
		[] -> skip;
		LeftList ->
			erlang:send_after(1000, self(), {reload_modules, LeftList})
	end;

handle_msg(do_check_and_reload) -> 
	Now = erlang:localtime(),
	do_check_and_reload(get(last_check_time), Now),
	put(last_check_time, Now);

handle_msg(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.


terminate() -> 
	ok.


%% 暂时没有开启循环
do_loop(_Now) ->
	ok.


reload_modules(ModuleList) -> 
	reload_modules(ModuleList, []).

%% cerl_map_api是nif模块，不能热更新
%% mod_ets_service貌似一直无法soft_purge
reload_modules([Mod | Rest], Acc) when Mod == cerl_map_api;
									   Mod == mod_ets_service  -> 
	reload_modules(Rest, Acc);
reload_modules([Module | Rest], Acc) -> 
	Acc2 = case code:soft_purge(Module) of
		false -> 
			?INFO("Reloading ~p failed for cannot soft purge, wait for next reload.", [Module]),
			[Module | Acc];
		_ -> 
			case code:load_file(Module) of 
				{module, Module} ->
					?INFO("Reloading ~p ... ok.", [Module]);
        		{error, Reason} ->
					?INFO("Reloading ~p failed for reason:~p.", [Module, Reason])
			end,
			Acc
	end,
	reload_modules(Rest, Acc2);
reload_modules([], Acc) -> Acc.


do_check_and_reload(From, To) ->
	[case file:read_file_info(Filename) of
         {ok, #file_info{mtime = Mtime}} when Mtime >= From, Mtime < To -> 
         	self() ! {reload_modules, [Module]};
         {ok, _} ->
             unmodified;
         {error, enoent} ->
             %% The Erlang compiler deletes existing .beam files if
             %% recompiling fails.  Maybe it's worth spitting out a
             %% warning here, but I'd want to limit it to just once.
             gone;
         {error, Reason} ->
             ?INFO("Error reading ~s's file info: ~p",
                       [Filename, Reason]),
             error
     end || {Module, Filename} <- code:all_loaded(), is_list(Filename)].

