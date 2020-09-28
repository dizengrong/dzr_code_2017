-module(ptc_usr_info_equi).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D123.

get_name() -> usr_info_equi.

get_des() ->
	[ 
		 {pid,uint64,0},
		 {name,string,""},
		 {prof,uint32,0},
		 {camp,uint32,0},
		 {headid,uint32,0},
		 {title,uint32,0},
		 {military,uint32,0},
		 {vip_lev,uint32,0},
		 {relife_time,uint32,0},
		 {achieve_lev,uint32,0},
		 {model_clothes,uint32,0},
	     {fighting,uint32,0},
		 {item_list,{list,item_des},[]},
		 {other_gem_list,{list,other_gem_list},[]}
	].

get_note() ->"其他玩家装备信息\r\n\t
			{pid=玩家ID,name=玩家名字,prof=玩家职业,title=玩家称号，military=玩家军衔，achieve_lev=玩家成就等级，vip_lev=玩家VIP等级，
			\r\n\trelife_time=玩家转生次数，model_clothes=玩家穿戴的时装，fighting=玩家战力，item_list=玩家穿戴的装备列表}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).