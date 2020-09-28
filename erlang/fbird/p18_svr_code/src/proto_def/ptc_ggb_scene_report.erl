-module (ptc_ggb_scene_report).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E204.

get_name() -> ggb_scene_report.

get_des() ->
	[ 
	 {report_type,uint8,0},
	 {datas,{list,string},[]}
	].

get_note() ->"跨服战场景战报". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).