-module(ptc_entourage_succeed_new).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f037.

get_name() -> entourage_succeed_new.

get_des() ->
	[
	 {success_action,uint32,0},
	 {success_data,uint32,0}
	].

get_note() ->"佣兵手工操作:\r\n\t
			{success_action=行为ID,success_data=相关的数据}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).