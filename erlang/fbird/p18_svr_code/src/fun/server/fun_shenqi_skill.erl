%% @doc 处理场景内释放神器技能的

-module (fun_shenqi_skill).
-include("common.hrl").
-export([handle/1, robot_cast_shenqi_skill/5, user_cast_shenqi_skill/2]).

%% 神器技能释放范围
-define(AREA_TYPE_TARGET_ONE, 1).  %% 单个目标 	
-define(AREA_TYPE_TARGET_CIR, 2).  %% 以某个目标为中心的圆形区域 	
-define(AREA_TYPE_TARGET_RECT, 5).  %% 以某个目标为中心的矩形区域 	
%% 2017-11-2:下面两种范围暂时没有实现
-define(AREA_TYPE_SELF_ONE,   3).  %% 自己 	
-define(AREA_TYPE_SELF_CIR,   4).  %% 以某自己为中心的圆形区域 	



robot_cast_shenqi_skill(_CasterObj, _TargetID, _TargetPos, {_SkillType, _SkillLev}, _Seq) ->
	todo.


user_cast_shenqi_skill(Uid, Seq) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data = #scene_usr_ex{skill_list = Skill_List}} -> 
			handle({continue_cast_shenqi_skill, Uid, Seq, Skill_List});
		_ -> 
			?ERROR("NO user ~p object when cast shenqi skill?", [Uid])
	end.


handle({continue_cast_shenqi_skill, Uid, Seq, Skill_List}) ->
	case get(battle_stop) of
		false ->
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{pos = Pos} = Usr ->
					case Skill_List of
						[{SkillType,SkillLev} | RestSkills]->
							put(is_in_fight, true), %% 主关卡刷怪需要知道是否玩家是在战斗中
							CastPos = Pos,
							case fun_scene:usr_skill(Usr,{SkillType,SkillLev},0,CastPos,Seq,true,scene:get_scene_long_now()) of
								{error, not_succ} -> skip;
								_ ->
									Msg = {handle_msg, ?MODULE, {continue_cast_shenqi_skill, Uid, Seq, RestSkills}},
									RestSkills /= [] andalso erlang:send_after(200, self(), Msg)
							end;	
						_ -> 
							?WARNING("user ~p has no shenqi skill loaded",[Uid])
					end;
				_ -> ?ERROR("NO user ~p object when cast shenqi skill?", [Uid])
			end;
		_ -> ?DEBUG("main scene battle is stop")
	end.