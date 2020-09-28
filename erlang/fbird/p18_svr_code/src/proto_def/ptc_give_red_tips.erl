-module(ptc_give_red_tips).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D25B.

get_name() -> give_red_tips.

get_des() -> [].

get_note() ->"give password red tips".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


