-module(ptc_ret_ride_info).



-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E111.

get_name() -> ret_ride_info.


get_des() ->
	[
	 {ride_type,uint32,0},
	 {ride_id,uint32,0},
	 {lev,uint8,0},
	 {exp,uint32,0},
	 {ride_state,uint8,0},
	 {fighting,uint32,0},
	 {currskin,uint32,0},
	 {eq1,uint32,0},
	 {eq2,uint32,0},
	 {eq3,uint32,0},
	 {eq4,uint32,0},
	 {eq5,uint32,0},
	 {eq6,uint32,0},
	 {skin,{list,r_skin},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).