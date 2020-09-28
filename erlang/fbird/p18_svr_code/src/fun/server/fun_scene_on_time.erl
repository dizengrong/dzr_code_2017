%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name : 	scene do_on_time
%% author:  Andy lee
%% date : 	15/7/23 
%% Company: fbird
%% Desc : 	from  fun_scene:do_on_time()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_scene_on_time).
-include("common.hrl").
-export([do_on_time/1]).
-export([task_dungeons_finish/0]).
-export([get_difficulty/1]).


 do_on_time({s_reborn_usr,Uid,Pos,Time})->
 	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true, data = #scene_usr_ex{sid = Sid}} -> 
			Pt = #pt_revive_notify{
				nofity_type = 0,
				data = Time
			},
			?send(Sid,proto:pack(Pt)),
			erlang:start_timer(Time*1000, self(),{fun_interface,do_reborn_usr,{Uid,Pos}});
		_ -> skip
	end;

 do_on_time({s_wait_reborn_usr_new,Uid,_Pos,Time,Type})->
 	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true, data = #scene_usr_ex{hid = Hid}} ->
			mod_msg:send_to_agent(Hid, {usr_revive_new, Uid, Time, Type});
		_ -> skip
	end;

 do_on_time({s_wait_reborn_usr,Uid,_Pos,Time})->
 	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true, data = #scene_usr_ex{hid = Hid}} ->
			mod_msg:send_to_agent(Hid, {usr_revive, Uid, Time});
		_ -> skip
	end;

 do_on_time({s_add_buff_by_uid,Uid,BuffType})->
   case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr, BuffType, Uid));
		_ -> skip
	end;
 do_on_time({s_add_buff_to_hero_by_uid,Uid,BuffType})->
   case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		#scene_spirit_ex{data = #scene_usr_ex{battle_entourage=EntourageList}} ->
			Fun = fun(EntourageOid) ->
				case fun_scene_obj:get_obj(EntourageOid, ?SPIRIT_SORT_ENTOURAGE) of
					EntourageObj = #scene_spirit_ex{die=false} ->
						fun_scene_obj:update(fun_scene_buff:add_buff(EntourageObj, BuffType, Uid));
					_->0
				end
			end,
			lists:foreach(Fun, EntourageList);
		_ -> skip
	end;
 do_on_time({s_del_buff_by_uid,Uid,BuffType})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{die = true} -> skip;
		Usr = #scene_spirit_ex{} ->
			fun_scene_obj:update(fun_scene_buff:del_buff_by_type(Usr, BuffType));
		_ -> skip
	end;
 do_on_time({s_change_all_camp,Camp})->
    case fun_scene_obj:get_ul()of  
		 Usrs  when  erlang:is_list(Usrs)->
			Fun=fun(#scene_spirit_ex{id=Uid,data=#scene_usr_ex{sid=_Sid}}=Usr)-> 
				fun_scene_obj:update(Usr#scene_spirit_ex{camp=Camp}),
				Pt=#pt_update_camp{
					uid = Uid,
					camp = Camp
				},
				fun_scene_obj:send_all_usr(proto:pack(Pt))
			end,
			lists:foreach(Fun, Usrs);
		_->[]
	end;

 do_on_time({s_notice_reborn_time,Uid,Time})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}} ->
			Pt=#pt_start_timer{
				timelen = Time
			},
			?send(Sid,proto:pack(Pt));
		_ -> skip
	end;
do_on_time({s_add_tag_point,Uid,{X,Y,Z}})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}} ->
			Pt=#pt_ret_guide_tag_point{
				x = X,
				y = Y,
				z = Z
			},
			?send(Sid,proto:pack(Pt));
		_ -> skip
	end;
do_on_time({s_usr_area_notice,Uid,Area})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}} ->
			Pt=#pt_ret_war_usr_area{
				area = Area
			},
			 ?send(Sid,proto:pack(Pt));
		_ -> skip
	end;

do_on_time({s_usr_die_notice,_Uid})->
	skip;

