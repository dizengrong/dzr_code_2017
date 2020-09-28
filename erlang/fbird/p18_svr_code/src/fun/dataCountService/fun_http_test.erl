-module(fun_http_test).

-export([test_send/1]).


test_send(1)->
fun_dataCount_update:update_online_usr(1,1,1);

test_send(2)->
	fun_dataCount_update:get_cdkey_info(1, 1, 1, 1, self());
test_send(_)->
	ok.