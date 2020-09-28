-module(ptc_update_mail).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D211.

get_name() -> update_mail.

get_des() ->
	 [ 
	 {update_data,{list,update_mails},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


