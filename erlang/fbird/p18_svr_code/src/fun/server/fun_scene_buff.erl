-module(fun_scene_buff).
-include("common.hrl").
-export([add_buff/3,add_buff/4,add_buff/5,add_buff/6,add_skill_self_buff/3,add_skill_target_buff/6,count_demage/3,count_exp/2]).
-export([rand_move/1,can_be_atk/1,can_be_kick/1,can_start_skill/1,can_start_normal/1,can_continue_skill/1,can_controll_move/1,can_start_move/1,can_continue_move/1]).
-export([del_buff_by_type/2,get_buff_by_type/2,buff_act_remove/1,del_skill_target_buff/1,del_buff_by_die/1,del_buff_by_chg_map/1]).
-export([is_stun/1,is_sleep/1,is_banish/1,is_fear/1,is_sneered/1,get_sneered_buff/1,add_alive_buff/2,send_alive_buff/2]).
-export([
	remove_debuff/1,delay_add_buff/1,process_buff_skill/2,process_dot_buff/1,
	remove_timeout_buff/1,can_do_ai/1,remove_all_buff/0,handle/1
]).


add_buff(Obj, Type, Adder) ->
	add_buff(Obj, Type, Adder,{0,0}).
add_buff(Obj, Type, Adder,FromSkill) ->
	case data_buff:get_data(Type) of
		#st_buff_config{default_time=DefTime, default_value=DefValue} ->
			add_buff(Obj, Type, DefValue, DefTime, Adder,FromSkill);
		_ -> Obj
	end.
add_buff(Obj,Type,Power,Time,Adder) -> 
	add_buff(Obj,Type,Power,Time,Adder,{0,0}).



