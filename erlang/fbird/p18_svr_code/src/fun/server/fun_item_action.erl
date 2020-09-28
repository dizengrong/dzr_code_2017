%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2015-11-11
%% Company : fbird.Co.Ltd
%% Desc : fun_item_action
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_item_action).
-include("common.hrl").

-export([req_item_use/5,req_sell_item/5,send_item_model_to_sid/2]).
-export([add_reward/5,
		 add_buff/5,
		 add_hp/5,
		 add_mp/5,
		 % add_bag/5,
		 add_mount/5,
		 add_dress/5,
		 % add_title/5,
		 add_task/5,
		 add_exp/5,
		 add_vipexp/5,
		 guild_call/5,
		 camp_call/5,
		 add_playericon/5,
		 auto_add_title/2,
		 auto_add_mount/4,
		 add_exp_buff/5,
		 add_coin/5,
		 add_mining_protect/5,
		 fix_composite/5,
		 rand_composite/5]).

%%使用物品
req_item_use(Uid,Sid,ItemID,Times,Seq) when Times > 0 ->
	case fun_item_api:get_item_by_id(Uid, ItemID) of
		#item{type = Type, owner = 0} ->
			case data_item:get_data(Type) of 
				#st_item_type{req_lev = Uselev, action = ActionFunc, action_arg = ActionArg, action_arg1 = ActionArg2} ->
					Lev = util:get_lev_by_uid(Uid),
					if
						Lev >= Uselev andalso is_atom(ActionFunc)->
							case fun_item_use:check_usr_item_times(Uid, Type) of
								true -> use_item_help(Uid,Sid,Type,ItemID,Times,ActionFunc,ActionArg,ActionArg2);
								_-> ?error_report(Sid,"USE_END",Seq)
							end;
						true -> skip
					end;	
				_ -> skip
			end;
		_ -> skip
	end;
req_item_use(_Uid,_Sid,_ItemID,_Times, _Seq) -> ok.

%%出售物品
req_sell_item(Uid,Sid,ItemID,Num,_Seq) when Num > 0 ->
	case fun_item_api:get_item_by_id(Uid, ItemID) of
		#item{type = ItemType} ->
			case data_item:get_data(ItemType) of
				#st_item_type{price = Price,business=1} ->
					fun_item_api:check_and_add_items(Uid, Sid, [{?ITEM_WAY_SELL, {item_id, ItemID}, Num}], [{?ITEM_WAY_SELL, ?RESOUCE_COPPER_NUM, Price * Num}]);
				_ -> skip
			end;
		_ -> skip
	end;
req_sell_item(_Uid,_Sid,_ItemID,_Num,_Seq) -> ok.

use_item_help(Uid,Sid,Type,ItemID,Times,ActionFunc,ActionArg,ActionArg2) ->
	case fun_item_action:ActionFunc(Uid, Sid, {ItemID, Type, Times}, ActionArg, ActionArg2) of
		ok ->
			fun_item_use:add_usr_item_times(Sid, Uid, Type, Times),
			fun_item:send_backpack_is_full_bank(Uid);
		_ -> skip
	end.

add_reward(Uid, Sid, {ItemID, Type, Num1}, _ActionArg,Args)->
	NewArgs=together_item(Args,[]),
	AddItems = [{?ITEM_WAY_BOX_OPEN, T, N, [{strengthen_lev, L}]} || {T, N, L} <- NewArgs],
	SpendItems1 = [{?ITEM_WAY_BOX_OPEN, T, N * Num1} || {T, N} <- data_item_use_cost:get_data(Type)],
	SpendItems2 = [{?ITEM_WAY_USE, {item_id, ItemID}, Num1}],
	SpendItems = lists:append(SpendItems1, SpendItems2),
	SuccCallBack = fun() ->
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, NewArgs)
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, undefined),
	ok.

%%add by Andy Lee on July 5,2016
together_item([],Ret) -> Ret;
together_item([{ItemType,ItemNum,ItemLev} | Next], Ret) ->
	NewRet=case data_item:get_data(ItemType) of			
		#st_item_type{max=1} ->
			lists:append(Ret, [{ItemType,ItemNum,ItemLev}]);		
		_ ->
			case lists:keyfind(ItemType, 1, Ret) of
				{ItemType,N} -> lists:keyreplace(ItemType, 1, Ret, {ItemType,N+ItemNum,0});	
				_ -> lists:append(Ret, [{ItemType,ItemNum,0}])
			end					
	end,
	together_item(Next, NewRet).

