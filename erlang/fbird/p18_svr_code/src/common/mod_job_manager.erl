%% @doc 通用工作管理器，每一个工作将会启动一个进程来执行
-module (mod_job_manager).
-export ([init/0, add_worker/2, start_and_wait/1, start_async/1]).


init() ->
	ets:new(ets_worker, [named_table, set, public, {keypos, 1}]),
	ok.


%% 添加一个worker，参数WorkerId为一个atom，用来标识worker的，
%% 相同的WorkerId将被组合到一个列表里
add_worker(WorkerId, Fun) -> 
	case ets:lookup(ets_worker, WorkerId) of
		[] -> 
			ets:insert(ets_worker, {WorkerId, [Fun]});
		[{_, FunList}] ->
			ets:insert(ets_worker, {WorkerId, [Fun | FunList]})
	end.


del_worker(WorkerId) ->
	ets:delete(ets_worker, WorkerId).


%% 启动worker进程，让他们去异步处理，不等待直接返回
start_async(WorkerId) -> 
	case ets:lookup(ets_worker, WorkerId) of
		[] -> no_worker;
		[{_, FunList}] ->
			del_worker(WorkerId),
			ParentPid = self(),
			_ = [erlang:spawn_link(fun() -> worker(ParentPid, Fun) end) || Fun <- FunList]
	end.


%% 启动worker进程，让他们去异步处理，并等待所有的worker进程结束
start_and_wait(WorkerId) ->
	case ets:lookup(ets_worker, WorkerId) of
		[] -> no_worker;
		[{_, FunList}] ->
			ParentPid = self(),
			[erlang:spawn_link(fun() -> worker(ParentPid, Fun) end) || Fun <- FunList],
			wait_for_worker(length(FunList)),
			del_worker(WorkerId)
	end.


worker(ParentPid, Fun) ->
	Fun(),
	ParentPid ! finished.


wait_for_worker(0) ->
	ok;
wait_for_worker(Num) ->
	receive 
		finished -> 
			wait_for_worker(Num - 1)
	end.
