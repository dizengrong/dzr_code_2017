-module(ptc_entourage_star).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D167.

get_name() -> entourage_star.

get_des() ->
	[ {uid,uint64,0},{star,uint32,0}].

get_note() ->"发送给其他玩家，当前玩家的出战佣兵星级:\r\n\t
			{uid=玩家ID,star=出战佣兵星级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).