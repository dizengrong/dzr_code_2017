-module(ptc_entourage_fetter_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D14C.

get_name() -> entourage_fetter_info.

get_des() ->
	[{entourage_fetter_info,{list,entourage_fetter_info},[]}].

get_note() ->"佣兵羁绊详细信息:\r\n\t". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).