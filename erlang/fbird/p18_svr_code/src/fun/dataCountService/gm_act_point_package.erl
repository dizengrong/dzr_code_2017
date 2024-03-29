%% @doc gm活动：积分兑换
-module (gm_act_point_package).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_POINT_PACKAGE).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	BoxId   = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "box")),
	Name    = util:to_list(fun_gm_activity_ex:get_json_value(KvList, "name")),
	BoxCont = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "boxcont"))),
	{BoxId, Name, BoxCont}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

refresh_global_data(_ActivityRec) -> skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_point_package{
		startTime 		= ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   		= ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc 			= util:to_list(ActivityRec#gm_activity.act_des),
		close_time   	= ActivityRec#gm_activity.close_time + util_time:get_time_zone(ActivityRec#gm_activity.close_time),
		datas     		= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_POING_PACKAGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	RewardDatas = ActivityRec#gm_activity.reward_datas,
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Fun = fun({_BoxId, _Name, BoxCont}, Acc) ->
		case lists:keyfind(RewardId, 1, BoxCont) of
			{RewardId, Reward, MaxTimes, _Discount, Type, Cost, NeedBox, _Desc} ->
				SpendItems1 = case Type of
					0 -> [];
					1 -> [{?ITEM_WAY_GM_ACT_POING_PACKAGE, T, N} || {T, N, _} <- Cost]
				end,
				Times = case lists:keyfind(RewardId, 1, FetchData) of
					{RewardId, Times1} -> Times1;
					_ -> 0
				end,
				if
					Times >= MaxTimes -> [{error, "error_fetch_reward_already_fetched"} | Acc];
					true ->
						case Type of
							0 ->
								Fun1 = fun(Id1) ->
									case lists:keyfind(Id1, 1, FetchData) of
										{Id1, Times2} when Times2 >= 1 -> true;
										_ -> false
									end
								end,
								case lists:all(Fun1, NeedBox) of
									true ->
										FetchData2 = lists:keystore(RewardId, 1, FetchData, {RewardId, Times + 1}),
										UsrActivityRec1 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
										RewardItem1 = lists:map(fun fun_item_api:make_item_get_pt/1, Reward),
										[{UsrActivityRec1, RewardItem1, SpendItems1} | Acc];
									_ -> [{error, "error_fetch_reward_not_reached"} | Acc]
								end;
							1 ->
								FetchData2 = lists:keystore(RewardId, 1, FetchData, {RewardId, Times + 1}),
								UsrActivityRec1 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
								RewardItem1 = lists:map(fun fun_item_api:make_item_get_pt/1, Reward),
								[{UsrActivityRec1, RewardItem1, SpendItems1} | Acc]
						end
				end;
			_ -> Acc
		end
	end,
	List = lists:foldl(Fun, [], RewardDatas),
	case List of
		[] -> {error, "error_fetch_reward_not_reached"};
		[{error, Reason}] -> {error, Reason};
		[{UsrActivityRec2, RewardItem, SpendItems}] -> {ok, UsrActivityRec2, RewardItem, SpendItems}
	end.

on_start_activity(_ActType) -> skip.

on_refresh_part_data(_Uid, _ActivityRec, _UsrActivityRec) -> skip.
	% RewardDatas = ActivityRec#gm_activity.reward_datas,
	% FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	% Fun = fun({_BoxId, _Name, BoxCont}) ->
	% 	Fun1 = fun({Id, _RewardItem, _MaxTimes, _Discount, Type, _Cost, _NeedBox, _Desc}) ->
	% 		case Type of
	% 			1 ->
	% 				case lists:keyfind(Id, 1, FetchData) of
	% 					{Id, _Times} ->
	% 						FetchData2 = lists:keystore(Id, 1, FetchData, {Id, 0}),
	% 						UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
	% 						fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2);
	% 					_ -> skip
	% 				end;
	% 			_ -> skip
	% 		end
	% 	end,
	% 	lists:foreach(Fun1, BoxCont)
	% end,
	% lists:foreach(Fun, RewardDatas).

%% 活动结束的处理
do_activity_end_help(_ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_point_package{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	Fun = fun({BoxId, Name, BoxCont}) ->
		#pt_public_act_point_package_des{
			id 		 = BoxId,
			name	 = Name,
			box_list = get_reward_state_list_help(BoxCont, UsrActivityRec)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

get_reward_state_list_help(BoxCont, UsrActivityRec) ->
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	Fun = fun({Id, RewardItem, MaxTimes, Discount, Type, Cost, NeedBox, Desc}) ->
		Times = case lists:keyfind(Id, 1, FetchData) of
			{Id, Time} -> Time;
			_ -> 0
		end,
		Status = if
			Times >= MaxTimes -> ?REWARD_STATE_FETCHED;
			true ->
				case Type of
					1 -> ?REWARD_STATE_CAN_FETCH;
					0 ->
						Fun1 = fun(Id1) ->
							case lists:keyfind(Id1, 1, FetchData) of
								{Id1, Times1} when Times1 >= 1 -> true;
								_ -> false
							end
						end,
						case lists:all(Fun1, NeedBox) of
							true -> ?REWARD_STATE_CAN_FETCH;
							_ -> ?REWARD_STATE_NOT_REACHED
						end;
					_ -> ?REWARD_STATE_FETCHED
				end
		end,
		#pt_public_act_point_package_box_des{
			id 		  = Id,
			max_times = MaxTimes,
			times 	  = Times,
			type 	  = Type,
			status 	  = Status,
			content   = Desc,
			discount  = Discount,
			item 	  = fun_item_api:make_item_pt_list(RewardItem),
			cost 	  = fun_item_api:make_item_pt_list(Cost)
		}
	end,
	lists:map(Fun, BoxCont).

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_return_investment:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_return_investment:test_del_config() end).
% test_set_config() ->
% 	ActivityRec = #gm_activity{
% 		act_id       = ?THIS_TYPE,
% 		act_name     = "name",
% 		type         = ?THIS_TYPE,
% 		start_time   = util:unixtime() + 10,
% 		end_time     = util:unixtime() + 20000,
% 		close_time   = util:unixtime() + 25000,
% 		act_des      = "ActDes",
% 		setting      = [],
% 		reward_datas = util:term_to_string(test_reward_datas(?THIS_TYPE))
% 	},
% 	db:insert(ActivityRec),
% 	fun_gm_activity_ex:activity_config_help(ActivityRec),
% 	ok.	

% test_del_config() ->
% 	fun_gm_activity_ex:del_config(?THIS_TYPE, ?THIS_TYPE).

% test_reward_datas(?THIS_TYPE) ->
% 	[{
% 		2000,
% 		[
% 			{1,[{2,10}],"第1天"},
% 			{2,[{1,10000}],"第2天"},
% 			{3,[{9,10000}],"第3天"},
% 			{4,[{11,100}],"第4天"},
% 			{5,[{2,20}],"第5天"},
% 			{6,[{1,10000}],"第6天"},
% 			{7,[{9003,5}],"第7天"}
% 		]
% 	}].