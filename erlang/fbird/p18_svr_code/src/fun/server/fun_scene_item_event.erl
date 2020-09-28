%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name :  fun_scene_item_event
%% author : Andy lee
%% date :  2015-10-12
%% Company : fbird.Co.Ltd
%% Desc : 处理移动,技能施放等触发事件
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_scene_item_event).
-include("common.hrl").
-export([fun_move_event_handler/3,fun_skill_event_handler/0,send_msg/5,click_scene_item/2,action_scene_item_del/1,on_time/1]).

%%距离场景物品范围时触发
-define(DIS_SCENE_ITEM_R,2).

-define(ITEM_ACTION_RESULT_DEAD,"DEAD").
-define(ITEM_ACTION_RESULT_REMAIN,"REMAIN").
-define(SCENE_ITEM_ACTION_REWARDS_TIME,60).

check_scene() ->
	Scene=get(scene),
	case data_scene_config:get_scene(Scene) of
		#st_scene_config{sort = ?SCENE_SORT_CITY}-> false;
		#st_scene_config{sort = ?SCENE_SORT_PEACE}-> false;
		#st_scene_config{sort = ?SCENE_SORT_CAMP}-> false;
		#st_scene_config{sort = ?SCENE_SORT_SCUFFLE}-> false;
		_ -> true
	end.


