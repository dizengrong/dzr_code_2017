-module(ptc_entourage_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D011.

get_name() -> entourage_info.

get_des() ->
	[
	 {eType,uint32,0},
	 {fighting,uint32,0},
	 {lev,uint32,0},
	 {exp,uint32,0},
	 {hp,uint32,0},
	 {itemType,uint32,0},
	 {itemVal,uint32,0},
	 {eStar,uint32,0},
	 {fightType,uint32,0},
	 {played,uint32,0},
	 {settle_type,uint32,0},
	 {skill_list,{list,skill_list},[]},
	 {equip_list,{list,equip_list},[]},
	 {property_list,{list,property_list},[]},
	 {rune_list,{list,entourage_rune_list},[]},
	 {entourage_fetter_info,{list,entourage_fetter_info},[]}
	].

get_note() ->"
		佣兵详细信息：\r\n\t
		\r\n\teType=佣兵类型,eStar=佣兵星级,exp=佣兵经验,fightType=佣兵出战类型（{1,激活},{2,出战}）,fighting=战力,hp=血量
		\r\n\t,itemType=佣兵碎片对应的物品ID,itemVal=佣兵碎片对应的物品数量,lev=佣兵等级,played=佣兵出战次数,
		\r\n\tskill_list=佣兵技能详情{skillId=技能ID,activateType=技能激活状态({0,未激活},{1,已激活}),runeId=技能符文ID,skillLev=技能等级},
		\r\n\tequip_list=佣兵装备详情{itemNum=物品数量,itemType=物品类型,activateType=激活状态({0,未激活},{1,已激活}),equipId=物品实例化ID},
		\r\n\tproperty_list =佣兵属性详情{propertyId=属性的类型,propertyVal=属性的数值}
		\r\n\tentourage_fetter_info=佣兵羁绊信息{{佣兵信息,佣兵羁绊ID,佣兵羁绊等级}}}
	". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).