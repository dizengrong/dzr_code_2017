%% @doc gm活动：地精宝藏
-module(gm_act_treasure).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_TREASURE).

-define(RECORDS_TYPE_ALL    , 1).  %% 所有记录
-define(RECORDS_TYPE_ADD_NEW, 2).  %% 新增一条记录

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	ONE_TIMES_COST     = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "one_times_cost")), 
	TEN_TIMES_COST     = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "ten_times_cost")), 
	ONE_TIMES_ITEMS    = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "one_times_items"))), 
	TEN_TIMES_ITEMS    = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "ten_times_items"))), 
	RAND_ITEMS         = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "rand_items"))), 
	RANK_REWARD        = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "rank_reward"))), 
	ALL_PEOPLE_WELFARE = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "exchange"))), 
	[{one_times_cost, ONE_TIMES_COST},
	 {ten_times_cost, TEN_TIMES_COST},
	 {one_times_items, ONE_TIMES_ITEMS},
	 {ten_times_items, TEN_TIMES_ITEMS},
	 {rand_items, RAND_ITEMS},
	 {rank_reward, RANK_REWARD},
	 {exchange, ALL_PEOPLE_WELFARE}].

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	MyTimes          = fun_gm_activity_ex:get_list_data_by_key(open_times, UsrActivityRec#gm_activity_usr.act_data, 0),
	OneTimesCost     = fun_gm_activity_ex:get_list_data_by_key(one_times_cost, ActivityRec#gm_activity.reward_datas, 0),
	TenTimesCost     = fun_gm_activity_ex:get_list_data_by_key(ten_times_cost, ActivityRec#gm_activity.reward_datas, 0),
	OneTimesItems    = fun_gm_activity_ex:get_list_data_by_key(one_times_items, ActivityRec#gm_activity.reward_datas, []),
	TenTimesItems    = fun_gm_activity_ex:get_list_data_by_key(ten_times_items, ActivityRec#gm_activity.reward_datas, []),
	RandItems        = fun_gm_activity_ex:get_list_data_by_key(rand_items, ActivityRec#gm_activity.reward_datas, []),
	Exchanges = fun_gm_activity_ex:get_list_data_by_key(exchange, ActivityRec#gm_activity.reward_datas, []),
	RankRewardList   = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	TotalTimes = fun_agent_mng:get_global_value(gm_act_open_treasure_times, 0),
	% ?debug("OneTimesCost:~p", [OneTimesCost]),
	Fun1 = fun({Id, NeedItem, NeedNum, GainItem, GainNum}) ->
		#pt_public_treasure_exchange_des{
			id        = Id,
			need_item = NeedItem,
			need_num  = NeedNum,
			gain_item = GainItem,
			gain_num  = GainNum
		}
	end,
	Fun2 = fun({BeginRank, EndRank, NeedTimes, Items, Desc}) ->
		#pt_public_treasure_rank_reward_des{
			begin_rank = BeginRank,
			end_rank   = EndRank,
			need_times = NeedTimes,
			items      = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
			desc       = Desc
		}
	end,
	RankingList = fun_agent_mng:get_global_value(treasure_rank_list, []),
	RankingList2 = make_treasure_rank_pt(RankingList, [], 1),
	MyRank = case lists:keyfind(Uid, #pt_public_treasure_ranking_des.uid, RankingList2) of
		false -> 0;
		#pt_public_treasure_ranking_des{rank = Rank} -> Rank
	end,
	Pt = #pt_gm_act_treasure{
		startTime 		= ActivityRec#gm_activity.start_time,
		endTime   		= ActivityRec#gm_activity.end_time,
		desc      		= ActivityRec#gm_activity.act_des,
		my_rank         = MyRank,
		my_times        = MyTimes,
		all_times       = TotalTimes,
		one_times_cost  = OneTimesCost,
		ten_times_cost  = TenTimesCost,
		one_times_items = lists:map(fun fun_item_api:make_item_get_pt/1, OneTimesItems),
		ten_times_items = lists:map(fun fun_item_api:make_item_get_pt/1, TenTimesItems),
		rand_items      = lists:map(fun fun_item_api:make_item_get_pt/1, [{I, N} || {I, N, _, _} <- RandItems]),
		exchange        = [Fun1(R) || R <- Exchanges],
		rank_reward     = [Fun2(R) || R <- RankRewardList],
		ranking_list    = RankingList2
	},
	?send(Sid, proto:pack(Pt)).

do_exchange(Uid, Sid, Id, Num) ->
	case fun_gm_activity_ex:find_open_activity(?THIS_TYPE) of
		false -> 
			?error_report(Sid, "error_activity_expired");
		{true, ActivityRec} ->
			Setting = ActivityRec#gm_activity.reward_datas,
			List = fun_gm_activity_ex:get_list_data_by_key(exchange, Setting, []),
			case lists:keyfind(Id, 1, List) of
				false -> 
					?debug("gm_act_treasure exchange id:~p is not right", [Id]);
				{_, NeedItem, NeedNum, GainItem, GainNum} ->
					AddItems = [{?ITEM_WAY_GM_ACT_TREASURE_EXCHANGE, GainItem, GainNum * Num}],
					SpendItems = [{?ITEM_WAY_GM_ACT_TREASURE_EXCHANGE, NeedItem, NeedNum * Num}],
					SuccCallBack = fun() ->
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, [{GainItem, GainNum * Num}])
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, undefined)
			end
	end.

%% 请求抽奖记录	
req_records(Uid, Sid, _Seq) ->
	case fun_gm_activity_ex:find_open_activity(?THIS_TYPE) of
		false -> 
			?error_report(Sid, "error_activity_expired");
		{true, _ActivityRec} ->
			List = fun_agent_mng:get_global_value(gm_act_treasure_records, []),
			send_treasure_records(Uid, Sid, ?RECORDS_TYPE_ALL, List)
	end.

send_treasure_records(_Uid, Sid, Type, List) ->
	Fun = fun({Name, Item}) ->
		#pt_public_treasure_record_des{
			name = Name,
			item = Item
		}
	end, 
	Pt  = #pt_gm_act_treasure_record{type = Type, records = [Fun(E) || E <- List]},
	?send(Sid, proto:pack(Pt)).

get_open_treasure_spend(Uid, Type, CostDiamond) ->
	Num = fun_item:get_item_num_by_type(Uid, 8002),
	case Type of
		1 -> 
			case Num > 0 of
				false -> [{?ITEM_WAY_GM_ACT_OPEN_TREASURE, ?RESOUCE_COIN_NUM, CostDiamond}];
				true -> [{?ITEM_WAY_GM_ACT_OPEN_TREASURE, 8002, 1}]
			end;
		_ -> [{?ITEM_WAY_GM_ACT_OPEN_TREASURE, ?RESOUCE_COIN_NUM, CostDiamond}]
	end.

open_treasure(Uid, Sid, Type) ->
	ActType = ?THIS_TYPE,
	case fun_gm_activity_ex:find_open_activity(ActType) of
		false -> 
			?error_report(Sid, "error_activity_expired");
		{true, ActivityRec} ->
			Setting = ActivityRec#gm_activity.reward_datas,
			{EnsureItems, RandItems} = rand_treasure_items(Type, Setting),
			Way          = get_reward_way(),
			EnsureItems2 = [{Way, Item, N} || {Item, N} <- EnsureItems],
			RandItems2   = [{Way, Item, N} || {Item, N, _} <- RandItems],
			AddItems     = EnsureItems2 ++ RandItems2,
			CostDiamond  = get_open_treasure_cost(Type, Setting),
			SpendItems = get_open_treasure_spend(Uid, Type, CostDiamond),
			SuccCallBack = fun() ->
				UsrActivityRec  = fun_gm_activity_ex:get_usr_activity_data(Uid, ActType),
				ActData         = UsrActivityRec#gm_activity_usr.act_data,
				OpenTimes       = fun_gm_activity_ex:get_list_data_by_key(open_times, ActData, 0),
				AddTimes        = get_open_treasure_times(Type),
				OpenTimes2      = OpenTimes + AddTimes,
				ActData2        = lists:keystore(open_times, 1, ActData, {open_times, OpenTimes2}),
				UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2},

				UsrActivityRec3 = case UsrActivityRec2#gm_activity_usr.act_time of
					0 -> UsrActivityRec2#gm_activity_usr{act_time = util_time:unixtime()};
					_ -> UsrActivityRec2
				end,
				fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec3),

				add_total_open_treasure_times(Uid, Sid, RandItems, AddTimes),
				[do_broadcast_open_treasure(Uid, I) || I <- RandItems],
				ranking_open_treasure(),
				
				fun_gm_activity_ex:send_info_to_client(Uid, Sid, ActType),
				% ?debug("AddItems:~p", [AddItems]),
				ShowList = [{T, N} || {_, T, N} <- AddItems],
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, ShowList),
				ok
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, undefined)
	end.

