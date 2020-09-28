%% @doc ets托管服务
%% 玩家登陆后创建ets表的请求将发到这里，由本进程来托管管理所有的玩家ets表
%% 存在这个的原因是，ets表存的是玩家的缓存数据，不能频繁的创建和销毁
%% 而由于移动应用的特性，断线重连的频率可能很高，只要玩家进程一退出，
%% 其拥有的ets表将被销毁，而可能玩家过会又登陆了。
%% 还有一种考虑就是即使玩家下线了，其数据也可能由于业务逻辑的需要被其他功能所读取
%% 为了不让其去数据库读取，将其缓存是一个不错的主意
%% 最后为了ets能回收，我们给ets加一个引用计数，当有一段时间没有访问了就回收
%% 引用计数:ets表增加一条数据：{'$my_ref', Number}，由于这个问题，托管的ets表的key暂时只能为第一个字段
%% 缓存回收策略：
%%	  玩家下线后开始计时，第一次下线，缓存保存2小时，第二次、第三次下线，缓存保存4小时
%%	  后面的则每次下线，缓存保存24小时
%%	  缓存时间到期了，且缓存没有人读取了，则回收缓存，系统每隔1小时检测和处理缓存
%%	  战力排行榜前30的玩家缓存将在系统启动时自动加载和创建，并且每天零点时再重建一次
-module (mod_ets_service).  %% common_server
-include ("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export ([create_ets/3, force_recycle/2, update_counter_ref/1, update_counter_ref/2]).

-define (REF_KEY, '$my_ref').  %% 引用key
-define (EXPIRE_KEY, '$expire_time').  %% 过期时间


%% 请求创建ets表，返回：
%%	{ok, new}：表示新创建
%%  {ok, exist}：表示已经存在了
%% 注意：Opts里设置的{keypos，N}，N必须为1才行
create_ets(EtsName, EtsDirtyName, Opts) ->
	gen_server:call(?MODULE, {create_ets, EtsName, EtsDirtyName, Opts}).

%% 强制回收ets表，不会进行保存操作的
force_recycle(RoleEts, RoleEtsDirty) ->
	gen_server:call(?MODULE, {force_recycle, RoleEts, RoleEtsDirty}).


update_counter_ref(Ets) ->
	ets:update_counter(Ets, ?REF_KEY, {2, 1}).
update_counter_ref(Ets, Offline) -> 
	ets:update_counter(Ets, ?REF_KEY, {2, 1}),
	Offline andalso (?MODULE ! {offline, Ets}).


init() -> 
	erlang:put(all_ets, []),
	start_worker(),
	ok.


start_worker() ->
	Self = self(),
	Pid = erlang:spawn_link(fun() -> worker(Self) end),
	erlang:put(service_worker, Pid),
    erlang:monitor(process, Pid).


handle_call({create_ets, EtsName, EtsDirtyName, Opts}) -> 
	case ets:info(EtsName) of 
		undefined -> 
			ets:new(EtsName, Opts),
			ets:new(EtsDirtyName, Opts),
			ets:insert(EtsName, {?REF_KEY, 0}),
			ets:insert(EtsName, {?EXPIRE_KEY, 0}),
			erlang:put(all_ets, [{EtsName, EtsDirtyName} | erlang:get(all_ets)]),
			{ok, new};
		_ -> 
			ets:insert(EtsName, {?EXPIRE_KEY, 0}),
			{ok, exist}
	end;

handle_call({force_recycle, Ets, DirtyEts}) -> 
	ets:delete(Ets),
	ets:delete(DirtyEts),
	erlang:put(all_ets, lists:delete({Ets, DirtyEts}, erlang:get(all_ets)));

handle_call(Request) ->
	?ERROR("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.


%% 通过offline_count计数里影响过期时长
handle_msg({offline, Ets}) -> 
	case get({offline_count, Ets}) of
		undefined -> 
			put({offline_count, Ets}, 1),
			ets:insert(Ets, {?EXPIRE_KEY, util_time:unixtime() + 2*3600});
		Count -> 
			put({offline_count, Ets}, Count + 1),
			AddTime = ?_IF(Count < 3, 4*3600, 24*3600),
			ets:insert(Ets, {?EXPIRE_KEY, util_time:unixtime() + AddTime})
	end;

handle_msg({recycle, RecycleList}) ->
	case RecycleList of
		[] -> ok;
		[{{Ets, DirtyEts}, Counter} | Rest] -> 
			case ets:info(Ets) of
				undefined -> %% 可能被强制回收了
					?INFO("ets ~p and ~p has been force recycled", [Ets, DirtyEts]);
				_ -> 
					%% 因为是异步的，所以再次检测下，万一又被引用了呢
					case ets:lookup_element(Ets, ?REF_KEY, 2) of
						Counter ->
							%% 如果正常回收时保存数据出错了，就不会调用ets:delete的
							%% 这样表就不会回收，这样可以保证不丢失数据，然后再修复它
							mod_role_tab:save(list_to_integer(atom_to_list(Ets))),
							ets:delete(Ets),
							ets:delete(DirtyEts),
							?INFO("ets ~p and ~p recycled succ", [Ets, DirtyEts]),
							erlang:put(all_ets, lists:delete({Ets, DirtyEts}, erlang:get(all_ets)));
						_ -> ignore
					end,
					self() ! {recycle, Rest}
			end
	end;

handle_msg({'DOWN', _, _process, Pid, Reason}) ->
	?ERROR("worker process ~p exit for reason:~p, restart a new worker", [Pid, Reason]),
	start_worker();


handle_msg(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.


terminate() -> 
	%% 正常情况关服会先让玩家下线，然后会保存数据的，这里再执行一次怕有异常情况下有数据没有保存
	[mod_role_tab:save(list_to_integer(atom_to_list(Ets))) || {Ets, _DirtyEts} <- erlang:get(all_ets)],
	ok.


% 一小时循环一次
do_loop(_Now) ->
	Pid = erlang:get(service_worker),
	Pid ! {check, erlang:get(all_ets)},
	ok.


worker(ParentPid) ->
	receive
		{check, AllEts} ->
			Now = util_time:unixtime(),
			case do_check(Now, AllEts, []) of
				[] -> ok;
				RecycleList ->
					ParentPid ! {recycle, RecycleList}
			end,
			worker(ParentPid)
	end.


do_check(_Now, [], Acc) -> Acc;
do_check(Now, [{Ets, DirtyEts} | Rest], Acc) ->
	Counter = ets:lookup_element(Ets, ?REF_KEY, 2),
	case erlang:get({last_check_counter, Ets}) of
		Counter  -> %% 这次检测Counter没有变化，就是没有人读取这个ets表了
			ExpireTime = ets:lookup_element(Ets, ?EXPIRE_KEY, 2),
			case ExpireTime > 0 andalso ExpireTime < Now of 
				true -> 
					erlang:erase({last_check_counter, Ets}),
					do_check(Now, Rest, [{{Ets, DirtyEts}, Counter} | Acc]);
				_ -> 	 
					do_check(Now, Rest, Acc)
			end;
		_ -> 
			erlang:put({last_check_counter, Ets}, Counter),
			do_check(Now, Rest, Acc)
	end.



