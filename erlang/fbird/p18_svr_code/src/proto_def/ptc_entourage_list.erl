-module(ptc_entourage_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D010.

get_name() -> entourage_list.

get_des() ->
	[
	 {entourage_list,{list,entourage_list},[]}
	].

get_note() ->"所有佣兵列表:\r\n\t:
			{lev=佣兵等级,estar=佣兵星级,etype=佣兵类型,exp=佣兵经验,fightType=佣兵出战,fighting=佣兵战力,itemType=佣兵对应的物品类型,itemVal=佣兵对应的物品类型的数量}
			". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).