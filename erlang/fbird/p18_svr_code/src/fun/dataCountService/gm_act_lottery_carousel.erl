%% @doc gm活动：抽奖转盘
-module (gm_act_lottery_carousel).
-include("common.hrl").
-compile([export_all]).

-define(THIS_TYPE, ?GM_ACTIVITY_LOTTERY_CAROUSEL).

%% 解析后台传来的数据
parse_config_datas_field(KvList) ->
	RewardItem  = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "dialreward"))),
	RankReward  = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "rankingreward"))),
	PointReward = fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "integralreward"))),
	MaxDiomand  = util:to_integer(fun_gm_activity_ex:get_json_value(KvList, "jackpot")),
	OneCost 	= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "raffle01"))),
	TenCost 	= fun_gm_activity_ex:string_to_term(util:to_list(fun_gm_activity_ex:get_json_value(KvList, "raffle02"))),
	{RewardItem, RankReward, PointReward, MaxDiomand, OneCost, TenCost}.

%% 充值的处理，返回true将会发送info协议
on_recharge_help(_ActivityRec, _Uid, _UsrActivityRec, _RechargeDiamond, _RechargeConfigID) ->
	skip.

%% 消费金币的处理，返回true将会发送info协议
on_cost_coin(_Uid, _Cost, _UsrActivityRec) ->
	skip.

%% 发送info数据给前端
send_info_to_client(Uid, Sid, ActivityRec, UsrActivityRec) ->
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid = Hid}] ->
			Msg = {req_info, Uid, Sid, Hid, ActivityRec, UsrActivityRec},
			to_global(Msg);
		_ -> skip
	end.

%% 领取奖励的item_way日志
get_reward_way() -> ?ITEM_WAY_GM_ACT_LOTTERY_CAROUSEL.

%% 领取奖励的展示类型
get_fetched_reward_show_type() -> ?SHOW_REWARD_COMMON.

%% 领取奖励的判断
check_fetch_reward(_Uid, UsrActivityRec, ActivityRec, RewardId) ->
	[{_, _, PointReward, _, _, _}] = ActivityRec#gm_activity.reward_datas,
	ActData = UsrActivityRec#gm_activity_usr.act_data,
	Point = fun_gm_activity_ex:get_list_data_by_key(point_num, ActData, 0),
	FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
	case lists:keyfind(RewardId, 1, PointReward) of
		{_, Need, ItemList, _} ->
			case lists:member(RewardId, FetchData) of
				false -> 
					case Point >= Need of
						true ->
							FetchData2 = [RewardId | FetchData],
							UsrActivityRec2 = UsrActivityRec#gm_activity_usr{fetch_data = FetchData2},
							RewardItem = lists:map(fun fun_item_api:make_item_get_pt/1, ItemList),
							{ok, UsrActivityRec2, RewardItem};
						_ -> {error, "error_fetch_reward_not_reached"}
					end;
				true -> {error, "error_fetch_reward_already_fetched"}
			end;
		_ -> {error, "error_fetch_reward_already_fetched"}
	end.

on_start_activity(ActType) ->
	Msg = {start_activity, ActType},
	to_global(Msg).

%% 活动结束的处理
do_activity_end_help(ActivityRec, UsrActivityRec) ->
	Uid = UsrActivityRec#gm_activity_usr.uid,
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] ->
			Pt = #pt_gm_act_lottery_carousel{},
			?send(Sid, proto:pack(Pt));
		_ -> skip
	end,
	Msg = {end_activity, ActivityRec},
	to_global(Msg).

req_draw(Uid, Sid, _Seq, Type) when Type == 1 orelse Type == 10 ->
	case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_LOTTERY_CAROUSEL) of
		{true, ActivityRec} ->
			case db:dirty_get(ply, Uid) of
				[#ply{agent_hid = Hid}] ->
					[{RewardItem, _, _, MaxDiomand, OneCost, TenCost}] = ActivityRec#gm_activity.reward_datas,
					{SpendItems, Point} = case Type of
						1  ->
							{T, N} = OneCost,
							{[{?ITEM_WAY_GM_ACT_LOTTERY_CAROUSEL, T, N}], 5};
						10 ->
							 {T, N} = TenCost,
							{[{?ITEM_WAY_GM_ACT_LOTTERY_CAROUSEL, T, N}], 50}
					end,
					UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?GM_ACTIVITY_LOTTERY_CAROUSEL),
					ActData = UsrActivityRec#gm_activity_usr.act_data,
					OldPoint = fun_gm_activity_ex:get_list_data_by_key(point_num, ActData, 0),
					Succ = fun() ->
						{AddItems, Ptm} = make_pt_list(RewardItem, RewardItem, Type, util:rand(1, 100), [], [], 0),
						Pt = #pt_lottery_carousel_list{list = Ptm},
						ActData2 = lists:keystore(point_num, 1, ActData, {point_num, OldPoint + Point}),
						UsrActivityRec2 = UsrActivityRec#gm_activity_usr{act_data = ActData2, act_time = util_time:unixtime()},
						fun_gm_activity_ex:set_usr_activity_data(UsrActivityRec2),
						Msg = {req_draw, Uid, Sid, Hid, MaxDiomand, AddItems, Pt, SpendItems, OldPoint + Point, util:get_name_by_uid(Uid), db:get_all_config(servername)},
						to_global(Msg)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end;
