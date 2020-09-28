-module(fun_item).
-include("common.hrl").
-export([check_item_id_num/3]).
-export([get_item_num_by_type/2,get_item_id_by_type/2,get_item_att_val_by_type/1,send_items_to_sid/3,send_items_to_sid/4]).
-export([req_item_info/3,destroy_item/4]).
-export([check_equipment_by_itemid/2,get_buy_remain_num/1,check_backpack_is_full/1,check_sort/1,get_backpack_balance/1,send_items_by_itemid/4]).
-export([check_backpack_ample/2,send_all_usr_items_to_sid/3,send_all_usr_items_to_sid/4,check_orange_equipment/1,add_item_action/5]).
-export([send_private_system_msg/3,send_private_system_msg_1/3,send_private_system_msg/2,send_private_system_msg/4,clean_backpack/2,
		 updata_name_card/5,add_entourage_exp/5,get_equ_gs_by_equ_id/1,get_all_equ_star/1,send_private_system_entourage/2,
		 get_item_equ_max_star/1,get_item_name/1,check_equipment/1,req_item_detail_info/4]).
-export([req_buy_bag_lev/4,get_card_add_bag/1]).
-export([send_backpack_is_full_bank/1,check_name/1]).
-export([get_entourage_pos_num/1,get_artifact_pos_num/1,get_rune_pos_num/1]).

%%获取物品的名字
get_item_name(ItemType)->
	case data_item:get_data(ItemType) of
		#st_item_type{name=Name}->Name;
		_->""
	end.

%%agent发送系统公告
send_private_system_msg(Uid,ItemType,DataNum,Star)->
	case data_item:get_data(ItemType) of
		#st_item_type{sort=Sort}->
			if
				Sort >= 1 andalso Sort =< 10->
					if
						DataNum == 222 ->
							gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_item_name(ItemType)),integer_to_list(Star)]});
						true->
							if
								DataNum == 209 orelse DataNum == 210 orelse DataNum == 211 ->
									gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_item_name(ItemType))]});
								true->
									gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_item_name(ItemType))]})
							end
					end;
				true -> skip
			end;
		_ -> skip
	end.
 
%%agent发送系统公告
send_private_system_msg(Uid,ItemType,DataNum)->
	case fun_item:check_orange_equipment(ItemType) of
		true->
			if
				DataNum == 209 orelse DataNum == 210 orelse DataNum == 211 orelse DataNum == 202 ->
					case data_item:get_data(ItemType) of
						#st_item_type{}->
							gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_item_name(ItemType))]});
						_ -> skip
					end;
				true ->
					gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_item_name(ItemType))]})
			end;
		_->skip
	end.

%%agent发送系统公告
send_private_system_entourage(Uid,ItemType)->
	case data_item:get_data(ItemType) of
		#st_item_type{color=Color,sort= Sort}->
			if Color >= 5 andalso Sort == 201->
				   gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(411),util:to_list(util:get_name_by_uid(Uid)),util:to_list(get_item_name(ItemType))]});
			   true->skip
			end;
		_->skip
	end.

%%agent发送系统公告
send_private_system_msg_1(Uid,ItemType,DataNum)->
	case fun_item:check_orange_equipment(ItemType) of
		true->
			gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid))]});
		_->skip
	end.

%%agent发送系统公告
send_private_system_msg(Uid,DataNum)->
	gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid))]}).

%%检查背包是否充足
check_backpack_ample(Uid,ItemList0)->
	NormalizeFun = fun(T) -> 
		case T of
			{ItemType, Num} -> {ItemType, Num, 0};
			{ItemType, Num, Lv} -> {ItemType, Num, Lv}
		end
	end,
	ItemList = [NormalizeFun(T) || T <- ItemList0],
	Fun= fun(Tuple)->
		ItemType = element(1, Tuple),
		fun_resoure:check_resouce(ItemType)
	end,
	{_ResouceList,NewItemList} = lists:partition(Fun, ItemList),
	Fun1 = fun({NewItemType,NewItemNum,L},NewAcc)->
		case lists:keyfind(NewItemType, 1, NewAcc) of
			{NewItemType,ItemOldNum,_}->
				lists:keyreplace(NewItemType, 1, NewAcc, {NewItemType,ItemOldNum+NewItemNum,L});
			_->
				lists:append(NewAcc, [{NewItemType,NewItemNum,L}])
		end
	end,
	ItemListInfo = lists:foldl(Fun1, [], NewItemList),
	Fun2 = fun({ItemType,ItemNum,_},Acc1)->
		case data_item:get_data(ItemType) of
			#st_item_type{max=Max}->
				Acc1 + util:ceil(ItemNum / Max);
			_ -> Acc1
		end
	end,						  
	LenItemListInfo = lists:foldl(Fun2, 0,ItemListInfo),
	BackPack = fun_item:get_backpack_balance(Uid),
	BackPack >= LenItemListInfo.

