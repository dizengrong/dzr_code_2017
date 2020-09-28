-module(ptc_recharge_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D233.

get_name() -> recharge_data.

get_des() ->
	 [
	  {datas,{list,recharge_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



