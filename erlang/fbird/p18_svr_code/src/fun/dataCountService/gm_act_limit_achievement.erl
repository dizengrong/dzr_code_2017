%% @doc gm活动：限时成就
-module (gm_act_limit_achievement).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_LIMIT_ACHIEVEMENT).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Type 		= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "type")),
	Day 		= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "day"))),
	Cumulative 	= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "cumulative"))),
	All 		= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "all"))),
	Num 		= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "number")),
	Need 		= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "conditions")),
	{Type, Day, Cumulative, All, Num, Need}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

on_refresh_part_data(_Uid, ActivityRec, UsrActivityRec) ->
	[{_, Day, _, _, _, _}] = ActivityRec#gm_activity.reward_datas,
	Fun = fun({DayId, _, _, _}) ->
		ActData = UsrActivityRec#gm_activity_usr.act_data,
		FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
		case ActData == [] andalso FetchData == [] of
			true -> skip;
			false ->
				ActData2 = lists:keystore(day_times, 1, ActData, {day_times, 0}),
				FetchData2 = lists:delete(DayId, FetchData),
				UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2, fetch_data = FetchData2},
				fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2)
		end
	end,
	lists:foreach(Fun, Day).

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec, fun_agent_mng:get_global_value(limit_achievement_time, 0)).
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec, AllTimes) ->
	Pt = #pt_limit_achievement_info{
		startTime 		= ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   		= ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc 			= util:to_list(ActivityRec#gm_activity.act_des),
		datas     		= get_reward_state_list(Uid, ActivityRec, UsrActivityRec, AllTimes)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_LIMIT_ACHIEVEMENT.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec, fun_agent_mng:get_global_value(limit_achievement_time, 0)),
	[#pt_public_limit_achievement_des{day_list = DayList, own_list = OwnList, total_list = TotalList}] = StateList,
	case lists:keyfind(RewardId, #pt_public_limit_achievement_day_des.day_id, DayList) of
		#pt_public_limit_achievement_day_des{can_day = ?REWARD_STATE_CAN_FETCH, day_reward = DayReward} ->
			FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
			FetchData2 = [RewardId | FetchData],
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
			{ok, UsrActivityRec2, DayReward};
		_ ->
			case lists:keyfind(RewardId, #pt_public_limit_achievement_own_des.own_id, OwnList) of
				#pt_public_limit_achievement_own_des{can_own = ?REWARD_STATE_CAN_FETCH, own_reward = OwnReward} ->
					FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
					FetchData2 = [RewardId | FetchData],
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					{ok, UsrActivityRec2, OwnReward};
				_ ->
					case lists:keyfind(RewardId, #pt_public_limit_achievement_total_des.all_id, TotalList) of
						#pt_public_limit_achievement_total_des{can_all = ?REWARD_STATE_CAN_FETCH, all_reward = AllReward} ->
							FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
							FetchData2 = [RewardId | FetchData],
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							{ok, UsrActivityRec2, AllReward};
						_ -> {error, "error_fetch_reward_not_reached"}
					end
			end
	end.

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid       = UsrActivityRec#gm_activity_usr.uid,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec, fun_agent_mng:get_global_value(limit_achievement_time, 0)),
	[do_activity_end_help2(Uid, ActivityRec, PtState) || PtState <- StateList],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_limit_achievement_info{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end,
	mod_msg:handle_to_agnetmng(?MODULE, {add_limit_achievement_time, 0}),
	mod_msg:handle_to_agnetmng(?MODULE, {set_limit_achievement_rank_list, []}).

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_limit_achievement_des{day_list = DayList,  own_list = OwnList, total_list = TotalList} = PtState,
	Fun1 = fun(#pt_public_limit_achievement_day_des{can_day = CanDay, day_reward = DayReward}) ->
		case CanDay of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_LIMIT_ACHIEVEMENT, Uid, ActivityRec#gm_activity.act_name, DayReward, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun1, DayList),
	Fun2 = fun(#pt_public_limit_achievement_own_des{can_own = CanOwn, own_reward = OwnReward}) ->
		case CanOwn of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_LIMIT_ACHIEVEMENT, Uid, ActivityRec#gm_activity.act_name, OwnReward, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun2, OwnList),
	Fun3 = fun(#pt_public_limit_achievement_total_des{can_all = CanAll, all_reward = AllReward}) ->
		case CanAll of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_LIMIT_ACHIEVEMENT, Uid, ActivityRec#gm_activity.act_name, AllReward, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun3, TotalList).

%% ================================================================
%% =========================== 内部方法 ===========================
ranking_limit_achievement() ->
	ActType = ?THIS_TYPE,
	case fun_gm_activity_ex:find_open_activity(ActType) of
		{true, ActivityRec} ->
			ranking_limit_achievement(ActivityRec);
		_ -> 
			skip
	end.

ranking_limit_achievement(ActivityRec) ->
	ActType = ActivityRec#gm_activity.type,
	{Num, Need} = get_ranking_length(ActivityRec),
	List = db:dirty_match(gm_activity_usr, #gm_activity_usr{_ = '_', type = ActType}),
	Fun = fun(Rec, Acc) -> 
		UsrActivityRec = fun_gm_activity_ex:usr_activity_rec_2_erl_format(Rec),
		OwnTimes = fun_gm_activity_ex:get_list_data_by_key(own_times, UsrActivityRec#gm_activity_usr.act_data, 0),
		%% 次数相同时，最先抽的排前面
		case OwnTimes >= Need of
			true  -> [{UsrActivityRec#gm_activity_usr.uid, {OwnTimes, -UsrActivityRec#gm_activity_usr.act_time}} | Acc];
			false -> Acc
		end
	end,
	List2 = lists:foldl(Fun, [], List),
	RankList = lists:sublist(lists:reverse(lists:keysort(2, List2)), Num),
	fun_agent_mng:set_global_value(limit_achievement_rank_list, RankList),
	{ok, ActivityRec, RankList}.

get_ranking_length(ActivityRec) ->
	List = ActivityRec#gm_activity.reward_datas,
	case List of
		[] -> {0, 0};
		_ -> 
			{_, _, _, _, Num, Need} = lists:last(List),
			{Num, Need}
	end.

get_reward_state_list(_Uid, ActivityRec, UsrActivityRec, AllTimes) ->
	RankList = fun_agent_mng:get_global_value(limit_achievement_rank_list, []),
	Fun = fun({Type, Day, Cumulative, All, Num, Need}) ->
		#pt_public_limit_achievement_des{
			type 			= Type,
			day_list		= get_day_reward_state_list_help(ActivityRec, UsrActivityRec, Day),
			own_list		= get_own_reward_state_list_help(ActivityRec, UsrActivityRec, Cumulative),
			total_list		= get_total_reward_state_list_help(ActivityRec, UsrActivityRec, All, AllTimes),
			rank_list_num	= Num,
			rank_list_need	= Need,
			rank_list 		= make_rank_list_pt(RankList, [], 1)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

get_day_reward_state_list_help(_ActivityRec, UsrActivityRec, Day) ->
	DayTimes = fun_gm_activity_ex:get_list_data_by_key(day_times, UsrActivityRec#gm_activity_usr.act_data, 0),
	Fun = fun({DayId, DayTime, DayReward, DayDesc}) ->
		CanDay = case lists:member(DayId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case DayTimes >= DayTime of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_limit_achievement_day_des{
			day_times	= min(DayTimes, DayTime),
			day_id 		= DayId,
			day_need 	= DayTime,
			day_reward 	= lists:map(fun fun_item_api:make_item_get_pt/1, DayReward),
			day_desc 	= DayDesc,
			can_day		= CanDay
		}
	end,
	lists:map(Fun, Day).

get_own_reward_state_list_help(_ActivityRec, UsrActivityRec, Cumulative) ->
	OwnTimes = fun_gm_activity_ex:get_list_data_by_key(own_times, UsrActivityRec#gm_activity_usr.act_data, 0),
	Fun = fun({OwnId, OwnTime, OwnReward, OwnDesc}) ->
		CanOwn = case lists:member(OwnId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case OwnTimes >= OwnTime of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_limit_achievement_own_des{
			own_times	= min(OwnTimes, OwnTime),
			own_id 		= OwnId,
			own_need 	= OwnTime,
			own_reward 	= lists:map(fun fun_item_api:make_item_get_pt/1, OwnReward),
			own_desc 	= OwnDesc,
			can_own		= CanOwn
		}
	end,
	lists:map(Fun, Cumulative).

get_total_reward_state_list_help(_ActivityRec, UsrActivityRec, All, AllTimes) ->
	Fun = fun({AllId, AllTime, AllReward, AllDesc}) ->
		CanAll = case lists:member(AllId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case AllTimes >= AllTime of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_limit_achievement_total_des{
			all_times 		= min(AllTimes, AllTime),
			all_id 			= AllId,
			all_need	 	= AllTime,
			all_reward 		= lists:map(fun fun_item_api:make_item_get_pt/1, AllReward),
			all_desc 		= AllDesc,
			can_all			= CanAll
		}
	end,
	lists:map(Fun, All).

make_rank_list_pt([], Acc, _Rank) -> lists:reverse(Acc);
make_rank_list_pt([{Uid, {Times, _Time}} | Rest1], Acc, Rank) ->
	case db:dirty_get(usr, Uid) of
		[#usr{name = UsrName, prof = Prof}|_]-> ok;
		_ -> UsrName = "", Prof = 3
	end,
	Pt = #pt_public_limit_achievement_ranking_des{
		rank  = Rank,
		uid   = Uid,
		prof  = Prof,
		name  = util:to_list(UsrName),
		times = Times
	},
	make_rank_list_pt(Rest1, [Pt | Acc], Rank + 1).

handle_achieve(Uid, Sid, Type, N) ->
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_LIMIT_ACHIEVEMENT) of
		false -> skip;
		{true, ActivityRec} ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?GM_ACTIVITY_LIMIT_ACHIEVEMENT),
			handle_achieve_help(Uid, Sid, Type, N, ActivityRec, UsrActivityRec)
	end.

handle_achieve_help(Uid, Sid, Type, N, ActivityRec, UsrActivityRec) ->
	AllTimes = fun_agent_mng:get_global_value(limit_achievement_time, 0),
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	{ActData2, NewAllTimes} = handle_achieve_help2(Uid, ActivityRec#gm_activity.reward_datas, Type, N, ActData, AllTimes),
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2, act_time = util_time:unixtime()},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	ranking_limit_achievement(),
	send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec2, NewAllTimes),
	ok.

handle_achieve_help2(_Uid, [], _Type, _N, Acc, AllTimes) -> {Acc, AllTimes};
handle_achieve_help2(Uid, [{AchType, _DayAch, _OwnAch, _AllAch, _Num, _Need} | Rest], Type, N, Acc, AllTimes) when Type == AchType ->
	DayTimes = fun_gm_activity_ex:get_list_data_by_key(day_times, Acc, 0),
	OwnTimes = fun_gm_activity_ex:get_list_data_by_key(own_times, Acc, 0),
	Acc2 = lists:keystore(day_times, 1, Acc, {day_times, DayTimes + N}),
	Acc3 = lists:keystore(own_times, 1, Acc2, {own_times, OwnTimes + N}),
	mod_msg:handle_to_agnetmng(?MODULE, {add_limit_achievement_time, AllTimes+N}),
	handle_achieve_help2(Uid, Rest, Type, N, Acc3, AllTimes+N);
handle_achieve_help2(Uid, [{_AchType, _DayAch, _OwnAch, _AllAch, _Num, _Need} | Rest], Type, N, Acc, AllTimes) ->
	handle_achieve_help2(Uid, Rest, Type, N, Acc, AllTimes).

handle({add_limit_achievement_time, Num}) ->
	fun_agent_mng:set_global_value(limit_achievement_time, Num);
handle({set_limit_achievement_rank_list, RankList}) ->
	fun_agent_mng:set_global_value(limit_achievement_rank_list, RankList).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_limit_achievement:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_limit_achievement:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?THIS_TYPE,
		act_name     = "name",
		type         = ?THIS_TYPE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?THIS_TYPE))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?THIS_TYPE, ?THIS_TYPE).

test_reward_datas(?THIS_TYPE) ->
	[{
		1, 
		[
			{0,5,[{9002,100}],"每日快速战斗5次可领取"}
		],	
		[
			{1,5,[{9002,100},{9002,100}],"累计快速战斗5次可领取"},
			{2,10,[{9002,100},{9002,100}],"累计快速战斗10次可领取"},
			{3,15,[{9002,100},{9002,100}],"累计快速战斗15次可领取"}
		],
		[
			{11,10,[{9002,100},{9002,100},{9002,100},{9002,100}],"本服累计快速战斗10次"},
			{12,20,[{9002,50},{9002,50},{9002,50},{9002,50}],"本服累计快速战斗20次"},
			{13,30,[{9002,30},{9002,30},{9002,30},{9002,30}],"本服累计快速战斗30次"},
			{14,40,[{9002,10},{9002,10},{9002,10},{9002,10}],"本服累计快速战斗40次"}
		],
		20,
		5
	}].
