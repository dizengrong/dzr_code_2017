-module(ptc_ret_titles).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E10B.

get_name() -> ret_titles.

get_des() ->
	[   {used,uint16,0},
		{titles,{list,title_obj},[]}  
    ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).