do_on_time({s_send_usr_error_report,Uid,Code})->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR)  of  
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}}->?error_report(Sid,Code);
		_->skip
	end;
do_on_time({s_send_usr_error_report,Uid,Code,Data}) ->	
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR)  of  
		#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}}-> ?error_report(Sid,Code,0,Data);
		_->skip
	end;



%% zzp=========================================
do_on_time({del_monster,ID})->
	case fun_scene_obj:get_obj(ID, ?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{} -> fun_scene_obj:remove_obj(ID);							
		_ -> skip
	end;

do_on_time({kill_monster,ID})->
	case fun_scene_obj:get_obj(ID, ?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{} -> fun_scene_obj:remove_obj(ID);							
		_ -> skip
	end;

do_on_time({kill_all_monster})->
	fun_monster:kill_all_monster();

do_on_time({kill_camp_monster,Camp})->
	ML=fun_scene_obj:get_ml(),
	Fun=fun(Monster) ->
			case Monster of
				#scene_spirit_ex{id=ID,camp=Camp,sort=?SPIRIT_SORT_MONSTER} ->
					fun_scene_obj:remove_obj(ID);						
				_ -> skip
			end					
		end,
	lists:foreach(Fun, ML);	

do_on_time({add_partrol_point,ID,Points})->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_MONSTER) of
		#scene_spirit_ex{die=Die,data = #scene_monster_ex{ai_module = Moudle,ai_data = AiData}} = Monster->
			if
				Die==false	-> 
					try
						NewData = Moudle:add_partrol_point(AiData,Points),
						fun_scene_obj:update(fun_scene_obj:put_monster_spc_data(Monster, ai_data, NewData))						
					catch _E:_R -> ok
					end;
				true	->skip
			end;
		_	->skip
	end;

%%中立阵营,场景物品的配置表ID为实例ID,为配置data_scene_item_dis索引ID
do_on_time({add_scene_item,ID,Type,Dir,Pos,HP,Camp,Length,High,Width}) ->
%% 	?debug("{ID,Type}=~p~n",[{ID,Type}]),
	{Script,ActiontType} = case data_scene_item_dis:get_data(ID-?OBJ_OFF) of
							   #st_scene_item_dis_config{script = Script1,actionType=ActiontType1} -> {Script1,ActiontType1};
							   _ -> {"",?SCENE_ITEM_ACTION_TRIGGER}
						   end,
	case data_scene_item:get_data(Type) of
		#st_scene_item_config{modelXY={LenX,LenY,LenZ},collideList=CollideList} ->				
			case fun_scene_map:check_point(tool_vect:to_map_point(Pos)) of
				true -> ?log_warning("add scene item in wrong position,scene=~p,Id=~p,Type=~p,Pos=~p", [get(scene),ID,Type,Pos]);
				_ -> skip
			end,					
			
			Moudle=case Script of
					   "" -> no;
					   "0" -> no;
					   "no" -> no;
					   _ -> util:to_atom(Script)
				   end,
			NCamp=if
					  Camp == 0 -> 1;
					  true -> Camp
				  end,
			{NLenX,NLenY,NLenZ}=if
									Length == 0 orelse Width == 0 -> {LenX,LenY,LenZ};
									true -> {Length,High,Width}
								end,					
			SendClient=case ActiontType of
						   ?SCENE_ITEM_ACTION_TRIGGER -> false;%%触发器不发送到客户端
						   ?SCENE_ITEM_ACTION_BLOCK ->%%是阻挡场景物品
							   fun_scene_map:add_scene_item_wall(ID,Dir,Pos,CollideList),true;									   
						   _ -> true
					   end,
			%% 					?debug("add scene item ,{id,sendclient}=~p~n",[{ID,SendClient}]),
			fun_scene_obj:add_scene_item(#scene_spirit_ex{id=ID,camp=NCamp,pos=Pos,dir=Dir,hp=HP}
										 ,#scene_item_ex{type=Type,length=NLenX,high=NLenY,width=NLenZ,action=Moudle,send_client=SendClient,create_time=util:longunixtime(),ontime_check=util:longunixtime()});
		
		_ -> ?log_error("add scene item error,type=~p~n",[Type])	
	end;


do_on_time({del_item,ID})->
%% 	?debug("del item id=~p~n",[ID]),
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ITEM) of
		#scene_spirit_ex{} ->
			fun_scene_obj:remove_obj(ID),
			case data_scene_item_dis:get_data(ID-?OBJ_OFF) of
				#st_scene_item_dis_config{actionType=?SCENE_ITEM_ACTION_BLOCK} ->
					fun_scene_map:del_scene_item_wall(ID);
				_ -> skip
			end;
		_ -> skip
	end;

do_on_time({kill_item,ID}) ->
	case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_ITEM) of
		#scene_spirit_ex{} ->
			fun_scene_obj:remove_obj(ID),
			case data_scene_item_dis:get_data(ID-?OBJ_OFF) of
				#st_scene_item_dis_config{actionType=?SCENE_ITEM_ACTION_BLOCK} ->
					fun_scene_map:del_scene_item_wall(ID);
				_ -> skip
			end;
		_ -> skip
	end;

