%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-3-15
%% Company : fbird.Co.Ltd
%% Desc : fun_gm_operation GM操作
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_gm_operation).
-include("common.hrl").
-export([start_shutup/2,check_shutup/3,remove_shutup/1,check_sethonor/2,start_sethonor/2,remove_sethonor/1,kick_usr/1,kick_all_usr/0]).
%%开始禁言
start_shutup(Uid,Time)->
	case db:dirty_get(gm_operation, Uid, #gm_operation.uid) of
		[GmOperation|_]->
			db:dirty_put(GmOperation#gm_operation{shutup_start_time=util:unixtime(),shutup_time=Time}),ok;
		_->
			case db:get_usr(Uid, ?TRUE) of
				[#usr{}|_]->
					db:insert(#gm_operation{shutup_start_time=util:unixtime(),shutup_time=Time,uid=Uid}),ok;
				_->error
			end
	end.
%%解除禁言
remove_shutup(Uid)->
	case db:dirty_get(gm_operation, Uid, #gm_operation.uid) of
		[GmOperation|_]->
			db:dirty_put(GmOperation#gm_operation{shutup_start_time=util:unixtime(),shutup_time=0}),ok;
		_R->skip
	end.

%%检查是不是禁言状态
check_shutup(Sid,Uid,Seq)->
	case db:dirty_get(gm_operation, Uid, #gm_operation.uid) of
		[#gm_operation{shutup_start_time=StartTime,shutup_time=ShutupTime}|_]->
			Now = util:unixtime(),
			if StartTime + ShutupTime > Now->?error_report(Sid,"chat_forbidden",Seq,[(StartTime + ShutupTime) - Now]),false;
			   true->true
			end;
		_->true
	end.

%%封号
start_sethonor(Uid,Time)->
	case get_aid_by_uid(Uid) of
		0->
			?log_trace("--------start_sethonor--Uid,Time=~p",[{Uid,Time}]),
			skip;
		Aid->
			case db:dirty_get(gm_operation, Aid, #gm_operation.aid) of
				[GmOperation|_]->
					db:dirty_put(GmOperation#gm_operation{sethonor_start_time=util:unixtime(),sethonor_time=Time}),ok;
				_->
					case db:getOrKeyFindData(account,Aid) of
						[_ACC|_]->
							db:insert(#gm_operation{sethonor_start_time=util:unixtime(),sethonor_time=Time,aid=Aid}),ok;
						_->?log_trace("----no Accid----start_sethonor--Uid,Time=~p",[{Uid,Time}]),error
					end
			end
	end.

%%一键踢所有人下线
kick_all_usr()->
	List = db:dirty_match(ply, #ply{_='_'}),
	Fun = fun(#ply{sid = Sid}) ->
		?error_report(Sid, "kick"),
		?discon(Sid,gm,1000)
	end,
	lists:foreach(Fun, List).

%%踢下线
kick_usr(Uid)->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid}|_]->
			?discon(Sid,gm,1000);
		_->skip
	end.


get_aid_by_uid(Uid)->
	case db:get_usr(Uid, ?TRUE) of
		[#usr{acc_id=Aid}|_]->
			case db:load_usrs_by_aid(Aid) of
				UsrList when is_list(UsrList) andalso length(UsrList)>0->
					Fun = fun(#usr{id=Uid1})->
								  case db:dirty_get(ply, Uid1) of
									  [#ply{sid=Sid}|_]->
										  ?discon(Sid,gm,1000);
									  _->skip
								  end
						  end,
					lists:foreach(Fun, UsrList),
					Aid;
				_R->?log_trace("------account no usr=~p",[{Uid}]),0
			end;
		_->?log_trace("------No usr=~p",[{Uid}]),0
	end.
%%解除封号
remove_sethonor(Uid)->
	case db:get_usr(Uid, ?TRUE) of
		[#usr{acc_id=Aid}|_]->
			case db:dirty_get(gm_operation, Aid, #gm_operation.aid) of
				[GmOperation|_]->
					db:dirty_put(GmOperation#gm_operation{sethonor_start_time=util:unixtime(),sethonor_time=0}),ok;
				_R->skip
			end;
		_->skip
	end.

%%检查是不是封号状态
check_sethonor(Aid,_Seq)->
	case db:dirty_get(gm_operation, Aid, #gm_operation.aid) of
		[#gm_operation{sethonor_start_time=StartTime,sethonor_time=ShutupTime}|_]->
			Now = util:unixtime(),
			if
				StartTime + ShutupTime > Now -> {false, StartTime + ShutupTime - Now};
				true -> true
			end;
		_ -> true
	end.