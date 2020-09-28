%% @doc gm活动：连续充值
-module (gm_act_continuous_recharge).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_CONTINUOUS_RECHARGE).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Any 		= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "any"))),
	Specified 	= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "specified"))),
	Continuous 	= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "continuous"))),
	{Any, Specified, Continuous}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(ActivityRec, Uid, UsrActivityRec, RechargeDiamond, RechargeConfigID) ->
	Now = util_time:unixtime(),
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[#pt_public_continuous_recharge_des{any_id = AnyId, spe_id = SpeId, spe_need = SpeNeedDiomand}] = StateList,
	ActData  = UsrActivityRec#gm_activity_usr.act_data,
	ActData2 = case lists:keyfind(AnyId, 1, ActData) of
		false -> lists:keystore(AnyId, 1, ActData, {AnyId, Now});
		_ -> ActData
	end,
	ActData3 = case lists:keyfind(SpeId, 1, ActData2) == false andalso RechargeDiamond >= SpeNeedDiomand of
		true -> lists:keystore(SpeId, 1, ActData2, {SpeId, Now});
		_ -> ActData2
	end,
	Fun1 = fun({Id, _}) ->
		case Id == AnyId orelse Id == SpeId of
			true -> false;
			_ -> true
		end
	end,
	List = lists:filter(Fun1, ActData3),
	ActData4 = case List of
		[] -> [{RechargeConfigID, Now} | ActData3];
		_ -> 
			Fun = fun({Id, Time}) ->
				case Id == AnyId orelse Id == SpeId of
					true -> false;
					_ ->
						case util_time:is_same_day(Time, Now) of
							true -> true;
							_ -> false
						end
				end
			end,
			CanAdd = lists:any(Fun, ActData3),
			if 
				CanAdd -> ActData3;
				true -> [{RechargeConfigID, Now} | ActData3]
			end
	end,
	UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData4},
	fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
	true.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

