%% @doc 服务器级别相关的头文件


-ifdef(pre18).
-define (OTP_PRE18, true).
-else.
-define (OTP_PRE18, false).
-endif.

%% 游戏服是否是debug模式
-ifdef(debug_mode).
-define(DEBUG_MODE, true).
-else.
-define(DEBUG_MODE, false).
-endif.


-define(LIB_MAP_MODULE, lib_c_map_module).

-define (PLAYER_NODE_KEY, agent).
-define (CROSS_NODE_KEY, cross).

-define (APP_SERVER   , agent_ctr).
-define (APP_SCENE   , scene_ctr).
-define (APP_CROSS   , cross_srv).


%% 跨服节点的serverid取值范围
-define (CROSS_NODE_SERVER_ID_MIN, 10000).
-define (CROSS_NODE_SERVER_ID_MAX, 10009).


-define (SUPERVISOR_SPEC(Mod, Args), 
    {Mod, {Mod, start_link, Args}, permanent, infinity, supervisor, [Mod]}
).

-define (COMMON_SERVER_SPEC(Mod, Args), 
	{Mod, {common_server, start_link, Args}, permanent, 5000, worker, [Mod]}
).


-define(PSW_CODE, 16#ABCD).

-define(LISTEN_TCP_OPTS, [
	binary, 
	{packet, 0},
	{reuseaddr, true}, 
	{nodelay, true},   
	{delay_send, true}, 
	{active, false},
	{backlog, 1024},
	{exit_on_close, true},
	{send_timeout, 15000}
]).


%% 收到socket连接后，该socket的设置参数：
-define (ACCEPTED_SOCKET_OPTS, [
	binary, 
	{packet, 0}, 
	{active, false}, 
	{nodelay, true}, 
	{delay_send, true},
	{exit_on_close, true},
	{keepalive, true}
]).


-record(client_state, {
    socket, 
    ip, 
    account,
    account_id,
    uid, 
    last_packet_time,
    sum_packet = 0,
    reg_name,
    left_bin = <<>>,  %% 粘包处理剩余的数据
    status = connected
}).


%% 启动mnesia数据库的方式
-define (START_MNESIA_FOR_GAMESERVER , 1). 		%% 正常游戏服节点启动
-define (START_MNESIA_FOR_CROSSSERVER, 2). 		%% 跨服节点启动
-define (START_MNESIA_FOR_RESTORE    , 3). 		%% 恢复数据库时启动
-define (START_MNESIA_FOR_MERGE      , 4). 		%% 合服时启动
-define (START_MNESIA_FOR_BACKUP     , 5). 		%% 备份时启动

%% 本服和跨服类型定义
-define (CROSS_TYPE_LOCAL, 0). 	%% 本服
-define (CROSS_TYPE_CROSS, 1). 	%% 跨服

