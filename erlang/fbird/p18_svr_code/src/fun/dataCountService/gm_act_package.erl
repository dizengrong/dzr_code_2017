%% @doc gm活动：特惠礼包
-module (gm_act_package).
-include("common.hrl").
-compile([export_all]).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	Id 		= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "id")),
	Items 	= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "items"))),
	Name 	= fun_gm_activity_ex:get_json_value(KvList, "name"), 
	Pic 	= fun_gm_activity_ex:get_json_value(KvList, "picture"), 
	Times 	= util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "times")), 
	Desc 	= fun_gm_activity_ex:get_json_value(KvList, "description"), 
	{Id, Items, Name, Pic, Times, Desc}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(ActivityRec, Uid, UsrActivityRec, _RechargeDiamond, RechargeConfigID) ->
	InfoList = ActivityRec#gm_activity.reward_datas,
	case lists:keyfind(RechargeConfigID, 1, InfoList) of
		false -> skip;
		{RechargeConfigID,ItemList,_,_,_,_} ->
			ActData = UsrActivityRec#gm_activity_usr.act_data,
			Time = fun_gm_activity_ex:get_list_data_by_key(RechargeConfigID, ActData, 0),
			ActData2 = lists:keystore(RechargeConfigID, 1, ActData, {RechargeConfigID, Time+1}),
			UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data=ActData2},
			fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
			AddItems = [{?ITEM_WAY_GM_ACT_PACKAGE, N, C} || {N, C} <- ItemList],
			case length(ItemList) > fun_item:get_buy_remain_num(Uid) of
				true -> 
					#mail_content{text = Content} = data_mail:data_mail(gm_act_not_fetch_mail),
					mod_mail_new:sys_send_personal_mail(Uid, ActivityRec#gm_activity.act_name, Content, AddItems, ?MAIL_TIME_LEN);
				_ -> 
					Sid = util:get_sid_by_uid(Uid),
					SuccCallBack = fun() ->
						fun_gm_activity_ex:show_fetched_reward(Uid, Sid, ?GM_ACTIVITY_PACKAGE, ItemList)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, SuccCallBack, undefined)
			end
	end,
	true.
%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	Pt = #pt_gm_act_package{
		startTime = ActivityRec#gm_activity.start_time + util_time:get_time_zone(ActivityRec#gm_activity.start_time),
		endTime   = ActivityRec#gm_activity.end_time + util_time:get_time_zone(ActivityRec#gm_activity.end_time),
		desc      = ActivityRec#gm_activity.act_des,
		datas     = get_reward_state_list(Uid, ActivityRec, UsrActivityRec)
	},
	?send(Sid, proto:pack(Pt)).	

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_PACKAGE.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, _UsrActivityRec, _ActivityRec, _RewardId) ->
	ok.

do_activity_end_help(_ActivityRec, #gm_activity_usr{uid = Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_package{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end.

%% ================================================================
%% =========================== 内部方法 ===========================
get_reward_state_list(_Uid, ActivityRec, UsrActivityRec) ->
	Fun = fun({Id, Items, Name, Pic, Times, Desc}) ->
		case lists:keyfind(Id, 1, UsrActivityRec#gm_activity_usr.act_data) of
			false -> BuyTimes = 0;
			{_, BuyTimes} -> ok
		end,
		State = if
			BuyTimes >= Times -> ?REWARD_STATE_NOT_REACHED;
			true -> ?REWARD_STATE_CAN_FETCH
		end,
		#pt_public_gm_act_package_des{
			id        	= Id,
			name 		= Name,
			pic 		= Pic,
			desc 		= Desc,
			times 		= BuyTimes,
			total_times = Times,
			state     	= State,
			item     	= lists:map(fun fun_item_api:make_item_get_pt/1, Items)
		}
	end,
	lists:map(Fun, ActivityRec#gm_activity.reward_datas).

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_acc_recharge:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_acc_recharge:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?GM_ACTIVITY_PACKAGE,
		act_name     = "name",
		type         = ?GM_ACTIVITY_PACKAGE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		act_des      = "ActDes",
		setting      = [],
		reward_datas = util:term_to_string(test_reward_datas(?GM_ACTIVITY_PACKAGE))
	},
	db:insert(ActivityRec),
	fun_gm_activity_ex:activity_config_help(ActivityRec),
	ok.	

test_del_config() ->
	fun_gm_activity_ex:del_config(?GM_ACTIVITY_PACKAGE, ?GM_ACTIVITY_PACKAGE).

test_reward_datas(?GM_ACTIVITY_PACKAGE) ->
	[{100, [{2,100}], "libao1", "", 5, "SortDescripte"},
	 {200, [{2,200}], "libao2", "", 5, "SortDescripte"},
	 {300, [{2,300}], "libao3", "", 5, "SortDescripte"}].