-module(ptc_guild_succeed).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D115.

get_name() -> guild_succeed.

get_des() ->
	[
	 {type,uint32,0},
	 {guild_operation_list,{list,guild_operation_list},[]}
	].

get_note() ->"客户端成功操作公会行为\r\n\t
			{success_action=公会操作行为ID[1,踢出|2,退出|3,创建|4,解散公会],success_data=操作的目标ID}
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).