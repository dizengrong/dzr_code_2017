-module(ptc_chat).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D208.

get_name() -> chat.

get_des() ->
	[
	 {pid,uint64,0},
	 {rec_uid,uint64,0},
	 {name,string,""},
	 {rec_name,string,""},
	 {vip_lev,uint32,0},
	 {chanle,uint32,0},
	 {content,{list,string},[]},
	 {sender_military,uint32,0},
	 {sender_camp,uint32,0},
	 {is_camp_leader,uint32,0},
	 {server_id,uint32,0},
	 {servre_name,string,""},
	 {guild_id,uint64,0},
	 {click_type,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).