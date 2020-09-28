-module(ptc_usr_title).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E10F.

get_name() -> usr_title.

get_des() ->
	[
	 	{uid,uint64,0},
	 	{titlelev,uint16,0},
	 	{titleexp,uint32,0},
	 	{chgProp,{list,title_chpprof},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