add_total_open_treasure_times(Uid, Sid, RandItems, AddTimes) ->
	mod_msg:handle_to_agnetmng(?MODULE, {add_total_open_treasure_times, Uid, Sid, RandItems, AddTimes}),
	ok.

handle({add_total_open_treasure_times, Uid, Sid, RandItems, AddTimes}) ->
	Times = fun_agent_mng:get_global_value(gm_act_open_treasure_times, 0),
	fun_agent_mng:set_global_value(gm_act_open_treasure_times, Times + AddTimes),
	List = fun_agent_mng:get_global_value(gm_act_treasure_records, []),
	Name = util:get_name_by_uid(Uid),
	List2 = add_treasure_record(Uid, Sid, Name, RandItems, List),
	fun_agent_mng:set_global_value(gm_act_treasure_records, List2),
	ok.	

add_treasure_record(_Uid, _Sid, _Name, [], List) -> List;
add_treasure_record(Uid, Sid, Name, [{Item, _N, 1} | RandItems], List) ->
	case length(List) >= 10 of
		true ->
			List2 = tl(List) ++ [{Name, Item}],
			send_add_treasure_record(Uid, Sid, Name, Item),
			add_treasure_record(Uid, Sid, Name, RandItems, List2);
		false ->
			send_add_treasure_record(Uid, Sid, Name, Item),
			add_treasure_record(Uid, Sid, Name, RandItems, List ++ [{Name, Item}])
	end;
