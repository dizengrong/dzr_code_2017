-module(ptc_rechargejifen_shop).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D41F.

get_name() -> rechargejifen_shop.

get_des() ->
	[
	 {start_time,uint32,0},
	 {end_time,uint32,0},
	 {close_time,uint32,0},
	 {my_jifen,uint32,0},
	 {desc,string,""},
	 {jifen_shop,{list,jifen_shop},[]}
	].

get_note() ->" ". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).