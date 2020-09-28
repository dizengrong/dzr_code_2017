-module(ptc_camp_leader_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D235.

get_name() -> camp_leader_info.

get_des() ->
	[
	 {uid,uint64,0},
	 {name,string,""},
	 {prof,int32,0},
	 {military_lev,int32,0},
	 {lev,int32,0},
	 {limit_lev,int32,0},
	 {time,int32,0},
	 {deputys,{list,deputy_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


