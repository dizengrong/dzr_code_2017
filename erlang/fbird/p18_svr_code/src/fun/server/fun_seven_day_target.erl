-module(fun_seven_day_target).
-include("common.hrl").
-export([add_seven_day_activty/2,req_seven_day_target_rewards/4,req_seven_day_rewards_date/3,
		 req_seven_day_activty_date/4,login_update_target_activity/1]).
-export([gm_minus_create_time/3,req_day_state_reward/4]).

-define(STATE_NO_FINISH,0).%%未完成
-define(STATE_FINISH,1).%%完成
-define(STATE_REWARDS,2).%%小目标已领取
-define(STATE_GET_REWARDS,1).%%已领取
-define(STATE_NO_GET_REWARDS,0).%%不能领取
-define(SECONDS_PER_DAY, 86400).

%% =============== 数据操作 ===============
get_data(Uid) ->
	db:dirty_get(seven_day_target, Uid, #seven_day_target.uid).
get_data(Uid, ActivityId) ->
	List = get_data(Uid),
	case lists:keyfind(ActivityId, #seven_day_target.activity_id, List) of
		false ->
			#st_day_target{days = DayId} = data_day_target:get_data(ActivityId),
			#seven_day_target{
				uid         = Uid, 
				activity_id = ActivityId,
				day_id      = DayId,
				state       = ?STATE_NO_FINISH
			};
		Rec -> Rec
	end.
set_data(Rec) ->
	case Rec#seven_day_target.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.
has_activity_data(Uid, ActivityId) ->
	List = get_data(Uid),
	lists:keymember(ActivityId, #seven_day_target.activity_id, List).	
%% =============== 数据操作 ===============


%%七日目标添加数
add_seven_day_activty(Uid,Date)->
	case Date of
		{Type,Val2,Val3}->
			List = data_day_target:select_typeId(Type),
			[updata_seven_day_target(Uid,T,Val2,Val3) || T <- List],
			ok;
		_->skip
	end.

updata_seven_day_target(Uid, ActivityId, DoneVal, DoneNum)->
	Rec = get_data(Uid, ActivityId),
	case Rec#seven_day_target.state of
		?STATE_REWARDS -> skip;
		?STATE_FINISH  -> skip;
		_ ->
			Sid = util:get_sid_by_uid(Uid),
			case check_count_seven_day_target(Uid, ActivityId) of
				true->
					case data_day_target:get_data(ActivityId) of
						#st_day_target{typeId=Type,val1 = Val1,val2=MaxNum}->
							OldNum = Rec#seven_day_target.activity_num,
							NewNum = get_activity_done_num(Type, DoneVal, Val1, OldNum, DoneNum, MaxNum),
							Status = ?_IF(NewNum >= MaxNum, ?STATE_FINISH, ?STATE_NO_FINISH),
							Rec2   = Rec#seven_day_target{
								activity_num = NewNum,
								state = Status
							},
							set_data(Rec2),
							case Status == ?STATE_FINISH of
								true -> req_seven_day_rewards_date(Sid, Uid, 0);
								_ -> skip
							end,
							req_seven_day_activty_date(Sid,Uid,0,0);
						_ -> skip
					end;
				_ -> skip
			end
	end.

% get_activity_done_num(?TASK_UP_PROP, DoneVal, Val1, OldNum, DoneNum, MaxNum) ->
% 	case DoneVal == Val1 of
% 		true ->  min(MaxNum, max(DoneNum, OldNum));
% 		false -> OldNum
% 	end;
% get_activity_done_num(?TASK_DRAW, DoneVal, Val1, OldNum, DoneNum, MaxNum) ->
% 	case DoneVal == Val1 of
% 		true ->  min(MaxNum, OldNum + DoneNum);
% 		false -> OldNum
% 	end;
% get_activity_done_num(Type, _DoneVal, _Val1, OldNum, DoneNum, MaxNum) 
% 	when Type == ?TASK_OWN_ALL_POS_IMP_LEV;
% 		 Type == ?TAKS_MOUNT_LEV;
% 		 Type == ?TASK_OWN_POS_IMP_LEV;
% 		 Type == ?TASK_PASS_BARRIER;
% 		 Type == ?TASK_OWN_ALL_POS_STR_LEV;
% 		 Type == ?TASK_ENTOURAGE_LV_UP;
% 		 Type == ?TASK_MAX_ITEM_STAR ->
% 	min(MaxNum, max(OldNum, DoneNum)); %% 传递的是完成的总量
get_activity_done_num(_Type, _DoneVal, _Val1, OldNum, DoneNum, MaxNum) ->
	min(MaxNum, OldNum + DoneNum). %% 传递的是增量

%%请求七日目标活动数据
req_seven_day_activty_date(Sid,Uid,_Day,Seq)->
	ActivityList = get_data(Uid),
	Fun = fun(#seven_day_target{activity_id=ActivityId,activity_num=ActivityNum,state=State})->
		{ActivityId,ActivityNum,State}
	end,
	NewActivityList = lists:map(Fun, ActivityList),
	sned_seven_day_activty_date(Sid, NewActivityList, Seq).

%%请求七日小目标奖励
req_day_state_reward(Uid, Sid, Seq, ActivityId) ->
	Rec = get_data(Uid, ActivityId),
	case Rec#seven_day_target.state of
		?STATE_FINISH ->
			case data_day_target:get_data(ActivityId) of
				#st_day_target{reward=ItemList} ->
					AddItems = [{?ITEM_WAY_SEVEN_DAY_STATE_REWARD, T, N} || {T, N} <- ItemList],
					Succ = fun() ->
						Rec1 = Rec#seven_day_target{state=?STATE_REWARDS},
						set_data(Rec1),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, ItemList),
						State = Rec1#seven_day_target.state,
						send_seven_day_state(Uid, Sid, Seq, State, ActivityId)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.
 

%%请求七日目标奖励数据
req_seven_day_rewards_date(Sid,Uid,Seq)->
	case db:dirty_get(seven_day_target,Uid, #seven_day_target.uid) of
		TargetList when is_list(TargetList)->
			Fun = fun(#seven_day_target{day_id=DayId},Acc)->
						  case lists:member(DayId, Acc) of
							  true->Acc;
							  _->Acc ++ [DayId]
						  end
				  end,
			NewTargetList = lists:foldl(Fun,[],TargetList),
			Fun1 = fun(DayId)->
						  case db:dirty_match(seven_day_rewards, #seven_day_rewards{uid=Uid,day_id=DayId,_='_'}) of
							  []->{DayId,get_day_finish_num(Uid,DayId),?STATE_NO_GET_REWARDS};
							  _->{DayId,get_day_finish_num(Uid,DayId),?STATE_GET_REWARDS}
						  end
				  end,
			NewRewardsList = lists:map(Fun1, NewTargetList),
			sned_seven_day_rewards_date(Sid, Uid, NewRewardsList, Seq);
		_->sned_seven_day_rewards_date(Sid, Uid, [], Seq)
	end.

%%获取当天已完成的活跃数	
get_day_finish_num(Uid,Day)->
	case db:dirty_match(seven_day_target,#seven_day_target{uid=Uid,day_id=Day,_='_'}) of
		List when is_list(List)->
			Fun = fun(#seven_day_target{state=State}) ->
					case State of
						?STATE_FINISH -> true;
						?STATE_REWARDS -> true;
						_ -> false
					end
				  end,
			List1 = lists:filter(Fun, List),
			length(List1);
		_->0
	end.

%%领取七日目标添奖励
req_seven_day_target_rewards(Sid,Uid,Seq,Day)->
	case data_day_reward:get_data(Day) of
		#st_day_reward{rewardId=ItemList}->
			DayActivityNum = length(data_day_target:select_days(Day)),
			case get_day_finish_num(Uid, Day) of
				FinishNum when is_number(FinishNum)->
					if 
						FinishNum >= DayActivityNum->
							case db:dirty_match(seven_day_rewards,#seven_day_rewards{uid=Uid,day_id=Day,_='_'}) of
								[] ->
									AddItems = [{?ITEM_WAY_SEVEN_DAY_STATE_REWARD, T, N} || {T, N} <- ItemList],
									Succ = fun() ->
										db:insert(#seven_day_rewards{uid=Uid,day_id=Day}),
										sned_seven_day_target_rewards(Sid, Seq, ItemList),
										req_seven_day_rewards_date(Sid, Uid, Seq)
									end,
									fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
								_ -> skip %%已经领取过
							end;
						true -> skip %%目标活动没有达成
					end;
				_ -> skip
			end;
		_ -> skip
	end.

gm_minus_create_time(Uid, _Sid, Days) ->
	[Usr = #usr{create_time=CreateTime}] = db:get_usr(Uid, ?TRUE),
	CreateTime2 = CreateTime - Days*3600*24,
	db:dirty_put(Usr#usr{create_time=CreateTime2}),
	login_update_target_activity(Uid),
	?debug("Days:~p", [Days]),
	ok.

%%获取今天是第几天
get_create_usr_time(Uid)->
	Day = util:get_relative_day(?AUTO_REFRESH_TIME),
	CreateTime = util:get_relative_day(util:get_create_usr_time(Uid), ?AUTO_REFRESH_TIME),
	abs(Day - CreateTime)+1.

%%获取是不是能够计数的任务
check_count_seven_day_target(Uid,Type)->
	DayTime = get_create_usr_time(Uid),
	case data_day_target:get_data(Type) of
		#st_day_target{days=Day}->
			if DayTime >=  Day-> true;
			   true->false
			end;
		_->false
	end.

send_seven_day_state(_Uid, Sid, Seq, State, ActivityId) ->
	Pt = #pt_seven_day_target_status{status = State, activitieid = ActivityId},
	?send(Sid,proto:pack(Pt, Seq)).


%%发送七日目标奖励数据
sned_seven_day_rewards_date(Sid,Uid,List,Seq)->
	CreateTime = get_create_usr_time(Uid),
	Fun = fun({RewardsId,RewardsNum,RewardsState}) ->		
		#pt_public_seven_day_target_rewards_list{rewards_id = RewardsId,rewards_num = RewardsNum,rewards_state = RewardsState}
	end,
	RewardsList = lists:map(Fun, List),
	
	Pt = #pt_seven_day_target_rewards_info{day = CreateTime,seven_day_target_rewards_list = RewardsList},
	?send(Sid,proto:pack(Pt,Seq)).

%%发送七日目标奖励活跃度数据
sned_seven_day_activty_date(Sid,List,Seq)->
	Fun = fun({TargetId,TargetNum,TargetState}) ->		
		#pt_public_seven_day_target_info_list{target_id = TargetId,target_num = TargetNum,target_state = TargetState}
	end,
	RewardsList = lists:map(Fun, List),
	
	Pt = #pt_seven_day_target_info{seven_day_target_info_list = RewardsList},
	?send(Sid,proto:pack(Pt,Seq)).

%%发送七日奖励领取成功
sned_seven_day_target_rewards(Sid,Seq,List)->
	Fun = fun({ItemType,ItemNum}) ->		
		#pt_public_item_list{item_id = ItemType,item_num = ItemNum}
	end,
	RewardsList = lists:map(Fun, List),
	Pt = #pt_seven_day_target_succeed{item_list = RewardsList},
	?send(Sid,proto:pack(Pt,Seq)).

%% 登陆处理目标活跃度，激活新的活动
login_update_target_activity(Uid)->
	DayLsit = data_day_reward:get_all(),
	Fun = fun(Day) ->
		ActivityIdList = data_day_target:select_days(Day),
		[login_update_target_activity2(Uid, Id) || Id <- ActivityIdList]
	end,
	[Fun(Day) || Day <- DayLsit],
	ok.

login_update_target_activity2(Uid, ActivityId) ->
	case check_count_seven_day_target(Uid, ActivityId) of
		true ->
			#st_day_target{typeId=TypeId,val1=Val1,val2=Val2} = data_day_target:get_data(ActivityId),
			Num = fun_task_condition:init_condition({TypeId,Val1,Val2}, Uid),
			case has_activity_data(Uid, ActivityId) of
				false ->
					updata_seven_day_target(Uid, ActivityId, Val1, Num);
				_ ->
					skip
			end;
		false -> 
			skip
	end.