on_refresh_part_data(Uid, ActivityRec, UsrActivityRec) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[#pt_public_continuous_recharge_des{any_id = AnyId, spe_id = SpeId}] = StateList,
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	case ActData == [] andalso FetchData == [] of
		true -> skip;
		false ->
			ActData2 = lists:keydelete(AnyId, 1, ActData),
			ActData3 = lists:keydelete(SpeId, 1, ActData2),
			FetchData2 = lists:delete(AnyId, FetchData),
			FetchData3 = lists:delete(SpeId, FetchData2),
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData3, fetch_data = FetchData3},
			fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2)
	end.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_continuous_recharge_info{
		startTime 		= ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   		= ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		total_recharge  = get_total_recharge_times(Uid, ActivityRec, UsrActivityRec),
		desc 			= util:to_list(ActivityRec#gm_activity.act_des),
		datas     		= get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_CONTINUOUS_RECHARGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId) ->
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[#pt_public_continuous_recharge_des{any_id=AnyId,any_reward=AnyReward,can_any=CanAny,spe_id=SpeId,spe_reward=SpeReward,can_spe=CanSpe,continuous_list=Continuous}] = StateList,
	case RewardId of
		AnyId -> 
			case CanAny == ?REWARD_STATE_CAN_FETCH of
				true ->
					FetchData       = UsrActivityRec#gm_activity_usr.fetch_data,
					FetchData2      = [RewardId | FetchData],
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					{ok, UsrActivityRec2, AnyReward};
				_ -> {error, "error_fetch_reward_not_reached"}
			end;
		SpeId -> 
			case CanSpe == ?REWARD_STATE_CAN_FETCH of
				true ->
					FetchData       = UsrActivityRec#gm_activity_usr.fetch_data,
					FetchData2      = [RewardId | FetchData],
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
					{ok, UsrActivityRec2, SpeReward};
				_ -> {error, "error_fetch_reward_not_reached"}
			end;
		_ -> 
			case lists:keyfind(RewardId, #pt_public_continuous_recharge_reward_des.id, Continuous) of
				#pt_public_continuous_recharge_reward_des{reward = RewardItems, can_fetch = CanFetch} ->
					case CanFetch == ?REWARD_STATE_CAN_FETCH of
						true ->
							FetchData       = UsrActivityRec#gm_activity_usr.fetch_data,
							FetchData2      = [RewardId | FetchData],
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							{ok, UsrActivityRec2, RewardItems};
						_ -> {error, "error_fetch_reward_not_reached"}
					end;
				_ -> {error, "error_fetch_reward_not_reached"}
			end
	end.

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid       = UsrActivityRec#gm_activity_usr.uid,
	StateList = get_reward_state_list(Uid, ActivityRec, UsrActivityRec),
	[do_activity_end_help2(Uid, ActivityRec, PtState) || PtState <- StateList],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_continuous_recharge_info{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

do_activity_end_help2(Uid, ActivityRec, PtState) ->
	#pt_public_continuous_recharge_des{can_any=CanAny,any_reward=AnyReward,can_spe=CanSpe,spe_reward=SpeReward,continuous_list=Continuous} = PtState,
	case CanAny of
		?REWARD_STATE_CAN_FETCH ->
			fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_CONTINUOUS_RECHARGE, Uid, ActivityRec#gm_activity.act_name, AnyReward, 1);
		_ -> skip
	end,
	case CanSpe of
		?REWARD_STATE_CAN_FETCH ->
			fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_CONTINUOUS_RECHARGE, Uid, ActivityRec#gm_activity.act_name, SpeReward, 1);
		_ -> skip
	end,
	Fun = fun(#pt_public_continuous_recharge_reward_des{can_fetch = CanFetch, reward = RewardItems}) ->
		case CanFetch of
			?REWARD_STATE_CAN_FETCH ->
				fun_gm_activity_ex:send_not_fetch_mail(?GM_ACTIVITY_CONTINUOUS_RECHARGE, Uid, ActivityRec#gm_activity.act_name, RewardItems, 1);
			_ -> skip
		end
	end,
	lists:foreach(Fun, Continuous).

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(Uid, ActivityRec, UsrActivityRec) ->
	Now = util_time:unixtime(),
	Fun = fun({Any, Specified, Continuous}) ->
		{AnyId, AnyReward, AnyDes} = Any,
		{SpeId, SpeNeedDiomand, SpeReward, SpeDes} = Specified,
		CanAny = case lists:member(AnyId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case lists:keyfind(AnyId, 1, UsrActivityRec#gm_activity_usr.act_data) of
					false -> ?REWARD_STATE_NOT_REACHED;
					_ -> ?REWARD_STATE_CAN_FETCH
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		CanSpe = case lists:member(SpeId, UsrActivityRec#gm_activity_usr.fetch_data) of
			false -> 
				case lists:keyfind(SpeId, 1, UsrActivityRec#gm_activity_usr.act_data) of
					false -> ?REWARD_STATE_NOT_REACHED;
					_ -> ?REWARD_STATE_CAN_FETCH
				end;
			true -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_continuous_recharge_des{
			any_id          = AnyId,
			any_reward     	= lists:map(fun fun_item_api:make_item_get_pt/1, AnyReward),
			any_desc 		= AnyDes,
			can_any         = CanAny,
			spe_id          = SpeId,
			spe_need      	= SpeNeedDiomand,
			spe_reward      = lists:map(fun fun_item_api:make_item_get_pt/1, SpeReward),
			spe_desc        = SpeDes,
			can_spe 		= CanSpe,
			continuous_list	= get_reward_state_list_help(Uid, ActivityRec, UsrActivityRec, Continuous)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

get_reward_state_list_help(Uid, ActivityRec, UsrActivityRec, Continuous) ->
	Times = get_total_recharge_times(Uid, ActivityRec, UsrActivityRec),
	Fun = fun({ID,NeedDay,Reward,Desc}) ->
		CanFetch = case lists:member(ID, UsrActivityRec#gm_activity_usr.fetch_data) of
			false ->
				case Times >= NeedDay of
					true -> ?REWARD_STATE_CAN_FETCH;
					_ -> ?REWARD_STATE_NOT_REACHED
				end;
			_ -> ?REWARD_STATE_FETCHED
		end,
		#pt_public_continuous_recharge_reward_des{
			id 			= ID,
			need_day 	= NeedDay,
			reward 		= lists:map(fun fun_item_api:make_item_get_pt/1, Reward),
			desc 		= Desc,
			can_fetch	= CanFetch
		}
	end,
	lists:map(Fun, Continuous).

get_total_recharge_times(_Uid, ActivityRec, UsrActivityRec) ->
	List = ActivityRec#gm_activity.reward_datas,
	case List of
		[] -> 0;
		[{Any, Specified, _}] ->
			{AnyId, _, _} = Any,
			{SpeId, _, _, _} = Specified,
			List1 = UsrActivityRec#gm_activity_usr.act_data,
			SubLen = case lists:keyfind(AnyId, 1, List1) of
				false ->
					case lists:keyfind(SpeId, 1, List1) of
						false -> 0;
						_ -> 1
					end;
				_ -> 
					case lists:keyfind(SpeId, 1, List1) of
						false -> 1;
						_ -> 2
					end
			end,
			length(lists:sublist(List1, max(length(List1)-SubLen, 0)))
	end.

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_continuous_recharge:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_continuous_recharge:test_del_config() end).
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
		{0,[{9002,100}],"每日充值任意钻石领取"}, 
		{100,680,[{9002,100},{9002,100}],"每日充值680以上钻石可领取"},	
		[
			{1,1,[{9002,100},{9002,100},{9002,100},{9002,100}],"连续充值1天可领取奖励"},
			{2,3,[{9002,50},{9002,50},{9002,50},{9002,50}],"连续充值3天可领取奖励"},
			{3,5,[{9002,30},{9002,30},{9002,30},{9002,30}],"连续充值5天可领取奖励"},
			{4,7,[{9002,10},{9002,10},{9002,10},{9002,10}],"连续充值7天可领取奖励"}
		]
	}].
