-module (ptc_shenqi_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f118.

get_name() ->shenqi_info.

get_des() ->
	[
	 {load_id,uint32,0},
	 {list,{list,property_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).