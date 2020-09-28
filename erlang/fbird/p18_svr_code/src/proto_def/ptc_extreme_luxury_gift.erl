-module(ptc_extreme_luxury_gift).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D406.

get_name() -> extreme_luxury_gift.

get_des() ->
	[ 
	 {extreme_luxury_gift_info,{list,extreme_luxury_gift_info},[]},
	  {extreme_ranklist,{list,extreme_ranklist},[]}
	].

get_note() ->"至尊豪礼". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).