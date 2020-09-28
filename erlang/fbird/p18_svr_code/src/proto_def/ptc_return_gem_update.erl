-module(ptc_return_gem_update).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D103.

get_name() -> return_gem_update.

get_des() ->
	[ 
	 {gem_list,{list,gem_list},[]}
	 ].

get_note() ->"宝石详细信息：
		\r\n\t{gem_id=宝石ID,gem_exp=宝石经验,gem_lev=宝石等级}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).