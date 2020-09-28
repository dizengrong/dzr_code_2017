%% @doc gm活动：神秘礼包
-module (gm_act_mystery_gift).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_MYSTERY_GIFT).


%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	GiftId      = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "id")),
	GiftType    = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "type")),
	GiftName    = util:to_list(fun_gm_activity_ex:get_json_value(KvList, "name")),
	OriginGold  = util:to_list(fun_gm_activity_ex:get_json_value(KvList, "originalPrice")),
	CurrentGold = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "presentPrice")),
	NeedStage   = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "checkpoint")),
	DiscountDes = util:to_list(fun_gm_activity_ex:get_json_value(KvList, "discount")),
	BackPic	    = util:to_list(fun_gm_activity_ex:get_json_value(KvList, "background")),
	Reward      = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	{GiftId, GiftType, GiftName, OriginGold, CurrentGold, NeedStage, DiscountDes, Reward, BackPic}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.


on_pass_copy(Uid, Sid) ->
	case fun_gm_activity_ex:find_open_activity(?THIS_TYPE) of 
		false -> skip;
		{true, ActivityRec} ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?THIS_TYPE),
			send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec)
	end.


%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_mystery_gift_info{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = util:to_list(ActivityRec#gm_activity.act_des),
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_MYSTERY_GIFT.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	RewardDatas = ActivityRec#gm_activity.reward_datas,
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	case lists:keyfind(RewardId, 1, RewardDatas) of
		{_GiftId, GiftType, _GiftName, _OriginGold, CurrentGold, NeedStage, _DiscountDes, Reward, _BackPic} -> 
			case lists:keyfind(GiftType, 1, FetchData) of
				{GiftType, FetchId} when FetchId >= RewardId -> {error, "error_fetch_reward_already_fetched"};
				_ ->
					case NeedStage =< mod_scene_lev:get_curr_scene_lv(Uid) of
						true ->
							FetchData2 = lists:keystore(GiftType, 1, FetchData, {GiftType, RewardId}),
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, Reward),
							SpendItems = [{?ITEM_WAY_GM_ACT_MYSTERY_GIFT, ?RESOUCE_COIN_NUM, CurrentGold}],
							{ok, UsrActivityRec2, RewardItem, SpendItems};
						_ -> {error, "error_fetch_reward_not_reached"}
					end
			end;
		_ -> {error, "error_fetch_reward_not_reached"}
	end.


%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_mystery_gift_info{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.


%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(Uid, ActivityRec, UsrActivityRec) ->
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Fun = fun({GiftId, GiftType, GiftName, OriginGold, CurrentGold, NeedStage, DiscountDes, Reward, BackPic}, Acc) ->
		case lists:keyfind(GiftType, #pt_public_mystery_gift_info_des.type, Acc) of
			false ->
				case lists:keyfind(GiftType, 1, FetchData) of
					{GiftType, FetchId} when FetchId >= GiftId -> Acc;
					_ ->
						State = case mod_scene_lev:get_curr_scene_lv(Uid) >= NeedStage of
							true  -> ?REWARD_STATE_CAN_FETCH;
							false -> ?REWARD_STATE_NOT_REACHED
						end,
						Pt = #pt_public_mystery_gift_info_des{
							id            = GiftId,
							type          = GiftType,
							gift_name     = GiftName,
							originalPrice = OriginGold,
							presentPrice  = CurrentGold,
							checkpoint    = NeedStage,
							discount      = DiscountDes,
							status        = State,
							backpic 	  = BackPic,
							reward_list   = lists:map(fun fun_item_api:make_item_get_pt/1, Reward)
						},
						[Pt | Acc]
				end;
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], ActivityRec#gm_activity.reward_datas).


handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).
