-module(ptc_camp_worship).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D21E.

get_name() -> can_worship.

get_des() ->
	 [
	 	{can_wor,int32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



