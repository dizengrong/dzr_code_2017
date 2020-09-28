%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-4-15
%% Company : fbird.Co.Ltd
%% Desc : fun_item_use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_item_use).
-include("common.hrl").
-export([add_usr_item_times/4,add_usr_item_times/5,check_usr_item_times/2,req_item_use_time/3,refresh_datas/1]).

%% =============================================================================
get_use_times(Uid) -> 
	case mod_role_tab:lookup(Uid, t_use_item_times) of
		[] -> [];
		[#t_use_item_times{times = Times}] ->
			Times
	end.


get_use_times(Uid,ItemGroupId)->
	case lists:keyfind(ItemGroupId, 1, get_use_times(Uid)) of
		{_,Times}->Times;
		_->0
	end.


set_use_times(Uid, Times) ->
	case mod_role_tab:lookup(Uid, t_use_item_times) of
		[] -> 
			Rec = #t_use_item_times{uid = Uid, times = Times},
			mod_role_tab:insert(Rec#t_use_item_times.uid, Rec);
		[Rec = #t_use_item_times{}] ->
			mod_role_tab:insert(Rec#t_use_item_times.uid, Rec#t_use_item_times{times = Times})
	end.
%% =============================================================================

refresh_datas(Uid) -> 
	set_use_times(Uid, []).


%%添加使用次数
add_usr_item_times(Sid,Uid,ItemType,Num)->
	add_usr_item_times(Sid,Uid,ItemType,Num,0).
add_usr_item_times(Sid,Uid,ItemType,Num,Seq)->
	case data_item_groupId_by_item_type(ItemType) of
		0->skip;
		GroupType-> 
			GroupList = get_use_times(Uid),
			GroupList2 = case lists:keyfind(GroupType, 1, GroupList) of
				{_,Times}->
					lists:keyreplace(GroupType, 1, GroupList, {GroupType,Num+Times});
				_-> 
					[{GroupType,Num} | GroupList]
			end,
			set_use_times(Uid, GroupList2),
			send_usr_item_times_to_sid(Sid,Seq,GroupList2)
	end.

data_item_groupId_by_item_type(_ItemType)->0.

data_usr_item_times(Uid,ItemGroupId)->
	case data_uselimit_group:get_data(ItemGroupId) of
			#st_uselimit_group{limitTimes = LimitTimes}->
				case ItemGroupId of
					1->
						VipTime = fun_vip_jurisdiction:data_vip(exTaskUseTimes, Uid),
							VipTime+LimitTimes;
					_->LimitTimes
				end;
			_->0
	end.

check_usr_item_times(Uid,ItemType)->
	case data_item_groupId_by_item_type(ItemType) of
		0 -> true;
		ItemGroupId->
			VipTime = 
				case ItemGroupId of
					1->
						fun_vip_jurisdiction:data_vip(exTaskUseTimes, Uid);
					_->0
				end,
			DataTimes = data_usr_item_times(Uid,ItemGroupId)+VipTime,
			Times = get_use_times(Uid, ItemGroupId),
			Times < DataTimes
	end.


%%请求物品使用次数
req_item_use_time(Sid,Uid,Seq)->
	List = get_use_times(Uid),
	send_usr_item_times_to_sid(Sid, Seq, List).

send_usr_item_times_to_sid(Sid,Seq,List)->
	Fun = fun({ID,Time}) ->		
		#pt_public_use_item_groupId{group_id=ID,group_id_time=Time}
	end,
	NewList = lists:map(Fun, List),
	Pt = #pt_use_item_groupId{use_item_groupId=NewList},
	?send(Sid,proto:pack(Pt,Seq)).
