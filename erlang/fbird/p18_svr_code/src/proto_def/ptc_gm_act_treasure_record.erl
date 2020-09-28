-module(ptc_gm_act_treasure_record).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f124.

get_name() ->gm_act_treasure_record.

get_des() ->
	[
	 {type,uint32,0},
	 {records,{list,treasure_record_des},[]}
	].

get_note() ->"
type:1:所有记录 2:新增一条记录
treasure_record_des:抽奖记录
". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).