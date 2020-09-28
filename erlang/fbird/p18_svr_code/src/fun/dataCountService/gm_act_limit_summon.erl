%% @doc gm活动：限时推荐召唤
-module(gm_act_limit_summon).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_LIMIT_SUMMON).

-define(RECORDS_TYPE_ALL    , 1).  %% 所有记录
-define(RECORDS_TYPE_ADD_NEW, 2).  %% 新增一条记录

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	RANK_REWARD        = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "rank_reward"))), 
	[{rank_reward, RANK_REWARD}].

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	MyTimes          = fun_gm_activity_ex:get_list_data_by_key(limit_summon_open_times, UsrActivityRec#gm_activity_usr.act_data, 0),
	RankRewardList   = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	Fun = fun({BeginRank, EndRank, NeedTimes, Items, Desc}) ->
		#pt_public_limit_summon_rank_reward_des{
			begin_rank = BeginRank,
			end_rank   = EndRank,
			need_times = NeedTimes,
			items      = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
			desc       = Desc
		}
	end,
	RankingList = fun_agent_mng:get_global_value(limit_summon_rank_list, []),
	RankingList2 = make_treasure_rank_pt(RankingList, [], 1),
	MyRank = case lists:keyfind(Uid, #pt_public_limit_summon_ranking_des.uid, RankingList2) of
		false -> 0;
		#pt_public_limit_summon_ranking_des{rank = Rank} -> Rank
	end,
	Pt = #pt_gm_act_limit_summon{
		startTime 		= ActivityRec#gm_activity.start_time,
		endTime   		= ActivityRec#gm_activity.end_time,
		desc      		= ActivityRec#gm_activity.act_des,
		my_rank         = MyRank,
		my_times        = MyTimes,
		rank_reward     = [Fun(R) || R <- RankRewardList],
		ranking_list    = RankingList2
	},
	?send(Sid, proto:pack(Pt)).

open_treasure(Uid, Sid, Times) ->
	ActType = ?THIS_TYPE,
	case fun_gm_activity_ex:find_open_activity(ActType) of
		false -> 
			?error_report(Sid, "error_activity_expired");
		{true, _ActivityRec} ->
				UsrActivityRec  = fun_gm_activity_ex:get_usr_activity_data(Uid, ActType),
				ActData         = UsrActivityRec#gm_activity_usr.act_data,
				OpenTimes       = fun_gm_activity_ex:get_list_data_by_key(limit_summon_open_times, ActData, 0),
				AddTimes        = Times,
				OpenTimes2      = OpenTimes + AddTimes,
				ActData2        = lists:keystore(limit_summon_open_times, 1, ActData, {limit_summon_open_times, OpenTimes2}),
				UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},

				UsrActivityRec3 = case UsrActivityRec2#gm_activity_usr.act_time of
					0 -> UsrActivityRec2#gm_activity_usr{act_time = util_time:unixtime()};
					_ -> UsrActivityRec2
				end,
				fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec3),
				ranking_open_times(),
				fun_gm_activity_ex:send_info_to_client(Uid, Sid, ActType),
				ok
	end.

%% 领取奖励的item_way日志
get_reward_way() -> ok.