%%场景物品定时响应
on_time(Item=#scene_spirit_ex{data=#scene_item_ex{trigger_list=List}}) ->
	Fun=fun({Uid,_}) ->
			case fun_scene_obj:get_obj(Uid) of
				#scene_spirit_ex{pos=Pos,dir=Dir} ->				
					case distance(Pos,Dir,Item) of
						true ->	true;		
						_ -> false
					end;
				_ -> false
			end		
		end,
	lists:filter(Fun, List).


fun_move_event_handler(Uid,Sort,ToPos) when Sort == ?SPIRIT_SORT_USR orelse Sort == ?SPIRIT_SORT_MONSTER -> 
	case check_scene() of
		true ->
			L=fun_scene_map:get_il_bojs_by_id(Uid),	
			del_pos(Uid),
			F=fun(Oid) ->
				case fun_scene_obj:get_obj(Oid,?SPIRIT_SORT_ITEM) of
					Item=#scene_spirit_ex{} ->
						handle(Uid,ToPos,Item);
					_ -> skip	
				end		  
			end,
			lists:foreach(F, L),
			get_pos(Uid);			
		_ -> no
	end;
fun_move_event_handler(_Uid,_Sort,ToPos) -> ToPos.

fun_skill_event_handler() -> ok.

%%目标判断
check_target(?SPIRIT_SORT_MONSTER,"monster") -> true;
check_target(?SPIRIT_SORT_USR,"player") -> true;
check_target(_,"all") -> true;
check_target(_,_) -> false.

%%处理触发行为
handle(Uid,{Tx,Ty,Tz},Item=#scene_spirit_ex{id=ID,data=#scene_item_ex{type=Type}}) ->
%% 	?debug("handle,{ID,Type}=~p~n",[{ID,Type}]),
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{sort = Sort} ->
			case data_scene_item:get_data(Type) of
				#st_scene_item_config{touchType=?CLICK_SCENE_ITEM_COLLIDE,actionTarget = ActionTarget} -> %%只有此类型的场景物品是在此触发	
%% 					?debug("handle,{Sort,ActionTarget}=~p~n",[{Sort,ActionTarget}]),
					case check_target(Sort,ActionTarget) of
						true -> 
							case data_scene_item_dis:get_data(ID-?OBJ_OFF) of
								#st_scene_item_dis_config{actionType=?SCENE_ITEM_ACTION_OTHER} ->
									action_handler(Uid,{Tx,Ty,Tz},other,Item);
								#st_scene_item_dis_config{actionType=?SCENE_ITEM_ACTION_TRIGGER} ->							
									action_handler(Uid,{Tx,Ty,Tz},trigger,Item);
%% 								#st_scene_item_dis_config{actionType=?SCENE_ITEM_ACTION_BUFF} ->	
%% 									?debug("---------get_alive_buff---------"),
%% 									action_handler(Uid,{Tx,Ty,Tz},buff,Item);	
								#st_scene_item_dis_config{actionType=?SCENE_ITEM_ACTION_BLOCK} -> skip;
								_R-> action_handler(Uid,{Tx,Ty,Tz},trigger,Item)	  
							end;
						_ ->skip
					end;
				_ ->skip
			end;
		_ ->skip
	end.

%%处理触发行为
action_handler(Uid,{Tx,Ty,Tz},trigger,Item=#scene_spirit_ex{id=ID,data=#scene_item_ex{action=Module,trigger_list=Trigg_List}}) ->	
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{sort=Sort,dir=Dir} ->
%% 			?debug("action_handler,{{Tx,Ty,Tz},Dir,Item}=~p~n",[{{Tx,Ty,Tz},Dir,Item}]),
			case distance({Tx,Ty,Tz},Dir,Item) of
				true ->
%% 					?debug("action_handler,Trigg_List=~p~n",[Trigg_List]),
					case lists:keyfind(Uid, 1, Trigg_List) of
						{Uid,_TriggLock} -> skip;
						_ ->
							case data_scene_item_dis:get_data(Item#scene_spirit_ex.id-?OBJ_OFF) of
								#st_scene_item_dis_config{actionResult=ActionResult,connectItemId=ConItemID,connectType=ConType,jumpTime=TimeLen} ->															
									action({Uid,Sort,{Module,ID-?OBJ_OFF,Item#scene_spirit_ex.pos,ActionResult},ConItemID,ConType,TimeLen}),
									
									NTL=lists:append(Trigg_List, [{Uid,1}]),									
									fun_scene_obj:update(fun_scene_obj:put_item_spc_data(Item,trigger_list,NTL));
								_ -> 
									action({Uid,Sort,{no,ID-?OBJ_OFF,Item#scene_spirit_ex.pos,0},0,?SCENE_ITEM_NONE,0}),
									
									NTL=lists:append(Trigg_List, [{Uid,1}]),									
									fun_scene_obj:update(fun_scene_obj:put_item_spc_data(Item,trigger_list,NTL))	  
							end													
					end;						 
				false -> skip%%放到场景物品自己的定时器处清理锁定数据
			end;
		_ -> skip
	end;

%%处理触发行为
action_handler(Uid,{Tx,_Ty,Tz},other,Item=#scene_spirit_ex{id=ID,pos={X,_Y,Z},data=#scene_item_ex{action=Module,trigger_list=Trigg_List}}) ->
	case fun_scene_obj:get_obj(Uid) of
		#scene_spirit_ex{sort=Sort} ->	
			Dis=tool_vect:lenght(tool_vect:to_map_point({Tx-X,0,Tz-Z})),
			if
				Dis < ?DIS_SCENE_ITEM_R ->
					case lists:keyfind(Uid, 1, Trigg_List) of
						{Uid,_TriggLock} -> skip;
						_ ->
							case data_scene_item_dis:get_data(ID-?OBJ_OFF) of
								#st_scene_item_dis_config{actionResult=ActionResult,connectItemId=ConItemID,connectType=ConType,jumpTime=TimeLen} ->																
									action({Uid,Sort,{Module,ID-?OBJ_OFF,Item#scene_spirit_ex.pos,ActionResult},ConItemID,ConType,TimeLen}),
									
									NTL=lists:append(Trigg_List, [{Uid,1}]),
									fun_scene_obj:update(fun_scene_obj:put_item_spc_data(Item,trigger_list,NTL));
								_ -> skip	  
							end													
					end;
				true -> skip
			end;
		_ -> skip
	end;

action_handler(_Uid,_Pos,_,_Item) -> skip.

action({Uid,Sort,{Module,ItemID,Pos,ActionResult},ConItemID,ConType,TimeLen}) ->
	?debug("action,{Module,ID}=~p~n",[{Module,ItemID,ActionResult,ConType}]),
	
	%%添加场景触发脚本 satan 2016.1.30
	case Sort of
		?SPIRIT_SORT_USR -> fun_scene:run_scene_script(onActionSceneItem,[ItemID,Pos,Uid,Sort]);
		_ -> fun_scene:run_scene_script(onActionSceneItem,[ItemID,Pos,Uid - ?OBJ_OFF,Sort])
	end,	
	
	case Module of
		no -> skip;
		_ ->
			try
				Module:onAction(ItemID,Pos)	
			catch E:R -> ?log_error("scene item action error,E=~p,R=~p,stack=~p",[E,R,erlang:get_stacktrace()]) 
			end					
	end,
	action_con(Uid,Sort,{ItemID,ActionResult},ConItemID,ConType,TimeLen);
action(_R) -> ok.

action_con(Uid,Sort,{ItemType,ActionResult},ConItemID,?SCENE_ITEM_TRANS,_TimeLen) ->
	case fun_scene_obj:get_obj(Uid) of
		Usr=#scene_spirit_ex{} ->
			if
				ActionResult == ?ITEM_ACTION_RESULT_DEAD -> fun_interface:s_del_item(ItemType);
				true -> skip
			end,
			case fun_interface:s_get_scene_item(ConItemID) of
				#scene_spirit_ex{pos={X,Y,Z}} ->
					put_pos(Uid,{X,Y,Z}),
					fun_scene_obj:update(Usr#scene_spirit_ex{pos={X,Y,Z}}),
					%%瞬间移动,移动时间为0
					send_msg(Uid,Sort,ItemType,0,{X,Y,Z});
				_ -> skip
			end;
		_ -> skip	
	end;		
action_con(Uid,Sort,{ItemType,ActionResult},ConItemID,?SCENE_ITEM_JUMP,TimeLen) ->	
	case fun_scene_obj:get_obj(Uid) of
		Usr=#scene_spirit_ex{} ->
			if
				ActionResult == ?ITEM_ACTION_RESULT_DEAD -> fun_interface:s_del_item(ItemType);
				true -> skip
			end,			
			case fun_interface:s_get_scene_item(ConItemID) of
				#scene_spirit_ex{pos={X,Y,Z}} ->
					put_pos(Uid,{X,Y,Z}),
					fun_scene_obj:update(Usr#scene_spirit_ex{pos={X,Y,Z}}),
					send_msg(Uid,Sort,ItemType,TimeLen,{X,Y,Z});
				_ -> skip
			end;
		_ -> skip	
	end;		
action_con(Uid,Sort,{ItemType,ActionResult},ConItemID,?SCENE_ITEM_OPERATE,_TimeLen) ->
	if
		ActionResult == ?ITEM_ACTION_RESULT_DEAD -> fun_interface:s_del_item(ItemType);
		true -> skip
	end,	
	case fun_interface:s_get_scene_item(ConItemID) of
		#scene_spirit_ex{pos=Pos,data=#scene_item_ex{action=NModule}} ->					
			case data_scene_item_dis:get_data(ConItemID) of
				#st_scene_item_dis_config{connectItemId=NConItemID,connectType=NConType,jumpTime=NTimeLen} ->
					action({Uid,Sort,{NModule,ConItemID,Pos},NConItemID,NConType,NTimeLen});
				_ -> skip 
			end;					
		_ -> skip
	end;
action_con(_Uid,_Sort,{ItemType,ActionResult},ConItemID,?SCENE_ITEM_DEL,_TimeLen) ->
	if
		ActionResult == ?ITEM_ACTION_RESULT_DEAD -> fun_interface:s_del_item(ItemType);
		true -> skip
	end,					
	case data_scene_item_dis:get_data(ConItemID) of
		#st_scene_item_dis_config{} ->
			fun_interface:s_del_item(ConItemID);
		_ -> skip 
	end;

action_con(_Uid,_Sort,{ItemType,ActionResult},_ConItemID,?SCENE_ITEM_ACTION_BUFF,_TimeLen) ->
	if
		ActionResult == ?ITEM_ACTION_RESULT_DEAD -> fun_interface:s_del_item(ItemType);
		true -> skip
	end;

action_con(_Uid,_Sort,{_ItemType,_ActionResult},_ConItemID,_ConType,_TimeLen) -> ok.%%NONE只响应脚本

action_scene_item_del(ID) ->%%场景物品消亡	
	fun_interface:s_del_item(ID).

distance({Mx,_My,Mz},_Dir,Item=#scene_spirit_ex{dir=ItemDir,data=#scene_item_ex{type=Type}}) ->
	Type=Item#scene_spirit_ex.data#scene_item_ex.type,
	case data_scene_item:get_data(Type) of
		#st_scene_item_config{modelXY= {DX,_,DZ}} ->			
			{X,_Y,Z}=Item#scene_spirit_ex.pos,			
			VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(ItemDir)), %%方向向量
			VL = tool_vect:get_vect_by_dir(tool_vect:angle2radian(ItemDir + 90)),%%方向垂直向量
			W = tool_vect:dot_line_dis(VD, tool_vect:dec(tool_vect:to_map_point({Mx,0,Mz}),tool_vect:to_map_point({X,0,Z}))),%%方向垂直的距离
			D = tool_vect:dot_line_dis(VL, tool_vect:dec(tool_vect:to_map_point({Mx,0,Mz}),tool_vect:to_map_point({X,0,Z}))),%%方向的距离
%% 			W = tool_vect:dot_line_dis(VD, tool_vect:dec(tool_vect:to_map_point({X,0,Z}),tool_vect:to_map_point({Mx,0,Mz}))),%%方向垂直的距离
%% 			D = tool_vect:dot_line_dis(VL, tool_vect:dec(tool_vect:to_map_point({X,0,Z}),tool_vect:to_map_point({Mx,0,Mz}))),%%方向的距离										  
%% 			?debug("{DX,DZ}=~p,{W,D}=~p~n",[{DX,DZ},{W,D}]),
			if										 
				W < DX/2 andalso D < DZ/2 -> true;%%in		 
				true -> false%%out
			end;				
		_ -> false
	end.

send_msg(Uid,_Sort,ID,Time,{X,Y,Z}) ->
	NSort=fun_scene_obj:get_spirit_client_type(Uid),
	Pt = #pt_scene_transform{
							  oid = Uid,
							  obj_sort = NSort,
							  type = ID,
							  time = Time,
							  x = X,
							  y = Y,
							  z = Z
							 },	
%% 	Pt1=pt_scene_transform_c013:set_oid(Pt, Uid),	
%% 	Pt2=pt_scene_transform_c013:set_obj_sort(Pt1, NSort),
%% 	Pt3=pt_scene_transform_c013:set_type(Pt2, ID),
%% 	Pt4=pt_scene_transform_c013:set_time(Pt3, Time),
%% 	Pt5=pt_scene_transform_c013:set_x(Pt4, X),
%% 	Pt6=pt_scene_transform_c013:set_y(Pt5, Y),
%% 	Pt7=pt_scene_transform_c013:set_z(Pt6, Z),
	Data=proto:pack(Pt),
	fun_scene_obj:send_all_usr(Data).


%%响应点击场景物品,点击可能是攻击
click_scene_item(Uid,TargetID) ->
	case fun_scene_obj:get_obj(TargetID, ?SPIRIT_SORT_ITEM) of
		Item=#scene_spirit_ex{data = #scene_item_ex{type=Type}} ->
			case data_scene_item:get_data(Type) of
				#st_scene_item_config{touchType=?CLICK_SCENE_ITEM_TOUCH} ->		
					click_action_handler(Uid,Item);									
				_ -> skip					
			end;
		_ -> skip
	end.

%%处理触发行为
click_action_handler(Uid,#scene_spirit_ex{id=ID,data=#scene_item_ex{action=Module}}) ->
	case fun_scene_obj:get_obj(Uid,?SPIRIT_SORT_USR) of
		#scene_spirit_ex{sort=Sort,pos=Pos} ->
			case data_scene_item_dis:get_data(ID-?OBJ_OFF) of
				#st_scene_item_dis_config{actionResult=ActionResult,connectItemId=ConItemID,connectType=ConType,jumpTime=TimeLen} ->	
					action({Uid,Sort,{Module,ID-?OBJ_OFF,Pos,ActionResult},ConItemID,ConType,TimeLen});
				_ -> skip	  
			end;
		_ -> skip
	end.

get_pos(Uid) ->
	L=get_pos_list(),
	case lists:keyfind(Uid, 1, L) of
		{Uid,Pos} -> Pos;
		_ -> no
	end.
put_pos(Uid,Pos) ->
	case get_pos(Uid) of
		no ->
			L=get_pos_list(),
			NL = lists:append(L,[{Uid,Pos}]),
			put_pos_list(NL);
		_ -> 
			L=get_pos_list(),
			NL = lists:keyreplace(Uid, 1, L, {Uid,Pos}),
			put_pos_list(NL)			
	end.

del_pos(Uid) ->
	case get(scene_item_trans_pos) of
		undefined -> skip;		
		List when is_list(List) ->
			NL = lists:keydelete(Uid, 1, List),					
			put_pos_list(NL);
		_ -> skip
	end.

get_pos_list() ->
	case get(scene_item_trans_pos) of
		undefined -> [];		
		List when is_list(List) -> List;
		_ -> []
	end.

put_pos_list(L) ->
	put(scene_item_trans_pos,L).