add_treasure_record(Uid, Sid, Name, [_ | RandItems], List) ->
	add_treasure_record(Uid, Sid, Name, RandItems, List).

send_add_treasure_record(Uid, Sid, Name, Item) ->
	?debug("-------"),
	send_treasure_records(Uid, Sid, ?RECORDS_TYPE_ADD_NEW, [{Name, Item}]).


do_broadcast_open_treasure(_, _) -> 
	ok.


get_open_treasure_cost(1, Setting) ->
	fun_gm_activity_ex:get_list_data_by_key(one_times_cost, Setting, 10000);
get_open_treasure_cost(2, Setting) ->
	fun_gm_activity_ex:get_list_data_by_key(ten_times_cost, Setting, 1000000).

rand_treasure_items(Type, Setting) ->
	EnsureKey = case Type of
		1 -> one_times_items;
		2 -> ten_times_items
	end,
	List        = fun_gm_activity_ex:get_list_data_by_key(rand_items, Setting, []),
	List2       = [{{Item, N, BroadCast}, Weight} || {Item, N, Weight, BroadCast} <- List],
	RandItems   = [element(1, util:random_from_tuple_weights(List2, 2)) || _ <- lists:seq(1, get_open_treasure_times(Type))],
	EnsureItems = fun_gm_activity_ex:get_list_data_by_key(EnsureKey, Setting, []),
	{EnsureItems, RandItems}.	

get_open_treasure_times(1) -> 1;
get_open_treasure_times(2) -> 10.

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_TREASURE.


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
			Pt = #pt_gm_act_treasure{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_treasure_rank_reward(ActivityRec) ->
	ranking_open_treasure(ActivityRec),
	RankingList    = fun_agent_mng:get_global_value(treasure_rank_list, []),
	RankingList2   = make_treasure_rank_pt(RankingList, [], 1),
	% ?debug("RankingList2:~p", [RankingList2]),
	RankRewardList = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	% ?debug("RankRewardList:~p", [RankRewardList]),
	[do_treasure_rank_reward2(ActivityRec, RankData, RankRewardList) || RankData <- RankingList2],

	%% 发奖励结束就清除排行数据
	set_treasure_rank_list([]), 
	fun_agent_mng:set_global_value(gm_act_open_treasure_times, 0),	
	fun_agent_mng:set_global_value(gm_act_treasure_records, []),	
	ok.	

