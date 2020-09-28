%% @doc 世界等级
-module(fun_worldlevel).
-include("common.hrl").
-export([init_worldlevel/0,req_worldlevel_info/3,req_worldlevel_reward/4,refresh_data/1]).
-export([handle/1]).

-define(HOT_FETCHED, 0).
-define(HAS_FETCHED, 1).
-define(REFRESH_INTERVAL, 300000).

-define(FREE, 0).
-define(DIAMOND1, 1).
-define(DIAMOND2, 2).

handle({send_info_to_client, Uid, Sid}) ->
	req_worldlevel_info(Uid, Sid, 0).

init_worldlevel() ->
	MaxLen = util:get_data_para_num(1157),
	Ranklist = [],
	Average = max(1, min(length(Ranklist), MaxLen)),
	Fun = fun({_, Lev, _}, Acc) ->
		Acc + Lev
	end,
	WorldLevel = util:floor(lists:foldl(Fun, 0, Ranklist)/Average) - util:get_data_para_num(1174),
	fun_agent_mng:set_global_value(worldlevel, WorldLevel),
	[mod_msg:handle_to_agent(Rec#ply.agent_hid, ?MODULE, {send_info_to_client, Rec#ply.uid, Rec#ply.sid}) || Rec <- db:dirty_match(ply, #ply{_='_'})],
	erlang:start_timer(?REFRESH_INTERVAL, self(), {?MODULE, init_worldlevel}).

req_worldlevel_info(Uid, Sid, Seq) ->
	Fetch = fun_usr_misc:get_misc_data(Uid, world_level_reward),
	WorldLevel = fun_agent_mng:get_global_value(worldlevel, 0),
	Pt = #pt_worldlevel_info{world_level=WorldLevel,is_reward=Fetch},
	?send(Sid, proto:pack(Pt, Seq)).

req_worldlevel_reward(Uid, Sid, Seq, Type) ->
	WorldLevel = fun_agent_mng:get_global_value(worldlevel, 0),
	[#usr{lev = Lev}] = db:dirty_get(usr, Uid),
	Rewards = data_worldlevel:get_base_reward(1),
	Multi = data_worldlevel:get_reward_multi(WorldLevel - Lev),
	Fetch = fun_usr_misc:get_misc_data(Uid, world_level_reward),
	case length(Rewards) == 0 orelse Multi == 0 orelse Fetch == ?HAS_FETCHED of
		true -> ?error_report(Sid, "worldlevel01", Seq);
		_ ->
			{CostMulti,Cost} = case Type of
				?FREE -> {1, 0};
				?DIAMOND1 -> {util:get_data_para_num(1160), util:get_data_para_num(1158)};
				?DIAMOND2 -> {util:get_data_para_num(1161), util:get_data_para_num(1159)};
				_ -> {0, 0}
			end,
			SpendItems = [{?ITEM_WAY_WORLDLEVEL_REWARD, ?RESOUCE_COIN_NUM, Cost}],
			AddItems = [{?ITEM_WAY_WORLDLEVEL_REWARD, T, N * Multi * CostMulti} || {T, N} <- Rewards],
			Succ = fun() ->
				fun_usr_misc:set_misc_data(Uid, world_level_reward, ?HAS_FETCHED),
				?error_report(Sid, "worldlevel03", Seq),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
				req_worldlevel_info(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined)
	end.

refresh_data(Uid) -> fun_usr_misc:set_misc_data(Uid, world_level_reward, ?HOT_FETCHED).