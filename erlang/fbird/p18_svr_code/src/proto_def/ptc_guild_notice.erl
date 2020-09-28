-module(ptc_guild_notice).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D138.

get_name() -> guild_notice.

get_des() ->
	[ {data,string,""} ].

get_note() ->"公会公告：\r\n\tdata=公会内容". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).