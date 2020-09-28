-module(ptc_pwd_red_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D259.

get_name() -> pwd_red_info.

get_des() -> 
	[
	 {reds,{list,pwd_red_list},[]}
	].

get_note() ->"password red list info".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


