-module(ptc_item_compound_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D143.

get_name() -> ptc_item_compound_succeed.

get_des() ->
	[{get_success_list,{list,get_success_list},[]}].

get_note() ->"合成成功\r\n\t
			{success_action=1,success_data=物品type}
				". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).