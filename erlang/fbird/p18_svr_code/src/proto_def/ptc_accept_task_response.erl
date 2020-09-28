-module(ptc_accept_task_response).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D018.

get_name() -> accept_task_response.

get_des() ->
	 [
	  	{tasks,{list,task_list_info},[]} 
%% 	 	{taskid,uint32,0},
%% 	 	{taskstep,uint32,0},
%% 		{state,uint32,0},	
%% 	 	{c1_num,uint32,0},
%% 	 	{c2_num,uint32,0},
%% 	 	{c3_num,uint32,0}		 
	 ].

get_note() ->"接受任务返回:\r\n\t
		c1_num=计数器1的数量,c2_num=计数器2的数量,c3_num=计数器3的数量,state=任务状态,taskid=任务ID,taskstep=任务步骤". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).


