-module(ptc_charge_card).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#F00D.

get_name() -> charge_card.

get_des() ->
	[
	 {sort,uint32,0},
	 {date,int32,0}
	].

get_note() ->"充值卡". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).