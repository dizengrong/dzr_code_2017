%% @doc 玩家事件
-module (mod_role_event).
-include("common.hrl").
-export ([init/1, trigger_event/5]).
-export ([register_listener/2, unregister_listener/1, unregister_listener/2]).

init(Uid) ->
	%% 玩家登录时初始化各个模块的监听数据
	fun_main_task:init_listener_events(Uid),
	fun_daily_task:init_listener_events(Uid),
	ok.

%% 获取该事件的监听者队列
get_listener_queue(EventType) -> 
	util_misc:get_process_dict({event_queue, EventType}, []).

%% 设置事件的监听者队列
set_listener_queue(EventType, Queue) ->
	put({event_queue, EventType}, Queue).

%% 加入到事件的监听者队列去
add_2_listener_queue(EventType, Listener) ->
	Queue = get_listener_queue(EventType),
	case lists:member(Listener, Queue) of
		true -> skip;
		_ -> set_listener_queue(EventType, [Listener | Queue])
	end.

remove_from_listener_queue(EventType, Listener) ->
	Queue = get_listener_queue(EventType),
	case lists:member(Listener, Queue) of
		true -> skip;
		_ -> set_listener_queue(EventType, lists:delete(Listener, Queue))
	end.

%% 获取监听者感兴趣的事件列表
get_listener_events(Listener) ->
	util_misc:get_process_dict({listener, Listener}, []).

set_listener_events(Listener, Events) ->
	put({listener, Listener}, Events).

remove_listener(Listener) ->
	erase({listener, Listener}).


%% 注册事件监听者
register_listener(Listener, EventType) when is_integer(EventType) ->
	List = get_listener_events(Listener),
	case lists:member(EventType, List) of
		true -> skip;
		_ -> 
			set_listener_events(Listener, [EventType | List]),
			add_2_listener_queue(EventType, Listener)
	end;
register_listener(Listener, Events) when is_list(Events) ->
	List = get_listener_events(Listener),
	Events2 = Events -- List,
	case Events2 of
		[] -> skip;
		_ ->
			set_listener_events(Listener, Events2 ++ List),
			[add_2_listener_queue(EventType, Listener) || EventType <- Events],
			ok
	end.

%% 删除事件监听者所监听的所有事件
unregister_listener(Listener) ->
	Events = get_listener_events(Listener),
	%% 删除监听者所监听的事件
	remove_listener(Listener),
	%% 从各个事件队列里删除这个监听者
	[remove_from_listener_queue(EventType, Listener) || EventType <- Events],
	ok.

unregister_listener(Listener, EventType) -> 
	Events = get_listener_events(Listener),
	set_listener_events(Listener, lists:delete(EventType, Events)),
	remove_from_listener_queue(EventType, Listener).


%% 触发事件
trigger_event(Uid, Sid, EventType, Val2, Val3) ->
	%% 当该事件没有监听者，就到此结束了，压根不会调用任何多余的处理了，所以其效率高
	case get({event_queue, EventType}) of
		undefined -> skip;
		Queue ->
			[trigger_event_help(Uid, Sid, EventType, Val2, Val3, Listener) || Listener <- Queue],
			ok
	end.

trigger_event_help(Uid, Sid, EventType, Val2, Val3, Listener) ->
	try
		Listener:on_role_event(Uid, Sid, EventType, Val2, Val3)
	catch
		E:R ->
			?EXCEPTION_LOG(E, R, Listener, [EventType, Val2, Val3])
	end.

