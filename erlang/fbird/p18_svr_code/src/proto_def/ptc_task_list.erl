-module(ptc_task_list).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D013.

get_name() -> task_list.

get_des() ->
	[	 
	 {tasks,{list,task_list_info},[]}
	 ].

get_note() ->"返回任务列表:\r\n\t
					{taskid=任务ID,taskstep=任务步骤,state=任务状态,c1_num=第一计数器数量,c2_num=第二计数器数量,c3_num=第三计数器数量}
				". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).

