%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name : normal ai
%% author : Andy lee
%% date : 15/7/23 
%% Company : fbird
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(ai_normal).
-include("common.hrl").
-export([init/5,do_ai/3,add_partrol_point/2,script_move_control/2]).

init(Scene,Id,Type,{X,Y,Z},_Dir) ->
	case data_monster:get_monster(Type) of
		{} -> {};
		_  ->			
			#ai_data{id=Id,type=Type,status=create,scene=Scene,x=X,y=Y,z=Z,move_dir=0,create_time=util:longunixtime()}
	end. 

add_partrol_point(AiData,Points) -> 
	AiData#ai_data{still_partrol_points = Points}.

script_move_control(AiData,_Pos)-> AiData.

do_ai(Obj = #scene_spirit_ex{pos = Pos}, Moving, AiData = #ai_data{status = Status}) ->
	% ?debug("Status = ~p",[Status]),
	case Status of
		create -> do_create(Pos, AiData);
		chase -> do_chase(Pos, Moving, AiData);
		impact -> do_impact(Pos, Moving, AiData);
		fear -> do_fear(Pos, Moving, AiData);
		atk -> do_atk(Pos, Moving, AiData);
		move -> do_move(Obj, Moving, AiData);
		_ ->
			?log_error("error normal ai s=~p",[Status]),
			AiData
	end.

%%create
do_create({Mx,My,Mz},#ai_data{id = Id, type=Type,create_time=CreateTime} = Data) ->
	case fun_ai:check_create(Id,Type,CreateTime) of
		{chase,Oid} -> 
			Data#ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
		impact -> 
		 	Data#ai_data{status=impact,x=Mx,y=My,z=Mz};
		_ -> 
			Data#ai_data{x=Mx,y=My,z=Mz}
	end.

%%chase
do_chase({Mx,My,Mz},Moving,#ai_data{id=ID,status=chase,type=Type,target=Target,move_dir=MoveDir}=Data) ->
	case fun_ai:check_chase(ID,Type,{Mx,My,Mz},Target) of 
		fear -> Data#ai_data{status=fear,x=Mx,y=My,z=Mz};
		impact -> Data#ai_data{status=impact,x=Mx,y=My,z=Mz};
		{chase,NewOid} ->
			case fun_ai:chase(ID,Type,{Mx,My,Mz},Moving,MoveDir,NewOid) of
				atk -> Data#ai_data{status=atk,x=Mx,y=My,z=Mz};
				{walk,Dir,ToPoint} -> {move,ToPoint,Data#ai_data{status=move,x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
				{chase,Oid} -> Data#ai_data{x=Mx,y=My,z=Mz,target=Oid};
				_ -> Data#ai_data{x=Mx,y=My,z=Mz}
			end;
		_ ->
			case fun_ai:chase(ID,Type,{Mx,My,Mz},Moving,MoveDir,Target) of
				atk -> Data#ai_data{status=atk,x=Mx,y=My,z=Mz};
				{walk,Dir,ToPoint} -> {move,ToPoint,Data#ai_data{status=move,x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
				{chase,Oid} -> Data#ai_data{x=Mx,y=My,z=Mz,target=Oid};
				_ -> Data#ai_data{x=Mx,y=My,z=Mz}
			end
	end.

do_move(#scene_spirit_ex{pos={Mx,My,Mz}, move_data = MoveData}, _Moving, AiData) -> 
	case MoveData of
		#move_data{start_time = StartTime, all_time = NeedMoveTime} ->
			case scene:get_scene_long_now() >= StartTime + NeedMoveTime + 200 of
				true -> 
					AiData#ai_data{status=chase,x=Mx,y=My,z=Mz};
				_ -> 
					AiData
			end;
		_ -> 
			AiData#ai_data{status=chase,x=Mx,y=My,z=Mz}
	end.


% %%back
% ai({Mx,My,Mz},Moving,#ai_data{id=ID,status=back,type=Type,move_dir=MoveDir,born_pos=BornPos} = Data) ->
% 	case fun_ai:check_back({Mx,My,Mz},BornPos) of
% 		free -> Data#ai_data{status=free,x=Mx,y=My,z=Mz};
% 		_ ->
% 			case fun_ai:back(ID,Type,{Mx,My,Mz},Moving,MoveDir,BornPos) of
% 				{walk,Dir,ToPoint} -> {move,ToPoint,Data#ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
% 				_ -> Data#ai_data{x=Mx,y=My,z=Mz}
% 			end
% 	end;

%%impact
do_impact({Mx,My,Mz},Moving,#ai_data{id=ID,status=impact,type=Type,move_dir=MoveDir,move_time=Last_time}=Data) ->
	case fun_ai:impact(ID,Type,{Mx,My,Mz},Moving,MoveDir,Last_time) of
		chase -> Data#ai_data{status=chase,x=Mx,y=My,z=Mz};
		{walk,Dir,ToPoint} -> {move,ToPoint,Data#ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
		_ -> Data#ai_data{x=Mx,y=My,z=Mz}
	end.

%%fear
do_fear({Mx,My,Mz},Moving,#ai_data{id=ID,status=fear,type=Type,move_time=Last_time}=Data) ->
	case fun_ai:fear(ID,Type,{Mx,My,Mz},Moving,Last_time) of
		free -> Data#ai_data{status=free,x=Mx,y=My,z=Mz};
		{walk,Dir,ToPoint} -> {move,ToPoint,Data#ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
		_ -> Data#ai_data{x=Mx,y=My,z=Mz}
	end.

%%atk
do_atk({Mx,My,Mz},Moving,#ai_data{id=ID,status=atk,type=Type,target=Target,move_dir=MoveDir}=Data) ->
	case fun_ai:check_atk(ID,Type,{Mx,My,Mz},Moving,MoveDir,Target) of
		fear -> Data#ai_data{status=fear,x=Mx,y=My,z=Mz};
		{walk,Dir,ToPoint} -> {move,ToPoint,Data#ai_data{x=Mx,y=My,z=Mz,move_dir=Dir,move_time=util:longunixtime()}};
		{chase,Oid} -> Data#ai_data{status=chase,x=Mx,y=My,z=Mz,target=Oid};
		_ ->
			case fun_ai:atk(ID,Type) of
				{atk,Skill} -> fun_ai:atk_tag(Skill,{Mx,My,Mz},Target,Data#ai_data{x=Mx,y=My,z=Mz});
				_ -> Data#ai_data{x=Mx,y=My,z=Mz}
			end
	end.