do_on_time({next_step})->	
	Step = get(step) + 1,
	put(step,Step),
	ScriptMoudle = fun_scene:get_script_module(),
	try
		ScriptMoudle:onStep(Step)
	catch E:R -> ?log_error("scene onStep error Module = ~p,E = ~p,R=~p,stack=~p",[ScriptMoudle,E,R,erlang:get_stacktrace()])
	end;

do_on_time({notic_bubl,Uid,MonID,SayID})->
	case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR) of  
		Usr when  erlang:is_record(Usr, scene_spirit_ex) ->	
			Pt=#pt_say_notify{
				target_id = MonID,
				say_id = SayID
			},
%% 			?debug("monster say,{MonID,SayID}=~p~n",[{MonID,SayID}]),
			?send(fun_scene_obj:get_usr_spc_data(Usr, sid),proto:pack(Pt));
		_ -> skip
	end;

do_on_time({monster_cast_skill,AtkOid,SkillID,TargetID})-> 	
	case fun_scene_obj:get_obj(AtkOid, ?SPIRIT_SORT_MONSTER) of		
		Monster= #scene_spirit_ex{pos=Pos,dir=Dir} ->
			case fun_scene_obj:get_obj(TargetID, ?SPIRIT_SORT_MONSTER) of		
				#scene_spirit_ex{pos=TargetPos} ->
					NDir = tool_vect:get_dir_angle(tool_vect:dec( tool_vect:to_map_point(TargetPos), tool_vect:to_map_point(Pos) )),					
					fun_scene:monster_skill(Monster,SkillID,TargetID,NDir,TargetPos);
				_ ->
					fun_scene:monster_skill(Monster,SkillID,TargetID,Dir,{0,0,0})
			end;
		_ -> skip
	end;

do_on_time({move_monster, ID, Pos}) ->
%% 	?debug("{move_monster, ID, Pos} = ~p",[{move_monster, ID, Pos}]),	
	case fun_scene_obj:get_obj(ID, ?SPIRIT_SORT_MONSTER) of
		Monster=#scene_spirit_ex{data=#scene_monster_ex{ai_module=AI_Module,ai_data=AiData}=Data} ->			
			NewAiData= try
						   AI_Module:script_move_control(AiData,Pos)
					   catch _E:_R -> ?log_error("script_move_control error,AI_Module=~p",[AI_Module]),AiData
					   end,			
