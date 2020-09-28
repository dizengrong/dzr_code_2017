-module(ptc_guild_commonality).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D114.

get_name() -> guild_commonality.

get_des() ->
	[ 
	 {guild_id,uint64,0},
	 {guild_name,string,""},
	 {president_name,string,""},
	 {guild_ranking,int32,0},
	 {lev,int32,0},
	 {fighting,uint64,0},
	 {member_amount,int32,0},
	 {guild_resource,int32,0},
	 {guild_exp,int32,0},
	 {my_donation,int32,0},
	 {donation_times,int32,0},
	 {guild_state,uint32,0}
	].
get_note() ->"公会公共信息:\r\n\t 
		{guild_id=公会ID,president_name=会长名字,member_amount=人数,lev=等级,guild_ranking=公会排名,
		guild_resource=公会总资源,guild_name= 公会名称,my_donation=我的贡献,donation_times=捐献次数,guild_exp=公会经验},". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).