%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	case lists:keyfind(RewardId, #pt_public_acc_recharge_des.need_diamond, StateList) of
		false -> {error, "error_fetch_reward_not_reached"};
		#pt_public_acc_recharge_des{state = ?REWARD_STATE_CAN_FETCH, products = RewardItems} ->
			FetchData       = UsrActivityRec#gm_activity_usr.fetch_data,
			FetchData2      = [RewardId | FetchData],
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
			{ok, UsrActivityRec2, RewardItems};
		_ -> 
			{error, "error_fetch_reward_not_reached"}
	end.

%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_limit_summon{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_treasure_rank_reward(ActivityRec) ->
	ranking_open_times(ActivityRec),
	RankingList    = fun_agent_mng:get_global_value(limit_summon_rank_list, []),
	RankingList2   = make_treasure_rank_pt(RankingList, [], 1),
	% ?debug("RankingList2:~p", [RankingList2]),
	RankRewardList = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	% ?debug("RankRewardList:~p", [RankRewardList]),
	[do_treasure_rank_reward2(ActivityRec, RankData, RankRewardList) || RankData <- RankingList2],

	%% 发奖励结束就清除排行数据
	set_treasure_rank_list([]), 
	ok.	

do_treasure_rank_reward2(ActivityRec, RankData, RankRewardList) ->
	#pt_public_limit_summon_ranking_des{
		uid   = Uid,
		rank  = Rank,
		times = Times
	} = RankData,
	case find_treasure_rank_reward(Rank, Times, RankRewardList) of
		false -> skip;
		{true, Items} ->
			ActName = ActivityRec#gm_activity.act_name,
			ActType = ActivityRec#gm_activity.type,
			fun_dataCount_update:gm_activity_rank(Uid,ActType,Rank),
			send_treasure_rank_mail(ActType, ActName, Uid, Rank, Items)
	end.

send_treasure_rank_mail(_ActType, ActName, Uid, Rank, RewardItems) ->
	#mail_content{text = Content} = data_mail:data_mail(title3),
	Content2 = util:format_lang(Content, [Rank]),
	mod_mail_new:sys_send_personal_mail(Uid, ActName, Content2, RewardItems, ?MAIL_TIME_LEN).	


find_treasure_rank_reward(_Rank, _Times, []) -> false;
find_treasure_rank_reward(Rank, Times, [{_BeginRank, EndRank, NeedTimes, Items, _} | Rest]) ->
	case  Rank =< EndRank andalso Times >= NeedTimes of
		true -> {true, Items};
		false -> find_treasure_rank_reward(Rank, Times, Rest)
	end.

ranking_open_times() ->
	ActType = ?THIS_TYPE,
	case fun_gm_activity_ex:find_open_activity(ActType) of
		{true, ActivityRec} ->
			ranking_open_times(ActivityRec);
		_ -> 
			skip
	end.

ranking_open_times(ActivityRec) ->
	ActType = ActivityRec#gm_activity.type,
	{Len, MinTimes} = get_treasure_rank_length(ActivityRec),
	List = db:dirty_match(gm_activity_usr, #gm_activity_usr{_ = '_', type = ActType}),
	Fun = fun(Rec, Acc) -> 
		UsrActivityRec = fun_gm_activity_ex:usr_activity_rec_2_erl_format(Rec),
		OpenTimes = fun_gm_activity_ex:get_list_data_by_key(limit_summon_open_times, UsrActivityRec#gm_activity_usr.act_data, 0),
		%% 次数相同时，最先抽的排前面
		case OpenTimes >= MinTimes of
			true  -> [{UsrActivityRec#gm_activity_usr.uid, {OpenTimes, -UsrActivityRec#gm_activity_usr.act_time}} | Acc];
			false -> Acc
		end
	end,
	List2 = lists:foldl(Fun, [], List),

	RankList = lists:sublist(lists:reverse(lists:keysort(2, List2)), Len),
	set_treasure_rank_list(RankList),
	{ok, ActivityRec, RankList}.

get_treasure_rank_length(ActivityRec) ->
	List = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	case List of
		[] -> {0, 0};
		_ -> 
			{_, MaxLen, MinTimes, _, _} = lists:last(List),
			{MaxLen, MinTimes}
	end.

set_treasure_rank_list(RankList) -> 
	fun_agent_mng:set_global_value(limit_summon_rank_list, RankList).
get_treasure_rank_list() -> 
	fun_agent_mng:get_global_value(limit_summon_rank_list, []).


make_treasure_rank_pt([], Acc, _Rank) -> lists:reverse(Acc);
make_treasure_rank_pt([{Uid, {Times, _Time}} | Rest1], Acc, Rank) ->	
	case db:dirty_get(usr, Uid) of
		[#usr{name = UsrName, prof = Prof}|_]-> ok;
		_ -> UsrName = "", Prof = 3
	end,
	Pt = #pt_public_limit_summon_ranking_des{
		rank  = Rank,
		uid   = Uid,
		prof  = Prof,
		name  = util:to_list(UsrName),
		times = Times
	},
	make_treasure_rank_pt(Rest1, [Pt | Acc], Rank + 1).

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(Uid, ActivityRec, UsrActivityRec) ->
	StartTime     = ActivityRec#gm_activity.start_time,
	EndTime       = ActivityRec#gm_activity.end_time,
	TotalRecharge = fun_recharge:get_total_recharge_by_time(Uid, StartTime, EndTime),
	Fun = fun({NeedDiamond, Items, Sort, SortDesc, Desc}) ->
		State = case lists:member(NeedDiamond, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				?_IF(TotalRecharge >= NeedDiamond, ?REWARD_STATE_CAN_FETCH, ?REWARD_STATE_NOT_REACHED);
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_acc_recharge_des{
			sort             = Sort,
			need_diamond     = NeedDiamond,
			recharge_diamond = TotalRecharge,
			state            = State,
			sort_desc        = SortDesc,
			desc             = Desc,
			products         = lists:map(fun fun_item_api:make_item_get_pt/1, Items)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).


%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_limit_summon:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_limit_summon:test_del_config() end).
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
	[
		%% 抽奖次数排名奖励
		{rank_reward, [
			%% {开始名次, 结束名次, 要求次数, 奖励}
			{1, 1, 100, [{2, 1}], "奖励描述"},
			{2, 2, 80, [{2, 1}], "奖励描述"},
			{3, 3, 50, [{2, 1}], "奖励描述"},
			{4, 10, 0, [{2, 1}], "奖励描述"}
		]}
	].