%% 			NewAiData=AI_Module:script_move_control(AiData,Pos),
			fun_scene_obj:update(Monster#scene_spirit_ex{skill_data=0,data=Data#scene_monster_ex{ai_data=NewAiData}});
		_ -> skip
	end;

do_on_time({add_buff, ID, BuffType}) ->
	case fun_scene_obj:get_obj(ID) of
		Obj when erlang:is_record(Obj, scene_spirit_ex) ->	
			NewObj=fun_scene_buff:add_buff(Obj, BuffType, ID),
			fun_scene_obj:update(NewObj);
		_ -> skip
	end;

do_on_time({add_buff_to_all_monster, BuffType}) ->
	ML=fun_scene_obj:get_ml(),
	Fun=fun(Monster) ->
			case Monster of
				#scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER} ->
					NewMonster=fun_scene_buff:add_buff(Monster, BuffType, Monster#scene_spirit_ex.id),
					fun_scene_obj:update(NewMonster);							
				_ -> skip
			end
		end,
	lists:foreach(Fun, ML);

do_on_time({add_buff_to_all_usr, BuffType}) ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
			case Usr of
				#scene_spirit_ex{sort=?SPIRIT_SORT_USR} ->
					NewObj=fun_scene_buff:add_buff(Usr, BuffType, Usr#scene_spirit_ex.id),
					fun_scene_obj:update(NewObj);							
				_ -> skip
			end					
		end,
	lists:foreach(Fun, UL);

do_on_time({del_buff_to_all_usr, BuffType}) ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
			case Usr of
				#scene_spirit_ex{sort=?SPIRIT_SORT_USR} ->
					%%NewObj=fun_scene_buff:add_buff(Usr, BuffType, Usr#scene_spirit_ex.id),
					NewObj=fun_scene_buff:del_buff_by_type(Usr, BuffType),
					fun_scene_obj:update(NewObj);							
				_ -> skip
			end					
		end,
	lists:foreach(Fun, UL);

do_on_time({add_buff_to_camp_usr, BuffType,Camp}) ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
			case Usr of
				#scene_spirit_ex{sort=?SPIRIT_SORT_USR,camp=Camp} ->
					NewObj=fun_scene_buff:add_buff(Usr, BuffType, Usr#scene_spirit_ex.id),
					fun_scene_obj:update(NewObj),					
					ok;							
				_ -> skip
			end					
		end,
	lists:foreach(Fun, UL);

do_on_time({add_buff_to_camp_usr, BuffType,_Camp,UnionBuffNum,MonType}) ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
		case Usr of
			#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR,camp=_Camp} ->
			%%#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR} ->
				%%?debug("add_buff_to_camp_usr,UnionBuffNum=~p",[UnionBuffNum]),
				NewObj=fun_scene_buff:add_buff(Usr, BuffType, Usr#scene_spirit_ex.id),
				fun_scene_obj:update(NewObj),
				fun_interface:s_send_usr_national_info(Uid,MonType,UnionBuffNum),
				ok;
			_ -> skip
		end
	end,
	lists:foreach(Fun, UL);

do_on_time({del_buff_to_camp_usr, BuffType,Camp}) ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
		case Usr of
			#scene_spirit_ex{sort=?SPIRIT_SORT_USR,camp=Camp} ->
				NewObj=fun_scene_buff:del_buff_by_type(Usr, BuffType),
				fun_scene_obj:update(NewObj),
				ok;
			_ -> skip
		end
	end,
	lists:foreach(Fun, UL);

do_on_time({del_buff_to_camp_usr, BuffType,Camp,UnionBuffNum,MonType}) ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
		case Usr of
			#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR,camp=Camp} ->
				NewObj=fun_scene_buff:del_buff_by_type(Usr, BuffType),
				fun_scene_obj:update(NewObj),
				fun_interface:s_send_usr_national_info(Uid,MonType,UnionBuffNum),
				ok;
			_ -> skip
		end
	end,
	lists:foreach(Fun, UL);

do_on_time({task_dungeons_finish,DelayTime}) ->
	erlang:start_timer(DelayTime*1000, self(), {?MODULE, task_dungeons_finish});

do_on_time({add_trap,{SkillType,SkillLev,SkillPerformance,OwnID,TrapType,Pos,Dir}}) ->
	case fun_scene_obj:get_obj(OwnID, ?SPIRIT_SORT_MONSTER) of
		Monster = #scene_spirit_ex{} ->
			fun_scene_arrow:add_trap({SkillType,SkillLev,SkillPerformance,Monster,TrapType,Pos,Dir,util:longunixtime()});	
		_ -> skip	
	end;

do_on_time({arena_start_time,Sec}) ->
	Pt=#pt_arena_start_time{
		start_time = Sec
	},
	fun_scene_obj:send_all_usr(proto:pack(Pt));

do_on_time({send_scene_finish_time}) ->
	Now=util:unixtime(),
	case get(scene_finish_time) of
		undefined -> skip;
		Val ->
			if
				Now < Val ->
					Pt=#pt_copy_exist_time{time_len = Val-Now},
					fun_scene_obj:send_all_usr(proto:pack(Pt));
				true -> skip
			end
	end;

do_on_time({set_jb_mon,Num}) ->	
	Pt=#pt_crowd_num{num = Num},	
	fun_scene_obj:send_all_usr(proto:pack(Pt));

do_on_time({send_error_report,Code}) ->	
	UL=fun_scene_obj:get_ul(),
	Fun= fun(#scene_spirit_ex{id=Id,data = #scene_usr_ex{sid = Sid}}) ->	
				 ?debug("-----send_error_report----------Id=~p,Code=~p",[Id,Code]),
				 ?error_report(Sid,Code)
		 end,
	lists:foreach(Fun, UL);

do_on_time({send_error_report,Code,Data}) ->	
	UL=fun_scene_obj:get_ul(),
	Fun= fun(#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}}) ->	
				 ?error_report(Sid,Code,0,Data)
		 end,
	lists:foreach(Fun, UL);

do_on_time({kick_all}) ->	
	lists:foreach(fun(#scene_spirit_ex{id=Uid})-> fun_scene:copy_out_decision(Uid,0) end, fun_scene_obj:get_ul());

do_on_time({quit_copy}) ->	
	Fun = fun(#scene_spirit_ex{data = #scene_usr_ex{hid=AgentHid}}) ->
		mod_msg:handle_to_agent(AgentHid, mod_scene_lev, copy_out)
	end,
	[Fun(O) || O <- fun_scene_obj:get_ul()];

do_on_time({set_usr_penta_kill,AtkOid,DefOid,_DemageList}) ->
	case fun_scene_obj:get_obj(AtkOid, ?SPIRIT_SORT_USR) of
		AtkedObj=#scene_spirit_ex{data=Data} ->
			Num=Data#scene_usr_ex.penta_kill,
			fun_scene_obj:update(AtkedObj#scene_spirit_ex{data=Data#scene_usr_ex{penta_kill=Num+1,penta_kill_time=util:longunixtime()}}),
			fun_scene:send_count_event(AtkOid, kill_someone, 0, 1, 1),
%% 			NewAtkedObj1=fun_scene_obj:put_usr_spc_data(AtkedObj,penta_kill,Num+1),
%% 			NewAtkedObj=fun_scene_obj:put_usr_spc_data(NewAtkedObj1,penta_kill_time,util:longunixtime()),
%% 			fun_scene_obj:update(NewAtkedObj),
			case fun_scene_obj:get_obj(DefOid, ?SPIRIT_SORT_USR) of
				_BeAtkedObj=#scene_spirit_ex{camp =Camp} ->
					private_system_msg(AtkOid,Camp, DefOid, Num+1); 
				_ -> skip	
			end;			
		_ -> skip	
	end;

do_on_time({s_transmit_to_pos,Uid,Pos={X,Y,Z}}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			fun_scene_obj:update(Usr#scene_spirit_ex{pos=Pos}),
			NSort=fun_scene_obj:get_spirit_client_type(Uid),
			Pt=#pt_scene_transform{
									  oid = Uid,
									  obj_sort = NSort,
									  type = 0,
									  time = 0,%%瞬移时间为0
									  x = X,
									  y = Y,
									  z = Z
									 },
			Data=proto:pack(Pt),
			fun_scene_obj:send_all_usr(Data);			
		_ -> skip	
	end;
do_on_time({s_transmit_to_pos,Uid,Pos={X,Y,Z},Seq,State}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{data=#scene_usr_ex{sid=Sid}} ->
			fun_scene_obj:update(Usr#scene_spirit_ex{pos=Pos}),
			NSort=fun_scene_obj:get_spirit_client_type(Uid),
			Pt=#pt_scene_transform{
									  oid = Uid,
									  obj_sort = NSort,
									  type = 0,
									  time = 0,%%瞬移时间为0
									  x = X,
									  y = Y,
									  z = Z
									 },
			Data=proto:pack(Pt,Seq),
			?send(Sid,Data),
			fun_scene:send_flying_shoes(Sid,State); 
		_ -> skip	
	end;

do_on_time({clear_skill_cd,Uid}) ->
	fun_scene_cd:clear_entourage_cd(Uid),
	fun_scene_cd:clear_cd(Uid);

do_on_time(Event) -> ?log("do_on_time no proc Event = ~p",[Event]),skip.
private_system_msg(AtkOid,DefCamp,DefOid,Num)->
	case fun_scene_obj:get_obj(AtkOid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{camp=AtKCamp,data=#scene_usr_ex{hid=AgentHid}} ->
%% 			fun_scene_obj:agentmng_msg(AgentHid, {camp_kill,AtkOid, DefOid,0}),%%和do_effect重复
			if
				Num ==5->send_system_msg(AtkOid, 243,DefCamp);
				Num ==10->send_system_msg(AtkOid, 244,DefCamp);
				Num ==20->send_system_msg(AtkOid, 244,DefCamp);
				Num ==30->send_system_msg(AtkOid, 245,DefCamp); 
				Num ==40->send_system_msg(AtkOid, 246,DefCamp);
				Num ==50->send_system_msg(AtkOid, 247,DefCamp);
				true->
					fun_scene_obj:agentmng_msg(AgentHid,{system_speaker,[integer_to_list(416),util:to_list(util:get_name_by_uid(DefOid)),util:to_list(get_scene_name(get(scene))),util:to_list(util:get_name_by_uid(AtkOid))]
														  ,{?CHANLE_CAMP,AtKCamp}}),
					fun_scene_obj:agentmng_msg(AgentHid,{system_speaker,[integer_to_list(242),util:to_list(util:get_name_by_uid(DefOid)),util:to_list(get_scene_name(get(scene))),util:to_list(util:get_name_by_uid(AtkOid))]
														  ,{?CHANLE_CAMP,DefCamp}})
			end;
		_->skip
	end.
		
send_system_msg(Uid,DataNum,DefCamp)->
	SceneId = get(scene),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{hid=AgentHid}} ->
			fun_scene_obj:agentmng_msg(AgentHid,{system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_scene_name(SceneId))],{?CHANLE_CAMP,DefCamp}});
		_->skip
	end.
%% 	gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_scene_name(SceneId))],{?CHANLE_CAMP,DefCamp}}).

task_dungeons_finish() ->
	UL=fun_scene_obj:get_ul(),
	Fun=fun(Usr) ->
			case Usr of
				#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR} ->
					fun_scene:send_count_event(Uid, task_dungeons_finish, 0, get(scene), 1),
					fun_scene:copy_out_decision(Uid, 0);
				_ -> skip
			end					
		end,
	lists:foreach(Fun, UL).	





get_scene_name(SceneId)->
	case data_scene_config:get_scene(SceneId) of
		#st_scene_config{name=Name}->Name;
		_->""
	end.

get_difficulty(Scene) ->
	case data_dungeons_config:select(Scene) of
		[DungeonID | _] ->
			case data_dungeons_config:get_difficulty(DungeonID) of 
				Diff = #st_dungeon_dificulty{} ->	Diff;
				_ -> #st_dungeon_dificulty{}
			end;
		_ -> #st_dungeon_dificulty{}
	end.
