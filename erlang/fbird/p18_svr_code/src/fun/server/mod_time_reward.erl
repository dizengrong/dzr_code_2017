%% 挂机收益
-module(mod_time_reward).
-include("common.hrl").
-export([init_data/1]).
-export([req_time_reward_info/3,req_fetch_time_reward/3]).

%% ===================== 数据操作 =====================
init_data(Uid) ->
	Rec = #t_time_reward{
		uid = Uid,
		start_time = agent:agent_now()
	},
	set_data(Rec).

get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_time_reward) of
		[] -> #t_time_reward{uid = Uid, start_time = agent:agent_now()};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_time_reward.uid, Rec).
%% ===================== 数据操作 =====================

req_time_reward_info(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Pt = #pt_time_reward{
		time = agent:agent_now() - Rec#t_time_reward.start_time
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_fetch_time_reward(Uid, Sid, Seq) ->
	Now = agent:agent_now(),
	Rec = get_data(Uid),
	Start = Rec#t_time_reward.start_time,
	case Now - Start >= data_para:get_data(9) * 60 of
		true ->
			Min = min((Now - Start) div 60, data_para:get_data(11) * 60),
			SceneLev = mod_scene_lev:get_curr_scene_lv(Uid),
			#st_dungeons_config{time_reward = BaseReward, time_box = BaseBox} = data_dungeons_config:get_dungeons(SceneLev),
			ItemReward = [{T, N * (Min div data_para:get_data(9))} || {T, N} <- BaseReward],
			BoxReward = make_reward_help(BaseBox, Min div data_para:get_data(10), []),
			ShowReward = lists:append(ItemReward, BoxReward),
			BoxReward1 = [{T, N, [{strengthen_lev, V}]} || {T, N, V} <- BoxReward],
			Succ = fun() ->
				NewRec = Rec#t_time_reward{
					start_time = Now
				},
				set_data(NewRec),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, ShowReward),
				req_time_reward_info(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_TIME_REWARD,
				add      = lists:append(ItemReward, BoxReward1),
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args);
		_ -> ?error_report(Sid, "hang_up_revenue", Seq)
	end.

make_reward_help(_Box, 0, Acc) -> Acc;
make_reward_help(Box, Times, Acc) ->
	make_reward_help(Box, Times - 1, lists:append(fun_draw:box(Box), Acc)).