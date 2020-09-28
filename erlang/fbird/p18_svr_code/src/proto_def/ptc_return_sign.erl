-module(ptc_return_sign).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D105.

get_name() -> return_sign.

get_des() ->
	[
	  {signe_state, uint32, 0},
	  {sign_dates, uint32, 0},
	  {fetched_list, {list, uint32}, []}
	].

get_note() ->"signe_state:今日是签到状态(0:未 1:已签到), sign_dates:累积签到天数, fetched_list:已领取的累积签到奖励id列表". 

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).