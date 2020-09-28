-module(ptc_action_string).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D004.

get_name() -> action_string.

get_des() ->
	[
	 {action,int32,0},
	 {data,string,""}
	 ].

get_note() ->"
			1032	搜索好友(目标玩家名字)
			1041	请求创建公会(公会名字)
			1050	搜索公会(公会名字)
			1066	更新公告(公告内容)
				
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
