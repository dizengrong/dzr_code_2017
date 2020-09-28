%% @doc 闯关获得奖励活动
-module (fun_barrier_rewards).
-include("common.hrl").

-export([req_info/4, req_fetch/5, pass_barrier/2]).
-export([init_data/1]).

-define(TYPE_LIST, [1,2]).

type_2_data_key(1) -> barrier_reward1;
type_2_data_key(2) -> barrier_reward2.

%% =============== 数据操作 ===============
get_data(Uid, Type) ->
	fun_usr_misc:get_misc_data(Uid, type_2_data_key(Type)).

set_data(Uid, Type, Data) ->
	fun_usr_misc:set_misc_data(Uid, type_2_data_key(Type), Data).
%% =============== 数据操作 ===============

init_data(Uid) ->
	[init_data(Uid, Type) || Type <- ?TYPE_LIST].

init_data(Uid, Type) ->
	case get_data(Uid, Type) of
		FetchedId when is_number(FetchedId) ->
			List = case FetchedId of
				0 -> [];
				_ ->
					F = fun(I,Acc)-> 
						{ok, [I | Acc]} 
					end,
					{ok, NewList} = util:for(1, FetchedId, F, []),
					NewList
			end,
			set_data(Uid, Type, List);
		undefined -> set_data(Uid, Type, []);
		_ -> skip
	end.

get_current_fetched(Id) ->
	List = fun_agent_mng:get_global_value(barrier_rewards_fetch_num, []),
	case lists:keyfind(Id, 1, List) of
		false -> 0;
		{_, FetchedNum} -> FetchedNum
	end. 

add_current_fetched(Id) ->
	List = fun_agent_mng:get_global_value(barrier_rewards_fetch_num, []),
	List2 = case lists:keyfind(Id, 1, List) of
		false -> [{Id, 1} | List];
		{_, FetchedNum} -> 
			lists:keystore(Id, 1, List, {Id, FetchedNum + 1}) 
	end,
	fun_agent_mng:set_global_value(barrier_rewards_fetch_num, List2).

pass_barrier(Uid, Sid) ->
	req_info(Uid, Sid, 0, 1),
	req_info(Uid, Sid, 0, 2),
	ok.


req_info(Uid, Sid, Seq, Type) ->
	FetchedList = get_data(Uid, Type),
	Barrier = mod_scene_lev:get_curr_scene_lv(Uid),
	Pt = #pt_barrier_rewards_info{type = Type, datas = make_reward_info_pt(Type, FetchedList, Barrier)},
	?send(Sid, proto:pack(Pt, Seq)).

make_reward_info_pt(Type, FetchedList, Barrier) ->
	[make_reward_info_pt_help(Type, FetchedList, Barrier, Id) || Id <- get_conf_all_list(Type)].

make_reward_info_pt_help(Type, FetchedList, Barrier, Id) ->
	{Condtion, _Rewards, Max} = get_conf_data_info(Type, Id),
	#pt_public_barrier_rewards_des{
		id              = Id, 
		done            = max(Condtion, Barrier),
		state           = get_reward_state(Type, Condtion, Barrier, FetchedList, Id, Max),
		current_fetched = get_current_fetched(Id)
	}.

get_reward_state(Type, Condtion, Barrier, FetchedList, Id, Max) ->
	Has_fetch = lists:member(Id, FetchedList),
	if
		Has_fetch -> ?REWARD_STATE_FETCHED;
		Barrier >= Condtion andalso Type == 1 -> 
			?REWARD_STATE_CAN_FETCH;
		Barrier >= Condtion andalso Type == 2 -> 
			CurrentNum = get_current_fetched(Id),
			case CurrentNum >= Max of
				true -> ?REWARD_STATE_NOT_REACHED;
				_ -> ?REWARD_STATE_CAN_FETCH
			end;
		true -> ?REWARD_STATE_NOT_REACHED
	end.

req_fetch(Uid, Sid, Seq, Type, Id) ->
	% ?debug("Type:~p", [Type]),
	% ?debug("Id:~p", [Id]),
	case check_fetch(Uid, Type, Id) of
		{error, Error} -> 
			?debug("Error:~p", [Error]),
			?error_report(Sid, Error);
		{ok, Rewards} ->
			AddItems = [{?ITEM_BARRIER_REWARDS,T,N} || {T,N} <- Rewards],
			SuccCallBack = fun() -> 
				case Type of
					2 -> add_current_fetched(Id);
					_ -> skip
				end,
				FetchedList = get_data(Uid, Type),
				set_data(Uid, Type, [Id | FetchedList]),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
				req_info(Uid, Sid, Seq, Type)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, SuccCallBack, undefined)
	end.

check_fetch(Uid, Type, Id) ->
	FetchedList = get_data(Uid, Type),
	Barrier = mod_scene_lev:get_curr_scene_lv(Uid),
	{Condtion, Rewards, Max} = get_conf_data_info(Type, Id),
	State = get_reward_state(Type, Condtion, Barrier, FetchedList, Id, Max),
	if
		State == ?REWARD_STATE_FETCHED -> {error, "error_fetch_reward_already_fetched"};
		State == ?REWARD_STATE_NOT_REACHED -> {error, "error_fetch_reward_not_reached"};
		true -> {ok, Rewards}
	end.


get_conf_all_list(1) -> data_barrier_rewards:all_ids1();
get_conf_all_list(2) -> data_barrier_rewards:all_ids2().

get_conf_data_info(1, Id) -> data_barrier_rewards:get_data1(Id);
get_conf_data_info(2, Id) -> data_barrier_rewards:get_data2(Id).
