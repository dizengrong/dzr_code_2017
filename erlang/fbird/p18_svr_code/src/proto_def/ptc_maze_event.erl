-module (ptc_maze_event).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f050.

get_name() ->maze_event.

get_des() ->
	[
	 {id,uint32,0},
	 {name,string,""},
	 {lev,uint32,0},
	 {vip_lev,uint32,0},
	 {head_id,uint32,0},
	 {fighting,uint32,0},
	 {server_id,uint32,0},
	 {servername,string,""},
	 {monster_type,uint32,0}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).