-module (ptc_hero_illustration).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#f08c.

get_name() -> hero_illustration.

get_des() ->
	[
	 {hero_illustration_list,{list,id_list},[]}
	].

get_note() ->"".

write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).