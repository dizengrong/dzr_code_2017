%% @doc 活跃度系统
-module (fun_liveness).
-include("common.hrl").

-export([send_info_to_client/2, fetch_reward/3, refresh_data/1, handle/1]).
-export([do_draw_hero_card/2, do_hero_lv_up/1, do_hero_skill_up/1]).
-export([do_give_gift/1, do_pet_lv_up/1, do_mount_lv_up/1, do_guild_contribution/1]).
-export([do_arean_win/1, do_store_buy/2, do_copy_win/2, do_kill_monster/1]).
-export([do_barrier_win/1, do_equip_melting/2, do_equip_strength/1, do_buy_coin/1]).
-export([do_draw_a_card/2, equip_compose/1, up_gem/1, do_item_star/1]).
-export([do_quick_fight/2,req_liveness_reward/4,get_data/1,set_data/1,do_limit_boss/1]).

%% =============== 数据操作 ===============
get_data(Uid) ->
	case db:dirty_get(liveness, Uid, #liveness.uid) of
		[]    -> #liveness{uid = Uid};
		[Rec] -> 
			DoneList    = Rec#liveness.done_list,
			FetchedList = Rec#liveness.fetched_list,
			Rec#liveness{
				done_list  = util:string_to_term(util:to_list(DoneList)),
				fetched_list = util:string_to_term(util:to_list(FetchedList))
			}
	end.
