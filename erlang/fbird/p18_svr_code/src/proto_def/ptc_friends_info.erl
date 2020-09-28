-module(ptc_friends_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D107.

get_name() -> friends_info.

get_des() ->
	[ 
	 {add_or_remove,uint32,0},
	 {rest_fp_get_num,uint32,0},
	 {rest_fp_give_times,uint32,0},
	 {friends_info,{list,friends_info},[]},
	 {enemy_info,{list,enemy_info},[]},
	 {apply_info,{list,apply_info},[]},
	 {history_info_list,{list,history_info_list},[]}
	 
	].

get_note() ->"关系信息:\r\n\t
			\r\n\tadd_or_remove=(1,添加|2,删除|3,修改),thumb_up_num=点赞次数,by_thumb_up_num=被点赞数
			\r\n\tfriends_info = 好友详情 {by_thumb_up=被点赞数,camp=玩家阵营,lev=玩家等级,name=玩家名字,prof=玩家职业,state=是否在线(0,不在线|1,在线),thumb_up=点赞次数,uid=角色ID}
			\r\n\tenemy_info = 仇人详情{camp=玩家阵营,lev=玩家等级,name=玩家名字,prof=玩家职业,state=是否在线(0,不在线|1,在线),uid=角色ID}
			\r\n\tapply_info = 申请详情{lev=玩家等级,name=玩家名字,prof=玩家职业,uid=角色ID}
			\r\n\history_info_list = 历史信息{history_sort={1,被谁添加好友|2,被谁击杀},object_name=对象的名字,time=发生的时间}


". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).