%% @doc 账号创建服务
-module (mod_account_service).
-include("common.hrl"). 
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([check_role_name_exists/1, check_account_name_exists/1]).


check_account_name_exists(AccountName) ->
	gen_server:call(mod_account_service, {check_account_name_exists, AccountName}).


check_role_name_exists(Name) ->
	gen_server:call(mod_account_service, {check_role_name_exists, Name}).


init() ->
	ok.


handle_call({check_account_name_exists, AccountName}) -> 
	db_api:dirty_index_read(account, AccountName, #account.name) =/= [];

handle_call({check_role_name_exists, Name}) -> 
    db_api:dirty_index_read(usr, Name, #usr.name) =/= [];

handle_call(Request) ->
	?ERROR("unhandled request:~p", [Request]),
	no_reply.


handle_msg(Msg) ->
	?ERROR("unhandled msg:~p", [Msg]),
	ok.

terminate() ->
	ok.


do_loop(_Now) ->
	ok.

