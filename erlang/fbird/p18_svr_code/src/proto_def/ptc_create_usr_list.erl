-module(ptc_create_usr_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#A107.

get_name() -> create_usr_list.

get_des() ->
	[
	 {usr_list,{list,create_usr_info},[]}
	 ].

get_note() ->"创建角色详细信息:\r\n\t{id=角色ID,name=角色名字,level=角色等级, prof=角色职业,camp=角色阵营,
				\r\n\t	equip_id_list = 装备列表{equip_id = 装备type} ,last_login_time = 角色最后登陆时间,
				\r\n\tcreate_time =角色创建时间,model_clothes=时装ID,paragon_level=巅峰等级,vip_lev=VIP等级,sum_star=装备总星数}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