do_treasure_rank_reward2(ActivityRec, RankData, RankRewardList) ->
	#pt_public_treasure_ranking_des{
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
	#mail_content{text = Content} = data_mail:data_mail(title4),
	Content2 = util:format_lang(Content, [Rank]),
	mod_mail_new:sys_send_personal_mail(Uid, ActName, Content2, RewardItems, ?MAIL_TIME_LEN).


find_treasure_rank_reward(_Rank, _Times, []) -> false;
find_treasure_rank_reward(Rank, Times, [{_BeginRank, EndRank, NeedTimes, Items, _} | Rest]) ->
	case  Rank =< EndRank andalso Times >= NeedTimes of
		true -> {true, Items};
		false -> find_treasure_rank_reward(Rank, Times, Rest)
	end.

ranking_open_treasure() ->
	ActType = ?THIS_TYPE,
	case fun_gm_activity_ex:find_open_activity(ActType) of
		{true, ActivityRec} ->
			ranking_open_treasure(ActivityRec);
		_ -> 
			skip
	end.

ranking_open_treasure(ActivityRec) ->
	ActType = ActivityRec#gm_activity.type,
	{Len, MinTimes} = get_treasure_rank_length(ActivityRec),
	List = db:dirty_match(gm_activity_usr, #gm_activity_usr{_ = '_', type = ActType}),
	Fun = fun(Rec, Acc) -> 
		UsrActivityRec = fun_gm_activity_ex:usr_activity_rec_2_erl_format(Rec),
		OpenTimes = fun_gm_activity_ex:get_list_data_by_key(open_times, UsrActivityRec#gm_activity_usr.act_data, 0),
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
	fun_agent_mng:set_global_value(treasure_rank_list, RankList).
get_treasure_rank_list() -> 
	fun_agent_mng:get_global_value(treasure_rank_list, []).


make_treasure_rank_pt([], Acc, _Rank) -> lists:reverse(Acc);
make_treasure_rank_pt([{Uid, {Times, _Time}} | Rest1], Acc, Rank) ->
	case db:dirty_get(usr, Uid) of
		[#usr{name = UsrName, prof = Prof}|_]-> ok;
		_ -> UsrName = "", Prof = 3
	end,
	Pt = #pt_public_treasure_ranking_des{
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
% world_svr:debug_call(agent_mng, fun() -> gm_act_treasure:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_treasure:test_del_config() end).
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
		{one_times_cost, 100}, %% 抽一次消耗非绑元宝数
		{ten_times_cost, 900}, %% 抽十次消耗非绑元宝数
		{one_times_items, [{5004, 1}]}, %% 单次必给道具
		{ten_times_items, [{5004, 10}]}, %% 10连抽必给道具
		%% 抽奖随机道具
		{rand_items, [
			%% {道具id, 数量, 权重, 是否公告}
			{110, 1, 100, 1},
			{111, 1, 100, 1},
			{112, 1, 100, 1},
			{113, 1, 100, 1},
			{114, 1, 100, 1},
			{115, 1, 100, 1},
			{116, 1, 100, 1},
			{11000, 1, 100, 1},
			{11001, 1, 100, 1},
			{11002, 1, 100, 1},
			{11003, 1, 100, 1}
		]},
		%% 抽奖次数排名奖励
		{rank_reward, [
			%% {开始名次, 结束名次, 要求次数, 奖励}
			{1, 1, 100, [{110, 1}], "奖励描述"},
			{2, 2, 80, [{110, 1}], "奖励描述"},
			{3, 3, 50, [{110, 1}], "奖励描述"},
			{4, 10, 0, [{110, 1}], "奖励描述"}
		]},
		%% 兑换
		{exchange, [
			{1, 2, 100, 5004, 10},
			{2, 2, 200, 5003, 10}
		]}
	].
