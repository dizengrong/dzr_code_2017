%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-4-7
%% Company : fbird.Co.Ltd
%% Desc : fun_paragon_level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_paragon_level).
-include("common.hrl").
-export([req_legendary_exp_info/3,req_exchange_legendary_exp/4]).
-export([req_legendary_level_info/3,req_add_legendary_prop/4,req_update_legendary_lev/3]).
-export([get_prop_val_by_paragon_level/1,get_fighting_by_paragon_level/1]).
-export([refresh_data/1,add_legendary_exp/3]).
-export([get_bag_lev/1]).

-define(EXP_CHANGE, 1). %% 经验兑换

init_data(Uid) ->
	#usr_legendary_level{
		uid = Uid
	}.

% fun_agent_ets:lookup(10000000003, usr_legendary_level)
get_data(Uid) ->
	case fun_agent_ets:lookup(Uid, usr_legendary_level) of
		[Rec = #usr_legendary_level{}] ->
			Rec#usr_legendary_level{
				buy_times 	 = util:string_to_term(util:to_list(Rec#usr_legendary_level.buy_times)),
				prop_point   = util:string_to_term(util:to_list(Rec#usr_legendary_level.prop_point))
			};
		_ -> init_data(Uid)
	end.

set_data(Rec) ->
	NewRec = Rec#usr_legendary_level{
		buy_times 	 = util:term_to_string(Rec#usr_legendary_level.buy_times),
		prop_point   = util:term_to_string(Rec#usr_legendary_level.prop_point)
	},
	fun_agent_ets:insert(NewRec#usr_legendary_level.uid, NewRec).

%% 请求详细数据
req_legendary_level_info(Uid,Sid,Seq)->
	send_info_to_client(Uid, Sid, Seq).

req_legendary_exp_info(Uid, Sid, Seq) ->
	send_exp_info_to_client(Uid, Sid, Seq).

req_update_legendary_lev(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	[Usr = #usr{exp = Exp}] = db:dirty_get(usr, Uid),
	case check_update(Rec#usr_legendary_level.lev, Rec#usr_legendary_level.exp, Usr, Rec) of
		{ok, NewExp} ->
			NUsr = Usr#usr{paragon_level = Rec#usr_legendary_level.lev + 1},
			NewRec = Rec#usr_legendary_level{lev = Rec#usr_legendary_level.lev + 1, exp = NewExp},
			db:dirty_put(NUsr),
			set_data(NewRec),
			gen_server:cast({global, agent_mng},{updata_usr_paragon_level,Uid,Rec#usr_legendary_level.lev + 1,Exp}),
			fun_agent:send_to_scene({update_paragon_level,Uid,Rec#usr_legendary_level.lev + 1,Exp}),
			fun_agent:send_to_scene({hp_mp_prop_update,Uid,hplimit,mplimit}),
			#mail_content{mailName = Title, text = Content} = data_mail:data_mail(peakedness_upgrade),
			mod_mail_new:sys_send_personal_mail(Uid, Title, Content, [{5925, util:get_data_para_num(1228)}], ?MAIL_TIME_LEN),
			PropList = [],
			% PropList = [{?PROPERTY_PARAGON_LEVEL,Rec#usr_legendary_level.lev + 1}],
			fun_property:updata_fighting(Uid),
			fun_agent_property:send_update_base(Uid,PropList),
			fun_item:req_item_info(Uid,Sid,Seq),
			send_exp_info_to_client(Uid, Sid, Seq),
			Pt = #pt_legendary_level_start{},
			?send(Sid, proto:pack(Pt)),
			% fun_task_count:process_count_event(top_lev_up,{0,0,NLev},Uid,util:get_sid_by_uid(Uid));
			% fun_charge_active:update_charge_reward_schedule(Uid,?CHARGE_ACTIVE_LEV_REWARD, Lev1+NLev);
			ok;
		{error, Reason} -> ?error_report(Sid, Reason, Seq)
	end.

req_add_legendary_prop(Uid,Sid,Type,Seq) ->
	Rec = get_data(Uid),
	{NewList, NewNum} = case lists:keyfind(Type, 1, Rec#usr_legendary_level.prop_point) of
		{Type, Num} -> {lists:keystore(Type, 1, Rec#usr_legendary_level.prop_point, {Type, Num + 1}), Num + 1};
		_ ->  {lists:keystore(Type, 1, Rec#usr_legendary_level.prop_point, {Type, 1}), 1}
	end,
	case NewNum > util:get_data_para_num(1227) * util:get_paragon_level_by_uid(Uid) of
		false ->
			SpendItems = [{?ITEM_WAY_LEGENDARY_LEVEL, 5925, 1}],
			Succ = fun() ->
				NewRec = Rec#usr_legendary_level{prop_point = NewList},
				set_data(NewRec),
				fun_property:updata_fighting(Uid),
				send_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		_ -> ?error_report(Sid, "peakedness_add02", Seq)
	end.

%% 兑换传奇等级以经验
req_exchange_legendary_exp(Uid,Sid,Type,Seq)->
	Rec = get_data(Uid),
	case data_legendary_level:get_exchange_data(Type) of
		#st_legendary_exp_info{need_item = Item, add_exp = AddExp, max_times = MaxTimes} ->
			{SpendItems, CostExp} = get_cost(Type, Item),
			[Usr = #usr{exp = Exp}] = db:dirty_get(usr, Uid),
			case check_exchange(Exp, CostExp, Type, Rec#usr_legendary_level.buy_times, MaxTimes) of
				{ok, NewList} ->
					Succ = fun() ->
						case Type of
							?EXP_CHANGE ->
								NUsr = Usr#usr{exp = Exp - CostExp},
								db:dirty_put(NUsr),
								fun_resoure:send_resource_to_client(Uid,[{?RESOUCE_EXP_NUM,NUsr#usr.exp}]);
							_ -> skip
						end,
						NewRec = Rec#usr_legendary_level{buy_times = NewList},
						set_data(NewRec),
						add_legendary_exp(Uid, Sid, AddExp)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
				{error, Reason} -> ?error_report(Sid, Reason, Seq)
			end;
		_ -> skip
	end.

add_legendary_exp(Uid, Sid, Exp) ->
	Rec = get_data(Uid),
	NewRec = Rec#usr_legendary_level{exp = Rec#usr_legendary_level.exp + Exp},
	set_data(NewRec),
	send_exp_info_to_client(Uid, Sid, 0).

%% 传说等级属性
get_prop_val_by_paragon_level(Uid)->
	Rec = get_data(Uid),
	Fun = fun({Type, Num}, Acc) ->
		NewList = [{PropType, PropVal * Num} || {PropType, PropVal} <- data_legendary_level:get_point_attr(Type)],
		lists:append(Acc, NewList)
	end,
	lists:append(lists:foldl(Fun, [], Rec#usr_legendary_level.prop_point), data_legendary_level:get_level_attr(Rec#usr_legendary_level.lev)).

%% 传说等级战力
get_fighting_by_paragon_level(Uid)->
	Rec = get_data(Uid),
	Fun = fun({Type, Num}, Acc) ->
		data_legendary_level:get_point_fighting(Type) * Num + Acc
	end,
	lists:foldl(Fun, 0, Rec#usr_legendary_level.prop_point) + data_legendary_level:get_level_fighting(Rec#usr_legendary_level.lev).

get_cost(Type, Item) ->
	case Type of
		?EXP_CHANGE ->
			Fun = fun({T,_}) ->
				T /= ?RESOUCE_EXP_NUM
			end,
			Exp = case lists:keyfind(?RESOUCE_EXP_NUM, 1, Item) of
				{_, Num} -> Num;
				_ -> 0
			end,
			{[{?ITEM_WAY_LEGENDARY_LEVEL, T, N} || {T, N} <- lists:filter(Fun, Item)], Exp};
		_ -> {[{?ITEM_WAY_LEGENDARY_LEVEL, T, N} || {T, N} <- Item], 0}
	end. 

send_info_to_client(Uid,Sid,Seq) ->
	Rec = get_data(Uid),
	Fun = fun({Type, Lev}) ->
		#pt_public_legendary_level_info_list{
			type = Type,
			lev  = Lev
		}
	end,
	Pt = #pt_legendary_level_info{
		list = lists:map(Fun, Rec#usr_legendary_level.prop_point)
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_exp_info_to_client(Uid,Sid,Seq) ->
	Rec = get_data(Uid),
	Fun = fun({Type, Times}) ->
		#pt_public_legendary_exp_buy_list{
			type  = Type,
			times = Times
		}
	end,
	Pt = #pt_legendary_level_exp_info{
		exp  = Rec#usr_legendary_level.exp,
		list = lists:map(Fun, Rec#usr_legendary_level.buy_times)
	},
	?send(Sid, proto:pack(Pt, Seq)).

check_exchange(Exp, CostExp, Type, List, MaxTimes) ->
	if
		Exp >= CostExp ->
			case lists:keyfind(Type, 1, List) of
				{Type, Num} ->
					if
						Num >= MaxTimes -> {error, "not_enough_times"};
						true -> {ok, lists:keystore(Type, 1, List, {Type, Num + 1})}
					end;
				_ -> {ok, lists:keystore(Type, 1, List, {Type, 1})}
			end;
		true -> {error, "not_enough_exp"}
	end.

check_update(Lev, Exp, #usr{id = Uid, lev = UsrLev, fighting = Fighting}, #usr_legendary_level{prop_point = PropList}) ->
	case data_legendary_level:get_data(Lev + 1) of
		#st_legendary_level{} ->
			case data_legendary_level:get_data(Lev) of
				#st_legendary_level{need_lev = NeedLev, need_exp = NeedExp, need_gs = NeedGs, need_legendary_point = NeedPoint, need_legendary_equipment = {NeedGodLev, NeedNum}} ->
					Fun = fun({_, Num}, Acc) ->
						Num + Acc
					end,
					Point = lists:foldl(Fun, 0, PropList),
					if
						UsrLev >= NeedLev andalso Exp >= NeedExp andalso Fighting >= NeedGs andalso Point >= NeedPoint ->
							case fun_item_god_costume:check_equ_num(Uid, NeedGodLev, NeedNum) of
								true -> {ok, Exp - NeedExp};
								_ -> {error, "peakedness_equip"}
							end;
						true -> {error, "peakedness_upgrade"}
					end;
				_ -> {error, "error_common_data_error"}
			end;
		_ -> {error, "peakedness_lvmax"}
	end.

refresh_data(Uid) ->
	Rec = get_data(Uid),
	NewRec = Rec#usr_legendary_level{
		buy_times = []
	},
	set_data(NewRec).

get_bag_lev(Uid) ->
	Lev = util:get_paragon_level_by_uid(Uid),
	data_legendary_level:get_bag_lev(Lev).