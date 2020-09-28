-module (ptc_client_error_report).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f130.

get_name() ->client_error_report.

get_des() ->
	[
	 {report_type,uint32,0},
	 {msg,string,""}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

