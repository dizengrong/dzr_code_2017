-module(fun_scene_drop_item).
-include("common.hrl").

-export([pick_drop/3,drop_box/1,get_owner_team_members/1,get_temp_team_uids/1,check_item_sort_by_dropId/2]).

-define(CAN_PICK,0).
-define(NO_PICK,1).

get_temp_team_uids(CurrMembers) ->
%% 	?debug("CurrMembers = ~p",[CurrMembers]),
	case CurrMembers of
		{_,Members} -> Members;
		_ -> []
	end.

get_owner_team_members(Uid)->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data=#scene_usr_ex{team_leader=TeamLeader,team_info=TeamInfo,curr_members = CurrMembers}}->
			lists:usort(TeamInfo ++[TeamLeader]++[Uid] ++ get_temp_team_uids(CurrMembers));
		_->[]
	end.
		
pick_drop(Uid,IDList,_Seq) -> 
	DropItemDic = case get(drop_item_list) of
					  undefined -> dict:new();
					  DropItemDic1 -> DropItemDic1
				  end,
	case dict:find(Uid, DropItemDic) of
		{ok,[OldList]} -> 
			Fun = fun({ID,_,_,_,_,_,_}) -> 
						  case lists:keyfind(ID, 3, IDList) of
							  {_,_,_} -> true;
							  _ -> false
						  end
				  end,
			{PickList,NewList} = lists:partition(Fun, OldList),
			pick_drop_enter_backpack(Uid,PickList,IDList),
			NDropItemDic1 = dict:erase(Uid, DropItemDic),
			put(drop_item_list,dict:append(Uid, NewList, NDropItemDic1));
		_ -> skip
	end.
check_item_sort_by_dropId(Uid,IDList)->
	Fun = fun({_,_,ID},Acc)->
				  case get(drop_item_list) of
					  undefined->Acc;
					  DropItemDic ->
						  case dict:find(Uid, DropItemDic) of
							  {ok,[OldList]} -> 
								  case lists:keyfind(ID,1, OldList) of
									  {_,_,_,ItemType,_,_,_}->
										  case fun_resoure:check_resouce(ItemType) of
											  true->resource;
											  _->
												  case data_item:get_data(ItemType) of
													  #st_item_type{sort=208}->royal_box;
													  _->item
												  end
										  end;
									  _->Acc
								  end;
							  _->Acc
						  end
				  end
		  end,
	lists:foldl(Fun,no, IDList).

