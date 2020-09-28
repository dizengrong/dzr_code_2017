-module(ptc_expedition_request).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D251.

get_name() -> expedition_request.

get_des() ->
	[
	 {action,int32,0},
	 {datas,{list,exped_entourage_list},[]}
	].

get_note() ->"远征请求".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


