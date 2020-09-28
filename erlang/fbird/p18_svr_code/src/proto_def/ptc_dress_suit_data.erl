-module(ptc_dress_suit_data).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D262.

get_name() -> dress_suit_data.

get_des() ->
	[ 
	  {dress_suit_list,{list,id_list},[]}
	].

get_note() ->"套装数据". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


