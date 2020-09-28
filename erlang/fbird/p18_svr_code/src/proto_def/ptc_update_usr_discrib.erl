-module(ptc_update_usr_discrib).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E10D.

get_name() -> update_usr_discrib.

get_des() ->
	
	[  
	    {uid, uint64,0},
	    {sort,uint16,0},
		{int_data,uint32,0},
		{str_data,string,""}  
    ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).