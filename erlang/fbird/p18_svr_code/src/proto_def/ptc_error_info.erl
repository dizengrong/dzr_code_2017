-module(ptc_error_info).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D001.

get_name() -> error_info.

get_des() ->
	[
	 {error,int32,0},
	 {msg,{list,normal_info},[]}
	 ].

get_note() ->"错误提示:\r\n\t{error=错误提示Id,msg=错误提示内容{{type=类型[{1,数字},{2,浮点数},{3,列表}],data=错误提示Id}}}".
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).
