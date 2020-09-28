-module(ptc_gm_continu_recharage).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D25C.

get_name() -> gm_continu_recharge.

get_des() ->
	[	 
	 {data,{list,diamond_lev_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


