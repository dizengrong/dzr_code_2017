-module(ptc_paragon_level).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D147.

get_name() -> paragon_level.

get_des() ->
	[{paragon_level,{list,paragon_level},[]} ].

get_note() ->"巅峰属性加点\r\n\t
		{prop_type=属性的类型,prop_val=属性的值}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).