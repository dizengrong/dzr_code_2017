-module(fun_scene_map).
-include("common.hrl").

-export([init/0,check_point/1,check_dir/2,check_dir/3,add_scene_item_wall/4,del_scene_item_wall/1]).
-export([process_cell/1,leave_cell/2,process_recon/1,send_to_all_cell_usr/3,send_to_all_cell_real_usr/3,get_all_bojs_by_cell/1,get_ml_bojs_by_cell/1]).
-export([get_ml_bojs_by_id/1,get_usr_and_mon_num_by_pos/2,get_area_mon_num/2,get_il_bojs_by_id/1,get_all_bojs_by_id/1,get_all_objs_by_obj/1,get_all_cell_usr/2]).
-export([get_cell_by_point/1,get_camp_cell_usr/2,get_usr_bojs_by_pos/1,get_camp_usr_bojs_by_pos/2]).
-export([has_usr_obj_near_by/1]).


init() ->
	SceneType = get(scene),
	case data_scene_config:get_scene(SceneType) of
		#st_scene_config{res = Res} ->
			?LIB_MAP_MODULE:set_module(Res);
		_ -> skip
	end.

check_point(Point) ->
	case ?LIB_MAP_MODULE:check_point(Point) of
		false -> false;
		R ->
			R
			%% 性能优化：这个暂时屏蔽，不需要检测
			% case check_scene_item_point(tool_vect:to_map_point(Point)) of
			% 	false -> false;
			% 	_ -> R
			% end
	end.

