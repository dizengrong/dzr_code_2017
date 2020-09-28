-module(ptc_all_guild_list_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D111.

get_name() -> all_guild_list_info.

get_des() ->
	[   
	    {guild_state,uint32,0},
		{guild_info_list,{list,guild_info_list},[]} 
	].

get_note() ->"发送所有公会列表:\r\n\tguild_state=前台更新操作,
						\r\n\tguild_info_list=｛guild_camp=公会阵营,guild_id=公会id,guild_level=公会等级,guild_name=公会名字,
						\r\n\tguild_ranking=公会名次,member_amount=公会成员数量,president_name=军团长的名字,req_state=公会申请状态,total_honor=公会总荣誉｝". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).