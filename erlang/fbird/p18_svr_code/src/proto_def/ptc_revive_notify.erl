-module (ptc_revive_notify).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f12b.

get_name() ->revive_notify.

get_des() ->
	[
	 {nofity_type,uint32,0},
	 {data,uint32,0}
	].

get_note() ->"nofity_type:保留，暂时只用为延时复活的等待时间通知;data:等待的秒数". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