req_draw(Uid, _Sid, _Seq, Type) -> ?log_error("someone send error info, uid = ~p, type = ~p",[Uid,Type]).



%% ================================================================
%% =========================== 内部方法 ===========================
make_pt_list(_, _, 0, _Rand, Acc1, Acc2, _Acc3) -> {Acc1, Acc2};
make_pt_list(RewardItem, [{Id, Sort, R, List} | Rest], Type, Rand, Acc1, Acc2, Acc3) ->
	case Rand > Acc3 andalso Rand =< (Acc3 + R) of
		true ->
			Pt = #pt_public_id_list{
				id = Id
			},
			NewList = [{Sort, T, N} || {T, N} <- List],
			make_pt_list(RewardItem, RewardItem, Type - 1, util:rand(1, 100), [hd(NewList) | Acc1], [Pt | Acc2], 0);
		_ -> make_pt_list(RewardItem, Rest, Type, Rand, Acc1, Acc2, Acc3 + R)
	end.

to_global(Msg) ->
	Msg2 = {global_gm_act_lottery_carousel, Msg},
	gen_server:cast({global, global_client}, {to_global, Msg2}).

handle({ranklist_reward, Uid, Rank, RewardItem}) ->
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(turnplate_award),
	Content2 = util:format_lang(util:to_binary(Content), [Rank]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, RewardItem, ?MAIL_TIME_LEN);

handle({get_draw_reward, Uid, Sid, NewAddItem, Pt}) ->
	AddItem = [{?ITEM_WAY_GM_ACT_LOTTERY_CAROUSEL, T, N} || {T, N} <- NewAddItem],
	Succ = fun() -> ?send(Sid, proto:pack(Pt)) end,
	fun_item_api:check_and_add_items(Uid, Sid, [], AddItem, Succ, undefined);

handle(Msg) -> ?log_error("~p unhandled message:~p", [?MODULE, Msg]).

get_drop_item([], _Rand, _Acc) -> [];
get_drop_item([{T, R} | Rest], Rand, Acc) ->
	case Rand > Acc andalso Rand =< (Acc + R) of
		true -> [{T, 1}];
		_ -> get_drop_item(Rest, Rand, Acc + R)
	end.

%% =============================================================================
%% ========================= 测试方法 ==========================================
% world_svr:debug_call(agent_mng, fun() -> gm_act_lottery_carousel:test_set_config() end).
% world_svr:debug_call(agent_mng, fun() -> gm_act_lottery_carousel:test_del_config() end).
test_set_config() ->
	ActivityRec = #gm_activity{
		act_id       = ?THIS_TYPE,
		act_name     = "name",
		type         = ?THIS_TYPE,
		start_time   = util:unixtime() + 10,
		end_time     = util:unixtime() + 20000,
		close_time   = util:unixtime() + 25000,
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
		[
			{1,2,2,[{0,10}]},
			{2,1,10,[{1,10000}]},
			{3,1,10,[{9,10000}]},
			{4,1,10,[{11,100}]},
			{5,2,3,[{0,20}]},
			{6,1,10,[{1,10000}]},
			{7,1,10,[{9003,5}]},
			{8,2,0,[{0,30}]},
			{9,1,10,[{9005,5}]},
			{10,1,10,[{2,30}]},
			{11,1,10,[{200001,5}]},
			{12,2,0,[{0,50}]},
			{13,1,10,[{200003,5}]},
			{14,1,5,[{200004,5}]}
		],
		[
			{30,1,[{1,10000},{2,100},{9002,100}],"第1名"},
			{31,2,[{1,8000},{2,50},{9002,50}],"第2名"},
			{32,3,[{1,7000},{2,30},{9002,30}],"第3名"},
			{33,4,[{1,6000},{2,1000},{9002,20}],"第4名"},
			{34,5,[{1,5000},{2,10000}],"第5名"},
			{35,6,[{1,4000},{2,10000}],"第6名"},
			{36,7,[{1,3000},{2,10000}],"第7名"},
			{37,8,[{1,2000},{2,10000}],"第8名"},
			{38,9,[{1,1000},{2,10000}],"第9名"},
			{39,10,[{2,10000}],"第10名"}
		],
		[
			{60,10,[{1,10000},{2,100},{9002,100}],"10积分领取奖励"},
			{61,20,[{1,8000},{2,50},{9002,50}],"20积分领取奖励"},
			{62,30,[{1,7000},{2,30},{9002,30}],"30积分领取奖励"},
			{63,40,[{1,6000},{2,1000},{9002,20}],"40积分领取奖励"},
			{64,50,[{1,5000},{2,10000}],"50积分领取奖励"},
			{65,60,[{1,4000},{2,10000}],"60积分领取奖励"},
			{66,70,[{1,3000},{2,10000}],"70积分领取奖励"},
			{67,80,[{1,2000},{2,10000}],"80积分领取奖励"},
			{68,90,[{1,1000},{2,10000}],"90积分领取奖励"},
			{69,100,[{2,10000}],"100积分领取奖励"}
		],
		10000000,
		{2,100},
		{2,900}
	}].