add_buff(Uid, Sid, {ItemID, Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_item:req_item_info(Uid,Sid,0),
	fun_item_use:add_usr_item_times(Sid, Uid, Type, Num1), 
	fun_agent:send_to_scene({add_buff, Uid,ActionArg}).

add_hp(Uid, Sid, {ItemID,_Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_item:req_item_info(Uid,Sid,0), 
	case db:dirty_get(usr, Uid) of
		[Usr |_] ->
			UHp = (Num1*ActionArg),
			Hp = Usr#usr.hp,
			MaxHp = fun_property:property_get_data(fun_agent_property:get_property_bank(), ?PROPERTY_HPLIMIT),
			NewHp = 
				if Hp +UHp >MaxHp->
					   MaxHp;
				   true->Hp +UHp 
				end,
			db:dirty_put(Usr#usr{hp=NewHp}),
			fun_agent:send_to_scene({usr_item_prop_update, Uid,hp,UHp});
		_->skip
	end.

add_mp(Uid, Sid, {ItemID, Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_item:del_item_by_type(Uid, Sid, Type, Num1,?ITEM_WAY_USE),
	fun_item:req_item_info(Uid,Sid,0),
	case db:dirty_get(usr, Uid) of
		[Usr |_] ->
			UMp = Usr#usr.mp+(Num1*ActionArg),
			db:dirty_put(Usr#usr{hp= UMp}),
			Mp = Usr#usr.mp,
					MaxMp = fun_property:property_get_data(fun_agent_property:get_property_bank(), ?PROPERTY_MPLIMIT),
					NewMp = 
					if Mp +UMp >MaxMp->
						   MaxMp;
					   true->Mp +UMp 
					end,
					db:dirty_put(Usr#usr{hp=NewMp}),
					fun_agent:send_to_scene({usr_item_prop_update, Uid,mp,UMp});
		_->skip
	end.

add_mount(_Uid, _Sid, {_ItemID, _Type, _Num1}, _ActionArg,_Args)->
	%% 	fun_item:del_item_by_type(Uid, Sid, Type, Num1,?ITEM_WAY_USE),
	%% 	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	%% 	fun_ride:add_ride_skin(Uid, Sid, ActionArg),
	%% 	fun_item:req_item_info(Uid,Sid,0),
	%% 	send_item_model_to_sid(Sid, Type).
	ok.

% add_title(Uid, Sid, {ItemID,_Type, Num1}, ActionArg,_Args)->
% 	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
% %% 	fun_item:del_item_by_type(Uid, Sid, Type, Num1,?ITEM_WAY_USE),
% 	fun_title:usr_acquire_title(ActionArg, Uid, Sid),
% 	fun_item:req_item_info(Uid,Sid,0).
% %% 	?error_report(Sid,"get_title",0,[ActionArg]).

add_task(Uid, Sid, {ItemID,_Type, Num1}, _ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_item:req_item_info(Uid,Sid,0).

add_exp(Uid,_Sid, {ItemID,_Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_resoure:add_exp(Uid,Num1 *  ActionArg, 0).

add_vipexp(Uid, Sid, {ItemID,_Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_vip:add_vip_exp(Uid, Sid, ActionArg*Num1).

guild_call(Uid,_Sid, {ItemID,_Type, Num1}, _ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	case get(use_call_up_minLev) of
		?UNDEFINED->skip;
		Lev->
			fun_agent:send_to_scene({send_guild_call,Uid,ItemID,Lev})
	end.

camp_call(Uid,_Sid, {ItemID,_Type, Num1}, _ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	case get(use_call_up_minLev) of
		?UNDEFINED->skip;
		Lev->
			fun_agent:send_to_scene({send_camp_call,Uid,ItemID,Lev})
	end.

add_dress(Uid,_Sid, {ItemID,_Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_item_model_clothes:add_model_clothes(Uid, ActionArg).

add_playericon(Uid, Sid, {ItemID,_Type, Num1}, ActionArg,_Args)->
	fun_item:del_item_id_num(Uid, ItemID, Num1, ?ITEM_WAY_USE),
	fun_usr_head:add_playericon(Uid, Sid, ActionArg).

add_coin(Uid, Sid, {_ItemID, Type, Num}, ActionArg, _Args) ->
	SceneLev = mod_scene_lev:get_curr_scene_lv(Uid),
	{_,Coin,_,_} = mod_off_line:get_off_line_award(Uid,ActionArg,SceneLev,0),
	AddItems = [{?ITEM_WAY_USE,?RESOUCE_COPPER_NUM,Coin*Num}],
	SpendItems = [{?ITEM_WAY_USE,Type,Num}],
	Succ = fun() ->
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, [{?RESOUCE_COPPER_NUM,Coin*Num}])
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined).

add_exp_buff(Uid, Sid, {ItemID, Type, Num}, ActionArg, _Args) ->
	fun_item:del_item_id_num(Uid, ItemID, Num, ?ITEM_WAY_USE),
	#st_item_type{action_arg1=ActionArg2} = data_item:get_data(Type),
	fun_medicine:add_buff(Uid, Sid, add_exp, Type, Num, ActionArg, ActionArg2).
	
add_mining_protect(Uid, Sid, {_ItemID, Type, Num}, ActionArg, _Args) ->
	SpendItems = [{?ITEM_WAY_USE,Type,Num}],
	Succ = fun() -> 
		fun_mining_service:add_protect(Uid, Sid, Num*ActionArg)
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined).


%% rename(Uid, Sid, {ItemID, Type, Num1}, ActionArg,Args)->ok.
%% 	case db:dirty_get(usr, Uid) of
%% 		[Usr |_] ->
%% 			db:dirty_put(Usr#usr{name= Num1*ActionArg});
%% 		_->skip
%% 	end,
%% check_rename(Uid, , {ItemID, Type, Num1}, ActionArg)->
%% 	case check_own_item(Uid,  {ItemID, Type, Num1}) of
%% 		true->{true,[ActionArg]};
%% 		_->{false,[]}
%% 	end.

auto_add_title(Uid, ActionArg)->
	Sid = util:get_sid_by_uid(Uid),
	fun_title:usr_acquire_title(ActionArg, Uid, Sid),
	?error_report(Sid,"get_title",0,[ActionArg]).


auto_add_mount(Uid,Sid,Type,ActionArg)->
	fun_ride:add_ride_skin(Uid, Sid, ActionArg),
	send_item_model_to_sid(Sid, Type).

fix_composite(Uid, Sid, {_ItemID, Type, Times}, ActionArg, ActionArg2)->
	Item = [{T, N * Times, V} || {T, N, V} <- ActionArg2],
	SpendItems = [{?ITEM_WAY_USE, T, N * Times} || {T, N} <- ActionArg],
	AddItems = [{?ITEM_WAY_USE, T, N, [{strengthen_lev, V}]} || {T, N, V} <- Item],
	Succ = fun() ->
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Item),
		send_item_model_to_sid(Sid, Type),
		ok
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined).

rand_composite(Uid, Sid, {_ItemID, Type, Times}, ActionArg, ActionArg2)->
	SpendItems = [{?ITEM_WAY_USE, T, N * Times} || {T, N} <- ActionArg],
	Fun = fun(_I,Acc) ->
		case fun_draw:box(ActionArg2) of
			List when length(List) > 0 -> {ok, lists:append(List, Acc)};
			_ -> {ok,Acc}
		end
	end,
	{ok, Items} = util:for(1, Times, Fun, []),
	AddItems = [{?ITEM_WAY_USE, T, N, [{strengthen_lev, V}]} || {T, N, V} <- Items],
	Succ = fun() ->
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Items),
		send_item_model_to_sid(Sid, Type),
		ok
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined).

%%使用物品道具获得一个新的模型会通过模型展示界面展示
send_item_model_to_sid(Sid,ItemType)->
	Pt = #pt_item_model{item_id=ItemType},
	?send(Sid,proto:pack(Pt)).