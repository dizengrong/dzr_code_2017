-module(ptc_item_model_clothes).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D146.

get_name() -> item_model_clothes.

get_des() ->
	[ {item_model_clothes,{list,item_model_clothes},[]} ].

get_note() ->"时装的详细信息：\r\n\t
				{state=是否穿戴(1,拥有,2，穿戴),type=时装ID,lev=时装等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).