add_buff(Obj1,Type,Power,Time,Adder,FromSkill) ->
	%%如果是冲锋bug的时候,删除减速bug
	Obj = can_path_del_attributeper(Obj1, Type),
	
	case check_add_buff(Obj, Type) of
		true ->
			CheckBossBuff=check_boss_add_buff(Obj,Type),
			case CheckBossBuff of
				true ->
					add_buff_break_progress_bar(Obj,Type),
					case data_buff:get_data(Type) of 
						#st_buff_config{delayTime=Dalay_Time}-> 
							if  
								Dalay_Time=<0->now_add_buff(Obj,Type,Power,Time,Adder,FromSkill);
								true->
									scene_big_loop:add_callback(Dalay_Time div 1000, ?MODULE, delay_add_buff, {Obj#scene_spirit_ex.id,Type,Power,Time,Adder,FromSkill}),
									Obj
							end;
						_->Obj
					end;					
				_ -> Obj
			end;
		_ -> 
			Obj
	end.

check_add_buff(ToObj, Type) ->
	%%目标无敌的时候，有害buff不能添加
	case fun_scene_buff:can_be_atk(ToObj#scene_spirit_ex.buffs) of
	 	true -> 
	 		case data_buff:get_data(Type) of   										
				 #st_buff_config{bdemage=2}-> {false,wudi};
				 _ -> check_add_buff2(ToObj, Type)
			end;
	 	_ -> check_add_buff2(ToObj, Type)
	end.

check_add_buff2(ToObj, Type) ->
	case data_buff:get_data(Type) of   										
		 #st_buff_config{sort="CONTROL"}-> {false,wudi};
		 _ -> check_add_buff3(ToObj, Type)
	end.

check_add_buff3(_ToObj = #scene_spirit_ex{final_property = #battle_property{stun_defeat = StunDefeat}}, Type) ->
	case data_buff:get_data(Type) of   										
		 #st_buff_config{sort=?BUFF_CONTROLL_SORT_XUANYUN} -> 
		 	case StunDefeat > 0 of
		 		false -> true;
		 		_ -> 
		 			util:rand(0, 10000) > StunDefeat
		 	end;
		 _ -> true
	end.


delay_add_buff({Oid,Type,Power,Time,Adder,FromSkill}) ->
	case fun_scene_obj:get_obj(Oid) of
		Obj = #scene_spirit_ex{die=Die} when Die=/=true->
			fun_scene_obj:update(fun_scene_buff:now_add_buff(Obj, Type, Power, Time, Adder, FromSkill));
		_ -> skip
	end.

remove_debuff(Uid) -> 
	case fun_scene_obj:get_obj(Uid) of
		Obj = #scene_spirit_ex{buffs = Buffs} -> 
			Fun = fun(#scene_buff{type = Type}, Acc) ->
				case data_buff:get_data(Type) of
					#st_buff_config{bdemage = 2} -> %% 减益buff
						del_buff_by_type(Acc, Type);
					_ -> 
						Acc
				end
			end,
			NewObj = lists:foldl(Fun, Obj, Buffs),
			fun_scene_obj:update(NewObj),
			ok;
		_ -> skip
	end.
	

can_path_del_attributeper(Obj,BuffType)->
	case data_buff:get_data(BuffType)  of 
		#st_buff_config{sort = ?BUFF_SORT_PATH}->
			Fun = fun(#scene_buff{type = OwnType},GetObj) ->
						  case  data_buff:get_data(OwnType)  of   
							  #st_buff_config{sort = ?BUFF_SORT_PROPERTY_PER,bdemage=2,data1=?PROPERTY_MOVESPD}-> 
								  del_buff_by_type(GetObj, OwnType);
							  _R-> GetObj
						  end
				  end,
			lists:foldl(Fun, Obj, Obj#scene_spirit_ex.buffs);
		_->Obj
	end.


now_add_buff(Obj,Type,Power,Time,Adder,FromSkill) ->
	LongNow = scene:get_scene_long_now(),
	case lists:keyfind(Type, #scene_buff.type, Obj#scene_spirit_ex.buffs) of
		Buff = #scene_buff{power = ThisPower,mix_lev = MixLev} ->
			if
				abs(ThisPower) > abs(Power) -> Obj;
				ThisPower == Power ->
					case data_buff:get_data(Type) of  
						#st_buff_config{maxmix = MaxLev} -> 
							if
								MixLev + 1 >  MaxLev ->  
									NBuff = Buff#scene_buff{mix_lev=MaxLev,start=LongNow,lenth=new_buff_time(Buff, Time),effect_time=LongNow,buff_adder=Adder,from_skill = FromSkill},
									chg_buff(Obj,NBuff,false);
								true ->
									NBuff = Buff#scene_buff{mix_lev=MixLev + 1,start=LongNow,lenth=new_buff_time(Buff, Time),effect_time=LongNow,buff_adder=Adder,from_skill = FromSkill},
									chg_buff(Obj,NBuff,true)
							end;
						 _ -> Obj
					 end;
				 true ->
					 case data_buff:get_data(Type) of  
						 #st_buff_config{} -> 
							 NBuff = Buff#scene_buff{power=Power,mix_lev=1,start=LongNow,lenth=Time,effect_time=LongNow,buff_adder=Adder,from_skill = FromSkill},
							 chg_buff(Obj,NBuff,true);
						 _ -> Obj							
					 end
			 end;
		 _ ->
			 %%不同type的buff比较是否同组buffGroup			 
			 case data_buff:get_data(Type) of   										
				 #st_buff_config{sort = Sort}->	
					 NBuff = #scene_buff{type = Type,sort = Sort,power=Power,mix_lev=1,start=LongNow,lenth=Time,effect_time=LongNow,buff_adder=Adder,from_skill = FromSkill},
					 add_new_buff(Obj,NBuff);
				 _R-> Obj
			 end	 
	 end.

%% 同类同等级buff叠加时，有些buff策划想时间叠加
new_buff_time(Buff, AddTime) ->
	case data_buff:get_data(Buff#scene_buff.type) of
		#st_buff_config{sort= "EXPINCREPER"} -> Buff#scene_buff.lenth + AddTime;
		_ -> AddTime
	end.


%% all control buff break progress bar
add_buff_break_progress_bar(#scene_spirit_ex{id=Uid,sort=?SPIRIT_SORT_USR},BuffType) ->
	case data_buff:get_data(BuffType) of   										
		#st_buff_config{sort=?BUFF_SORT_NO}->
			fun_progress_bar:break_progress_bar(Uid);
		_ -> skip		 
	end;
add_buff_break_progress_bar(_,_BuffType) -> ok.

del_buff_by_die(Obj=#scene_spirit_ex{buffs=Buffs, data = #scene_usr_ex{}}) ->
	TargetSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	Fun = fun(#scene_buff{type=ThisType}) ->
				  case data_buff:get_data(ThisType) of
					  #st_buff_config{dieRetain = 0} -> true;
					  _ -> false
				  end
		  end,
	{DelBuffs,ContinueBuffs} = lists:partition(Fun, Buffs),
	send_del_buff_info(Obj, DelBuffs, TargetSort),

	FunProperty = fun(Buff,GetList) ->
		case is_property_buff(Buff) of
			true -> [Buff#scene_buff.type] ++ (GetList -- [Buff#scene_buff.type]); 
			_ -> GetList
		end
	end,
	TypeList = lists:foldl(FunProperty, [], DelBuffs),
	case TypeList /= [] of
		true -> update_buff_prop(Obj#scene_spirit_ex{buffs = ContinueBuffs},TypeList);
		_ -> Obj#scene_spirit_ex{buffs = ContinueBuffs}
	end;
del_buff_by_die(_Obj)-> _Obj.

del_buff_by_chg_map(Obj=#scene_spirit_ex{buffs=Buffs, data = #scene_usr_ex{}}) ->
	TargetSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	Fun = fun(#scene_buff{type=ThisType}) ->
				  case data_buff:get_data(ThisType) of
					  #st_buff_config{sceneRetain = 0} -> true;
					  _ -> false
				  end
		  end,
	{DelBuffs,ContinueBuffs} = lists:partition(Fun, Buffs),

	send_del_buff_info(Obj, Buffs, TargetSort),

	FunProperty = fun(Buff,GetList) ->
		case is_property_buff(Buff) of
			true -> [Buff#scene_buff.type | GetList]; 
			_ -> GetList
		end
	end,
	TypeList = lists:foldl(FunProperty, [], DelBuffs),
	TypeList /= [] andalso update_buff_prop(Obj#scene_spirit_ex{buffs = ContinueBuffs},TypeList);
del_buff_by_chg_map(_Obj)-> _Obj.

del_buff_by_type(Obj=#scene_spirit_ex{buffs=Buffs},Type) ->
	TargetSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	Fun = fun(#scene_buff{type=ThisType}) -> 
						if
							ThisType == Type ->  true;
							true -> false
						end
				end,
	{DelBuffs,ContinueBuffs} = lists:partition(Fun, Buffs),

	send_del_buff_info(Obj, DelBuffs, TargetSort),

	FunProperty = fun(Buff,GetList) ->
		case is_property_buff(Buff) of
			true -> [Buff#scene_buff.type | GetList]; 
			_ -> GetList
		end
	end,
	TypeList = lists:foldl(FunProperty, [], DelBuffs),
	case TypeList /= [] of
		true -> update_buff_prop(Obj#scene_spirit_ex{buffs = ContinueBuffs},TypeList);
		_ -> Obj#scene_spirit_ex{buffs = ContinueBuffs}
	end;
	
del_buff_by_type(_Obj,_)-> _Obj.

get_buff_by_type(#scene_spirit_ex{buffs=Buffs},Type) ->
	Fun = fun(#scene_buff{type=ThisType}) -> 
						if
							ThisType == Type ->  true;
							true -> false
						end
				end,
	lists:filter(Fun, Buffs).


rand_move(Buffs) -> 
	lists:keyfind(?BUFF_CONTROLL_SORT_KONGJU, #scene_buff.sort, Buffs) /= false. 

can_be_atk(Buffs) -> 
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of   
					  #st_buff_config{sort = ?BUFF_SORT_WUDI}-> true;
					  #st_buff_config{controlSort=?BUFF_CONTROLL_SORT_FANGZHU} -> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> false;
		_ -> true
	end.
can_be_kick(Buffs) -> 
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of 
					  #st_buff_config{sort = ?BUFF_SORT_WUDI}-> true;
					  #st_buff_config{sort = ?BUFF_SORT_BATI}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> false;
		_ -> true
	end.
	
can_start_skill(Buffs) -> 
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of   										
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_KONGJU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CUIMIAN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_FANGZHU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CHENMO}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_YINGDAO}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CHIXU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_XUANYUN}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> true;
		_ -> false
	end.
can_start_normal(Buffs) -> 
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of   										
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_KONGJU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CUIMIAN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_FANGZHU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_YINGDAO}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CHIXU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_XUANYUN}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> true;
		_ -> false
	end.
can_continue_skill(Buffs) -> 
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of   										
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_KONGJU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CUIMIAN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_FANGZHU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CHENMO}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_XUANYUN}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> false;
		_ -> true
	end.
can_controll_move(Buffs) ->
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of   										
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_KONGJU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CUIMIAN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_FANGZHU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_XUANYUN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_DINGSHEN}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> false;
		_ -> true
	end.
can_start_move(Buffs) ->
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of 
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CUIMIAN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_FANGZHU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_XUANYUN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_DINGSHEN}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> false;
		_ -> true
	end.
can_continue_move(Buffs) -> 
	Fun = fun(#scene_buff{type = Type}) ->
				  case  data_buff:get_data(Type)  of 
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_CUIMIAN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_FANGZHU}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_XUANYUN}-> true;
					  #st_buff_config{controlSort = ?BUFF_CONTROLL_SORT_DINGSHEN}-> true;
					  _R-> false
				  end
		  end,
	case lists:filter(Fun, Buffs) of
		[] -> false;
		_ -> true
	end.

check_boss_add_buff(Obj,Type) ->
	if
		Obj#scene_spirit_ex.sort == ?SPIRIT_SORT_MONSTER ->
			case data_monster:get_monster(Obj#scene_spirit_ex.data#scene_monster_ex.type) of
				#st_monster_config{rank_level=0} ->
					case data_buff:get_data(Type) of   
						#st_buff_config{controlSort=?BUFF_CONTROLL_SORT_XUANYUN} -> true;%%眩晕
						#st_buff_config{controlSort=?BUFF_CONTROLL_SORT_CUIMIAN} -> true;%%休眠
						#st_buff_config{controlSort=?BUFF_CONTROLL_SORT_FANGZHU} -> true;%%放逐
						#st_buff_config{controlSort=?BUFF_CONTROLL_SORT_KONGJU} ->  true;%%恐惧
						_ -> true							 
					end;
				_ -> false	
			end;			
		true -> true
	end.

is_exp_buff(#scene_buff{sort = Sort}) -> 
	Sort == ?BUFF_SORT_EXP_INCRE_PER.

is_property_buff(#scene_buff{sort = Sort}) ->
	Sort == ?BUFF_SORT_PROPERTY_NUM orelse Sort == ?BUFF_SORT_PROPERTY_PER.

is_stun(Buffs)->%%眩晕	
	lists:keyfind(?BUFF_CONTROLL_SORT_XUANYUN, #scene_buff.sort, Buffs) /= false. 

is_sleep(Buffs)->%%睡眠	
	lists:keyfind(?BUFF_CONTROLL_SORT_CUIMIAN, #scene_buff.sort, Buffs) /= false. 

is_banish(Buffs)->%%放逐
	lists:keyfind(?BUFF_CONTROLL_SORT_FANGZHU, #scene_buff.sort, Buffs) /= false. 

is_fear(Buffs)->%%恐惧	
	lists:keyfind(?BUFF_CONTROLL_SORT_KONGJU, #scene_buff.sort, Buffs) /= false. 

is_sneered(Buffs) ->%%嘲讽
	lists:keyfind(?BUFF_CONTROLL_SORT_TAUNT, #scene_buff.sort, Buffs) /= false. 


can_do_ai(#scene_spirit_ex{buffs = []}) -> true;
can_do_ai(#scene_spirit_ex{buffs = Buffs}) ->
	case is_stun(Buffs) of
		true -> false;
		_ -> 
			case is_sleep(Buffs) of
				true -> false;
				_ -> 
					case is_banish(Buffs) of
						true -> false;
						_ -> true
					end
			end
	end.

get_sneered_buff(Buffs) ->%%嘲讽
	Fun=fun(#scene_buff{type=Type})-> 
				case data_buff:get_data(Type) of   
					#st_buff_config{controlSort=?BUFF_CONTROLL_SORT_TAUNT} -> true;
					_R -> false							 
				end    
		end,
	lists:filter(Fun,Buffs).

chg_buff(Obj,NBuff,ChgProperty) ->
%%  	?debug("chg_buff,data = ~p",[{Obj,NBuff,ChgProperty}]),

	send_add_buff_info(Obj, NBuff),
	NBuffs = lists:keyreplace(NBuff#scene_buff.type, #scene_buff.type, Obj#scene_spirit_ex.buffs, NBuff),
	case is_property_buff(NBuff) of
		true -> 
			case ChgProperty of
				true -> 
					update_buff_prop(Obj#scene_spirit_ex{buffs = NBuffs},[NBuff#scene_buff.type]);
				_ -> Obj#scene_spirit_ex{buffs = NBuffs}
			end;
		_ -> Obj#scene_spirit_ex{buffs = NBuffs}
	end.
add_new_buff(Obj = #scene_spirit_ex{id = Oid},NBuff0 = #scene_buff{}) ->
	case hook_add_buff(Obj, NBuff0) of
		false -> Obj;
		NBuff ->
			send_add_buff_info(Obj, NBuff),
			NBuffs = [NBuff |  Obj#scene_spirit_ex.buffs],
			NewObj = case is_property_buff(NBuff) of
				true -> 
					update_buff_prop(Obj#scene_spirit_ex{buffs = NBuffs},[NBuff#scene_buff.type]);
				_ -> Obj#scene_spirit_ex{buffs = NBuffs}
			end,
			setup_buff_timer(Oid, NBuff),
			NewObj
	end.

has_control_buff([], _ControlSort) -> false;
has_control_buff([Rec | Rest], ControlSort) -> 
	case data_buff:get_data(Rec#scene_buff.type) of 
		#st_buff_config{controlSort=ControlSort} -> 
			{true, Rec};
		_ -> 
			has_control_buff(Rest, ControlSort)
	end.


hook_add_buff(Obj, AddBuff) ->
	case data_buff:get_data(AddBuff#scene_buff.type) of 
		#st_buff_config{controlSort=?BUFF_CONTROLL_SORT_XUANYUN} -> 
			case has_control_buff(Obj#scene_spirit_ex.buffs, ?BUFF_CONTROLL_SORT_CHANGE_XUANYUN) of
				{true, ChangeBuffRec} ->
					NewTime = max(0, AddBuff#scene_buff.lenth * (1 + ChangeBuffRec#scene_buff.power * ChangeBuffRec#scene_buff.mix_lev / 10000)),
					case NewTime > 0 of
						true -> AddBuff#scene_buff{lenth = NewTime};
						_ -> false
					end;
				_ -> AddBuff
			end;
		#st_buff_config{sort=Sort} when Sort == ?BUFF_SORT_DOT_NUM; Sort == ?BUFF_SORT_DOT_PER ->
			case has_control_buff(Obj#scene_spirit_ex.buffs, ?BUFF_CONTROLL_SORT_CHANGE_TREAT) of
				{true, ChangeBuffRec} ->
					NewPower = max(0, trunc(AddBuff#scene_buff.power * (1 + ChangeBuffRec#scene_buff.power * ChangeBuffRec#scene_buff.mix_lev/ 10000))),
					case NewPower > 0 of
						true -> AddBuff#scene_buff{power = NewPower};
						_ -> false
					end;
				_ -> AddBuff
			end; 
		_ ->  
			AddBuff
	end.

setup_buff_timer(Oid, NBuff = #scene_buff{type = Type, lenth = TimeLen}) ->
	case data_buff:get_data(Type) of
		#st_buff_config{sort = S, per_time = PerTime} when S == ?BUFF_SORT_DOT_NUM orelse S == ?BUFF_SORT_DOT_PER -> 
			% Tick = PerTime div 1000,
			erlang:start_timer(PerTime, self(), {?MODULE, process_dot_buff, {PerTime, Oid, Type}});
			%% 加上去就要生效一次
			% util_misc:msg_handle_cast(self(), ?MODULE, {process_dot_buff, {PerTime, Oid, Type}});
			% scene_big_loop:add_callback(Tick, ?MODULE, process_dot_buff, {Tick, Oid, Type});
		#st_buff_config{sort = S} when S == ?BUFF_SORT_SKILL -> 
			skip; %% 这类buff不在这里删除
		#st_buff_config{} when TimeLen == 0 -> 
			skip; %% 永久buff
		_ -> 
			scene_big_loop:add_callback(NBuff#scene_buff.lenth div 1000, ?MODULE, remove_timeout_buff, {Oid, Type})
	end.

handle({process_dot_buff, Arg}) -> 
	process_dot_buff(Arg);
handle(Msg) -> 
	?ERROR("unhandled msg:~p", [Msg]).


remove_timeout_buff({Oid, Type}) -> 
	case fun_scene_obj:get_obj(Oid) of
		Obj = #scene_spirit_ex{buffs = Buffs} ->
			case lists:keyfind(Type, #scene_buff.type, Buffs) of
				false -> skip;
				#scene_buff{start = StartTime, lenth = ExpireTime} ->
					DiffMS = StartTime + ExpireTime - scene:get_scene_long_now(),
					case DiffMS =< 0 of
						true -> 
							fun_scene_obj:update(del_buff_by_type(Obj, Type));
						_ -> 
							scene_big_loop:add_callback(max(1, DiffMS div 1000), ?MODULE, remove_timeout_buff, {Oid, Type})
					end
			end;
		_ -> skip
	end,
	ok.

add_alive_buff(Obj,NBuff)->
	NBuffs = [NBuff | Obj#scene_spirit_ex.buffs],
	NewObj = case is_property_buff(NBuff) of
		true -> 
			update_buff_prop(Obj#scene_spirit_ex{buffs = NBuffs},[NBuff#scene_buff.type]);
		_ -> Obj#scene_spirit_ex{buffs = NBuffs}
	end,
	setup_buff_timer(Obj#scene_spirit_ex.id, NBuff),
	NewObj.

send_alive_buff(Obj,NBuff)->
	send_add_buff_info(Obj,NBuff).

get_buffs_all_power(Buffs) ->
	Fun = fun(#scene_buff{power = Power,mix_lev = MixLev},AllPower) -> AllPower + Power * MixLev end,
	lists:foldl(Fun,0, Buffs).


calc_buff_attrs(#scene_buff{type = Type, power = Power,mix_lev = MixLev}, PropRec) ->
	#st_buff_config{sort = Sort,data1 = Property} = data_buff:get_data(Type),
	case Sort of
		?BUFF_SORT_PROPERTY_NUM -> 
			calc_buff_attrs_help(Property, Power * MixLev, PropRec);
		?BUFF_SORT_PROPERTY_PER ->
			calc_rate_buff_attrs_help(Property, Power * MixLev / 10000, PropRec)
	end.

calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_ATK_PERCENT -> 
	[{?PROPERTY_ATK, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_ATK) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_DEF_PERCENT -> 
	[{?PROPERTY_DEF, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DEF) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_HPLIMIT, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_HPLIMIT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_MPLIMIT, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_MP_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_REALDMG, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_REALDMG_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_DMGDOWN, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DMGDOWN_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_DEFIGNORE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DEFIGNORE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_DEF, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DEF_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_CRI, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_CRI_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_CRIDOWN, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_CRIDOWN_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_HIT, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_HIT_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_DOD, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DOD_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_CRIDMG, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_CRIDMG_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_TOUGHNESS, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_TOUGHNESS_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_BLOCKRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_BLOCKRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_BREAKDEF, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_BREAKDEF_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_BREAKDEFRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_BREAKDEFRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_BLOCKDMGRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_BLOCKDMGRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_DMGRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DMGRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_DMGDOWNRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_DMGDOWNRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_CONTORLRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_CONTORLRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_CONTORLDEFRATE, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_CONTORLDEFRATE_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_MOVESPD, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_MOVESPD_PERCENT) * (Add/10000))}];
calc_buff_attrs_help(AttrId, Add, PropRec) when AttrId == ?PROPERTY_HP_PERCENT -> 
	[{?PROPERTY_LIMITDMG, util:floor(fun_property:property_get_data(PropRec, ?PROPERTY_LIMITDMG_PERCENT) * (Add/10000))}];

calc_buff_attrs_help(AttrId, Add, _PropRec) -> 
	[{AttrId, util:floor(Add)}].


%% 这种情况下不应该配比例属性的比例
calc_rate_buff_attrs_help(AttrId, AddRate, PropRec) ->
	[{AttrId, util:floor(fun_property:property_get_data(PropRec, AttrId) * AddRate)}].



%% 注意，只有TypeList中的buff为属性类的buff才会调用这个方法
%% TypeList可能为新增列表、改变列表，还可能为删除的buff列表
update_buff_prop(Obj,TypeList) ->
	Buffs = Obj#scene_spirit_ex.buffs,
	Fun = fun(Type, GetObj = #scene_spirit_ex{final_property = PropRec, buff_property = BuffPropList}) ->
		case lists:keyfind(Type, #scene_buff.type, Buffs) of
			false -> %% 删除buff
				{value, {_, OldBuffAttrs}, NewBuffPropList} = lists:keytake(Type, 1, BuffPropList),
				NewFinalProps = fun_property:minus_attrs_from_property3(Obj, PropRec, OldBuffAttrs),
				GetObj#scene_spirit_ex{
					final_property = NewFinalProps,
					buff_property   = NewBuffPropList
				};
			BuffRec = #scene_buff{} -> %% 新增或改变buff
				BuffAttrs = calc_buff_attrs(BuffRec, GetObj#scene_spirit_ex.base_property),
				case lists:keyfind(Type, 1, BuffPropList) of
					false ->
						NewFinalProps = fun_property:add_attrs_to_property(PropRec, BuffAttrs),
						GetObj#scene_spirit_ex{
							final_property = NewFinalProps,
							buff_property = [{Type, BuffAttrs} | BuffPropList]
						};
					{_, OldBuffAttrs} ->
						NewFinalProps0 = fun_property:minus_attrs_from_property3(Obj, PropRec, OldBuffAttrs),
						NewFinalProps1 = fun_property:add_attrs_to_property(NewFinalProps0, BuffAttrs),
						GetObj#scene_spirit_ex{
							final_property = NewFinalProps1,
							buff_property = lists:keystore(Type, 1, BuffPropList, {Type, BuffAttrs})
						}
				end
		end
	end,
	NewObj = lists:foldl(Fun, Obj, TypeList),
	
	OldProp = Obj#scene_spirit_ex.final_property, 
	NewProp = NewObj#scene_spirit_ex.final_property,
	OldHpLimit = OldProp#battle_property.hpLimit,
	NewHpLimit = NewProp#battle_property.hpLimit,
	
	if
		OldHpLimit == NewHpLimit -> NewObj;
		OldHpLimit >= NewHpLimit ->
			Hp = if
					 Obj#scene_spirit_ex.hp >= NewHpLimit -> NewHpLimit;
					 true -> Obj#scene_spirit_ex.hp
				 end,
			NewObj1 = NewObj#scene_spirit_ex{hp = Hp},  
			case NewObj1 of
				#scene_spirit_ex{sort=?SPIRIT_SORT_USR}->
					fun_scene:send_agent_prop(Obj#scene_spirit_ex.id,[{?PROPERTY_HP,Hp}]),
					fun_scene:send_agent_prop(Obj#scene_spirit_ex.id, OldProp, NewProp);
				_->skip
			end,
			NewObj1;
		true ->
			Hp = if
					 Obj#scene_spirit_ex.hp >= OldHpLimit -> NewHpLimit;
					 true -> NewHpLimit - (OldHpLimit - Obj#scene_spirit_ex.hp)
				 end,
			NewObj1 = NewObj#scene_spirit_ex{hp = Hp},
			case NewObj1 of
				#scene_spirit_ex{sort=?SPIRIT_SORT_USR}->
					fun_scene:send_agent_prop(Obj#scene_spirit_ex.id,[{?PROPERTY_HP,Hp}]),
					fun_scene:send_agent_prop(Obj#scene_spirit_ex.id, OldProp, NewProp);
				_->skip
			end,
			NewObj1
	end.
	

process_dot(Obj,#scene_buff{type = Type,power=Power,mix_lev=MixLev,buff_adder=Adder,from_skill={Skill,Lev}}) -> 
	case fun_scene_obj:get_obj(Adder) of
		AdderObj = #scene_spirit_ex{} ->
			case data_buff:get_data(Type) of
				#st_buff_config{sort = Sort, data1 = DotType} ->
					fun_scene_skill:buff_dot(Obj,Sort,Type,DotType,Power * MixLev,AdderObj,Skill,Lev);
				_ -> Obj
			end;
		_ -> Obj%%modify by Andy Lee on 2016-10-17
		%%_ -> skip
	end;
process_dot(Obj,_Buff) -> Obj.


process_dot_buff({Tick, Oid, BuffType}) ->
	case fun_scene_obj:get_obj(Oid) of
		Obj = #scene_spirit_ex{buffs = Buffs} -> 
			case lists:keyfind(BuffType, #scene_buff.type, Buffs) of
				false ->
					skip;
				BuffRec -> 
					#scene_buff{start = Start,lenth = Lenth} = BuffRec,
					case util_time:longunixtime() >= Start + Lenth of
						true -> 
							fun_scene_obj:update(del_buff_by_type(Obj, BuffType));
						false -> 
							Obj2 = process_dot(Obj, BuffRec),
							fun_scene_obj:update(Obj2),
							erlang:start_timer(Tick, self(), {?MODULE, process_dot_buff, {Tick, Oid, BuffType}})
							% scene_big_loop:add_callback(Tick, ?MODULE, process_dot_buff, {Tick, Oid, BuffType})
					end
			end;
		_ -> skip
	end.

process_buff_skill(Obj = #scene_spirit_ex{buffs=Buffs},Now) ->  
	case lists:keyfind(?BUFF_SORT_SKILL, #scene_buff.sort, Buffs) of
		false -> Obj;
		Buff = #scene_buff{type = Type, start = Start, lenth = Lenth} ->
			#st_buff_config{per_time = PerTime} = data_buff:get_data(Type),
			if 
				Now < Start + Lenth andalso Now >= Buff#scene_buff.effect_time ->
					Obj2 = fun_scene_skill:buff_skill(Obj, Buff),
					Buff2 = Buff#scene_buff{effect_time = Buff#scene_buff.effect_time + PerTime},
					NewBuffs = lists:keystore(Type, #scene_buff.type, Obj2#scene_spirit_ex.buffs, Buff2),
					Obj2#scene_spirit_ex{buffs = NewBuffs};
				Now < Buff#scene_buff.effect_time -> 
					Obj;
				true -> %% Now >= Start + Lenth 
					fun_scene_obj:update(del_buff_by_type(Obj, Buff#scene_buff.type))
			end
	end.

count_demage(AtkObj, _BeAtkedObj = #scene_spirit_ex{sort = ?SPIRIT_SORT_USR, data = #scene_usr_ex{battle_entourage = EL}}, Damage) ->
	Fun = fun(Eid, Acc) ->
		case fun_scene_obj:get_obj(Eid, ?SPIRIT_SORT_ENTOURAGE) of
			#scene_spirit_ex{buffs = BuffList} ->
				NewBuffList = make_buff_list(Eid, BuffList, []),
				lists:append(Acc, NewBuffList);
			_ -> Acc
		end
	end,
	List = lists:foldl(Fun, [], EL),
	case List of
		[] -> {Damage, []};
		_ ->
			Fun1 = fun({Power, NewEid}, Acc) ->
				case Acc of
					[] -> [{Power, NewEid}];
					[{Power1, NewEid1}] ->
						case Power >= Power1 of
							true -> [{Power1, NewEid1}];
							_ -> Acc
						end
				end
			end,
			[{NewPower, TEid}] = lists:foldl(Fun1, [], List),
			BearDamage = util:ceil(Damage * (NewPower / 10000)),
			% Time = case data_buff:get_data(6000) of
			% 	#st_buff_config{default_time=DefTime} -> DefTime;
			% 	_ -> 0
			% end,
			% fun_scene_obj:update(add_buff(fun_scene_obj:get_obj(TEid), 6000, BearDamage, Time, BeAtkedOid)),
			{Damage - BearDamage, [{AtkObj#scene_spirit_ex.id,TEid,hit,no,BearDamage,null}]}
	end;
count_demage(_AtkObj, _BeAtkedObj, Demage) -> {Demage, []}.

make_buff_list(_Eid, [], Acc) -> Acc;
make_buff_list(Eid, [#scene_buff{type = Type, power = Power} | Rest], Acc) ->
	case data_buff:get_data(Type) of
		#st_buff_config{sort = ?BUFF_SORT_BEAR_DAMAGE} ->
			case Acc of
				[] -> make_buff_list(Eid, Rest, [{Power, Eid}]);
				[{Power1, Eid1}] ->
					case Power >= Power1 of
						true -> make_buff_list(Eid1, Rest, [{Power1, Eid1}]);
						_ -> make_buff_list(Eid, Rest, [{Power, Eid}])
					end
			end;
		_ -> make_buff_list(Eid, Rest, Acc)
	end.

count_exp(#scene_spirit_ex{buffs=Buffs},Exp) ->
	Fun = fun(Buff) -> is_exp_buff(Buff) end,
	ExpBuffs = lists:filter(Fun, Buffs),
	AllPower = get_buffs_all_power(ExpBuffs),
	{util:ceil(Exp * (AllPower / 10000)),AllPower}.

add_skill_self_buff(Obj,{SkillType,Lev},#st_skillleveldata_config{selfBuff = SelfBuffs}) ->
	% ?debug("SelfBuffs = ~p",[SelfBuffs]),
	Fun = fun({BuffType, PropertyType, PropertyBase, PropertyAdd, BasePower, PowerAdd, BaseLen, LenAdd}, ThisObj) ->
		Property = fun_property:property_get_data(ThisObj#scene_spirit_ex.final_property,PropertyType),
		PropertyPower = util:ceil(Property*((PropertyBase+(PropertyAdd * (Lev-1)))/10000)),
		Power = PropertyPower + BasePower + PowerAdd * (Lev - 1),
		Len = BaseLen + LenAdd*(Lev-1),
		get_inscription_effects_buff(ThisObj#scene_spirit_ex.id, ThisObj, SkillType, BuffType, Power, Len, Lev)
	end,
	lists:foldl(Fun, Obj, SelfBuffs);
add_skill_self_buff(Obj,_,_) -> Obj.

add_skill_target_buff(Adder,Obj,{SkillType,Lev},#st_skillleveldata_config{targetBuff = TargetBuffs},SkillWay,BuffReleaseType) -> 
	case check_take_effect(SkillWay, BuffReleaseType) of 
		true->
			Fun = fun({BuffType, PropertyType, PropertyBase, PropertyAdd, BasePower, PowerAdd, BaseLen, LenAdd}, ThisObj) ->
				Property = fun_property:property_get_data(Adder#scene_spirit_ex.final_property,PropertyType),
				PropertyPower = util:ceil(Property*((PropertyBase+(PropertyAdd * (Lev-1)))/10000)),
				Power = PropertyPower + BasePower + PowerAdd * (Lev - 1),
				Len = BaseLen + LenAdd*(Lev-1),
				get_inscription_effects_buff(Adder, ThisObj, SkillType, BuffType, Power, Len, Lev)
			end,
			lists:foldl(Fun, Obj, TargetBuffs);
		_->Obj
	end;
add_skill_target_buff(_Adder,Obj,_,_,_,_) -> Obj.

get_inscription_effects_buff(Adder,Obj,SkillType,BuffType,Power,Len,Lev)->
	case fun_scene_obj:get_obj(Adder, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{inscription_effects=InscriptionEffects}}->
			case lists:keyfind(SkillType,2,InscriptionEffects) of
				{SkillType,_Id,_OldLev,Sort,NewBuffType,NewBaseatt}->
					if Sort == "BuffPower" andalso NewBuffType == BuffType->
						   add_buff(Obj,BuffType,util:ceil(Power+NewBaseatt),Len,Adder,{SkillType,Lev});
					   Sort == "BuffTime" andalso NewBuffType == BuffType->
						   add_buff(Obj,BuffType,Power,util:ceil(Len+NewBaseatt),Adder,{SkillType,Lev});
					   true->
						   add_buff(Obj,BuffType,Power,Len,Adder,{SkillType,Lev})
					end;
				_->add_buff(Obj,BuffType,Power,Len,Adder,{SkillType,Lev})
			end;
		_->add_buff(Obj,BuffType,Power,Len,Adder,{SkillType,Lev})
	end.	

%%生效buff
check_take_effect(SkillWay,BuffReleaseType)->
	case BuffReleaseType of
		?ALL_SKILL->true;
		?BUFF_SKILL->
			case data_buff:get_data(BuffReleaseType) of
				#st_buff_config{transmitEnable=1}->true;
				_->false
			end;
		_-> SkillWay == BuffReleaseType
	end.
		
del_skill_target_buff(BeAtkedObj)->
	buff_act_remove(BeAtkedObj).


buff_act_remove(BeAtkedObj)->
	ActRemoveList = data_buff:get_act_remove(),
	Buffs = BeAtkedObj#scene_spirit_ex.buffs,
	Fun = fun(#scene_buff{type=ThisType},Acc)->
				  case lists:member(ThisType, ActRemoveList) of
							true->
								del_buff_by_type(BeAtkedObj, ThisType);
					  		_->Acc
				  end
		  end,
	lists:foldl(Fun, BeAtkedObj, Buffs).

remove_all_buff() ->
	case fun_scene_obj:get_el() of
		[] -> skip;
		List ->
			Fun = fun(Obj = #scene_spirit_ex{buffs = Buffs}) ->
				[fun_scene_obj:update(del_buff_by_type(Obj, Type)) || #scene_buff{type = Type} <- Buffs]
			end,
			lists:foreach(Fun, List)
	end.

get_buff_sort(Type) ->
	#st_buff_config{bdemage = BuffSort} = data_buff:get_data(Type),
	BuffSort.

send_add_buff_info(Obj, NBuff) ->
	TargetSort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	AddSort = fun_scene_obj:get_spirit_client_type(NBuff#scene_buff.buff_adder),
	BuffSort = get_buff_sort(NBuff#scene_buff.type),
	Pt = #pt_scene_chg_buff{
		oid            = Obj#scene_spirit_ex.id,
		buff_type      = NBuff#scene_buff.type,
		buff_sort      = BuffSort,
		buff_power     = NBuff#scene_buff.power,
		buff_mix_lev   = NBuff#scene_buff.mix_lev,
		buff_len       = NBuff#scene_buff.lenth,
		obj_sort       = TargetSort,
		adder_oid      = NBuff#scene_buff.buff_adder,
		adder_obj_sort = AddSort
	},
	fun_scene_obj:send_all_usr(proto:pack(Pt)).

send_del_buff_info(Obj, BuffList, TargetSort) ->
	FunSend = fun(#scene_buff{type = Type}) ->
		Pt = #pt_scene_remove_buff{
			oid       = Obj#scene_spirit_ex.id,
			buff_type = Type,
			obj_sort  = TargetSort
		},
		fun_scene_obj:send_all_usr(proto:pack(Pt))
	end,
	lists:foreach(FunSend, BuffList).