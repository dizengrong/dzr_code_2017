-module(ptc_recommend_friends_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D109.

get_name() -> recommend_friends_list.

get_des() ->
	[
	 {relation_info,{list,relation_info},[]}
	].

get_note() ->"推荐好友返回：\r\n\t{camp=阵营,lev=等级,name=名字,prof=职业,uid=玩家ID}
		". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).