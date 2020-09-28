%% @doc 公会科技模块
-module (mod_guild_technology).
-include("common.hrl").
-export ([req_info/3, req_up_lv/4, req_reset/4, get_add_attr/2, on_init/1]).

%% ================================= 数据操作 ==================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_guild_technology) of
		[] -> 
			#t_guild_technology{
				uid = Uid,
				datas = data_guild_technology:get_init_list()
			};
		[Rec] -> Rec
	end.

set_data(Uid, Rec) ->
	mod_role_tab:insert(Uid, Rec).

% get_tec_lv(Uid, TecId) ->
% 	Rec = get_data(Uid),
% 	case lists:keyfind(TecId, 1, Rec#t_guild_technology.datas) of
% 		false -> 0;
% 		{_, Lv} -> Lv 
% 	end.

set_tec_lv(Uid, Rec, TecId, Lv) ->
	Datas = lists:keystore(TecId, 1, Rec#t_guild_technology.datas, {TecId, Lv}),
	set_data(Uid, Rec#t_guild_technology{datas = Datas}).
%% ================================= 数据操作 ==================================

on_init(Uid) ->
	Rec = get_data(Uid),
	[recalc_prof_attr(Prof, Rec) || Prof <- ?ALL_HERO_PROF],
	ok.

recalc_prof_attr(Prof, Rec) -> 
	Attrs = get_add_attr2(Prof, Rec#t_guild_technology.datas, []),
	put({?MODULE, Prof}, Attrs),
	Attrs.

req_info(Uid, Sid, Seq) ->
	case fun_guild:get_role_guild_id(Uid) of
		0 -> skip;
		_ -> 
			send_info_to_client(Uid, Sid, Seq, 0)
			
	end.


send_info_to_client(Uid, Sid, Seq, UpdateType) ->
	Rec = get_data(Uid),
	Pt = #pt_guild_tec_info{
		update_type      = UpdateType,
		used_reset_times = Rec#t_guild_technology.used_reset_times,
		datas            = util_pt:make_two_int(Rec#t_guild_technology.datas)
	},
	?send(Sid, proto:pack(Pt, Seq)).


req_up_lv(Uid, Sid, Seq, TecId) ->
	case check_up_lv(Uid, TecId) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, Rec, Lv, Costs} -> 
			Succ = fun() -> 
				NewLv = Lv + 1,
				set_tec_lv(Uid, Rec, TecId, NewLv),
				send_info_to_client(Uid, Sid, Seq, 1),
				check_and_unlock_slot(Uid, Sid, TecId, NewLv),
				Prof = data_guild_technology:get_for_prof(TecId),
				recalc_prof_attr(Prof, get_data(Uid)),
				fun_agent_property:update_all_cached_hero_prop(Uid, prop_class_guild_tec, Prof)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_UP_GUILD_TEC,
				spend    = Costs,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

check_up_lv(Uid, TecId) ->
	Rec = get_data(Uid),
	case lists:keyfind(TecId, 1, Rec#t_guild_technology.datas) of
		false -> 
			{error, "common_not_activited"};
		{_, Lv} -> 
			case Lv >= data_guild_technology:get_max_lv(TecId) of
				true -> 
					{error, "common_lv_full"};
				_ -> 
					Slot = data_guild_technology:get_slot(TecId),
					Costs = data_guild_technology:get_lv_up_cost(Slot, Lv),
					{ok, Rec, Lv, Costs}
			end
	end.


check_and_unlock_slot(Uid, Sid, TecId, Lv) ->
	NextTecId = TecId + 1,
	Rec = get_data(Uid),
	Slot1 = data_guild_technology:get_slot(TecId),
	Slot2 = data_guild_technology:get_slot(NextTecId),
	case Slot1 + 1 == Slot2 of
		true ->
			case Lv >= util:get_data_para_num(31) of
				true -> 
					case lists:keyfind(NextTecId, 1, Rec#t_guild_technology.datas) of
						false ->
							do_unlock(Uid, Sid, NextTecId, Rec);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> 
			skip
	end.

do_unlock(Uid, Sid, TecId, Rec) ->
	set_tec_lv(Uid, Rec, TecId, 0),
	send_info_to_client(Uid, Sid, 0, 2).


req_reset(Uid, Sid, Seq, Prof) ->
	Items = get_reset_return_back(Uid, Prof),
	case Items of
		[] -> %% 没有需要重置的
			?error_report(Sid, "check_data_error", Seq);
		_ ->
			Succ = fun() -> 
				NewRec = reset_data(Uid, Prof),
				set_data(Uid, NewRec),
				send_info_to_client(Uid, Sid, Seq, 0)
			end,
			Rec = get_data(Uid),
			MaxTimes = data_buy_time_price:get_max_times(?BUY_GUILD_TEC_RESET_TIMES),
			Times = min(Rec#t_guild_technology.used_reset_times + 1, MaxTimes),
			#st_buy_time_price{cost = Costs} = data_buy_time_price:get_data(?BUY_GUILD_TEC_RESET_TIMES, Times),
			Args = #api_item_args{
				way      = ?ITEM_WAY_RESET_GUILD_TEC,
				spend    = Costs,
				add      = Items,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

reset_data(Uid, Prof) ->
	Rec = get_data(Uid),
	NewDatas = reset_data2(Prof, Rec#t_guild_technology.datas, []),
	Rec#t_guild_technology{
		datas = NewDatas,
		used_reset_times = Rec#t_guild_technology.used_reset_times
	}.

reset_data2(Prof, [T = {TecId, _Lv} | Rest], Acc) ->
	case data_guild_technology:get_for_prof(TecId) == Prof of
		false -> 
			Acc2 = [T | Acc];
		_ -> 
			Acc2 = Acc
	end,
	reset_data2(Prof, Rest, Acc2);
reset_data2(_Prof, [], Acc) ->
	Acc.


get_reset_return_back(Uid, Prof) ->
	Rec = get_data(Uid),
	get_reset_return_back2(Prof, Rec#t_guild_technology.datas, []).

get_reset_return_back2(Prof, [{TecId, Lv} | Rest], Acc) ->
	case data_guild_technology:get_for_prof(TecId) == Prof of
		true ->
			Acc2 = get_reset_return_back3(TecId, Lv, Acc);
		_ ->
			Acc2 = Acc
	end,
	get_reset_return_back2(Prof, Rest, Acc2);
get_reset_return_back2(_Prof, [], Acc) -> 
	Acc.

get_reset_return_back3(TecId, Lv, Acc) when Lv > 0 -> 
	Slot = data_guild_technology:get_slot(TecId),
	Costs = data_guild_technology:get_lv_up_cost(Slot, Lv),
	get_reset_return_back3(TecId, Lv - 1, util_list:add_and_merge_list(Acc, Costs, 1, 2));
get_reset_return_back3(_TecId, _Lv, Acc) -> 
	Acc. 


%% 获取给英雄的属性加成
get_add_attr(Uid, EntourageId) -> 
	#item{type = Type} = fun_entourage:get_entourage(Uid, EntourageId),
	#st_entourage_config{profession = Prof} = data_entourage:get_data(Type),
	get({?MODULE, Prof}).

get_add_attr2(Prof, [{TecId, Lv} | Rest], Acc) ->
	Acc2 = case data_guild_technology:get_for_prof(TecId) == Prof of
		true ->
			Slot = data_guild_technology:get_slot(TecId),
			AddRate = data_guild_technology:get_lv_attr_rate(Slot, Lv),
			Attrs = data_guild_technology:get_base_attr(TecId),
			Attrs2 = [{AttrId, util:floor(Val*AddRate / 10000)} || {AttrId, Val} <- Attrs],
			util_list:add_and_merge_list(Acc, Attrs2, 1, 2);
		_ ->
			Acc
	end,
	get_add_attr2(Prof, Rest, Acc2);
get_add_attr2(_Prof, [], Acc) -> 
	Acc.

