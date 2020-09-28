-module(ptc_turning_wheel_config).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D25F.

get_name() -> turning_wheel_config.

get_des() ->
	[	 
	 {data,{list,turning_wheel_config_list},[]}
	].

get_note() ->"". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


