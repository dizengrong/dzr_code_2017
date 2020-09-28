-module (ptc_global_guild_ranklist_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f054.

get_name() ->global_guild_ranklist_info.

get_des() ->
	[
	 {type,uint32,0},
	 {my_num,uint32,0},
	 {my_rank,uint32,0},
	 {ranklist,{list,global_guild_ranklist},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).