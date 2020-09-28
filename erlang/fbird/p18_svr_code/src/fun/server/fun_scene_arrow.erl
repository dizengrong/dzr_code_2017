-module(fun_scene_arrow).
-include("common.hrl").

-export([init/0,add_arrows/10,onTimer/1,delay_add_arrow/8,add_arrow/1,delay_add_trap/8,add_trap/1]).
-export([delete_trap/1]).

-record(arrow_data,{id=1,config=0,skill_type=0,skill_lev=0,skill_performance=0,owner= 0,point=0,dir=0,effecteds=[],effected_time=0,start_time=0,last_effect_time=0}).
-record(arrow_effected,{id=1,time=0}).
-record(trap_data,{id=1,config=0,skill_type=0,skill_lev=0,skill_performance=0,owner= 0,point=0,dir=0,effected_time=0,start_time=0,last_effect_time=0}).

-define(EFFECT_TIME,200).

init() -> 
	put(arrows,[]),
	put(traps,[]).

get_new_arrow_id() ->
	case get(arrow_id) of
		undefined -> put(arrow_id,2),1;
		ID -> 
			NID = if
					  ID >= 1000000000 -> 1;
					  true -> ID + 1
				  end,
			put(arrow_id,NID),ID
	end.

delay_add_arrow(SkillType, SkillLev, SkillPerformance, Owner, Type, Point, Dir, Now)->
	if  
		SkillPerformance#st_skillperformance_config.delayTimes=<0->add_arrow({SkillType, SkillLev, SkillPerformance, Owner, Type,Point,Dir,Now});
		true->erlang:start_timer(SkillPerformance#st_skillperformance_config.delayTimes, self(), {?MODULE, add_arrow, {SkillType, SkillLev, SkillPerformance, Owner, Type,Point,Dir,Now}})
	end.
	
add_arrow({SkillType,SkillLev,SkillPerformance,Owner,Type,Point1,Dir,Now})->
	case data_arrow:get_data(Type) of
		{} -> skip;
		Config -> 
			case get(arrows) of
				undefined -> skip;
				Olds ->
					ID = get_new_arrow_id(),
					Point =  tool_vect:to_map_point(Point1),
					
					Arrow = #arrow_data{id=ID,config=Config,
										skill_type=SkillType,skill_lev=SkillLev,
										skill_performance=SkillPerformance,owner= Owner,point=Point,
										dir=Dir,effecteds=[],start_time=Now,last_effect_time=Now},
					
					OwnerSort = util_scene:server_obj_type_2_client_type(Owner#scene_spirit_ex.sort),
					
					#map_point{x = X,y = Y,z = Z} = Point,
					ArrowData = #pt_public_scene_arrow{
																  owner_id = Owner#scene_spirit_ex.id,
																  owner_sort = OwnerSort,
																  aid = ID,
																  type = Type,
																  dir = Dir,
																  x = X,
																  y = Y,
																  z = Z
																 },
					Pt = #pt_scene_add_arrow{list = [ArrowData]},
%% 					?debug("Pt2 = ~p",[Pt2]),
					fun_scene_obj:send_all_usr(proto:pack(Pt)),
					
					put(arrows,lists:append(Olds, [Arrow]))
			end
	end.
