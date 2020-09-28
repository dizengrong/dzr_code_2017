-module(fun_agent_pt_post).
-include("common.hrl").

-export([fill/1, fill_pt/1]).
%% 选择消息转发进程
fill(<<Id:16/unsigned-integer,_Binary/binary>>) -> fill_pt(Id).

%% fill_pt(16#B003) -> agent;
%% fill_pt(16#B005) -> agent;
%% fill_pt(16#D002) -> agent;
%% fill_pt(16#D003) -> agent;
%% fill_pt(16#D004) -> agent;
%% fill_pt(16#D005) -> agent;
fill_pt(16#C001) -> 
%% 	?debug("-------------"),
	scene;
fill_pt(16#C004) -> scene;
fill_pt(16#C005) -> scene;
fill_pt(16#C010) -> scene;
fill_pt(16#C012) -> scene;
fill_pt(16#C019) -> scene;
fill_pt(16#C01A) -> scene;
fill_pt(16#D134) -> scene;
fill_pt(16#D144) -> scene;
fill_pt(16#D320) -> scene;
fill_pt(16#F11A) -> scene;
fill_pt(16#D025) -> agent_mng;
fill_pt(16#D027) -> agent_mng;
fill_pt(16#E10E) -> agent_mng;
fill_pt(16#D214) -> agent_mng;
fill_pt(16#D251) -> agent_mng;

fill_pt(16#D20D) -> mod_mail;
fill_pt(16#D210) -> mod_mail;

%% fill_pt(16#BB03) -> {post,agent_mng};
fill_pt(_Id) -> agent.