check_dir(PointFrom,PointTo) ->
	case ?LIB_MAP_MODULE:check_dir_by_point(PointFrom,PointTo) of
		{_Ret,_Dis,CrossPoint} -> 
			%%?debug("check_dir,data = ~p",[{_Ret,_Dis,CrossPoint}]),
			case check_scene_item_dir(PointFrom,CrossPoint) of
				{true,NewCrossPoint} ->
					case check_point(NewCrossPoint) of
						{true,_,NewCrossPoint1} -> {find,tool_vect:lenght(tool_vect:dec(NewCrossPoint1#map_point{y = 0}, PointFrom#map_point{y = 0})),NewCrossPoint1};
						_ -> {find,tool_vect:lenght(tool_vect:dec(NewCrossPoint#map_point{y = 0}, PointFrom#map_point{y = 0})),NewCrossPoint}
					end;						
				_ -> {error,scene_item_check_error}
			end;
		R -> R
	end.

check_dir(PointFrom,Dir,MaxDis) ->
	Lp = tool_vect:lenght_power(Dir#map_point{y = 0}),
	if
		Lp < 0.0001 -> {error,dir_error};
		true ->
			case ?LIB_MAP_MODULE:check_dir(PointFrom,Dir,MaxDis) of
				{_Ret,_Dis,CrossPoint} -> 
					case check_scene_item_dir(PointFrom,CrossPoint) of
						{true,NewCrossPoint} ->
							case check_point(NewCrossPoint) of
								{true,_,NewCrossPoint1} -> {find,tool_vect:lenght(tool_vect:dec(NewCrossPoint1#map_point{y = 0}, PointFrom#map_point{y = 0})),NewCrossPoint1};
								_ -> {find,tool_vect:lenght(tool_vect:dec(NewCrossPoint#map_point{y = 0}, PointFrom#map_point{y = 0})),NewCrossPoint}
							end;						
						_ -> {error,scene_item_check_error}
					end;
				R -> R
			end
	end.

get_scene_item_walls() ->
	case get(scene_item_walls) of
		Walls when erlang:is_list(Walls) -> Walls;
		_ -> []
	end.

chg_scene_item(Wall = {ID,_}) ->
	Walls = get_scene_item_walls(),
	case lists:keyfind(ID, 1, Walls) of
		false -> put(scene_item_walls,[Wall | Walls]);
		_ -> put(scene_item_walls,lists:keyreplace(ID, 1, Walls, Wall))
	end.

del_scene_item(ID) ->
	Walls = get_scene_item_walls(),
	case lists:keyfind(ID, 1, Walls) of
		false -> skip;
		_ -> put(scene_item_walls,lists:keydelete(ID, 1, Walls))
	end.
	
add_scene_item_wall(ID,Dir,Pos = {X,Y,Z},List) ->
	%%?debug("add_scene_item_wall,data = ~p",[{ID,Dir,Pos,List}]),
	Fun = fun({XL,ZL,XO,ZO}) ->
				  case {XO,ZO} of
					  {0,0} -> {#map_point{x = X - XL / 2,y = Y,z = Z - ZL / 2},#map_point{x = X + XL / 2,y = Y,z = Z + ZL / 2}};
					  _ -> 
						  {POX,_,POZ} = tool_vect:to_point(tool_vect:add(tool_vect:to_map_point(Pos), tool_vect:rotate_radian(#map_point{x = XO,y = 0,z = ZO}, tool_vect:angle2radian(Dir)))),
						  {#map_point{x = POX - XL / 2,y = Y,z = POZ - ZL / 2},#map_point{x = POX + XL / 2,y = Y,z = POZ + ZL / 2}}
				  end
		  end,
	ListData = lists:map(Fun, List),
	chg_scene_item({ID,ListData}).

del_scene_item_wall(ID) -> 
	%%?debug("del_scene_item_wall,data = ~p",[{ID}]),
	del_scene_item(ID).

% check_scene_item_point(Point) ->
% 	%%?debug("check_scene_item_point,Point = ~p",[Point]),
% 	FunWall = fun({#map_point{x = SX,z = SZ},#map_point{x = EX,z = EZ}}) ->
% 					  if
% 						  Point#map_point.x > SX andalso Point#map_point.x < EX andalso Point#map_point.z > SZ andalso Point#map_point.z < EZ -> 
% 							  true;
% 						  true -> false
% 					  end
% 			  end,
% 	Fun = fun({_,Walls}) ->
% 				  lists:any(FunWall, Walls) 
% 		  end,
% 	case lists:any(Fun, get_scene_item_walls()) of
% 		true -> false;
% 		_ -> true
% 	end.

check_scene_item_dir(_PointFrom,CrossPoint) ->	
	{true,CrossPoint}.
	%% 性能优化：场景物品不再检测
	% Dir = tool_vect:dec(CrossPoint, PointFrom),
	% Lp = tool_vect:lenght_power(Dir#map_point{y = 0}),
	% if
	% 	Lp < 0.0001 -> error;
	% 	true ->
	% 		case check_scene_item_point(tool_vect:add(PointFrom,tool_vect:ride(tool_vect:normal(Dir), 0.001))) of
	% 			true -> 
	% 				FunLine = fun({LP1,LP2},{LastPoint,LastLenPower}) ->
	% 								  %%?debug("{LP1,LP2},{LastPoint,LastLenPower} = ~p",[{{LP1,LP2},{LastPoint,LastLenPower}}]),
	% 								  case tool_vect:get_cross_point(LP1,LP2,PointFrom,CrossPoint) of
	% 									  {ok,Point} -> 
	% 										  LenPower = tool_vect:lenght_power(tool_vect:dec(Point, PointFrom)),
											  
	% 										  if
	% 											  LenPower < 0.001 -> {LastPoint,LastLenPower};
	% 											  LastLenPower == 0 -> {Point,LenPower};
	% 											  LenPower < LastLenPower -> {Point,LenPower};
	% 											  true -> {LastPoint,LastLenPower}
	% 										  end;
	% 									  _ -> {LastPoint,LastLenPower}
	% 								  end
	% 						  end,
					
	% 				FunWall = fun({#map_point{x = SX,z = SZ},#map_point{x = EX,z = EZ}},DataCross) ->
	% 								  if
	% 									  PointFrom#map_point.x < SX andalso CrossPoint#map_point.x < SX -> DataCross;
	% 									  PointFrom#map_point.x > EX andalso CrossPoint#map_point.x > EX -> DataCross;
	% 									  PointFrom#map_point.z < SZ andalso CrossPoint#map_point.z < SZ -> DataCross;
	% 									  PointFrom#map_point.z > EZ andalso CrossPoint#map_point.z > EZ -> DataCross;
	% 									  true ->
	% 										  Lines = [{#map_point{x = SX,y = 0,z = SZ},#map_point{x = SX,y = 0,z = EZ}},
	% 												   {#map_point{x = SX,y = 0,z = SZ},#map_point{x = EX,y = 0,z = SZ}},
	% 												   {#map_point{x = EX,y = 0,z = EZ},#map_point{x = SX,y = 0,z = EZ}},
	% 												   {#map_point{x = EX,y = 0,z = EZ},#map_point{x = EX,y = 0,z = SZ}}],
	% 										  lists:foldl(FunLine,DataCross, Lines)
	% 								  end
	% 						  end,
	% 				Fun = fun({_,Walls},DataCross) -> lists:foldl(FunWall,DataCross, Walls) end,
					
	% 				case lists:foldl(Fun, {no,0}, get_scene_item_walls()) of
	% 					{no,0} -> {true,CrossPoint};
	% 					{Point,_} -> {true,Point}
	% 				end;
	% 			_ -> error
	% 		end
	% end.


get_cell_width() ->
	SceneType = get(scene),
	case data_scene_config:get_scene(SceneType) of
		#st_scene_config{clipWidth=  CellWidth} -> CellWidth;
		_ -> 0
	end.
get_cell_by_pos({X,_,Z}) ->
	case get_cell_width() of
		0 -> {0,0};
		Width -> {util:floor(X / Width),util:floor(Z / Width)}
	end;
get_cell_by_pos(_) -> no.

collect_see_cells({CellX,CellY}) ->
	if
		CellX > 0 -> 
			if
				CellY > 0 -> 
					[{CellX - 1,CellY + 1},{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX - 1,CellY},{CellX,CellY},{CellX + 1,CellY},
					 {CellX - 1,CellY - 1},{CellX,CellY - 1},{CellX + 1,CellY - 1}];
				CellY == 0 -> 
					[{CellX - 1,CellY + 1},{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX - 1,CellY},{CellX,CellY},{CellX + 1,CellY}];
				true -> []
			end;
		CellX == 0 -> 
			if
				CellY > 0 -> 
					[{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX,CellY},{CellX + 1,CellY},
					 {CellX,CellY - 1},{CellX + 1,CellY - 1}];
				CellY == 0 -> 
					[{CellX,CellY + 1},{CellX + 1,CellY + 1},
					 {CellX,CellY},{CellX + 1,CellY}];
				true -> []
			end;
		true -> []
	end;
collect_see_cells(_) -> [].

create_cell({_,Cell}) ->
	SeeCells = collect_see_cells(Cell),
	{SeeCells,[]};
create_cell(_) -> {[],[]}.
	
find_cell(Key) ->
	case get(Key) of
		?UNDEFINED -> create_cell(Key);
		CellInfo -> CellInfo
	end.

fin_oids_by_cells(Cells) ->
	Fun=fun(Cell, Acc) ->
		Key = {scene_cell,Cell},
		case find_cell(Key) of
			{_SeeCells,HasOids} -> HasOids ++ Acc;
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], Cells).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%进入宫格只有增加视野对象
%%移动时候存在增加进入视野对象和减少视野对象两种
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
process_cell(Obj = #scene_spirit_ex{id=Oid,pos=CurPos,map_cell=OldCell}) ->
	case get_cell_by_pos(CurPos) of
		%%no -> Obj;
		OldCell -> {no_chg,OldCell};
		Cell ->
			Key = {scene_cell,Cell},
			case find_cell(Key) of
				{SeeCells,HasOids} ->
					put(Key,{SeeCells,[Oid]++HasOids});	
				_ -> skip
			end,
			OldKey = {scene_cell,OldCell},
			case find_cell(OldKey) of
				{OldSeeCells,OldHasOids} ->
					put(OldKey,{OldSeeCells,OldHasOids -- [Oid]});
				_ -> skip
			end,
			SeePt = fun_scene_obj:make_see_obj(Obj),
			MovePt = fun_scene_obj:make_continue_move(Obj),
			process_cell_objs(Obj,SeePt,MovePt,OldCell,Cell),
			{ok,Cell}			
	end.

%% 离开场景，游删除那边通知全场景，视野不用管理发送，只要自己清除数据
leave_cell(Oid,OldCell) ->
%% 	?debug("leave_cell,data = ~p",[{ID,OldCell}]),
	NewCell = no,
	OldKey = {scene_cell,OldCell},
	case find_cell(OldKey) of
		{OldSeeCells,OldHasOids} ->
			put(OldKey,{OldSeeCells,OldHasOids -- [Oid]});
		_ -> skip
	end,
	{ok,NewCell}.

process_cell_objs(Obj = #scene_spirit_ex{id = ID},SeePt,MovePt,OldCell,NewCell) ->
	OldSeeCells = collect_see_cells(OldCell),
	NewSeeCells = collect_see_cells(NewCell),
	SeeCells = NewSeeCells -- OldSeeCells,
	NoSeeCells = OldSeeCells -- NewSeeCells,
	FunSee = fun(SeeObjID,{UL1,RL1,ML1,IL1,EL1,ModL1,MoveList}) ->
		SeeObjRec=fun_scene_obj:get_obj(SeeObjID),
		case SeeObjRec of
			%%自己不处理
			#scene_spirit_ex{id = ID} -> {UL1,RL1,ML1,IL1,EL1,ModL1,MoveList};
			#scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{sid = SidS}} -> 
				case Obj of
					#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{owner_id = SeeObjID}} -> 
						%%自己不要看到自己的佣兵
						{UL1,RL1,ML1,IL1,EL1,ModL1,MoveList};
					_ ->
						%%?debug("send see me , {SeeObjID,Uid} = ~p",[{SeeObjID,ID}]),
						%%?debug("send see me , SeePt = ~p",[SeePt]),
						case SeePt of
							skip -> skip;
							_ -> ?send(SidS,SeePt)
						end,
						case MovePt of
							no -> skip;
							_ -> ?send(SidS,MovePt)
						end,
						{[SeeObjRec|UL1],RL1,ML1,IL1,EL1,ModL1,[SeeObjRec|MoveList]}
				end;
			#scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM} -> {UL1,RL1,ML1,[SeeObjRec|IL1],EL1,ModL1,MoveList};
			#scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER} -> {UL1,RL1,[SeeObjRec|ML1],IL1,EL1,ModL1,[SeeObjRec|MoveList]};
			#scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT} -> {UL1,[SeeObjRec|RL1],ML1,IL1,EL1,ModL1,[SeeObjRec|MoveList]};
			#scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{owner_id = OwnerID}} ->
				%%自己不要看到自己的佣兵
				if
					OwnerID == ID -> {UL1,RL1,ML1,IL1,EL1,ModL1,MoveList};
					true ->{UL1,RL1,ML1,IL1,[SeeObjRec|EL1],ModL1,[SeeObjRec|MoveList]}
				end;
			#scene_spirit_ex{sort = ?SPIRIT_SORT_MODEL} -> {UL1,RL1,ML1,IL1,EL1,[SeeObjRec|ModL1],MoveList};
			_ -> {UL1,RL1,ML1,IL1,EL1,ModL1,MoveList}
		end
	end,
	%%{UL,RL,ML,IL,EL,ModL,MoveL} = lists:foldl(FunSee, {[],[],[],[],[],[],[]}, get_objs_by_cells(CellInfo,SeeCells)),	
	{UL,RL,ML,IL,EL,ModL,MoveL} = lists:foldl(FunSee, {[],[],[],[],[],[],[]}, fin_oids_by_cells(SeeCells)),
	
	MySort = util_scene:server_obj_type_2_client_type(Obj#scene_spirit_ex.sort),
	Ptl = #pt_public_scene_objs{sort = MySort,
									id = ID
								   },
	PtN = #pt_scene_hide{hide_list = [Ptl]},
%% 	?debug("PtN1 = ~p",[PtN1]),
	PtNSee = proto:pack(PtN),
	
	
	FunNoSee = fun(NoSeeObjID,OObjDatsRet) ->
					   case fun_scene_obj:get_obj(NoSeeObjID) of
						   #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,data = #scene_usr_ex{sid = SidN}} -> 
							   %%?debug("send see no,me , {SeeObjID,Uid} = ~p",[{NoSeeObjID,ID}]),							   
							   %%自己的佣兵也不用发送消失
							   case Obj of
								   #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{owner_id = NoSeeObjID}} -> skip;
								   _ ->?send(SidN,PtNSee)
							   end,
							   
							   OSort = fun_scene_obj:get_spirit_client_type(NoSeeObjID),
							   Ptol = #pt_public_scene_objs{sort = OSort,
																 id = NoSeeObjID
																},
							   [Ptol|OObjDatsRet];
						   #scene_spirit_ex{sort = ObjSort} -> 
							   OSort = util_scene:server_obj_type_2_client_type(ObjSort),
							   Ptol = #pt_public_scene_objs{sort = OSort,
																 id = NoSeeObjID
																},
							   [Ptol|OObjDatsRet];
						   _ -> OObjDatsRet
					   end
			   end,
	OObjDats1 = lists:foldl(FunNoSee, [], fin_oids_by_cells(NoSeeCells)),	
	%%OObjDats1 = lists:map(FunNoSee, fin_oids_by_cells(NoSeeCells)),	
	
	case Obj of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} ->
			Len = erlang:length(UL) + erlang:length(RL) + erlang:length(ML) + erlang:length(IL) + erlang:length(EL) + erlang:length(ModL),
			if
				Len > 0 ->
					Pt = fun_scene_obj:make_see_objs(Obj,UL,RL,ML,IL,EL,ModL),
					?send(Sid,proto:pack(Pt)),
					fun_scene_obj:send_continue_move(Obj,MoveL),
					ok;
				true -> skip
			end,
			case OObjDats1 of	
				[] -> skip;
				_ ->
					PtNN = #pt_scene_hide{hide_list = OObjDats1},
					%%?debug("process_cell_objs,Pt = ~p",[PtNN1]),
					PtNNSee = proto:pack(PtNN),
					?send(Sid,PtNNSee)
			end;
		_ -> skip
	end.

process_recon(Obj = #scene_spirit_ex{id = ID,map_cell =Cell}) ->
%% 	?debug("process_recon,Cell = ~p",[Cell]),
	FunSee = fun(SeeObjID,{UL1,RL1,ML1,IL1,EL1,ModL1,MoveList}) ->
					 %%?debug("process_cell_objs,SeeObjID = ~p",[SeeObjID]),
					 SeeObjRec=fun_scene_obj:get_obj(SeeObjID),
					 case SeeObjRec of
						 #scene_spirit_ex{sort = ?SPIRIT_SORT_USR,id = UsrID} -> 
							 if
								 ID == UsrID -> {UL1,RL1,ML1,IL1,EL1,ModL1,MoveList};
								 true -> {[SeeObjRec|UL1],RL1,ML1,IL1,EL1,ModL1,[SeeObjRec|MoveList]}
							 end;
						 #scene_spirit_ex{sort = ?SPIRIT_SORT_ITEM} -> {UL1,RL1,ML1,[SeeObjRec|IL1],EL1,ModL1,MoveList};
						 #scene_spirit_ex{sort = ?SPIRIT_SORT_MONSTER} -> {UL1,RL1,[SeeObjRec|ML1],IL1,EL1,ModL1,[SeeObjRec|MoveList]};
						 #scene_spirit_ex{sort = ?SPIRIT_SORT_ROBOT} -> {UL1,[SeeObjRec|RL1],ML1,IL1,EL1,ModL1,[SeeObjRec|MoveList]};
						 #scene_spirit_ex{sort = ?SPIRIT_SORT_ENTOURAGE,data = #scene_entourage_ex{owner_id = OwnerID}} ->
							 %%自己不要看到自己的佣兵
							 if
								 OwnerID == ID -> {UL1,RL1,ML1,IL1,EL1,ModL1,MoveList};
								 true ->{UL1,RL1,ML1,IL1,[SeeObjRec|EL1],ModL1,[SeeObjRec|MoveList]}
							 end;
						 #scene_spirit_ex{sort = ?SPIRIT_SORT_MODEL} -> {UL1,RL1,ML1,IL1,EL1,[SeeObjRec|ModL1],MoveList};
						 _ -> {UL1,RL1,ML1,IL1,EL1,ModL1,MoveList}
					 end
			 end,
	{UL,RL,ML,IL,EL,ModL,MoveL} = lists:foldl(FunSee, {[],[],[],[],[],[],[]}, get_all_bojs_by_cell(Cell)),	
	
	case Obj of
		#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} ->
			Len = erlang:length(UL) + erlang:length(RL) + erlang:length(ML) + erlang:length(IL) + erlang:length(EL) + erlang:length(ModL),
			if
				Len > 0 ->
					Pt = fun_scene_obj:make_see_objs(Obj,UL,RL,ML,IL,EL,ModL),
					?send(Sid,proto:pack(Pt)),
					fun_scene_obj:send_continue_move(Obj,MoveL),	
					ok;
				true -> skip
			end;
		_ -> skip
	end,
	ok.


%%发送给视野九宫格玩家
send_to_all_cell_usr(Cell,Data,SendPid) ->
	%%?debug("send_to_all_cell_usr,Cell=~p,SendPid=~p",[Cell,SendPid]),
	Key = {scene_cell,Cell},			
	Uids = case find_cell(Key) of
		{SeeCells,_HasOids} ->
			fin_oids_by_cells(SeeCells);
		_ -> []
	end,
	Fun= fun(Oid) ->
		if
			Oid == SendPid -> skip;
			true -> 
				case fun_scene_obj:get_obj(Oid,?SPIRIT_SORT_USR) of
					#scene_spirit_ex{data = #scene_usr_ex{sid = Sid}} ->
						% ?DBG(is_pid(Sid)),
						?send(Sid,Data);
					_ -> skip
				end
		end
	end,
	lists:foreach(Fun, Uids).

%%发送给视野九宫格玩家
send_to_all_cell_real_usr(Cell,Data,SendPid) ->
	Key = {scene_cell,Cell},			
	Uids=case find_cell(Key) of
			 {SeeCells,_HasOids} ->
				 fin_oids_by_cells(SeeCells);
			 _ -> []
		 end,
	Fun= fun(Oid) ->
				 if
					 Oid == SendPid -> skip;
					 true -> 
						 case fun_scene_obj:get_obj(Oid,?SPIRIT_SORT_USR) of
							 #scene_spirit_ex{data = #scene_usr_ex{sid=Sid}} ->							
								 ?send(Sid,Data);
							 _ -> skip
						 end
				 end
		 end,
	lists:foreach(Fun, Uids).

get_all_cell_usr(Cell,Uid)->
	Key = {scene_cell,Cell},			
	Uids=case find_cell(Key) of
			 {SeeCells,_HasOids} ->
				 fin_oids_by_cells(SeeCells);
			 _ -> []
		 end,
	Fun= fun(Oid) ->
				 if
					 Oid == Uid -> false;
					 true -> 
						 case fun_scene_obj:get_obj(Oid,?SPIRIT_SORT_USR) of
							 #scene_spirit_ex{} -> true;
							 _ -> false
						 end
				 end
		 end,
	lists:filter(Fun, Uids).

%%获取九宫格内的对象
get_all_bojs_by_cell(Cell) ->
	Key = {scene_cell,Cell},			
	case find_cell(Key) of
		{SeeCells,_HasOids} ->
			fin_oids_by_cells(SeeCells);
		_ -> []
	end.

get_all_bojs_by_id(Oid) ->
	case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{map_cell=Cell} ->
			List=get_all_bojs_by_cell(Cell),
			Fun=fun(ID,Ret) ->
				case fun_scene_obj:get_obj(ID) of
					Obj=#scene_spirit_ex{} -> [Obj|Ret];
					_ -> Ret
				end
			end,
			lists:foldl(Fun, [], List);	
		_ -> []
	end.


get_all_objs_by_obj(#scene_spirit_ex{map_cell=Cell}) ->
	List=get_all_bojs_by_cell(Cell),		
	Fun=fun(ID,Ret) ->
			case fun_scene_obj:get_obj(ID) of
				Obj=#scene_spirit_ex{} -> [Obj|Ret];						
				_ -> Ret
			end
		end,
	lists:foldl(Fun, [], List).

get_ml_bojs_by_cell(Cell) ->
	All=get_all_bojs_by_cell(Cell),
	Fun=fun(Oid) ->
			case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_MONSTER) of
				#scene_spirit_ex{} -> true;					
				_ -> false
			end
		end,	
	lists:filter(Fun, All).

get_ml_bojs_by_id(Oid) ->
	case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{map_cell=Cell} ->
			get_ml_bojs_by_cell(Cell);	
		_ -> []
	end.

get_usr_and_mon_num_by_pos(Pos,ReflushID) ->
	case get_cell_by_pos(Pos) of
		no -> {0,0};		
		Cell ->
			All=get_all_bojs_by_cell(Cell),
			Fun=fun(Oid,{UsrNum,MonNum}) ->
						case fun_scene_obj:get_obj(Oid) of
							#scene_spirit_ex{sort=?SPIRIT_SORT_USR} -> {UsrNum+1,MonNum};
							#scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER,die=false,data=Data} ->
								if
									ReflushID == Data#scene_monster_ex.reflush_pos_id -> {UsrNum,MonNum+1};										
									true -> {UsrNum,MonNum}
								end;								
							_ -> {UsrNum,MonNum}
						end
				end,			
			lists:foldl(Fun, {0,0}, All)		
	end.

%% 获取指定刷怪点当前怪物数量
get_area_mon_num(Pos,ReflushID) ->
	case get_cell_by_pos(Pos) of
		no -> 0;		
		Cell ->
			All=get_all_bojs_by_cell(Cell),			
			F=fun(Oid) ->
					  case fun_scene_obj:get_obj(Oid) of					  
						  #scene_spirit_ex{sort=?SPIRIT_SORT_MONSTER,die=false,data=MonData} ->
							  if
								  ReflushID == MonData#scene_monster_ex.reflush_pos_id -> true;
								  true -> false
							  end;
					  	  _ -> false	
					  end
			  end,					  
			erlang:length(lists:filter(F, All))			
	end.

get_usr_bojs_by_pos(Pos) ->
	case get_cell_by_pos(Pos) of
		no -> [];		
		Cell ->			
			All=get_all_bojs_by_cell(Cell),			
			Fun=fun(Oid) ->
						case fun_scene_obj:get_obj(Oid) of
							#scene_spirit_ex{sort=?SPIRIT_SORT_USR} -> true;
							_ -> false
						end
				end,
			lists:filter(Fun, All)		
	end.

%% 坐标所在的九宫格内是否有玩家
has_usr_obj_near_by(Pos) ->
	case get_cell_by_pos(Pos) of
		no -> false;		
		Cell ->		
			All=get_all_bojs_by_cell(Cell),	
			Fun=fun(Oid) ->
				case fun_scene_obj:get_obj(Oid) of
					#scene_spirit_ex{sort=?SPIRIT_SORT_USR} -> true;
					_ -> false
				end
			end,
			lists:any(Fun, All)		
	end.

get_camp_usr_bojs_by_pos(Camp,Pos) ->
	case get_cell_by_pos(Pos) of
		no -> [];		
		Cell ->			
			All=get_all_bojs_by_cell(Cell),			
			Fun=fun(Oid) ->
						case fun_scene_obj:get_obj(Oid) of
							#scene_spirit_ex{sort=?SPIRIT_SORT_USR,camp=Camp} -> true;
							_ -> false
						end
				end,
			lists:filter(Fun, All)		
	end.

get_cell_by_point(Pos) -> get_cell_by_pos(Pos).

get_il_bojs_by_cell(Cell) ->
	All=get_all_bojs_by_cell(Cell),
	Fun=fun(Oid) ->
			case fun_scene_obj:get_obj(Oid, ?SPIRIT_SORT_ITEM) of
				#scene_spirit_ex{} -> true;					
				_ -> false
			end
		end,	
	lists:filter(Fun, All).

get_il_bojs_by_id(Oid) ->
	case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{map_cell=Cell} ->
			get_il_bojs_by_cell(Cell);	
		_ -> []
	end.

get_camp_cell_usr(Oid,Camp)->
	case fun_scene_obj:get_obj(Oid) of
		#scene_spirit_ex{map_cell=Cell} ->
			Key = {scene_cell,Cell},			
			Uids=case find_cell(Key) of
					 {SeeCells,_HasOids} ->
						 fin_oids_by_cells(SeeCells);
					 _ -> []
				 end,
			Fun= fun(ID) ->
						 case fun_scene_obj:get_obj(ID,?SPIRIT_SORT_USR) of
							 #scene_spirit_ex{camp=Camp} -> true;
							 _ -> false
						 end
				 end,
			lists:filter(Fun, Uids);			
		_ -> []
	end.