-module(ptc_send_red_packet_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D196.

get_name() -> send_red_packet_info.

get_des() ->
	[ 
	 {uid,uint64,0},
	 {name,string,""},
	 {prof,uint32,0},
	 {balance,uint32,0},
	 {sendnumber,uint32,0}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).