-module(ptc_mail_content).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D20C.

get_name() -> mail_content.

get_des() ->
	 [
	 {mail_id,uint32,0},
	 {title,string,""},
	 {content,string,""},	 
	 {items,{list,item_list},[]}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).




