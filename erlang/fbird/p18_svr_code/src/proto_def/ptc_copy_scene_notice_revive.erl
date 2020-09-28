-module(ptc_copy_scene_notice_revive).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D242.

get_name() -> copy_notice_revive.

get_des() -> [].

get_note() ->"副本死亡后通知显示复活". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

