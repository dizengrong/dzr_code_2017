-module(ptc_update_task_condition).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D014.

get_name() -> update_task.

get_des() ->
	 [	
	  	{tasks,{list,task_list_info},[]}  
%% 	 	{taskid,uint32,0},
%% 	 	{taskstep,uint32,0},
%% 	 	{c1_num,uint32,0},
%% 	 	{c2_num,uint32,0},
%% 	 	{c3_num,uint32,0}	 	
	 ].

get_note() ->"完成任务发送\r\n\t
				{c1_num=第一任务计数器计数,c2_num=第二任务计数器计数,c3_num=第三任务计数器计数,state=状态,taskid=任务ID,taskstep=任务步骤}". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).



