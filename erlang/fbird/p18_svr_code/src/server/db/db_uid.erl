%% @doc 唯一id生成器
%% 当某个表需要唯一id服务时，以这个表名key来生成id
-module (db_uid).
-include ("common.hrl").
-export ([new_id/1, temp_new_id/1, set_new_usr_tab_id/1]).

-define (TAB_UID, t_uid).
-define (TAB_TEMP_UID, t_temp_uid).


%% 生成一个新的id 
new_id(Key) when Key == account -> 
	ServerId = server_config:get_conf(serverid),
	db_api:dirty_update_counter(?TAB_UID, Key, 1) + ServerId * ?ONE_MILLION;
new_id(Key) when Key == usr -> 
	ServerId = server_config:get_conf(serverid),
	db_api:dirty_update_counter(?TAB_UID, Key, 1) + ServerId * ?UID_OFF;
new_id(Key) when Key == guild -> 
	ServerId = server_config:get_conf(serverid),
	db_api:dirty_update_counter(?TAB_UID, Key, 1) + ServerId * ?ONE_MILLION;
new_id(Key) when Key == t_auction_shop -> 
	db_api:dirty_update_counter(?TAB_UID, Key, 1);
new_id(Key) when Key == t_mail ->
	ServerId = server_config:get_conf(serverid),
	db_api:dirty_update_counter(?TAB_UID, Key, 1) + ServerId * ?ONE_MILLION;
new_id(Key) when Key == t_mail_public ->
	ServerId = server_config:get_conf(serverid),
	db_api:dirty_update_counter(?TAB_UID, Key, 1) + ServerId * ?ONE_MILLION;
new_id(Key) when Key == t_mail_read_public ->
	ServerId = server_config:get_conf(serverid),
	db_api:dirty_update_counter(?TAB_UID, Key, 1) + ServerId * ?ONE_MILLION;

new_id(Key) -> 
	db_api:dirty_update_counter(?TAB_UID, Key, 1).


set_new_usr_tab_id(MaxUserId) -> 
	db_api:dirty_update_counter(?TAB_UID, usr, 1 + MaxUserId).


temp_new_id(Key) -> 
	db_api:dirty_update_counter(?TAB_TEMP_UID, Key, 1).

