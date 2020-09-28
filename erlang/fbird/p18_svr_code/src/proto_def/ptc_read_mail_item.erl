-module(ptc_read_mail_item).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D210.

get_name() -> read_mail_item.

get_des() ->
	 [	 
	 {mails,{list,id_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


