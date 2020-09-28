-module (ptc_hero_attr_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f132.

get_name() ->hero_attr_info.

get_des() ->
	[
	 {eid,uint32,0},
	 {fighting,uint32,0},
	 {attrs,{list,attr_info},[]}
	].

get_note() ->"fighting:战力, attrs:属性列表". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

