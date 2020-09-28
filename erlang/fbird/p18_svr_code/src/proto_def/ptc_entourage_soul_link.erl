-module(ptc_entourage_soul_link).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D14D.

get_name() -> entourage_soul_link.

get_des() ->
	[
		{entourage_soul_link,{list,entourage_soul_link},[]},
		{all_unlinked_id,{list,uint32},[]}
	].

get_note() ->"佣兵灵魂连接:\r\n\t
			{entourage_id=佣兵类型,hole_site=位置,prop_type=添加的属性类型,prop_value=添加的属性值}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).