%% @doc agent被动技能
-module(fun_agent_passive_skill).
-include("common.hrl").
-export([init_passive_skill/1, get_skills/1, update_skills/1]).


%%登录处理
init_passive_skill(Uid) -> 
	put(passive_skill, all_module_skills(Uid)),
	ok.


get_skills(_Uid) ->
	get(passive_skill).


%% 其他系统也有被动技能就在这里添加
all_module_skills(Uid) ->
	List1 = fun_element_pearl:get_passive_skills(Uid),
	List2 = fun_talent:get_passive_skills(Uid),
	List1 ++ List2.


update_skills(Uid) -> 
	List = all_module_skills(Uid),
	put(passive_skill, List),
	fun_agent:send_to_scene({update_passive_skill, Uid, List}).




