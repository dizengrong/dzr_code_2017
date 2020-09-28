-module(ptc_usr_head).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D02a.

get_name() -> usr_head.

get_des() -> [
				{uid,uint64,0},
				{useid,uint32,0},
				{headlist,{list,usrid_list},[]}
			].

get_note() ->"用户头像". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).