%%英雄格子数
get_entourage_pos_num(Uid)->
	BackpackLev = get_entourage_backpack_lev(Uid),
	Initial = util:get_data_para_num(2),%%初始背包格子数
	GridBase = util:get_data_para_num(3),
	Initial + BackpackLev * GridBase.

%%获取英雄背包的等级
get_entourage_backpack_lev(Uid)->
	case db:dirty_get(usr, Uid) of
		[#usr{entourage_bag_lev = Backpack_lev}] -> Backpack_lev;
		_ -> 0
	end.

%%神器格子数
get_artifact_pos_num(Uid)->
	BackpackLev = get_artifact_backpack_lev(Uid),
	Initial = util:get_data_para_num(4),%%初始背包格子数
	GridBase = util:get_data_para_num(5),
	Initial + BackpackLev * GridBase.

%%符文格子数
get_rune_pos_num(_Uid)->
	util:get_data_para_num(18).

%%获取神器背包的等级
get_artifact_backpack_lev(Uid)->
	case db:dirty_get(usr, Uid) of
		[#usr{artifact_bag_lev = Backpack_lev}] -> Backpack_lev;
		_ -> 0
	end.


make_item_detail_pt(Uid, ItemRec) ->
	Sort = fun_item_api:get_item_sort(ItemRec#item.type),
	Status = case Sort of
		?ITEM_TYPE_ENTOURAGE -> fun_entourage:is_battle(Uid,ItemRec#item.id);
		_ -> ?NONE_WEARING
	end,
	Pt = util_pt:make_item_base_info_pt(ItemRec),
	Pt#pt_public_item_des{
		battle_status = Status,
		pos           = fun_entourage:get_pos(Uid, ItemRec#item.id),
		equips        = ItemRec#item.equip_list
	}.

%%将物品详细信息发给客户端
send_items_to_sid(Uid,Sid,ItemList) ->
	send_items_to_sid(Uid,Sid,ItemList,0).
send_items_to_sid(_Uid,_Sid,[],_Seq) -> skip;
send_items_to_sid(Uid,Sid,ItemList,Seq) ->
	Fun = fun(ItemRec) ->
		make_item_detail_pt(Uid, ItemRec)
	end,
	ItemList1 = lists:map(Fun, ItemList),
	Pt = #pt_item_chg{item_list=ItemList1},
	?send(Sid,proto:pack(Pt,Seq)).

%%将物品详细信息返回给客户端
send_items_by_itemid(Uid,Sid,ItemId,Seq) ->
	case fun_item_api:get_item_by_id(get(uid), ItemId) of
		Rec when is_record(Rec, item)  ->
			Fun = fun(ItemRec) ->
				make_item_detail_pt(Uid, ItemRec)
			end,
			ItemList1 = lists:map(Fun, [Rec]),
			Pt = #pt_item_info_return{item_list=ItemList1},
			?send(Sid,proto:pack(Pt,Seq));
		_ -> skip
	end.

%%获取该物品Type的数量
get_item_num_by_type(Uid,Type) ->
	case fun_resoure:check_resouce(Type) of
		true->
			fun_resoure:get_resoure(Uid, Type);
		_->
			Items = fun_item_api:filter_item_by_type(Uid, Type),
			lists:foldl(fun(#item{num = CurNum},OldNum) ->OldNum + CurNum  end, 0, Items)
	end.

%% 周卡、月卡增加背包等级
get_card_add_bag(Uid) ->
	Time=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Time),
	Today=Time-(3600*H+60*M+S),
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	WeekLev = case lists:keyfind(?CHARGE_ACTIVE_WEEK_CARD, #usr_charge_active.sort, List) of
		#usr_charge_active{schedule=Sc} ->
			case Sc =< Today of
				true -> 0;
				_ ->
					case data_charge_config:get_data(99997) of
						#st_charge_config{membership_reward = ItemList} ->
							Fun = fun({T,N}, Acc) ->
								case T == 30 of
									true -> Acc + (N div 6);
									_ -> Acc
								end
							end,
							lists:foldl(Fun, 0, ItemList);
						_ -> 0
					end
			end;
		_ -> 0
	end,
	MonthLev = case lists:keyfind(?CHARGE_ACTIVE_MONTH_CARD, #usr_charge_active.sort, List) of
		#usr_charge_active{schedule=Sc2} ->
			case Sc2 =< Today of
				true -> 0;
				_ ->
					case data_charge_config:get_data(99998) of
						#st_charge_config{membership_reward = ItemList2} ->
							Fun2 = fun({T,N}, Acc) ->
								case T == 30 of
									true -> Acc + (N div 6);
									_ -> Acc
								end
							end,
							lists:foldl(Fun2, 0, ItemList2);
						_ -> 0
					end
			end;
		_ -> 0
	end,
	% ?debug("Lev = ~p",[{WeekLev , MonthLev}]),
	WeekLev + MonthLev + fun_talent:get_talent_bag_lev(Uid) + fun_paragon_level:get_bag_lev(Uid).

%%请求物品详细信息
req_item_info(Uid,Sid,Seq) ->
	Items = fun_item_api:get_all_items(Uid),
	Fun = fun(ItemRec) ->
		make_item_detail_pt(Uid, ItemRec)
	end,
	Items1 = lists:map(Fun, Items),
	Pt = #pt_item_info{
		entourage_bag = get_entourage_pos_num(Uid), 
		artifact_bag  = get_artifact_pos_num(Uid), 
		fuwen_bag     = get_rune_pos_num(Uid), 
		item_list     = Items1
	},
	?send(Sid,proto:pack(Pt,Seq)).


req_item_detail_info(Uid,Sid,Seq,ItemId) ->
	case fun_item_api:get_item_by_id2(Uid, ItemId) of
		[Item] ->
			Pt = #pt_item_detail_info{
				items     = [make_item_detail_pt(Uid, Item)]
			},
			?send(Sid,proto:pack(Pt,Seq));
		_ -> 
			?ERROR("item ~p not find!", [ItemId])
	end.


%%毁坏物品
destroy_item(Uid,Sid,ID,Seq) ->
	case fun_item_api:get_item_by_id(Uid, ID) of
		Item = #item{uid = Uid,type=Type,num=Num} -> 
			mod_role_tab:delete(Uid, Item),
			send_items_to_sid(Uid,Sid,[Item#item{num = 0}],Seq),
            fun_task_count:process_count_event(item_add, {0,Type,-Num}, Uid, Sid),
			send_backpack_is_full_bank(Uid);
		_ -> no
	end.	

%%获取该物品Type的id
get_item_id_by_type(Uid,Type) ->
	case fun_item_api:get_all_items(Uid) of
		[] -> [];
		Items ->
			Fun = fun(#item{type = ThisType,id = ThisId},OldId) ->
						  if
							  ThisType == Type ->lists:append(OldId, [ThisId]);
							  true -> OldId
						  end
				  end,
			lists:foldl(Fun,[], Items)
	end.

get_item_att_val_by_type(Type)->
	case data_item:get_data(Type) of
		#st_item_type{prop = PropList} -> PropList;
		_ -> []
	end.

get_equ_gs_by_equ_id(_ID) -> 0.

check_item_id_num(Uid,ItemID,Num) ->
	if
		Num > 0->
			case fun_item_api:get_item_by_id(Uid, ItemID)  of
				#item{uid=Uid,num=ThenNum} when ThenNum >= Num -> true;
				_ -> false
			end;
		true -> false
	end.

%%检查物品是否是装备
check_equipment_by_itemid(Uid,ID)->
	case fun_item_api:get_item_by_id(Uid, ID) of
		#item{type = Type} -> check_equipment(Type);
		_ -> false
	end.
%%检查物品是不是装备
check_equipment(Type)->
	case data_item:get_data(Type)of
		#st_item_type{sort = Sort}-> Sort =< 10 andalso Sort >= 1;
		_->false
	end.

%%将物品详细信息发给客户端
send_all_usr_items_to_sid(Sid,Uid,ItemList) -> send_all_usr_items_to_sid(Sid,Uid,ItemList,0).
send_all_usr_items_to_sid(Sid,Uid,ItemList,Seq) ->
	Fun = fun({Type,State}) ->	
		#pt_public_equip_id_state_list{equip_id=Type,equip_state=State}
	end,
	ItemList1 = lists:map(Fun, ItemList),
	ModelClothes = fun_item_model_clothes:get_model_clothes_dress(Uid),
	Pt = #pt_reloading{equip_id_state_list=ItemList1,model_clothes=ModelClothes,uid=Uid}, 
	?send(Sid,proto:pack(Pt, Seq)),
	fun_agent:send_all_usr(Uid, proto:pack(Pt, Seq)).

check_sort(Sort)->
		if
			Sort>0 andalso Sort<12->true;
			true->false
		end.
%%检测背包是否已经满了
check_backpack_is_full(Uid)->
	Num = get_backpack_balance(Uid),
	Num =< 0.
		
%%获取背包的剩余格子数量
get_buy_remain_num(Uid)->
	get_backpack_balance(Uid).

%%背包已满状态更新
send_backpack_is_full_bank(Uid) ->
	BackpackIsFull = check_backpack_is_full(Uid),
	case check_backpack_state(BackpackIsFull) of
		true->
			fun_agent:send_to_scene({update_backpack_is_full,Uid,BackpackIsFull});
		_->skip
	end.
check_backpack_state(BackpackIsFull)->
	case get(backpack_state) of
		?UNDEFINED ->
			put(backpack_state,BackpackIsFull),true;
		BackpackIsFull ->
			false;
		_->put(backpack_state,BackpackIsFull),true
	end.
			
%%背包剩余格子数量
get_backpack_balance(Uid)->
	PosNum = get_entourage_pos_num(Uid),
	Pos = length(fun_item_api:get_entourage_items(Uid)),
	PosNum - Pos .

% get_all_equ_lev(Uid)->
% 	case fun_item:get_equipment_item(Uid) of
% 		EquipmentItem when is_list(EquipmentItem) ->
% 			lists:foldl(fun(#item{lev=Lev},Acc)->  Acc + Lev end,0, EquipmentItem);
% 		_->0
% 	end.

get_all_equ_star(Uid)->
	case fun_item:get_equipment_item(Uid) of
		EquipmentItem when is_list(EquipmentItem) ->
			lists:foldl(fun(#item{star=Star},Acc)->  Acc + Star end,0, EquipmentItem);
		_->0
	end.

%%检查是不是橙色装备
check_orange_equipment(Type)->
	case data_item:get_data(Type) of
		#st_item_type{color=Color}->
			if Color == 5->
				   true;
			   true->false
			end;
		_->false
	end.

clean_backpack(Uid,Sid) ->
	case fun_item_api:get_all_items(Uid) of
		Items when erlang:is_list(Items) andalso length(Items)> 0 ->			
			Fun = fun(Item)->
				case Item of
					#item{} -> mod_role_tab:delete(Uid, Item);
					_ -> skip
				end	
			end,
			lists:foreach(Fun, Items),
			req_item_info(Uid,Sid,0);
		_ -> skip
	end.	

add_item_action(Uid,ItemListWay,Sid,Title,Content)->
	ItemList=
		case ItemListWay of
			[NewItem|_]->
				case NewItem of
					{_,_,_}->
						lists:map(fun({Type,Num,_})->{Type,Num}end , ItemListWay);
					_->
						ItemListWay
				end;
			_->ItemListWay
		end,
	case fun_item:check_backpack_ample(Uid, ItemList) of
		true->
			lists:foreach(fun({Type,Num,Way})-> fun_item:add_item(Uid, Sid, Type, Num,Way) end, ItemListWay);
		_->
			?error_report(Sid,"reward_send_mail"),
			gen_server:cast({global, agent_mng}, {send_mail_info,Uid,Title,Content,ItemList})
	end.

updata_name_card(Uid,Seq,Sid,Type,Name)->
	case check_name(Name) of
		true->
			case data_item:get_data(Type) of
				#st_item_type{action=change_name}->
					case db:dirty_get(usr, Uid) of
						[Usr = #usr{}]->
							SpendItems = [{?ITEM_WAY_CHANGE_NAME, Type, 1}],
							Succ = fun() ->
								db:dirty_put(Usr#usr{name = util:to_binary(Name)}),
								Pt = #pt_update_name_succeed{name = Name},
								?send(Sid, proto:pack(Pt, Seq)),
								fun_agent:send_to_scene({update_name, Uid, Name}),
								mod_msg:send_to_agnetmng({change_name, Uid, Name}),
								?error_report(Sid, "rename_succeed", Seq)
							end,
							fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> ?error_report(Sid, "player_name_duplicate", Seq)
	end.

check_name(Name)->
	not mod_account_service:check_role_name_exists(util:to_binary(Name)).

%% 最多只升一级	
add_entourage_exp(Uid,Sid,_Type,EType,_Seq)->
	ItemTypeList = [5015, 5016, 5017],
	case fun_entourage:get_up_one_lv_need_exp(Uid, EType) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, NeedExp} ->
			TalEffect = case fun_talent:get_talent_effect(Uid, ?TALENT_ADD_ENTOURAGE_STONE_EXP) of
				[] -> 1;
				EffectList ->
					Fun = fun(Effect, Acc) -> Effect + Acc end,
					1 + (lists:foldl(Fun, 0, EffectList) / 10000)
			end,
			{AddExp, SpendItems}   = get_add_entourage_exp_cost(Uid, TalEffect, NeedExp, ItemTypeList, [], 0),
			SpendItems2  = [{?ITEM_WAY_ENTOURAGE_EXP, T, N} || {T, N} <- SpendItems],
			SuccCallBack = fun() ->
				fun_entourage:new_entourage_add_exp(Uid, Sid, EType, AddExp)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems2, [], SuccCallBack, undefined)
	end.

get_add_entourage_exp_cost(_Uid, _TalEffect, _NeedExp, [], SpendItems, AccExp) -> {AccExp, SpendItems};
get_add_entourage_exp_cost(Uid, TalEffect, NeedExp, [ItemType | Rest], SpendItems, AccExp) ->
	#st_item_type{action = add_heroexp, action_arg = AddExp1} = data_item:get_data(ItemType),
	AddExp = util:ceil(AddExp1 * TalEffect),
	Num = get_item_num_by_type(Uid, ItemType),
	% ?debug("Num:~p, AddExp:~p", [Num, AddExp]),
	case AddExp * Num >= NeedExp of
		true -> 
			RealNeedNum = util:ceil(NeedExp / AddExp),
			AccExp2 = AccExp + RealNeedNum*AddExp,
			{AccExp2, [{ItemType, RealNeedNum} | SpendItems]};
		false ->
			SpendItems2 = ?_IF(Num > 0, [{ItemType, Num} | SpendItems], SpendItems),
			AccExp2 = AccExp + Num*AddExp,
			get_add_entourage_exp_cost(Uid, TalEffect, NeedExp - (AddExp * Num), Rest, SpendItems2, AccExp2)
	end.

get_item_equ_max_star(Uid)->
	ItemList = fun_item:get_equipment_item(Uid),
	lists:foldl(fun(#item{star=Star},Acc)->if Star >Acc ->Star;true->Acc end end,0, ItemList).

%%英雄背包升级
req_buy_bag_lev(Uid,Sid,Type,Seq) ->
	[Usr = #usr{entourage_bag_lev = ELev, artifact_bag_lev = ALev}] = db:dirty_get(usr, Uid), 
	{Cost, NewUsr} = case Type of
		?BUY_HEROSPACE ->
			#st_buy_time_price{cost = Cost1} = data_buy_time_price:get_data(?BUY_HEROSPACE, min(ELev, data_buy_time_price:get_max_times(?BUY_HEROSPACE))),
			NewUsr1 = Usr#usr{entourage_bag_lev = ELev + 1},
			{Cost1, NewUsr1};
		?BUY_ARTIFACTSPACE ->
			#st_buy_time_price{cost = Cost1} = data_buy_time_price:get_data(?BUY_ARTIFACTSPACE, min(ALev, data_buy_time_price:get_max_times(?BUY_ARTIFACTSPACE))),
			NewUsr1 = Usr#usr{artifact_bag_lev = ALev + 1},
			{Cost1, NewUsr1}
	end,
	SpendItems = [{?ITEM_WAY_BACKPACK, T, N} || {T, N} <- Cost],
	Succ = fun() ->
		db:dirty_put(NewUsr),
		Pt = case Type of
			?BUY_HEROSPACE -> #pt_backpack_upgrade{entourage_bag = get_entourage_pos_num(Uid)};
			?BUY_ARTIFACTSPACE -> #pt_backpack_upgrade{artifact_bag = get_artifact_pos_num(Uid)}
		end,
		?send(Sid,proto:pack(Pt,Seq)),
		ok
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined).