-module(ptc_entourage_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D118.

get_name() -> entourage_succeed.

get_des() ->
	[{get_success_list,{list,get_success_list},[]}].

get_note() ->"佣兵出战成功:\r\n\t
			{success_action=行为ID{1,出战},success_data=佣兵的类型}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).