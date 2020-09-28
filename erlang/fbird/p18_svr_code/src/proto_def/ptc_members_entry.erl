-module(ptc_members_entry).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D113.

get_name() -> members_entry.

get_des() ->
	[ 
	 	{guild_members_entry_list,{list,guild_members_entry_list},[]} 
	 ].

get_note() ->"工会申请新成员验证：\r\n\t
			{lev=新成员验证等级,name=新成员验证名字,prof=新成员验证职业,uid=新成员验证玩家ID}
		
		". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).