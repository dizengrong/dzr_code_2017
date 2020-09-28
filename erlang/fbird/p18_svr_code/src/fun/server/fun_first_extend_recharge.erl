%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-4-11
%% Company : fbird.Co.Ltd
%% Desc : fun_first_extend_recharge
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_first_extend_recharge).
-include("common.hrl").
-export([req_first_extend_recharge_info/3,req_draw_rewards/4,put_recharge_time/2]).

get_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_recharge_extra_rewards) of
		[] -> #t_recharge_extra_rewards{uid = Uid};
		[Rec] -> Rec
	end.
set_data(Rec) ->
	mod_role_tab:insert(Rec#t_recharge_extra_rewards.uid, Rec).

%%获取该玩家充值多少次
get_recharge_time(Uid)->
	#t_recharge_extra_rewards{times=Times} = get_data(Uid),
	Times.

%%请求首次续次充值
req_first_extend_recharge_info(Sid,Uid,Seq)->
	send_recharge_info_to_sid(Sid,Uid,Seq).
			


%%获取奖励领取的状态
get_rewards_state(Uid)->
	#t_recharge_extra_rewards{recharge_rewards=RechargeRewards,times=Times} = get_data(Uid),
	if
		Times == 0 -> 
			{0, ?REWARD_STATE_NOT_REACHED};
		Times == RechargeRewards -> 
			{RechargeRewards, ?REWARD_STATE_FETCHED};
		Times > RechargeRewards -> 
			{RechargeRewards + 1, ?REWARD_STATE_CAN_FETCH};
		true -> 
			{0, ?REWARD_STATE_NOT_REACHED}
	end.


%%请求领取奖励
req_draw_rewards(Uid,Sid,DrawRewardsId,Seq)->
	RechargeTime = get_recharge_time(Uid),
	if RechargeTime >= DrawRewardsId->
		   {RewardsId,RewardsState}=get_rewards_state(Uid),
		   ?debug("RewardsId:~p, RewardsState:~p", [RewardsId, RewardsState]),
		   if DrawRewardsId  == RewardsId andalso RewardsState == ?REWARD_STATE_CAN_FETCH->
		   		Rec = get_data(Uid),
		   		{_, Money} = lists:keyfind(DrawRewardsId, 1, Rec#t_recharge_extra_rewards.charge_money_list), 
				[#ply{phone_type = PhoneType}] = db:dirty_get(ply, Uid),
		   		Box = data_charge_config:get_first_charge_reward(PhoneType, DrawRewardsId, Money),
				AddItems = fun_draw:box(Box, util:get_prof_by_uid(Uid)),
				AddItems2 = [{?ITEM_WAY_FIRST_EXTRA_RECHARGE, I, N, [{strengthen_lev, L}]} || {I, N, L} <- AddItems],
		   		SuccCallBack = fun() ->
		   			Rec2 = Rec#t_recharge_extra_rewards{recharge_rewards=DrawRewardsId},
		   			set_data(Rec2),
					req_first_extend_recharge_info(Sid, Uid, Seq),
					send_first_extend_recharge_to_sid(Sid, DrawRewardsId, AddItems, 0),
					do_broadcast(Uid, DrawRewardsId)
		   		end,
		   		fun_item_api:check_and_add_items(Uid, Sid, [], AddItems2, SuccCallBack, undefined);
			  true->skip
		   end;
	   true->skip
	end.

do_broadcast(Uid, DrawRewardsId) ->
	Id = case DrawRewardsId of
		1 -> 213;
		2 -> 573;
		3 -> 574;
		_ -> 0
	end,
	case Id > 0 of
		true -> fun_item:send_private_system_msg(Uid,Id);
		false -> skip
	end.

put_recharge_time(Uid, Money)->
	Rec = get_data(Uid),
	MaxTimes = data_charge_config:max_first_charge_times(),
	NewTimes = min(MaxTimes, Rec#t_recharge_extra_rewards.times+1),
	Rec2 = Rec#t_recharge_extra_rewards{
		times = NewTimes,
		charge_money_list = lists:sublist(lists:reverse([{NewTimes, Money} | Rec#t_recharge_extra_rewards.charge_money_list]), NewTimes)
	},
	set_data(Rec2),
	req_first_extend_recharge_info(util:get_sid_by_uid(Uid), Uid, 0).

%%发送到客户端
send_recharge_info_to_sid(Sid,Uid,Seq)->
	#t_recharge_extra_rewards{times=RechargeTime,charge_money_list = MoneyList} = get_data(Uid),
	{RewardsId, RewardsState}=get_rewards_state(Uid),
	case RewardsId of
		0 -> Money = 0;
		_ -> {_, Money} = lists:keyfind(RewardsId, 1, MoneyList)
	end,
	Pt = #pt_first_recharge{
		recharge_time       = RechargeTime,
		recharge_draw_id    = RewardsId,
		recharge_draw_money = Money,
		recharge_draw_state = RewardsState
	},
	?send(Sid,proto:pack(Pt,Seq)).

send_first_extend_recharge_to_sid(Sid,RewardsId,AddItems,Seq)->
	Pt = #pt_first_extend_recharge{
		recharge_succeed_id=RewardsId,
		rewards = fun_item_api:make_item_pt_list(AddItems)
	},
	?send(Sid,proto:pack(Pt,Seq)).