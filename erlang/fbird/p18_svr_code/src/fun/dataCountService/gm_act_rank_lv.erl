%% @doc gm活动：等级排行榜活动
-module (gm_act_rank_lv).

-include("common.hrl").
-compile([export_all]).

-define(RECORDS_TYPE_ALL    , 1).  %% 所有记录
-define(RECORDS_TYPE_ADD_NEW, 2).  %% 新增一条记录

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	RANK_REWARD = fun_gm_activity_ex:string_to_term( util:to_list(fun_gm_activity_ex:get_json_value(KvList, "rankingreward"))), 
	[{rank_reward, RANK_REWARD}].

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, _UsrActivityRec) ->
	% RankingList  = fun_toplist:get_top_list(?RANKLIST_LEV),
	RankingList = [],
	RankRewardList = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	Fun2 = fun({BeginRank, EndRank, Items, Desc}) ->
		#pt_public_lv_rank_reward_des{
			begin_rank = BeginRank,
			end_rank   = EndRank,
			items      = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
			desc       = Desc
		}
	end,
	RankingList2 = make_rank_pt(RankingList, [], 1),
	MyRank = case lists:keyfind(Uid, #pt_public_gm_act_lv_rank_des.uid, RankingList2) of
		false -> 0;
		#pt_public_gm_act_lv_rank_des{rank = Rank} -> Rank
	end,
	Pt = #pt_gm_act_lv_rank{
		startTime 	 = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   	 = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc         = ActivityRec#gm_activity.act_des,
		my_rank      = MyRank,
		rank_reward  = [Fun2(R) || R <- RankRewardList],
		ranking_list = RankingList2
	},
	?send(Sid, proto:pack(Pt)).


%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_lv_rank{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_rank_reward(ActivityRec) ->
	% RankingList  = fun_toplist:get_top_list(?RANKLIST_LEV),
	RankingList = [],
	RankingList2 = make_rank_pt(RankingList, [], 1),
	% ?debug("RankingList2:~p", [RankingList2]),
	RankRewardList = fun_gm_activity_ex:get_list_data_by_key(rank_reward, ActivityRec#gm_activity.reward_datas, []),
	% ?debug("RankRewardList:~p", [RankRewardList]),
	[do_treasure_rank_reward2(ActivityRec, RankData, RankRewardList) || RankData <- RankingList2],

	ok.	

do_treasure_rank_reward2(ActivityRec, RankData, RankRewardList) ->
	#pt_public_gm_act_lv_rank_des{
		uid  = Uid,
		rank = Rank,
		lv   = Lv
	} = RankData,
	case find_treasure_rank_reward(Rank, Lv, RankRewardList) of
		false -> skip;
		{true, Items} ->
			ActName = ActivityRec#gm_activity.act_name,
			ActType = ActivityRec#gm_activity.type,
			fun_dataCount_update:gm_activity_rank(Uid,ActType,Rank),
			send_treasure_rank_mail(ActType, ActName, Uid, Rank, Items)
	end.

send_treasure_rank_mail(_ActType, _ActName, Uid, Rank, RewardItems) ->
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(lv_list),
	Content2 = io_lib:format(Content, [Rank]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, RewardItems, ?MAIL_TIME_LEN).	


find_treasure_rank_reward(_Rank, _Times, []) -> false;
find_treasure_rank_reward(Rank, Times, [{_BeginRank, EndRank, Items, _} | Rest]) ->
	case  Rank =< EndRank of
		true -> {true, Items};
		false -> find_treasure_rank_reward(Rank, Times, Rest)
	end.

make_rank_pt([], Acc, _Rank) -> lists:reverse(Acc);
make_rank_pt([{Uid,Lev,{UsrName,_Camp,_ParagonLev}} | Rest1], Acc, Rank) ->
	Pt = #pt_public_gm_act_lv_rank_des{
		rank  = Rank,
		uid   = Uid,
		prof  = 0,
		name  = util:to_list(UsrName),
		lv = Lev
	},
	make_rank_pt(Rest1, [Pt | Acc], Rank + 1).

%% ================================================================
%% =========================== 内部方法 ===========================

