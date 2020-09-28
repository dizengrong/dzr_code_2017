-module(ptc_lost_item_recover).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D263.

get_name() -> lost_item_recover.

get_des() ->
	 [	 
	 	{id,uint32,0},
		{debris_num,uint32,0},	
	  	{recover_lev,uint32,0}
	 ].

get_note() ->"遗失之物复原".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



