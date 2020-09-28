-module(ptc_war_over).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E121.

get_name() -> war_over.

get_des() ->
	
%% 	完成任务数
%% 阻止完成任务数
%% 击杀
%% 击杀排名
%% 连续击杀
%% 个人分数
%% 击杀杂兵
%% 击杀队长
%% 击杀玩家
	
	[
	 {id,uint32,0},
	 {result,uint8,0},
	 {drops,uint32,0},
	 {items,{list,item_list},[]},
	 {cpl,uint32,0},
	 {prev,uint32,0},
	 {usrkill,uint32,0},
     {killrank,uint32,0},
	 {continuekill,uint32,0},
	 {score,uint32,0},
	 {killm,uint32,0},
     {killu,uint32,0},
     {killc,uint32,0}
	 ].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