%%掉落物品拾取放入背包
pick_drop_enter_backpack(Uid,PickList,IDList)->
	case PickList of
		[] ->skip;
		_->
			Fun = fun({DropID,{_X,_Y,_Z},_SceneId,ItemType,ItemNum,ItemBind,_ItemRestriction},Acc) ->
						  case lists:keyfind(DropID, 3, IDList) of
							  {_,State,_}->lists:append(Acc, [{State,ItemType,ItemNum,ItemBind}]);
							  _->Acc
						  end
				  end,
			NewPick = lists:foldl(Fun, [], PickList),
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{data = #scene_usr_ex{hid = AgentHid}} -> 
					fun_scene_obj:agent_msg(AgentHid,{pick_drop_enter_backpack,Uid,NewPick});
				_->skip
			end
	end.

get_drop_group(Box,Acc) ->
	case data_box_config:get_data(Box) of 
		#st_box_config{next=0,droprate=Rate,group=Group} ->
			add_to_group_list(Box, Group, Rate, Acc);
		#st_box_config{next=Box,droprate=Rate,group=Group} ->
			add_to_group_list(Box, Group, Rate, Acc);
		#st_box_config{next=Next,droprate=Rate,group=Group} ->
			Acc2 = add_to_group_list(Box, Group, Rate, Acc),
			get_drop_group(Next,Acc2);
		_ -> 
			?log_warning("Box id not find:~p", [Box]),
			Acc
	end.

add_to_group_list(Box, Group, Rate, Acc) ->
	Tuple = case lists:keyfind(Group, 1, Acc) of
		false -> {Group, [{Rate, Box}]};
		{Group, List} ->  {Group, [{Rate, Box} | List]}
	end,
	lists:keystore(Group, 1, Acc, Tuple).
				
drop_box(Box) when Box > 0 ->
	Groups = get_drop_group(Box, []), 
	drop_box_help(Groups,[]);
drop_box(_Box)  -> [].

drop_box_help([], GetList) -> GetList;
drop_box_help([{Group, BoxList} | Rest], GetList) ->
	% ?debug("drop_box_help,Box,Prof,GetList = ~p",[{Box,Prof,GetList}]),
	FunDrop = fun(_I, {Acc1, Acc2}) ->
		NewList = drop_droplist(Acc2),
		{ok, {lists:append(NewList, Acc1), Acc2}}
	end,
	case Group of
		0 -> 
			Fun = fun({Rate, BoxId}, Acc) ->
				Rand = util:rand(0, 9999),
				if
					Rand > Rate -> Acc;
					true -> 
						#st_box_config{droplistid=ListID, droptimes = Times} = data_box_config:get_data(BoxId),
						{ok, {GetDropList, ListID}} = util:for(1, Times, FunDrop, {[], ListID}),
						GetDropList ++ Acc
				end
			end,
			AddList = lists:foldl(Fun, [], BoxList);
		_ ->
			{_, BoxId} = util_list:random_from_tuple_weights(BoxList, 1),
			#st_box_config{droplistid= ListID, droptimes = Times} = data_box_config:get_data(BoxId),
			{ok, {AddList, ListID}} = util:for(1, Times, FunDrop, {[], ListID})
	end,
	drop_box_help(Rest, AddList ++ GetList).


drop_droplist(ID) ->
	GroupList = get_drop_group2(ID, []),
	drop_droplist_help(GroupList, []).

drop_droplist_help([], Acc) -> Acc;
drop_droplist_help([{Group, BoxList} | Rest], Acc) ->
	case Group of
		0 -> 
			Fun = fun({Rate, Id}, Acc1) ->
				Rand = util:rand(0, 9999),
				if
					Rand > Rate -> Acc1;
					true -> drop_droplist_help2(Id) ++ Acc1
				end
			end,
			AddList = lists:foldl(Fun, [], BoxList);
		_ ->
			{_, Id} = util_list:random_from_tuple_weights(BoxList, 1),
			AddList = drop_droplist_help2(Id)
	end,
	drop_box_help(Rest, AddList ++ Acc).

drop_droplist_help2(Id) ->
	case data_droplistconfig:get_data(Id) of
		#st_droplist_config{dropcontentid=ContentID,droptimes=DropTimes1,droptype=DropType,calculationtype=CalType1} ->
			{DropTimes, CalType} = if 
				CalType1 > 1 -> {1, CalType1};
				true -> {DropTimes1, 1}
			end,
			Fun = fun(_I,GetList) ->
				FilterList = case DropType of
					1 -> [];
					_ -> GetList
				end,
				case drop_content(ContentID,FilterList) of
					{Type,Num,Val} -> {ok, [{Type,Num,Val} | GetList]};
					_ -> {ok,GetList}
				end
			end,
			{ok, GetDropList1} = util:for(1, DropTimes, Fun, []),
			[{T, N * CalType, V} || {T, N, V} <- GetDropList1];
		_ -> []
	end.

get_drop_group2(Id,Acc) ->
	case data_droplistconfig:get_data(Id) of 
		#st_droplist_config{next=0,droprate=Rate,group=Group} ->
			add_to_group_list(Id, Group, Rate, Acc);
		#st_droplist_config{next=Id,droprate=Rate,group=Group} ->
			add_to_group_list(Id, Group, Rate, Acc);
		#st_droplist_config{next=Next,droprate=Rate,group=Group} ->
			Acc2 = add_to_group_list(Id, Group, Rate, Acc),
			get_drop_group2(Next,Acc2);
		_ -> 
			?log_warning("Box id not find:~p", [Id]),
			Acc
	end.

drop_content(ID,FilterList) ->
	List = data_dropcontentconfig:get_data(ID),
	FunFilter = fun({{ThisType,_,_},_}) ->
		case lists:keyfind(ThisType, 1, FilterList) of
			false -> true;
			_ -> false
		end
	end,
	ListDrop = lists:filter(FunFilter, List),
	{DropDes, _} = util_list:random_from_tuple_weights(ListDrop, 2),
	{ItemType2, ItemNum2, Val} = DropDes,
	%% 配置的是开始物品id和结束物品id（或数量），然后从这个区间等概率随机一个
	ItemType = case ItemType2 of
		[BeginItem, EndItem] -> 
			util:rand(BeginItem, EndItem);
		_ -> ItemType2
	end,
	ItemNum = case ItemNum2 of
		[BeginNum, EndNum] -> 
			util:rand(BeginNum, EndNum);
		_ -> ItemNum2
	end,
	ItemVal = case Val of
		0 -> fun_item_api:get_default_star(ItemType);
		_ -> Val
	end,
	{ItemType, ItemNum, ItemVal}.