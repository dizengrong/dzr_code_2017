-module(ptc_usr_info_entourage).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D125.

get_name() -> usr_info_entourage.

get_des() ->
	[ 
	 {entourage_info_list,{list,entourage_info_list},[]}
	].

get_note() ->"其他玩家佣兵信息\r\n\t
			{estar=佣兵星级,estate=佣兵状态(1,拥有|2,激活),etype=佣兵ID,lev=佣兵等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).