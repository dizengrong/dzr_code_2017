-module(ptc_use_someone_title).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E10C.

get_name() -> use_someone_title.

get_des() ->
	[
	 {title,uint16,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



