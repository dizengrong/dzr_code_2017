%% @doc gm活动：限时秒杀
-module (gm_act_sale).
-include("common.hrl").
-compile([export_all]).

-define(SALE_SORT_BUY   , 1).  %% 限时购买
-define(SALE_SORT_RETURN, 2).  %% 限时购买返利

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id            = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "server_id")), 
	ClientId      = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "client_id")), 
	Sort          = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "sort")), 
	TabTitle      = fun_gm_activity_ex:get_json_value(KvList, "tab_title"), 
	Items         = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	OriginalPrice = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "original_price")), 
	PresentPrice  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "present_price")), 
	ExchangeCost  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "already_consumed")), 
	Limit         = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "limit")), 
	{Id, ClientId, Sort, TabTitle, Items, OriginalPrice, PresentPrice, ExchangeCost, Limit}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	TotalScore = fun_gm_activity_ex:get_list_data_by_key(exchange_score, ActData, 0),
	Pt = #pt_gm_act_sale{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des,
		exchange_score = TotalScore,
		datas          = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).	

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_SALE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, _UsrActivityRec, _ActivityRec, RewardId0) when (RewardId0 rem 100) == 0 -> 
	{error, "check_data_error"};
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId0) ->
	case RewardId0 > 100 of
		true -> 
			RewardId = RewardId0 div 100,
			Num = RewardId0 rem 100;
		_ ->
			Num = 1,
			RewardId = RewardId0
	end,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	case lists:keyfind(RewardId, #pt_public_gm_act_sale_des.id, StateList) of
		#pt_public_gm_act_sale_des{state = ?REWARD_STATE_CAN_FETCH, items = Items, sort = Sort, present_price = Price, left_times = LeftTimes} ->
			FetchData  = UsrActivityRec#gm_activity_usr.fetch_data,
			ActData    = UsrActivityRec#gm_activity_usr.act_data,
			Num2       = min(LeftTimes, Num),
			Tuple      = {RewardId, fun_gm_activity_ex:get_list_data_by_key(RewardId, FetchData, 0) + Num2},
			FetchData2 = lists:keystore(RewardId, 1, FetchData, Tuple),
			ActData2 = case Sort of
				?SALE_SORT_BUY -> 
					Items2 = [P#pt_public_item_list{item_num = N*Num2} || P = #pt_public_item_list{item_num=N} <- Items],
					SpendItems = [{get_reward_way(), ?RESOUCE_COIN_NUM, Price*Num2}],
					TotalScore = fun_gm_activity_ex:get_list_data_by_key(exchange_score, ActData, 0),
					TotalScore2 = TotalScore + Price*Num2,
					lists:keystore(exchange_score, 1, ActData, {exchange_score, TotalScore2});
				_ -> 
					SpendItems = [],
					Items2 = Items,
					ActData
			end,
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{
				fetch_data = FetchData2,
				act_data   = ActData2
			},
			{ok, UsrActivityRec2, Items2, SpendItems};
		_ -> 
			{error, "error_fetch_reward_not_reached"}
	end.

do_activity_end_help(_ActivityRec, #gm_activity_usr{uid = Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_sale{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	ActData   = UsrActivityRec#gm_activity_usr.act_data,
	TotalScore = fun_gm_activity_ex:get_list_data_by_key(exchange_score, ActData, 0),
	Fun = fun({Id, ClientId, Sort, TabTitle, Items, OriginalPrice, PresentPrice, ExchangeCost, Limit}) ->
		UseTimes = fun_gm_activity_ex:get_list_data_by_key(Id, FetchData, 0),
		State    = case Sort of
			?SALE_SORT_BUY -> 
				if
					Limit == 0 -> ?REWARD_STATE_CAN_FETCH;
					UseTimes < Limit -> ?REWARD_STATE_CAN_FETCH;
					true -> ?REWARD_STATE_FETCHED
				end;
			?SALE_SORT_RETURN ->
				case UseTimes > 0 of
					true -> ?REWARD_STATE_FETCHED;
					false -> 
						?_IF(TotalScore >= ExchangeCost, ?REWARD_STATE_CAN_FETCH, ?REWARD_STATE_NOT_REACHED)
				end
		end,
		#pt_public_gm_act_sale_des{
			id             = Id,
			client_id      = ClientId,
			sort           = Sort,
			tab_title      = TabTitle,
			items          = lists:map(fun fun_item_api:make_item_get_pt/1, Items),
			original_price = OriginalPrice,
			present_price  = PresentPrice,
			cost_score     = ExchangeCost,
			limit          = Limit,
			left_times     = max(0, Limit - UseTimes),
			state          = State
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).
