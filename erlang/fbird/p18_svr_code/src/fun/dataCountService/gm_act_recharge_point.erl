%% @doc gm活动：充值建设点
-module (gm_act_recharge_point).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_RECHARGE_POINT).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Own  = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "persona_lrewards"))),
	All  = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "full_scale_reward"))),
	Rank = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "rank_reward"))),
	Need = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "num")),
	{Own, All, Rank, Need}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(ActivityRec, Uid, UsrActivityRec, RechargeDiamond, _RechargeConfigID) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			TotalPoint = fun_agent_mng:get_global_value(total_point_num, 0),
			ActData = UsrActivityRec#gm_activity_usr.act_data,
			OwnPoint = fun_gm_activity_ex:get_list_data_by_key(own_point_num, ActData, 0),
			ActData2 = lists:keystore(own_point_num, 1, ActData, {own_point_num, OwnPoint + RechargeDiamond}),
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2, act_time = util_time:unixtime()},
			fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
			mod_msg:handle_to_agnetmng(?MODULE, {add_total_point_num, TotalPoint + RechargeDiamond}),
			List = ActivityRec#gm_activity.reward_datas,
			case List of
				[] -> skip;
				_ ->
					{_, _, _, Need} = lists:last(List),
					case OwnPoint + RechargeDiamond >= Need of
						true -> mod_msg:handle_to_agnetmng(?MODULE, {update_ranklist, Uid, Sid, OwnPoint + RechargeDiamond, ActivityRec, UsrActivityRec2});
						_ -> skip
					end
			end,
			true;
		_ -> skip
	end.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_recharge_point{
		startTime   = ActivityRec#gm_activity.start_time,
		endTime     = ActivityRec#gm_activity.end_time,
		desc      	= ActivityRec#gm_activity.act_des,
		close_time  = ActivityRec#gm_activity.close_time,
		datas     	= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_RECHARGE_POINT.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[#pt_public_act_recharge_point_des{own_list = OwnList, total_list = TotalList}] = StateList,
	case lists:keyfind(RewardId, #pt_public_act_recharge_own_des.own_id, OwnList) of
		#pt_public_act_recharge_own_des{can_own = ?REWARD_STATE_CAN_FETCH, own_reward = OwnReward} ->
			FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
			FetchData2 = [RewardId | FetchData],
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
			{ok, UsrActivityRec2, OwnReward};
		_ ->
			case lists:keyfind(RewardId, #pt_public_act_recharge_total_des.all_id, TotalList) of
				#pt_public_act_recharge_total_des{can_all = ?REWARD_STATE_CAN_FETCH, all_reward = AllReward} ->
					FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
					FetchData2 = [RewardId | FetchData],
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					{ok, UsrActivityRec2, AllReward};
				_ -> {error, "error_fetch_reward_not_reached"}
			end
	end.

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[do_activity_end_help2(Uid, ActivityRec, PtState) || PtState <- StateList],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_recharge_point{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end,
	mod_msg:handle_to_agnetmng(?MODULE, {add_total_point_num, 0}),
	mod_msg:handle_to_agnetmng(?MODULE, {clean_ranklist, []}).

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_act_recharge_point_des{own_list = OwnList, total_list = TotalList} = PtState,
	Fun1 = fun(#pt_public_act_recharge_own_des{can_own = CanOwn, own_reward = OwnReward}) ->
		case CanOwn of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_RECHARGE_POINT, Uid, ActivityRec#gm_activity.act_name, OwnReward, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun1, OwnList),
	Fun2 = fun(#pt_public_act_recharge_total_des{can_all = CanAll, all_reward = AllReward}) ->
		case CanAll of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_RECHARGE_POINT, Uid, ActivityRec#gm_activity.act_name, AllReward, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun2, TotalList).

do_rank_reward(ActivityRec) ->
	RankList = fun_agent_mng:get_global_value(recharge_point_rank_list, []),
	case ActivityRec#gm_activity.reward_datas of
		[] -> skip;
		_ ->
			{_, _, Rank, _} = lists:last(ActivityRec#gm_activity.reward_datas),
			MaxLen = max(length(Rank), length(RankList)),
			RankList2 = make_rank_list_pt(RankList, [], 1, MaxLen, Rank),
			[do_treasure_rank_reward2(ActivityRec, RankData) || RankData <- RankList2]
	end,
	ok.	

do_treasure_rank_reward2(ActivityRec, RankData) ->
	#pt_public_act_recharge_ranklist_des{
		uid   		 = Uid,
		rank 		 = Rank,
		rank_reward  = RankReward
	} = RankData,
	case RankReward of
		[] -> skip;
		_ ->
			ActName = ActivityRec#gm_activity.act_name,
			ActType = ActivityRec#gm_activity.type,
			Rewards = fun_gm_activity_ex:transfer_pt_items(RankReward, ActType, 1),
			RewardItems = [{T, N, L} || {_, T, N, [{strengthen_lev, L}]} <- Rewards],
			fun_dataCount_update:gm_activity_rank(Uid,ActType,Rank),
			send_treasure_rank_mail(ActType, ActName, Uid, Rank, RewardItems)
	end.

send_treasure_rank_mail(_ActType, ActName, Uid, Rank, RewardItems) ->
	#mail_content{text = Content} = data_mail:data_mail(active_mail09),
	Content2 = util:format_lang(Content, [Rank]),
	mod_mail_new:sys_send_personal_mail(Uid, ActName, Content2, RewardItems, ?MAIL_TIME_LEN).	

%% ================================================================
%% =========================== 内部方法 ===========================
handle({update_ranklist, Uid, Sid, Num, ActivityRec, UsrActivityRec}) ->
	RankList = fun_agent_mng:get_global_value(recharge_point_rank_list, []),
	%% 积分相同时，最先抽的排前面
	NewList = lists:keystore(Uid, 1, RankList, {Uid, {Num, -UsrActivityRec#gm_activity_usr.act_time}}), 
	NewRankList = lists:reverse(lists:keysort(2, NewList)),
	fun_agent_mng:set_global_value(recharge_point_rank_list, NewRankList),
	send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec);
handle({add_total_point_num, Num}) ->
	fun_agent_mng:set_global_value(total_point_num, Num);
handle({clean_ranklist, RankList}) ->
	fun_agent_mng:set_global_value(recharge_point_rank_list, RankList).

get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	TotalPoint = fun_agent_mng:get_global_value(total_point_num, 0),
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	OwnPoint = fun_gm_activity_ex:get_list_data_by_key(own_point_num, ActData, 0),
	RankList = fun_agent_mng:get_global_value(recharge_point_rank_list, []),
	Fun = fun({Own, All, Rank, Need}) ->
		MaxLen = max(length(Rank), length(RankList)),
		#pt_public_act_recharge_point_des{
			need 			= Need,
			own_point 		= OwnPoint,
			all_point 		= TotalPoint,
			own_list		= get_own_reward_state_list_help(UsrActivityRec, OwnPoint, Own),
			total_list		= get_total_reward_state_list_help(UsrActivityRec, OwnPoint, TotalPoint, All),
			rank_list 		= make_rank_list_pt(RankList, [], 1, MaxLen, Rank)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

get_own_reward_state_list_help(UsrActivityRec, OwnPoint, Own) ->
	Fun = fun({OwnId, OwnNeed, OwnReward, OwnDesc}) ->
		CanOwn = case lists:member(OwnId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case OwnPoint >= OwnNeed of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_act_recharge_own_des{
			own_id 		= OwnId,
			own_point	= min(OwnPoint, OwnNeed),
			own_need 	= OwnNeed,
			own_reward 	= lists:map(fun fun_item_api:make_item_get_pt/1, OwnReward),
			own_desc 	= OwnDesc,
			can_own		= CanOwn
		}
	end,
	lists:map(Fun, Own).

get_total_reward_state_list_help(UsrActivityRec, OwnPoint, TotalPoint, All) ->
	Fun = fun({AllId, TotalNeed, AllNeed, AllReward, AllDesc}) ->
		CanAll = case lists:member(AllId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case OwnPoint >= AllNeed andalso TotalPoint >= TotalNeed of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_act_recharge_total_des{
			all_id 		= AllId,
			all_point	= min(OwnPoint, AllNeed),
			all_need 	= AllNeed,
			all_reward 	= lists:map(fun fun_item_api:make_item_get_pt/1, AllReward),
			all_desc 	= AllDesc,
			can_all		= CanAll
		}
	end,
	lists:map(Fun, All).

make_rank_list_pt([], Acc, RankNum, MaxLen, _Rank) when RankNum > MaxLen -> lists:reverse(Acc);
make_rank_list_pt([], Acc, RankNum, MaxLen, Rank) when RankNum =< MaxLen ->
	RankReward = case lists:keyfind(RankNum, 1, Rank) of
		{RankNum, Rewards, _} -> Rewards;
		_ -> []
	end, 
	Pt = #pt_public_act_recharge_ranklist_des{
		rank  		= RankNum,
		uid   		= 0,
		prof  		= 0,
		name  		= [],
		rank_reward = lists:map(fun fun_item_api:make_item_get_pt/1, RankReward),
		point 		= 0
	},
	make_rank_list_pt([], [Pt | Acc], RankNum + 1, MaxLen, Rank);
make_rank_list_pt([{Uid, {Point, _Time}} | Rest1], Acc, RankNum, MaxLen, Rank) ->
	RankReward = case lists:keyfind(RankNum, 1, Rank) of
		{RankNum, Rewards, _} -> Rewards;
		_ -> []
	end, 
	case db:dirty_get(usr, Uid) of
		[#usr{name = UsrName, prof = Prof}|_]-> ok;
		_ -> UsrName = "", Prof = 3
	end,
	Pt = #pt_public_act_recharge_ranklist_des{
		rank  		= RankNum,
		uid   		= Uid,
		prof  		= Prof,
		name  		= util:to_list(UsrName),
		rank_reward = lists:map(fun fun_item_api:make_item_get_pt/1, RankReward),
		point 		= Point
	},
	make_rank_list_pt(Rest1, [Pt | Acc], RankNum + 1, MaxLen, Rank).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_recharge_point:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_recharge_point:test_del_config() end).
% world_svr:debug_call(agent_mng, fun() -> fun_toplist:get_toplist_rank(14, 1000000999) end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?THIS_TYPE,
		act_name     = "name",
		type         = ?THIS_TYPE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		close_time   = util:unixtime() + 25000,
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
		[
			{1,1000,[{9002,100},{9002,100}],"個人建設度達到1000"},
			{2,2000,[{9002,90},{9002,90}],"個人建設度達到2000"},
			{3,3000,[{9002,80},{9002,80}],"個人建設度達到3000"}
		],
		[
			{11,1000,0,[{9002,100},{9002,100},{9002,100},{9002,100}],"全服總建設度達到100且個人建設達到0"},
			{12,2000,1000,[{9002,50},{9002,50},{9002,50},{9002,50}],"全服總建設度達到100且個人建設達到0"},
			{13,3000,2000,[{9002,30},{9002,30},{9002,30},{9002,30}],"全服總建設度達到100且個人建設達到0"},
			{14,4000,2500,[{9002,10},{9002,10},{9002,10},{9002,10}],"全服總建設度達到100且個人建設達到0"}
		],
		[
			{1,[{9002,100}],"第一名奖励"},
			{2,[{9002,90}],"第二名奖励"},
			{3,[{9002,80}],"第三名奖励"}
		],
		5000
	}].