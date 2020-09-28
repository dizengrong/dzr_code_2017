-module(ptc_ret_gamble_record).

-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E12A.

get_name() -> ret_gamble_record.

get_des() ->
	[ 
		 
		 {gamble_records,{list,gamble_record},[]}
	].

get_note() ->"抽奖记录\r\n\t
			{gamble_records=抽奖记录列表}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


