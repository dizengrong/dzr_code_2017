-module(ptc_growth_bible_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D178.

get_name() -> growth_bible_info.

get_des() ->
	[{growth_bible_info,{list,growth_bible_info},[]}].
get_note() ->"成长宝典信息".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).