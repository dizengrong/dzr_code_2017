-module(ptc_entourage_info_new).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f036.

get_name() -> entourage_info_new.

get_des() ->
	[
	 {type,uint32,0},
	 {fighting,uint32,0},
	 {lev,uint32,0},
	 {star,uint32,0},
	 {property_list,{list,property_list},[]}
	].

get_note() ->"船新版本，英雄详细信息 \r\n\t
		\r\n\ttype=佣兵类型,fighting=战力,lev=佣兵等级,star=佣兵星级,
		\r\n\tproperty_list =佣兵属性详情{propertyId=属性的类型,propertyVal=属性的数值}
".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).