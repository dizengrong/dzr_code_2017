-module(ptc_update_scene_usr_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D222.

get_name() -> update_scene_usr_data.

get_des() ->
	[
	 {uid,uint64,0},
	 {sort,uint32,0},	 
	 {sdata,string,""},
	 {idata,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



