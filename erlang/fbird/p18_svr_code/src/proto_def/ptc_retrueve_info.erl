-module(ptc_retrueve_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D15B.

get_name() -> retrueve_info.

get_des() ->
	[ {retrueve_info,{list,retrueve_info},[]} ].

get_note() ->"系统找回信息：
			{retrueve_id=系统功能ID,retrueve_time=系统功能次数}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).