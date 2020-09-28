-module(ptc_update_camp_leader).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D15A.

get_name() -> update_camp_leader.

get_des() ->
	[{camp_leader_id,uint32,0} ].

get_note() ->"发送阵营首领\r\n\t
			camp_leader_id = 阵营首领ID". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).