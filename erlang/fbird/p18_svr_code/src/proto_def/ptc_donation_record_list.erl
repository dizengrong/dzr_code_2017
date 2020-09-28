-module(ptc_donation_record_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D11B.

get_name() -> donation_record_list.

get_des() ->
	[{donation_record_list,{list,donation_record_list},[]}  ].

get_note() ->"公会捐献记录:\r\n\t {building_num=捐献资源数量,donation_subscriber=捐献者名字,donation_time=捐献的日期}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).