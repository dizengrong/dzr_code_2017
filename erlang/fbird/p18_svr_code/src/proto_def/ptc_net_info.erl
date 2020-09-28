-module(ptc_net_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A105.

get_name() -> net_info.

get_des() ->
	[
	 {ip,string,""},
	 {port,uint32,0},
	 {uid,uint64,0},
	 {key,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