delay_add_trap(SkillType,SkillLev,SkillPerformance,Owner,Type,Point,Dir,Now)->
	
	if  
		SkillPerformance#st_skillperformance_config.delayTimes=<0->add_trap({SkillType, SkillLev, SkillPerformance, Owner, Type,Point,Dir,Now});
		true-> erlang:start_timer(SkillPerformance#st_skillperformance_config.delayTimes, self(), {?MODULE,add_trap, {SkillType, SkillLev, SkillPerformance, Owner, Type,Point,Dir,Now}})
	end.

add_trap({SkillType,SkillLev,SkillPerformance,Owner,Type,Point1,Dir,_Now})->
    Now= util:longunixtime(),
	case data_trap:get_data(Type) of
		{} -> skip;
		Config -> 
			case get(traps) of
				undefined -> skip;
				Olds ->
					ID = get_new_arrow_id(),
					
					   Point=if
								 SkillPerformance#st_skillperformance_config.areaCenterRange == 0 ->Point1;
								 true -> fun_scene_skill:get_dis_center_cast_point(Point1,Dir,SkillPerformance#st_skillperformance_config.areaCenterRange)
							 end,
					Trap = #trap_data{id=ID,config=Config,
									  skill_type=SkillType,skill_lev=SkillLev,
									  skill_performance=SkillPerformance,owner= Owner,point=Point,
									  effected_time=0,last_effect_time= Now + Config#st_trap_config.trap_effect_time,
									  dir=Dir,start_time=Now},
			
					#map_point{x = X,y = Y,z = Z} = tool_vect:to_map_point(Point),
					
					OwnerSort = util_scene:server_obj_type_2_client_type(Owner#scene_spirit_ex.sort),
					
					ArrowData = #pt_public_scene_trap{
																  owner_id = Owner#scene_spirit_ex.id,
																  owner_sort = OwnerSort,
																  did = ID,
																  type = Type,
																  dir = Dir,
																  x = X,
																  y = Y,
																  z = Z
																 },
					Pt = #pt_scene_add_trap{list = [ArrowData]},
					fun_scene_obj:send_all_usr(proto:pack(Pt)),
					
					put(traps,lists:append(Olds, [Trap]))
			end
	end.

delete_trap(TrapId) ->
	List = get(traps),
	case lists:keyfind(TrapId, #trap_data.id, List) of
		false -> 
			?log_warning("TrapId ~p not exist but delete_trap called", [TrapId]);
		_Rec ->
			send_trap_delete_pt(TrapId)
	end.

add_arrows(SkillType,SkillLev,SkillPerformance,Owner,Type,Point1,DirFrom,DirTo,DirOff,Now)->
	case data_arrow:get_data(Type) of
		{} -> skip;
		Config -> 
			case get(arrows) of
				undefined -> skip;
				Olds ->
					case get_dirs(DirFrom,DirTo,DirOff,[]) of
						[] -> skip;
						Dirs ->
							Point =  tool_vect:to_map_point(Point1),
							Fun = fun(Dir) ->
										  ID = get_new_arrow_id(),
										  #arrow_data{id=ID,config=Config,
													  skill_type=SkillType,skill_lev=SkillLev,
													  skill_performance=SkillPerformance,owner= Owner,point=Point,
													  dir=Dir,effecteds=[],start_time=Now,last_effect_time=Now}
								  end,
							Arrows = lists:map(Fun, Dirs),
							
							FunArrow = fun(#arrow_data{id=ArrowID,point=ArrowPoint,dir=ArrowDir}) ->
											   #map_point{x = X,y = Y,z = Z} = ArrowPoint,
											   
											   OwnerSort = util_scene:server_obj_type_2_client_type(Owner#scene_spirit_ex.sort),
											   #pt_public_scene_arrow{
																  owner_id = Owner#scene_spirit_ex.id,
																  owner_sort = OwnerSort,
																  aid = ArrowID,
																  type = Type,
																  dir = ArrowDir,
																  x = X,
																  y = Y,
																  z = Z
																 }
									   end,
							ArrowDatas = lists:map(FunArrow, Arrows),

							Pt = #pt_scene_add_arrow{list = ArrowDatas},
							fun_scene_obj:send_all_usr(proto:pack(Pt)),
							
							put(arrows,lists:append(Olds, Arrows))
					end
			end
	end.


get_dirs(DirFrom,DirTo,DirOff,Gets) when DirFrom + DirOff > DirTo  -> lists:append(Gets,[DirFrom]);
get_dirs(DirFrom,DirTo,DirOff,Gets)  -> get_dirs(DirFrom + DirOff,DirTo,DirOff,lists:append(Gets,[DirFrom])).

onTimer(Now) ->
	case get(arrows) of
		undefined -> [];
		List -> {NList1} = update_arrows(List,Now,[]),
				Fun = fun(Data) ->
							  case Data of
								  null -> false;
								  _ -> true
							  end end,
				NList = lists:filter(Fun, NList1),
				put(arrows,NList)
	end,
	case get(traps) of
		undefined -> [];
		List2 -> {NList12} = update_traps(List2,Now,[]),
				Fun2 = fun(Data2) ->
							  case Data2 of
								  null -> false;
								  _ -> true
							  end end,
				NList2 = lists:filter(Fun2, NList12),
				put(traps,NList2)
	end.

update_arrows([],_Now,Get) -> {Get};
update_arrows([Data | Next],Now,Get) -> 
	case update_arrow(Data,Now) of
		NData = #arrow_data{} -> 
			update_arrows(Next,Now,lists:append(Get,[NData]));
		_ ->
			update_arrows(Next,Now,Get)
	end.

update_traps([],_Now,Get) -> {Get};
update_traps([Data | Next],Now,Get) -> 
	case update_trap(Data,Now) of
		NData = #trap_data{} -> 
			update_traps(Next,Now,lists:append(Get,[NData]));
		_ ->
			update_traps(Next,Now,Get)
	end.

update_arrow(Data = #arrow_data{last_effect_time=LastEffectTime},Now) when Now >= LastEffectTime ->
	effect_arrow(Data);
update_arrow(Data,_Now) -> Data.

update_trap(#trap_data{id =ID,start_time=StartTime,config = #st_trap_config{trap_all_time = All_time}},Now) when Now >= (StartTime + All_time) ->
	send_trap_delete_pt(ID),
	des;
update_trap(Data = #trap_data{last_effect_time=LastEffectTime},Now) when Now >= LastEffectTime ->
	effect_trap(Data);
update_trap(Data,_Now) ->
	Data.	

send_trap_delete_pt(Id) ->
	Pt = #pt_scene_delete_trap{tid = Id},
	fun_scene_obj:send_all_usr(proto:pack(Pt)).																	  
	
effect_arrow(Data = #arrow_data{id=ID,start_time=StartTime,last_effect_time=LastEffectTime,owner = Owner,
								effecteds=Effecteds,effected_time=EffectedTime,point = Point,dir=Dir,
								skill_performance=#st_skillperformance_config{targetType = TargetType},
								skill_type=SkillType,skill_lev=SkillLev,
								config = #st_arrow_config{id = ArrowType,speed = Speed,add_speed=Add_speed,arrowWidth = Width,
														  arrowUpHigh= UpHigh,arrowDownHigh= DownHigh,
														  max_effect=MaxEffect,one_max_effect=OneMaxEffect,max_dis=MaxDis}})->
%% 	?debug("effect_arrow data = ~p",[{Data}]),
	T = (LastEffectTime - StartTime) / 1000,
	OldDis = (T * Speed) + 0.5 * Add_speed * T * T,
	StartPoint = tool_vect:add(Point, tool_vect:ride(tool_vect:normal(tool_vect:get_vect_by_dir(tool_vect:angle2radian(Dir))), OldDis)),
	BDes = if
			   OldDis > MaxDis -> true;
			   true -> false
		   end,
	case BDes of
		true -> 
			Pt = #pt_scene_delete_arrow{aid = ID},
			fun_scene_obj:send_all_usr(proto:pack(Pt)),
			des; %%out of des
		_ ->
			TEnd = T + ?EFFECT_TIME / 1000,
			
			NowDis = (TEnd * Speed) + 0.5 * Add_speed * TEnd * TEnd,
			
			Length = if
					  NowDis > MaxDis -> MaxDis - OldDis;
					  true -> NowDis - OldDis
				  end,
			
%% 			?debug("effect_arrow data = ~p",[{T,StartPoint,TEnd,OldDis,NowDis,Length}]),
			
			Targets = fun_scene_skill:collect_arrow_run_targets(Owner#scene_spirit_ex.id,tool_vect:to_point(StartPoint), Dir, Width,Length,TargetType,UpHigh,DownHigh),
			
%% 			?debug("effect_arrow Targets = ~p",[Targets]),
			
			FunTarget = fun(#scene_spirit_ex{id=Id}) ->
								case lists:keyfind(Id,#arrow_effected.id, Effecteds) of
									#arrow_effected{time = EffectedTime} when EffectedTime < OneMaxEffect -> true;
									false ->   true;
									_ -> false
								end
						end,
			DoTargets1 = lists:filter(FunTarget, Targets),
			DoLen  = erlang:length(DoTargets1),
			{BDes2,DoTargets} = if
									EffectedTime + DoLen >= MaxEffect -> {true,lists:sublist(DoTargets1, MaxEffect - EffectedTime)};
									true -> {false ,DoTargets1}
								end,			
			
			GetOwner = case fun_scene_obj:get_obj(Owner#scene_spirit_ex.id) of
						   no -> Owner;
						   R -> R
					   end,
			FunEffect = fun(Obj = #scene_spirit_ex{}) -> fun_scene_skill:arrow_skill(GetOwner,Obj, TargetType,{SkillType,SkillLev},ArrowType) end,
			lists:foreach(FunEffect, DoTargets),
			
			case BDes2 of
				true -> 
					Pt = #pt_scene_delete_arrow{aid = ID},
					fun_scene_obj:send_all_usr(proto:pack(Pt)),
					des;
				_ -> 
					FunAddTarget = fun(#scene_spirit_ex{id = ID1},AddEffecteds) ->
										   case lists:keyfind(ID1,#arrow_effected.id, AddEffecteds) of
											   AddData = #arrow_effected{time = AddEffectedTime}  -> lists:keyreplace(ID1,#arrow_effected.id, AddEffecteds, 
																													  AddData#arrow_effected{time = AddEffectedTime + 1});
											   _ -> lists:append(AddEffecteds,[#arrow_effected{id = ID1,time = 1}])
										   end
								   end,
					
					NewEffecteds = lists:foldl(FunAddTarget, Effecteds, DoTargets),
					
					Data#arrow_data{last_effect_time = LastEffectTime + ?EFFECT_TIME,effected_time = EffectedTime + DoLen,effecteds = NewEffecteds}
			end
	end;
effect_arrow(_) -> des.

effect_trap(Data = #trap_data{owner = Owner,point = Point,dir=Dir,effected_time = EffectedTime,last_effect_time=LastEffectTime,
							  skill_type=SkillType,skill_lev=SkillLev,
							  skill_performance=#st_skillperformance_config{targetType = TargetType,areaCenterRange=ACR},
							  config = #st_trap_config{id = TrapType}}) ->
	Config = data_trap:get_data(TrapType),
	if
		EffectedTime >= Config#st_trap_config.max_effect -> skip;
		true ->
			%% 			?debug("effect_trap data = ~p",[{Data}]),
			GetOwner = case fun_scene_obj:get_obj(Owner#scene_spirit_ex.id) of
						   no -> Owner;
						   R -> R
					   end,
			fun_scene_skill:trap_skill(GetOwner,tool_vect:to_point(Point),Dir,ACR,TargetType,{SkillType,SkillLev},TrapType)
	end,
	Data#trap_data{last_effect_time = LastEffectTime + Config#st_trap_config.per_time,effected_time = EffectedTime + 1};
effect_trap(_) -> [].