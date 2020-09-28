-module(ptc_guild_member_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D112.

get_name() -> guild_member_info.

get_des() ->
	[ 
		{guild_member_list,{list,guild_member_list},[]}  
    ].

get_note() ->"公会成员列表\r\n\t
	id 名字 等级 职务 总贡献 最近在线时间 是否是好友 是否在线
{contribution=总贡献,friends_state=是否是好友(1,是|0,不是),member_id=玩家ID,member_name=名字,member_post=职务
 ,memberlevel=等级,online_state=是否在线,recentOnlineTime=最近在线时间}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).