set_data(Rec) ->
	Rec2 = Rec#liveness{
		done_list    = util:term_to_string(Rec#liveness.done_list),
		fetched_list = util:term_to_string(Rec#liveness.fetched_list)
	},
	case Rec#liveness.id of
		0 -> db:insert(Rec2);
		_ -> db:dirty_put(Rec2)
	end.
%% =============== 数据操作 ===============
refresh_data(Uid) ->
	Rec = get_data(Uid),
	set_data(Rec#liveness{done_list = [], fetched_list = []}).

handle({do_arean_win, Uid}) ->
	do_arean_win(Uid);
handle({do_guild_contribution, Uid}) ->
	do_guild_contribution(Uid).

%% 装备升星
do_item_star(Uid) -> handle_liveness(Uid, star, 1).
%% 快速战斗
do_quick_fight(Uid, Times) -> handle_liveness(Uid, quick_combat, Times).
%% 宝石升级
up_gem(Uid) -> handle_liveness(Uid, gemstone, 1).
%% 装备打造
equip_compose(Uid) -> handle_liveness(Uid, forging, 1).
%% 抽卡
do_draw_a_card(Uid, Times) -> handle_liveness(Uid, draw_a_card, Times).
%% 抽取英雄卡
do_draw_hero_card(Uid, Times) -> handle_liveness(Uid, draw_hero_card, Times).
%% 英雄升级
do_hero_lv_up(Uid) -> handle_liveness(Uid, hero_lv_up).
%% 英雄技能升级
do_hero_skill_up(Uid) -> handle_liveness(Uid, hero_skill_up).
%% 赠送礼物
do_give_gift(Uid) -> handle_liveness(Uid, give_gift).
%% 宠物升级
do_pet_lv_up(Uid) -> handle_liveness(Uid, pet_lv_up).
%% 坐骑升级
do_mount_lv_up(Uid) -> handle_liveness(Uid, mount_lv_up).
%% 公会捐献
do_guild_contribution(Uid) -> handle_liveness(Uid, guild_contribution).
%% 竞技场胜利
do_arean_win(Uid) -> handle_liveness(Uid, arean_win).
%% 商店购买
do_store_buy(Uid, StoreID) -> 
	case StoreID of
		?STORE_TYPE_HERO -> handle_liveness(Uid, store_hero);
		?STORE_TYPE_GUILD -> handle_liveness(Uid, store_guild);
		?STORE_TYPE_MISC -> handle_liveness(Uid, store_misc);
		_ -> ok
	end.
%% 通关副本
do_copy_win(_Uid, _DungeonsId) ->
	todo.

%% 杀怪
do_kill_monster(Uid) -> handle_liveness(Uid, kill_monster).
%% 通过关卡
do_barrier_win(Uid) -> handle_liveness(Uid, barrier_win).
%% 熔炼装备
do_equip_melting(Uid, Num) -> handle_liveness(Uid, equip_melting, Num).
%% 装备强化
do_equip_strength(Uid) -> handle_liveness(Uid, equip_strength).
%% 点金
do_buy_coin(Uid) -> handle_liveness(Uid, exchange_gold_coins).
%% 限时boss
do_limit_boss(Uid) -> handle_liveness(Uid, limit_boss).


liveness_type(AtomType) -> AtomType.

handle_liveness(Uid, Type) ->
	handle_liveness(Uid, Type, 1).
handle_liveness(Uid, Type, N) -> 
	case data_liveness:get_data(liveness_type(Type)) of
		{MaxTimes, _AddScore, _} -> 
			Rec = get_data(Uid),
			case lists:keyfind(Type, 1, Rec#liveness.done_list) of
				false -> 
					case N < MaxTimes of
						true -> 
							Status = ?REWARD_STATE_NOT_REACHED,
							NewTuple = {Type, util:min(MaxTimes, N), Status},
							handle_liveness_help(Uid, Rec, Type, NewTuple);
						_ -> 
							Status = ?REWARD_STATE_CAN_FETCH,
							NewTuple = {Type, util:min(MaxTimes, N), Status},
							handle_liveness_help(Uid, Rec, Type, NewTuple)
					end;
				{_, Times, _} -> 
					case Times < MaxTimes of
						true -> 
							case Times + N < MaxTimes of
								true ->
									Status = ?REWARD_STATE_NOT_REACHED,
									NewTuple = {Type, util:min(MaxTimes, Times + N), Status},
									handle_liveness_help(Uid, Rec, Type, NewTuple);
								_ -> 
									Status = ?REWARD_STATE_CAN_FETCH,
									NewTuple = {Type, util:min(MaxTimes, Times + N), Status},
									handle_liveness_help(Uid, Rec, Type, NewTuple)
							end;
						_ -> skip
					end
			end;
		_ -> skip
	end.

handle_liveness_help(Uid, Rec, Type, NewTuple) ->
	% ?debug("Tuple=~p",[NewTuple]),
	NewDoneList = lists:keystore(Type, 1, Rec#liveness.done_list, NewTuple),
	set_data(Rec#liveness{done_list = NewDoneList}),
	send_info_to_client(Uid, get(sid)).

send_info_to_client(Uid, Sid) ->
	Rec        = get_data(Uid),
	TotalScore = get_total_score(Rec),
	Pt = #pt_activity_info{
		activity_rewards = Rec#liveness.fetched_list,
		activity_val     = TotalScore,
		activity_info    = make_done_pt(Rec#liveness.done_list, [])
	},
	?send(Sid, proto:pack(Pt)),
	ok.

make_done_pt([], Acc) -> Acc;
make_done_pt([{Type, Times, Status} | Rest], Acc) ->
	case data_liveness:get_data(liveness_type(Type)) of
		{_, _, Id} ->
			Pt = #pt_public_activity_info{
				activity_id     = Id,
				activity_time   = Times,
				activity_status = Status
			},
			make_done_pt(Rest, [Pt | Acc]);
		_ -> 
			make_done_pt(Rest, Acc)
	end.

get_total_score(Rec) -> 
	get_total_score(Rec#liveness.done_list, 0).

get_total_score([], Acc) -> Acc;
get_total_score([{Type, Times, _} | Rest], Acc) ->
	Acc2 = case data_liveness:get_data(liveness_type(Type)) of
		{MaxTimes, AddScore, _} ->
			?_IF(Times >= MaxTimes, AddScore, 0) + Acc;
		_ -> Acc
	end,
	get_total_score(Rest, Acc2).

req_liveness_reward(Uid, Sid, _, Id) ->
	% ?debug("Id=~p",[Id]),
	{Type, RewardList} = data_liveness:get_reward(Id),
	Rec = get_data(Uid),
	DoneList = Rec#liveness.done_list,
	% ?debug("Type=~p,DoneList=~p",[Type,DoneList]),
	case lists:keyfind(Type, 1, DoneList) of
		false -> skip;
		{Type, Times, Status} -> 
			% ?debug("Status=~p",[Status]),
			case Status of
				?REWARD_STATE_CAN_FETCH ->
					AddItems = [{?ITEM_WAY_ACTIVITY,T,N} || {T,N} <- RewardList],
					SuccCallBack = fun() ->
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, RewardList),
						NewTuple = {Type, Times, ?REWARD_STATE_FETCHED},
						handle_liveness_help(Uid, Rec, Type, NewTuple),
						Pt = #pt_niubi{status = ?REWARD_STATE_FETCHED},
						?send(Sid, proto:pack(Pt))
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, SuccCallBack, undefined);
				?REWARD_STATE_NOT_REACHED -> ?error_report(Sid, "error_fetch_reward_not_reached");
				?REWARD_STATE_FETCHED -> ?error_report(Sid, "error_fetch_reward_already_fetched");
				_ -> skip
			end
	end.

fetch_reward(Uid, _Sid, 0) ->
	?log_error("client ~p send wrong fetch id:0", [Uid]); 
fetch_reward(Uid, Sid, Id) -> 
	Rec  = get_data(Uid),
	TotalScore = get_total_score(Rec),
	case check_can_fetch(Rec, TotalScore, Id) of
		true ->
			{_, RewardList} = data_liveness_reward:get_data(Id),
			AddItems = [{?ITEM_WAY_ACTIVITY,T,N} || {T,N} <- RewardList],
			SuccCallBack = fun() ->
				Rec2 = Rec#liveness{
					fetched_list = [Id | Rec#liveness.fetched_list]
				},
				set_data(Rec2),
				Pt = #pt_activity_success{
					reward_list = [fun_item_api:make_item_get_pt(T, N) || {T, N} <- RewardList]
				},
				?send(Sid, proto:pack(Pt)),
				send_info_to_client(Uid, Sid),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, RewardList)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, SuccCallBack, undefined);
		_ -> 
			?log_error("fetch liveness reward failed, TotalScore:~p, Id:~p", [TotalScore, Id])
	end,
	ok.

check_can_fetch(Rec, TotalScore, Id) ->
	{S, _} = data_liveness_reward:get_data(Id),
	case lists:member(Id, Rec#liveness.fetched_list) of
		true  -> false;
		false -> TotalScore >= S
	end.
