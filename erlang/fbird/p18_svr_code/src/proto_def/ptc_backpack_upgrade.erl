-module(ptc_backpack_upgrade).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D140.

get_name() -> backpack_upgrade.

get_des() ->
	[ 
	 {entourage_bag,int32,0},
	 {artifact_bag,int32,0}
	].

get_note() ->"背包等级:\r\n\t  entourage_bag=英雄背包，artifact_bag=神器背包". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).