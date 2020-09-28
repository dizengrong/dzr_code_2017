-module(ptc_mdf_team_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E10E.

get_name() -> mdf_team_info.

get_des() ->
	 [	 
	 	{min_lev,uint8,0},
		{max_plys,uint8,0},
		{min_gs,uint8,0},
	 	{need_verify,uint8,0}	 	 
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



