%% @doc common_server使用的每秒循环
-module (srv_loop).
-include ("common.hrl").
-export ([init/0]).
-export ([tick_loop/0, add_callback/4, send_after/2, send_after/3]).


init() ->
	tick_timer:init().


tick_loop() ->
	tick_timer:tick_loop(),
	ok.


%% 在AfterTick之后的tick上安装回调方法，AfterTick到期时将回调M:F(A)
add_callback(AfterTick, M, F, A) -> 
	tick_timer:add_callback(AfterTick, M, F, A).


%% @doc 发送延迟消息
%% AfterTick为延迟多少秒，Dest同erlang:send/2中的Dest，Msg为要发送的消息
send_after(AfterTick, Msg) -> 
	send_after(AfterTick, self(), Msg).
send_after(AfterTick, Dest, Msg) -> 
	tick_timer:send_after(AfterTick, Dest, Msg).



