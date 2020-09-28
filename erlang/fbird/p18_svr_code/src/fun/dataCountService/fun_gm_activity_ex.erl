%% @doc 后台GM配置的活动处理
-module(fun_gm_activity_ex).
-include("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([activity_config/1, del_config/2, start_activity/1, find_open_activity/1,is_act_open/1]).
-export([
	handle/1, set_usr_activity_data/2, refresh_data/1, do_activity_end/1,
	do_activity_close/1, fetch_reward/5, send_info_to_client/3, send_info_to_client/4,
	get_json_value/2, get_json_value/3, send_not_fetch_mail/5, send_not_fetch_mail/4,
	insert_test_act_data/1, on_usr_login/1, get_usr_activity_data/2,
	on_role_event/5, refresh_global_data/0, on_recharge/3, on_cost_coin/2,
	req_activity_info/3, get_list_data_by_key/3
]).

%% 活动与对应的模块设置
%% 通过回调的方式来实现gm活动，统一处理公共的东西 
get_gm_act_module(?GM_ACTIVITY_ACC_RECHARGE)          -> gm_act_acc_recharge;
get_gm_act_module(?GM_ACTIVITY_ACC_COST)              -> gm_act_acc_cost;
get_gm_act_module(?GM_ACTIVITY_DOUBLE_REWARD)         -> gm_act_double_reward;
get_gm_act_module(?GM_ACTIVITY_DISCOUNT)              -> gm_act_discount;
get_gm_act_module(?GM_ACTIVITY_WEEK_TASK)             -> gm_act_week_task;
get_gm_act_module(?GM_ACTIVITY_EXCHANGE)              -> gm_act_exchange;
get_gm_act_module(?GM_ACTIVITY_SALE)                  -> gm_act_sale;
get_gm_act_module(?GM_ACTIVITY_DROP)                  -> gm_act_drop;
get_gm_act_module(?GM_ACTIVITY_DAILY_ACC_RECHARGE)    -> gm_act_daily_acc_recharge;
get_gm_act_module(?GM_ACTIVITY_DAILY_ACC_COST)     	  -> gm_act_daily_acc_cost;
get_gm_act_module(?GM_ACTIVITY_TREASURE)           	  -> gm_act_treasure;
get_gm_act_module(?GM_ACTIVITY_PACKAGE)            	  -> gm_act_package;
get_gm_act_module(?GM_ACTIVITY_RESET_RECHARGE)    	  -> gm_act_reset_recharge;
get_gm_act_module(?GM_ACTIVITY_LIMIT_SUMMON)       	  -> gm_act_limit_summon;
get_gm_act_module(?GM_ACTIVITY_RANK_LV)            	  -> gm_act_rank_lv;
get_gm_act_module(?GM_ACTIVITY_CONTINUOUS_RECHARGE)   -> gm_act_continuous_recharge;
get_gm_act_module(?GM_ACTIVITY_LIMIT_ACHIEVEMENT)     -> gm_act_limit_achievement;
get_gm_act_module(?GM_ACTIVITY_GLOBAL_RECHARGE)       -> gm_act_global_recharge;
get_gm_act_module(?GM_ACTIVITY_GLOBAL_CONSUME)        -> gm_act_global_consume;
get_gm_act_module(?GM_ACTIVITY_GLOBAL_RECHARGEJIFEN)  -> gm_act_global_rechargejifen;
get_gm_act_module(?GM_ACTIVITY_GLOBAL_CONSUMEJIFEN)   -> gm_act_global_consumejifen;
get_gm_act_module(?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP)  -> gm_act_double_recharge_temp;
get_gm_act_module(?GM_ACTIVITY_RECHARGE_POINT) 		  -> gm_act_recharge_point;
get_gm_act_module(?GM_ACTIVITY_LITERATURE_COLLECTION) -> gm_act_literature_collection;
get_gm_act_module(?GM_ACTIVITY_LOTTERY_CAROUSEL) 	  -> gm_act_lottery_carousel;
get_gm_act_module(?GM_ACTIVITY_RETURN_INVESTMENT) 	  -> gm_act_return_investment;
get_gm_act_module(?GM_ACTIVITY_MYSTERY_GIFT) 	      -> gm_act_mystery_gift;
get_gm_act_module(?GM_ACTIVITY_SINGLE_RECHARGE) 	  -> gm_act_single_recharge;
get_gm_act_module(?GM_ACTIVITY_ACC_LOGIN) 			  -> gm_act_acc_login;
get_gm_act_module(?GM_ACTIVITY_POINT_PACKAGE) 		  -> gm_act_point_package;
get_gm_act_module(?GM_ACTIVITY_DIAMOND_PACKAGE) 	  -> gm_act_diamond_package;
get_gm_act_module(?GM_ACTIVITY_RMB_PACKAGE) 	  	  -> gm_act_rmb_package;
get_gm_act_module(?GM_ACTIVITY_TURNTANLE) 	  	 	  -> gm_act_turntable.

activity_config(Datas) ->
	gen_server:call(?MODULE, {activity_config, Datas}).


del_config(ActId, ActType) ->	
	gen_server:call(?MODULE, {del_config, ActId, ActType}).


insert_test_act_data(ActivityRec) ->
	gen_server:call(?MODULE, {insert_test_act_data, ActivityRec}).

init() -> 
	List = db_api:dirty_match_object(t_gm_activity, #t_gm_activity{_ = '_'}),
	Now = util_time:unixtime(),
	Fun = fun(ActivityRec) ->
		case ActivityRec#t_gm_activity.start_time - Now of
			Sec when Sec >= 0 -> 
				srv_loop:add_callback(Sec, ?MODULE, start_activity, ActivityRec#t_gm_activity.type);
			_ -> 
				skip
		end,
		setup_act_end_timer(ActivityRec)
	end,
	[Fun(E) || E <- List],
	ok.
	
start_activity(ActType) ->
	?debug("ActType:~p",[ActType]),
	Module = get_gm_act_module(ActType),
	case ActType of
		?GM_ACTIVITY_RESET_RECHARGE -> Module:on_start_activity(ActType);
		?GM_ACTIVITY_LOTTERY_CAROUSEL -> Module:on_start_activity(ActType);
		?GM_ACTIVITY_RETURN_INVESTMENT -> Module:on_start_activity(ActType);
		?GM_ACTIVITY_ACC_LOGIN -> Module:on_start_activity(ActType);
		_ -> skip
	end,
	Fun = fun(Uid) ->
		[#ply{agent_hid = Pid}] = db:dirty_get(ply, Uid),
		util_misc:msg_handle_cast(Pid, ?MODULE, {on_start_activity, ActType})
	end,
	[Fun(Uid) || Uid <- db_api:dirty_all_keys(ply)],
	?INFO("activity started actType:~p",[ActType]),
	ok.

handle_call({activity_config, Datas}) -> 
	activity_config2(Datas);

handle_call({del_config, ActId, ActType}) -> 
	del_config2(ActId, ActType);

handle_call({insert_test_act_data, ActivityRec}) -> 
	insert_test_act_data2(ActivityRec);

handle_call(Request) -> 
	?ERROR("unhandled request:~p", [Request]),
	no_reply.

handle_msg(Msg) ->
	?ERROR("unhandled msg:~p", [Msg]),
	ok.


terminate() ->
	ok.


do_loop(_Now) -> 
	ok.

%% agent 消息
handle({on_start_activity, ActType}) -> 
	Uid = get(uid),
	Module = get_gm_act_module(ActType),
	Module:on_start_activity(Uid),
	send_info_to_client(Uid, get(sid), ActType),
	ok.

del_config2(ActId, ActType) ->	
	?INFO("manual close gm activity, ActId:~p, ActType:~p", [ActId, ActType]),
	case db_api:dirty_match_object(t_gm_activity, #t_gm_activity{act_id = ActId, type = ActType, _ = '_'}) of
		[] -> 
			make_http_ret(error, io_lib:format("ActType:~w not exist!", [ActType]));
		[ActivityRec] ->
			do_activity_end(ActivityRec),
			do_activity_close_help(ActivityRec),
			make_http_ret(ok)
	end.


activity_config2(KvList) ->
	case parse_and_check_config_data(KvList) of
		{error, Reason} ->
			?log_error("set_config error:~p", [Reason]),
			make_http_ret(error, Reason);
		{ok, ActivityRec} -> ?debug("activity config now ok....."),
			db_api:dirty_write(ActivityRec),
			activity_config_help(ActivityRec),
			setup_act_end_timer(ActivityRec),
			?INFO("activity_config succ, type:~p", [ActivityRec#t_gm_activity.type]),
			make_http_ret(ok)
	end.


setup_act_end_timer(ActivityRec) -> 
	Now           = util_time:unixtime(),
	EndLeftSecs   = ActivityRec#t_gm_activity.end_time - Now,
	CloseLeftSecs = ActivityRec#t_gm_activity.close_time - Now,
	%% 因为游戏启动时也会调用这个接口，然后可能活动在停服时就结束了，启动后要能正常执行活动的关闭
	EndLeftSecs2 = ?_IF(EndLeftSecs < 0, 5, EndLeftSecs),
	CloseLeftSecs2 = ?_IF(CloseLeftSecs < 0, 5, CloseLeftSecs),
	srv_loop:add_callback(EndLeftSecs2, ?MODULE, do_activity_end, ActivityRec#t_gm_activity.act_id),
	srv_loop:add_callback(CloseLeftSecs2, ?MODULE, do_activity_close, ActivityRec#t_gm_activity.act_id),
	ok.


parse_and_check_config_data(KvList) ->
	case parse_config(KvList) of
		{ok, ActivityRec} ->
			case db_api:dirty_read(t_gm_activity, ActivityRec#t_gm_activity.act_id) of
				[] ->
					ActType = ActivityRec#t_gm_activity.type,
					case db_api:dirty_index_read(t_gm_activity, ActType, #t_gm_activity.type) of
						[] -> {ok, ActivityRec};
						List -> 
							Fun = fun(ExistRec) ->
								StartTime1 = ExistRec#t_gm_activity.start_time,
								EndTime1   = ExistRec#t_gm_activity.end_time,
								StartTime2 = ActivityRec#t_gm_activity.start_time,
								EndTime2   = ActivityRec#t_gm_activity.end_time,
								%% 相同类型的活动导入时间间隔要有30秒，防止计时的时间差问题
								(EndTime2 + 30 < StartTime1) orelse (StartTime2 > EndTime1 + 30)
							end,
							ExistList = lists:filter(Fun, List),
							case ExistList == [] of
								true ->
									?log_error("activity_config exist same time config:~p", [ExistList]),
									{error, "exist same time config"};
								false -> {ok, ActivityRec}
							end
					end;
				_ -> 
					{error, "exist same activity id config"}
			end;
		{error, Reason} -> 
			{error, Reason}
	end.


parse_config(KvList) ->
	case catch safe_parse_config(KvList) of
		end_time_big_than_close_time -> 
			{error, "end_time_big_than_close_time"};
		{string_is_not_erl_term, Key} ->
			?log_error("config_error:~p", [Key]),
			{error, Key};
		{'EXIT', Reason} ->
			?log_error("parse config exception:~n~p", [Reason]),
			{error, "parse config exception, please contact developer!"};
		Ret -> Ret
	end.
safe_parse_config(KvList) ->
	ActType = util:to_integer(get_json_value(KvList, "type")),
	Fields = get_act_config_fields(ActType),
	F = fun(Key) -> lists:keymember(Key, 1, KvList) end,
	case lists:all(F, Fields) of
		true  -> 
			{ok, ActivityRec} = parse_config_help(ActType, KvList),
			case ActivityRec#t_gm_activity.close_time =< ActivityRec#t_gm_activity.end_time of
				true -> 
					throw(end_time_big_than_close_time);
				_ -> 
					{ok, ActivityRec}
			end;
		false -> 
			{error, "json data error#some field is miss"}
	end.

get_act_config_fields(_) -> 
	["act_id", "type", "name", "starttime", "endtime", "data"].

parse_config_help(ActType, KvList) ->
	ActId           = get_json_value(KvList, "act_id"),
	ActName         = get_json_value(KvList, "name"),
	StartTime       = get_json_value(KvList, "starttime"),
	EndTime         = get_json_value(KvList, "endtime"),
	CloseTime		= get_json_value(KvList,"disappearancetime", util:to_integer(EndTime) + 5),
	Picture			= get_json_value(KvList,"picture",""),
	Icon 			= get_json_value(KvList,"icon",""),
	Setting         = parse_act_setting(ActType, KvList),
	Desc            = get_json_value(KvList, "desc", ""),
	RewardDatasObjs = get_json_value(KvList, "data"),
	RewardDatas2    = [parse_config_datas_field(ActType, Obj) || Obj <- RewardDatasObjs],
	RewardDatas3=lists:flatten(RewardDatas2),
	NewActId		= util:to_integer(ActId),
	ActivityRec = #t_gm_activity{
		act_id       = NewActId,
		act_name     = util:to_list(ActName),
		act_des      = Desc,
		picture      = Picture,
		icon         = Icon,
		type         = ActType,
		start_time   = util:to_integer(StartTime),
		end_time     = util:to_integer(EndTime),
		close_time	 = util:to_integer(CloseTime),
		setting      = Setting,
		reward_datas = RewardDatas3
	},
	{ok, ActivityRec}.

parse_act_setting(ActType, KvList) ->
	Mod = get_gm_act_module(ActType),
	Mod:parse_act_setting(KvList).

parse_config_datas_field(ActType, {obj, KvList}) ->
	Module = get_gm_act_module(ActType),
	Module:parse_config_datas_field(KvList).


make_http_ret(ok) -> rfc4627:encode({obj, ?SUCC_RET_DATAS}).
make_http_ret(error, Why) -> rfc4627:encode({obj, ?FAIL_RET_DATAS(Why)}).


get_json_value(KVList, Key) ->
	get_json_value(KVList, Key, undefined).
get_json_value(KVList, Key, Default) ->
	case lists:keyfind(Key, 1, KVList) of
		false -> Default;
		{_,Value} -> util:to_list(Value)
	end.


activity_config_help(ActivityRec) ->
	case ActivityRec#t_gm_activity.start_time - util_time:unixtime() of
		Sec when Sec > 0 -> 
			srv_loop:add_callback(Sec + 1, ?MODULE, start_activity, ActivityRec#t_gm_activity.type);
		_ -> 
			start_activity(ActivityRec#t_gm_activity.type)
	end.

find_open_activity(ActType) ->
	Now = util_time:unixtime(),
	case db:dirty_get(t_gm_activity, ActType, #t_gm_activity.type) of
		[] -> false;
		List ->			
			find_open_activity2(Now, List)
	end.

find_open_activity2(_Time, []) -> false;
find_open_activity2(Time, [ActivityRec | Rest]) ->
	StartTime = ActivityRec#t_gm_activity.start_time,
	EndTime   = ActivityRec#t_gm_activity.end_time,
	CloseTime = ActivityRec#t_gm_activity.close_time,
	case Time >= StartTime andalso (Time =< EndTime orelse Time =< CloseTime) of
		true -> 
			{true, ActivityRec};
		false -> 
			find_open_activity2(Time, Rest)
	end.

refresh_global_data() ->
	[refresh_global_data_help(Type) || Type <- ?DAILY_REFRESH_GLOBAL_GM_ACT_TYPE],
	ok.

refresh_global_data_help(Type) ->
	case fun_gm_activity_ex:find_open_activity(Type) of
		false -> skip;
		{true, ActivityRec} ->
			Module = get_gm_act_module(Type),
			Module:refresh_global_data(ActivityRec)
	end,
	ok.

%% =============================================================================
%% ===============================玩家逻辑处理==================================
%% =============================================================================
refresh_data(Uid) -> 
	[refresh_data_help(Uid, Type) || Type <- ?ALL_DAILY_REFRESH_GM_ACT_TYPE],
	[refresh_part_data_help(Uid, Type) || Type <- ?ALL_DAILY_PART_REFRESH_GM_ACT_TYPE],
	ok.

refresh_data_help(Uid, Type) ->
	case fun_gm_activity_ex:find_open_activity(Type) of
		false -> skip;
		{true, _ActivityRec} ->
			UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, Type),
			ActData = UsrActivityRec#gm_activity_usr.act_data,
			FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
			case ActData == [] andalso FetchData == [] of
				true -> skip;
				false ->
					UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = [], fetch_data = []},
					fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2)
			end
	end,
	ok.

refresh_part_data_help(Uid, Type) ->
	case fun_gm_activity_ex:find_open_activity(Type) of
		false -> skip;
		{true, ActivityRec} ->
			UsrActivityRec = get_usr_activity_data(Uid, Type),
			Module = get_gm_act_module(Type),
			Module:on_refresh_part_data(Uid, ActivityRec, UsrActivityRec)
	end,
	ok.

%% 活动结束，发奖
do_activity_end(ActId) when is_integer(ActId)  -> 
	case db_api:dirty_read(t_gm_activity, ActId) of
		[] -> %% 可能已经先手动关闭了，但定时器没有清除
			skip;
		[ActivityRec] -> 
			do_activity_end(ActivityRec)
	end;
do_activity_end(ActivityRec) ->
	Module = get_gm_act_module(ActivityRec#t_gm_activity.type),
	case ActivityRec#t_gm_activity.type of
		?GM_ACTIVITY_TREASURE ->
			Module:do_treasure_rank_reward(ActivityRec);
		?GM_ACTIVITY_LIMIT_SUMMON ->
			Module:do_treasure_rank_reward(ActivityRec);
		?GM_ACTIVITY_RANK_LV ->
			Module:do_rank_reward(ActivityRec);
		?GM_ACTIVITY_GLOBAL_RECHARGE ->
			Module:do_rank_reward(ActivityRec);
		?GM_ACTIVITY_GLOBAL_CONSUME ->
			Module:do_rank_reward(ActivityRec);
		?GM_ACTIVITY_GLOBAL_RECHARGEJIFEN ->
			Module:do_clear_data(ActivityRec);
		?GM_ACTIVITY_GLOBAL_CONSUMEJIFEN ->
			Module:do_clear_data(ActivityRec);
		?GM_ACTIVITY_RECHARGE_POINT ->
			Module:do_rank_reward(ActivityRec);
		_ -> skip
	end,
	[?TRY_CATCH(fun() -> do_activity_end_help(ActivityRec, Uid) end, E, R) || Uid <- db_api:dirty_all_keys(t_gm_act_usr)],
	?INFO("activity is end, actType:~p", [ActivityRec#t_gm_activity.type]),
	ok.

do_activity_end_help(ActivityRec = #gm_activity{type = ActType}, PlyRec)-> 
	Module = get_gm_act_module(ActType),
	UsrActivityRec = get_usr_activity_data(PlyRec#ply.uid, ActType),
	Module:do_activity_end_help(ActivityRec, UsrActivityRec).

%% 活动关闭，删除数据
do_activity_close(ActId) ->
	case db_api:dirty_read(t_gm_activity, ActId) of
		[] ->
			skip;
		[ActivityRec] -> 
			do_activity_close_help(ActivityRec)
	end.

do_activity_close_help(#t_gm_activity{act_id = ActId, type = ActType}) -> 
	[del_usr_activity_data(Uid, ActType) || Uid <- db_api:dirty_all_keys(t_gm_act_usr)],
	db_api:dirty_delete(t_gm_activity, ActId),
	?INFO("activity is closed, actType:~p", [ActType]),
	ok.

%% RewardTimes:奖励翻倍数，会乘以物品数量的
send_not_fetch_mail(ActType, Uid, ActName, RewardItems) ->
	send_not_fetch_mail(ActType, Uid, ActName, RewardItems, 1).
send_not_fetch_mail(ActType, Uid, ActName, RewardItems, RewardTimes) ->
	AddItems  = transfer_pt_items(RewardItems, ActType, RewardTimes),
	AddItems2 = [{T, N, L} || {_, T, N, [{_, L}]} <- AddItems],
	#mail_content{text = Content} = data_mail:data_mail(gm_act_not_fetch_mail),
	mod_mail_new:sys_send_personal_mail(Uid, ActName, Content, AddItems2, ?MAIL_TIME_LEN).

on_recharge(Uid, RechargeDiamond, RechargeConfigID) ->
	List = ?ALL_NEW_GM_ACT,
	[?TRY_CATCH(fun() -> on_recharge_help(T, Uid, RechargeDiamond, RechargeConfigID) end, E, R) || T <- List],
	ok.

%% 活动是否是开启的 todo:可以考虑优化为读取某一个状态，而不是像现在这样动态计算
is_act_open(ActType) -> 
	case find_open_activity(ActType) of
		{true, _} -> true;
		_ -> false
	end.

on_recharge_help(ActType, Uid, RechargeDiamond, RechargeConfigID) ->
	case find_open_activity(ActType) of
		false -> skip;
		{true, ActivityRec} -> 
			case is_stopped(ActivityRec) of
				true -> skip;
				_ ->
					UsrActivityRec = get_usr_activity_data(Uid, ActType),
					Module = get_gm_act_module(ActType),
					case Module:on_recharge_help(ActivityRec, Uid, UsrActivityRec, RechargeDiamond, RechargeConfigID) of
						true -> 
							send_info_to_client(Uid, get(sid), ActType);
						_ -> skip
					end
			end 
	end.

is_stopped(ActivityRec) ->
	Now = util_time:unixtime(),
	Now >= ActivityRec#gm_activity.end_time.

on_cost_coin(Uid, Cost) ->
	List = ?ALL_NEW_GM_ACT,
	[?TRY_CATCH(fun() -> on_cost_coin_help(T, Uid, Cost) end, E, R) || T <- List],
	ok.

on_cost_coin_help(ActType, Uid, Cost) ->
	case find_open_activity(ActType) of
		false -> 
			skip;
		{true, ActivityRec} ->
			case is_stopped(ActivityRec) of
				true -> skip;
				_ ->
					UsrActivityRec = get_usr_activity_data(Uid, ActType),
					Module = get_gm_act_module(ActType),
					case Module:on_cost_coin(Uid, Cost, UsrActivityRec) of
						true -> 
							send_info_to_client(Uid, get(sid), ActType);
						_ -> skip
					end
			end 
	end.

% on_recharge_jifen(Uid, Cost) ->
% 	List = [?GM_ACTIVITY_GLOBAL_RECHARGEJIFEN],
% 	[?TRY_CATCH(fun() -> on_recharge_jifen_help(T, Uid, Cost) end, E, R) || T <- List],
% 	ok.

% on_recharge_jifen_help(ActType, Uid, Cost) ->
% 	case find_open_activity(ActType) of
% 		false -> 
% 			skip;
% 		{true, #gm_activity{}} ->
% 			UsrActivityRec = get_usr_activity_data(Uid, ActType),
% 			Module = get_gm_act_module(ActType),
% 			case Module:on_recharge_jifen(Uid, Cost, UsrActivityRec) of
% 				true -> 
% 					send_info_to_client(Uid, get(sid), ActType);
% 				_ -> skip
% 			end
% 	end.
% on_consume(Uid, Cost) ->
% 	List = [?GM_ACTIVITY_GLOBAL_CONSUME],
% 	[?TRY_CATCH(fun() -> on_consume_help(T, Uid, Cost) end, E, R) || T <- List],
% 	ok.

% on_consume_help(ActType, Uid, Cost) ->
% 	case find_open_activity(ActType) of
% 		false -> 
% 			skip;
% 		{true, ActivityRec} ->
% 			case is_stopped(ActivityRec) of
% 				true -> skip;
% 				_ ->
% 					UsrActivityRec = get_usr_activity_data(Uid, ActType),
% 					Module = get_gm_act_module(ActType),
% 					case Module:on_consume(Uid, Cost, UsrActivityRec) of
% 						true -> 
% 							send_info_to_client(Uid, get(sid), ActType);
% 						_ -> skip
% 					end
% 			end 
% 	end.
% on_consume_jifen(Uid, Cost) ->
% 	List = [?GM_ACTIVITY_GLOBAL_CONSUMEJIFEN],
% 	[?TRY_CATCH(fun() -> on_consume_jifen_help(T, Uid, Cost) end, E, R) || T <- List],
% 	ok.

% on_consume_jifen_help(ActType, Uid, Cost) ->
% 	case find_open_activity(ActType) of
% 		false -> 
% 			skip;
% 		{true, ActivityRec} ->
% 			case is_stopped(ActivityRec) of
% 				true -> skip;
% 				_ ->
% 					UsrActivityRec = get_usr_activity_data(Uid, ActType),
% 					Module = get_gm_act_module(ActType),
% 					case Module:on_consume_jifen(Uid, Cost, UsrActivityRec) of
% 						true -> 
% 							send_info_to_client(Uid, get(sid), ActType);
% 						_ -> skip
% 					end
% 			end 
% 	end.

%% ============================ 活动的玩家数据操作=============================
%% return:#t_gm_act_usr{}
get_usr_act_rec(Uid) ->
	case db_api:dirty_read(t_gm_act_usr, Uid) of
		[] -> #t_gm_act_usr{uid = Uid};
		[Rec] -> Rec
	end.

%% return:#gm_activity_usr{}
get_usr_activity_data(Uid, ActType) ->
	case db_api:dirty_read(t_gm_act_usr, Uid) of
		[] -> 
			#gm_activity_usr{type = ActType};
		[#gm_activity_usr{act_data = List}] -> 
			case lists:keyfind(ActType, #gm_activity_usr.type, List) of
				false -> 
					#gm_activity_usr{type = ActType};
				Rec -> 
					Rec
			end
	end.

%% Rec:#gm_activity_usr{}
set_usr_activity_data(Uid, ActDataRec) -> 
	Rec = get_usr_act_rec(Uid),
	Datas = lists:keystore(ActDataRec#gm_activity_usr.type, #gm_activity_usr.type, Rec#t_gm_act_usr.act_data, ActDataRec),
	db_api:dirty_write(Rec#t_gm_act_usr{act_data = Datas}).

del_usr_activity_data(Uid, ActType) -> 
	Rec = get_usr_act_rec(Uid),
	case lists:keymember(ActType, #gm_activity_usr.type, Rec#t_gm_act_usr.act_data) of
		false -> skip;
		_ -> 
			Datas = lists:keydelete(ActType, #gm_activity_usr.type, Rec#t_gm_act_usr.act_data),
			case Datas of
				[] -> db_api:dirty_delete(t_gm_act_usr, Uid);
				_  -> db_api:dirty_write(Rec#t_gm_act_usr{act_data = Datas})
			end
	end.
%% ============================ 活动的玩家数据操作=============================

req_activity_info(_Uid, Sid, Seq) ->
	Fun = fun(ActType, Acc) ->
		case find_open_activity(ActType) of
			{true, ActivityRec} ->
				Ptm  = #pt_public_activity_list{
					id   = ActType,
					name = util:to_list(ActivityRec#gm_activity.act_name),
					icon = util:to_list(ActivityRec#gm_activity.icon)
				},
				[Ptm | Acc];
			_ -> Acc
		end
	end,
	Pt = #pt_gm_activity{
		activity_list = lists:foldl(Fun, [], ?ALL_NEW_GM_ACT)
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_info_to_client(Uid, Sid, ActType) ->
	send_info_to_client(Uid, Sid, 0, ActType).
send_info_to_client(Uid, Sid, Seq, ActType) ->
	send_info_to_client(Uid, Sid, Seq, ActType, true).
send_info_to_client(Uid, Sid, Seq, ActType, SendClosePt) ->
	case find_open_activity(ActType) of
		false when not SendClosePt -> 
			skip;
		false when SendClosePt -> 
			%% 发空数据让前段关闭活动
			ActivityRec = #t_gm_activity{type = ActType},
			UsrActivityRec = #gm_activity_usr{type = ActType},
			Module = get_gm_act_module(ActType),
			Module:send_info_to_client(Uid, Sid, Seq, ActivityRec, UsrActivityRec);
		{true, ActivityRec} -> 
			UsrActivityRec = get_usr_activity_data(Uid, ActType),
			Module = get_gm_act_module(ActType),
			Module:send_info_to_client(Uid, Sid, Seq, ActivityRec, UsrActivityRec)
	end.

transfer_pt_items(List, ActType, Multi) -> 
	Module = get_gm_act_module(ActType),
	Way    = Module:get_reward_way(),
	[{Way, T, N*Multi, [{strengthen_lev, L}]} || #pt_public_item_list{item_id=T,item_num=N,item_star=L} <- List].

%% 领取奖励
fetch_reward(Uid, Sid, ActType, RewardId, Arg) ->
	case check_fetch_reward(Uid, ActType, RewardId, Arg) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, NewUsrActivityRec, RewardItems} ->
			fetch_reward_help(Uid, Sid, ActType, RewardId, NewUsrActivityRec, RewardItems, [], true, undefined);
		{ok, NewUsrActivityRec, RewardItems, SpendItems} ->
			fetch_reward_help(Uid, Sid, ActType, RewardId, NewUsrActivityRec, RewardItems, SpendItems, true, undefined);
		{ok, NewUsrActivityRec, RewardItems, SpendItems, SendInfoPt} ->
			fetch_reward_help(Uid, Sid, ActType, RewardId, NewUsrActivityRec, RewardItems, SpendItems, SendInfoPt, undefined);
		{ok, NewUsrActivityRec, RewardItems, SpendItems, SendInfoPt, ModSuccFun} ->
			fetch_reward_help(Uid, Sid, ActType, RewardId, NewUsrActivityRec, RewardItems, SpendItems, SendInfoPt, ModSuccFun)
	end.

fetch_reward_help(Uid, Sid, ActType, RewardId, NewUsrActivityRec, RewardItems, SpendItems, SendInfoPt, ModSuccFun) ->
	AddItems = transfer_pt_items(RewardItems, ActType, 1),
	% Module = get_gm_act_module(ActType),
	SuccCallBack = fun() ->
		set_usr_activity_data(Uid, NewUsrActivityRec),
		ShowItems = [{T, N, L} || {_, T, N, [{_, L}]} <- AddItems],
		show_fetched_reward(Uid, Sid, ActType, ShowItems),
		SendInfoPt andalso send_info_to_client(Uid, Sid, ActType),
		is_function(ModSuccFun, 0) andalso ModSuccFun(),
		fun_dataCount_update:gm_activity(Uid, ActType, RewardId)
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, undefined).


show_fetched_reward(Uid, Sid, ActType, ShowItems) ->
	Module   = get_gm_act_module(ActType),
	ShowType = Module:get_fetched_reward_show_type(),
	fun_item_api:send_show_fetched_reward(Uid, Sid, ShowType, ShowItems),
	ok.

check_fetch_reward(Uid, ActType, RewardId, Arg) ->
	case find_open_activity(ActType) of
		false -> 
			{error, "error_activity_expired"};
		{true, ActivityRec} ->
			UsrActivityRec = get_usr_activity_data(Uid, ActType),
			Module         = get_gm_act_module(ActType),
			Module:check_fetch_reward(Uid, UsrActivityRec, ActivityRec, RewardId, Arg)
	end.

insert_test_act_data2(ActivityRec) ->
	db_api:dirty_write(ActivityRec),
	activity_config_help(ActivityRec),
	setup_act_end_timer(ActivityRec),
	insert_test_act_succ.

get_list_data_by_key(Key, List, Default) ->
	case List of
		undefined -> Default;
		_->
			case lists:keyfind(Key, 1, List) of
				false -> Default;
				{_, S} -> S
			end
	end.

%% =============================================================================
%% ============================== 各个事件的处理===============================
%% 这些事件是回调模块的可选事件，需要的话就在这里插入代码
on_usr_login(_Uid) ->
	ok.

% on_role_event(Uid, Sid, ?TASK_SPEND_DIAMOND_NUM, Val2, Val3) -> 
% 	case Val2 < 0 of
% 		true -> %% 表示消费
% 			on_usr_spend_diamond(Uid, Sid, Val3);
% 		_ -> skip
% 	end;
% on_role_event(Uid, Sid, ?TASK_RECHARGE, RechargeConfigID, _Val3) -> 
% 	 on_usr_recharge(Uid, Sid, RechargeConfigID);												   
% on_role_event(Uid, Sid, ?TASK_THUNDER_BOSS, Val2, _Val3) ->
% 	if
% 		Val2 > 0 -> on_usr_boss(Uid, Sid, Val2);			
% 		true ->skip
% 	end;
on_role_event(_Uid, _Sid, _Type, _Val1, _Val2) ->
	ok.

% on_usr_spend_diamond(_Uid, _Sid, _Num) -> 
% 	ok.

% on_usr_recharge(_Uid, _Sid, _RechargeConfigID) ->	
% 	ok.

% on_usr_boss(_Uid, _Sid, _Val) ->
% 	ok.

%% =============================================================================

% should_listen_event(_) -> ok.