%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name :  
%% author : Andy lee
%% date :  2016-4-13
%% Company : fbird.Co.Ltd
%% Desc : 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_recharge).
-include("common.hrl").
-export([load_recharge_data/1,request_first_recharge_data/2,gm_recharge_action/2,recharge_action/5]).
-export([get_total_recharge_by_time/3,check_trible_recharge/2,first_recharge_help/3]).

%%send to client record num
-define(RECORD_NUM,4).

%%extra prize state
-define(EXTRA_PRIZE_NOT_EXIST,0).
-define(FIRST_RECHARGE_DOUBLE,1).
-define(FIRST_RECHARGE_TRIBLE,2).
-define(FIRST_RECHARGE_DOUBLE_TEMP,3).

-define(FIRST_RECHARGE,  2).
-define(SECOND_RECHARGE, 1).
-define(OTHER_RECHARGE,  0).

%% -record(recharge_record, {id,uid=0,order_id="",money=0,platform=0,config_id=0,time=0}).
%% -record(recharge_error_record, {id,uid=0,order_id="",money=0,platform=0,config_id=0,time=0}).

%%load recharge data
load_recharge_data(Uid) ->
	dbm_worker:work({load, recharge_record, uid, list_to_binary(integer_to_list(Uid))}),
	dbm_worker:work({load, recharge_off_record, uid, list_to_binary(integer_to_list(Uid))}),
	refresh_recharge_data(Uid),
	login_off_recharge(Uid).

login_off_recharge(Uid) ->
	case db:dirty_get(ply, Uid) of
		[#ply{}] ->
			case db:dirty_get(recharge_off_record, Uid, #recharge_off_record.uid) of
				RecList when is_list(RecList) ->
					Fun=fun(#recharge_off_record{id=ID,order_id=OrderID,money=Money,platform=Platform,config_id=ConfigID}) ->
						db:dirty_del(recharge_off_record, ID),	
						recharge_online_action(Uid,OrderID,Money,Platform,ConfigID)								
					end,
					lists:foreach(Fun, RecList);			
				_ -> skip	
			end;
		_ -> skip
	end.

refresh_recharge_data(Uid) ->
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid=AgentHid,phone_type=PhoneType}] ->
			ConfigList = data_charge_config:get_all(PhoneType),
			List1 = fun_usr_misc:get_misc_data(Uid, first_recharge),
			List2 = db:dirty_get(recharge_record, Uid, #recharge_record.uid),
			case List1 == [] andalso List2 /= [] andalso fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_RESET_RECHARGE) == false of
				true -> 
					Fun = fun(ConfigID) ->
						case lists:keyfind(ConfigID, #recharge_record.config_id, List2) /= false andalso lists:keyfind(ConfigID, 1, List1) == false of
							true -> gen_server:cast(AgentHid,{first_recharge,Uid,ConfigID,PhoneType});
							_ -> skip
						end
					end,
					lists:foreach(Fun, ConfigList);
				_ -> skip
			end;
		_ -> skip
	end.

check_trible_recharge(Uid, PhoneType) ->
	All=data_charge_config:get_all(PhoneType),
	List = fun_usr_misc:get_misc_data(Uid, first_recharge),
	Fun = fun(ConfigId) ->
		case lists:keyfind(ConfigId, 1, List) of
			false -> false;
			_ -> true
		end
	end,
	case lists:filter(Fun, All) of
		[] -> true;
		_ -> false
	end. 

%%请求翻倍奖励数据
request_first_recharge_data(Uid,Seq) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid, phone_type = PhoneType}] ->
			All = data_charge_config:get_all(PhoneType),
			List = fun_usr_misc:get_misc_data(Uid, first_recharge),
			F = fun(ConfigID, Acc) ->
				case data_charge_config:get_data(ConfigID) of
					#st_charge_config{sort=Sort} when Sort == ?RECHARGE_SORT_NORMAL ->
						IsExist = case check_trible_recharge(Uid, PhoneType) of
							true -> ?FIRST_RECHARGE_TRIBLE;
							_ ->
								case lists:keyfind(ConfigID, 1, List) of
									false -> ?FIRST_RECHARGE_DOUBLE;
									{ConfigID, 1} -> ?FIRST_RECHARGE_DOUBLE;
									_ ->
										case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP) of
											{true, _} ->
												UsrActivityRec = fun_gm_activity_ex:get_usr_activity_data(Uid, ?GM_ACTIVITY_DOUBLE_RECHARGE_TEMP),
												FetchData = UsrActivityRec#gm_activity_usr.fetch_data,
												case lists:member(ConfigID, FetchData) of
													true -> ?EXTRA_PRIZE_NOT_EXIST;
													_ -> ?FIRST_RECHARGE_DOUBLE_TEMP
												end;
											_ -> ?EXTRA_PRIZE_NOT_EXIST
										end
								end
						end,
						Ptm = #pt_public_recharge_list{
							id = ConfigID,
							is_double = IsExist
						},
						[Ptm | Acc];
					_ -> Acc 
				end
			end,
			Pt=#pt_recharge_data{datas = lists:foldl(F, [], All)},
			?send(Sid,proto:pack(Pt, Seq));
		_ -> skip
	end.

%% client_req_recharge(Uid, _Sid, _Seq, RechargeConfigID) ->
%% %% 	?debug("client_req_recharge,RechargeConfigID=~p",[RechargeConfigID]),
%% 	case data_charge_config:get_data(RechargeConfigID) of
%% 		#st_charge_config{charge_money=Money} -> 
%% 			recharge_action(Uid, 123456, Money, 1, RechargeConfigID);			
%% 		_ -> skip	
%% 	end.	

gm_recharge_action(Uid, RechargeConfigID) ->
	?DBG(RechargeConfigID),
	case data_charge_config:get_data(RechargeConfigID) of
		#st_charge_config{charge_money=Money} ->
			% ?debug("gm recharge money:~p",[Money]),
			recharge_action(Uid, util:to_binary("123456"), Money, 1, RechargeConfigID);			
		_ -> skip	
	end.	
	
recharge_action(Uid, OrderId, Money, Platform, RechargeConfigID) ->
	?log_trace("recharge_action,Uid=~p,OrderId=~p,Money=~p,Platform=~p,RechargeConfigID=~p",[Uid,OrderId,Money,Platform,RechargeConfigID]),
	case check_recharge_config_id(RechargeConfigID) of
		true ->	
			case check_recharge_money(RechargeConfigID,Money) of
				true ->
					case db:get_usr(Uid, true) of
						[#usr{} | _ ] ->
							case db:dirty_get(ply, Uid) of
								[#ply{agent_hid=_AgentHid}] ->
									% ?debug("recharge online"),
									recharge_online_action(Uid,OrderId,Money,Platform,RechargeConfigID); 									
%% 									%%首次充值奖励
%% 									#st_charge_config{first_prize_sort=FirstSort,first_prize_num=FirstNum}=data_charge_config:get_data(RechargeConfigID),									
%% 									{FPrizeSort,FPrizeNum}=case check_first_recharge(Uid,RechargeConfigID) of
%% 																	   true -> {FirstSort,FirstNum};
%% 																	   _ -> {0,0}		
%% 																   end,									
%% 									if
%% 										FPrizeNum == 0 -> skip;
%% 										true -> add_first_recharge_prize(Uid,AgentHid,FPrizeSort,FPrizeNum)
%% 									end,								
%% 									%%充值记录插入数据库
%% 									db:insert(#recharge_record{uid=Uid,order_id=util:to_binary(OrderId),money=Money,platform=Platform,config_id=RechargeConfigID,time=util:unixtime()}),
%% 									add_diamond(Uid,AgentHid,RechargeConfigID),
%% 									send_msg(Uid,RechargeConfigID), 									
%% 									recharge_activity(Uid,AgentHid,RechargeConfigID);													
								_ ->
									%%处理离线充值事件
									?log_trace("offonline recharge action,uid=~p,RechargeConfigID=~p",[Uid,RechargeConfigID]),
									db:insert(#recharge_off_record{uid=Uid,order_id=util:to_binary(OrderId),money=Money,platform=Platform,config_id=RechargeConfigID,time=util:unixtime()})												

							end;
						_ -> 
							?log_error("recharge_action,can not find usr,uid=~p", [Uid]),
							db:insert(#recharge_error_record{uid=Uid,order_id=util:to_binary(OrderId),money=Money,platform=Platform,config_id=RechargeConfigID,time=util:unixtime()})
					end;				
				_ ->
					?log_error("recharge_error,config not find,RechargeConfigID=~p",[RechargeConfigID]),
					db:insert(#recharge_error_record{uid=Uid,order_id=util:to_binary(OrderId),money=Money,platform=Platform,config_id=RechargeConfigID,time=util:unixtime()})	
			end;
		_ -> 
			?log_error("recharge_error,config not find,RechargeConfigID=~p",[RechargeConfigID]),
			db:insert(#recharge_error_record{uid=Uid,order_id=util:to_binary(OrderId),money=Money,platform=Platform,config_id=RechargeConfigID,time=util:unixtime()})
	end.

recharge_online_action(Uid,OrderId,Money,Platform,RechargeConfigID) ->
	?log_trace("recharge_online_action,Uid=~p,OrderId=~p,Money=~p,Platform=~p,RechargeConfigID=~p",[Uid,OrderId,Money,Platform,RechargeConfigID]),
	case db:dirty_get(ply, Uid) of
		[#ply{aid=Aid,sid=_Sid,agent_hid=AgentHid,phone_type=PhoneType}] ->
			
			%%首次充值奖励
			[#usr{lev = Lev, vip_lev = _VipLev}] = db:dirty_get(usr, Uid),
			#st_charge_config{first_prize_num=First,second_prize_num=Second}=data_charge_config:get_data(RechargeConfigID),
			% case Lev >= NeedLev andalso VipLev >= NeedVipLev of
			% 	true ->
					FPrize = case check_first_recharge(Uid,RechargeConfigID,PhoneType) of
						?FIRST_RECHARGE -> 
							fun_dataCount_update:recharge(Uid, Aid,Lev, 1, Money, Platform,OrderId),
							First;
						?SECOND_RECHARGE -> 
							fun_dataCount_update:recharge(Uid, Aid,Lev, 1, Money, Platform,OrderId),
							Second;
						_ -> 
							fun_dataCount_update:recharge(Uid, Aid,Lev, 0, Money, Platform,OrderId),
							[]		
					end,
					
					%%充值记录插入数据库
					db:insert(#recharge_record{uid=Uid,order_id=util:to_binary(OrderId),money=Money,platform=Platform,config_id=RechargeConfigID,time=util:unixtime()}),
					PriceNum = add_diamond(Uid,AgentHid,RechargeConfigID),
					%%每日充值奖励
					case check_day_first_recharge(Uid) of
						true -> ok;%%gen_server:cast(AgentHid, {day_first_recharge,Uid,PriceNum});
						_->skip
					end,
					%%充值活动相关
					gen_server:cast(AgentHid,{on_usr_recharge,Uid,PriceNum,RechargeConfigID}),
					send_msg(Uid,RechargeConfigID),
					%%跨服活动相关处理
					recharge_activity(Uid,AgentHid,RechargeConfigID),
					% fun_agent_mng:send_count_event(Uid, charge_diamo, 0, ?RESOUCE_COIN_NUM, PriceNum+FPrizeNum),
					case FPrize of
						[] -> skip;
						_ -> 
							gen_server:cast(AgentHid,{first_recharge,Uid,RechargeConfigID,PhoneType}),
							add_first_recharge_prize(Uid,AgentHid,FPrize)
					end;
			% 	_ -> skip
			% end;
		_ -> skip	
	end.

send_msg(Uid,RechargeConfigID) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid}] -> 
			Pt=#pt_recharge_succ{
				recharge_id = RechargeConfigID
			},
			?send(Sid,proto:pack(Pt));
		_ -> skip					
	end.

%%添加钻石	
add_diamond(Uid,AgentHid,RechargeConfigID) ->
	case data_charge_config:get_data(RechargeConfigID) of
		#st_charge_config{diamond=Diamond} ->
%% 			?debug("add_diamond,Diamond=~p",[Diamond]),
			gen_server:cast(AgentHid, {add_resoure,Uid,[{?RESOUCE_COIN_NUM, Diamond}], ?ITEM_WAY_RECHARGE}),
			Diamond;
		_ -> 0		
	end.

%%添加首次充值翻倍奖励
add_first_recharge_prize(Uid,AgentHid,List) ->
	gen_server:cast(AgentHid, {add_resoure, Uid, List, ?ITEM_WAY_FIRST_RECHARGE}).
	
%%充值活动
recharge_activity(Uid,AgentHid,RechargeConfigID) ->
	first_recharge_activity(Uid,AgentHid,RechargeConfigID), 
	case data_charge_config:get_data(RechargeConfigID) of
		#st_charge_config{sort=?RECHARGE_SORT_NORMAL} -> skip;
		#st_charge_config{sort=Sort} ->
			gen_server:cast(AgentHid, {recharge_activity,Uid,Sort});
		_ -> skip	
	end.
%%首充活动
first_recharge_activity(Uid,AgentHid,RechargeConfigID) ->
	Len=case db:dirty_get(recharge_record,Uid,#recharge_record.uid) of
			L when erlang:is_list(L) -> length(L);
			_ -> 0			
		end,
	case data_charge_config:get_data(RechargeConfigID) of	
		#st_charge_config{vip_exp=VipExp,charge_money=Money} ->		
			gen_server:cast(AgentHid, {first_recharge_activity,Uid,Len,VipExp,Money});
		_ -> skip	
	end.

check_day_first_recharge(Uid) ->
	Now=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Now),
	Today=Now-3600*H-60*M-S,
	Tomorrow=Today+3600*24,
	     
	case db:dirty_select(recharge_record, [{#recharge_record{time='$1',uid='$2', _='_'},[{'==','$2', Uid},{'>','$1', Today},{'<','$1', Tomorrow}],['$_']}])	 of
		Datas  when  length(Datas)==1 -> true;
		_R -> false
	end.

check_first_recharge(Uid,ConfigID,PhoneType) ->
	case check_trible_recharge(Uid, PhoneType) of
		true -> ?FIRST_RECHARGE;
		_ ->
			List = fun_usr_misc:get_misc_data(Uid, first_recharge),
			case lists:keyfind(ConfigID, 1, List) of
				false -> ?SECOND_RECHARGE;
				{ConfigID, 1} -> ?SECOND_RECHARGE;
				_ -> ?OTHER_RECHARGE
			end
	end.

check_recharge_config_id(ID) ->
	case data_charge_config:get_data(ID) of
		#st_charge_config{} -> true;			
		_ -> false	
	end.

check_recharge_money(RechargeConfigID,Money) ->
	case data_charge_config:get_data(RechargeConfigID) of
		#st_charge_config{charge_money=Money} -> true;			
		_ -> false	
	end.

%% 获取位于区间[StartSec, EndSec]中的总的充值额
get_total_recharge_by_time(Uid, StartSec, EndSec) ->
	RechargeList = db:dirty_get(recharge_record, Uid, #recharge_record.uid),
	get_total_recharge_help(RechargeList, StartSec, EndSec, 0).


get_total_recharge_help([], _StartSec, _EndSec, Total) -> Total;
get_total_recharge_help([Rec | Rest], StartSec, EndSec, Total) ->
	ReChargeTime = Rec#recharge_record.time,
	Total2 = case ReChargeTime >= StartSec andalso ReChargeTime =< EndSec of
		true  -> 
			#st_charge_config{
				diamond = Diamond
			} = data_charge_config:get_data(Rec#recharge_record.config_id),
			Total + Diamond;
		false -> Total
	end,
	get_total_recharge_help(Rest, StartSec, EndSec, Total2).

first_recharge_help(Uid,RechargeConfigID,PhoneType) ->
	List = fun_usr_misc:get_misc_data(Uid, first_recharge),
	case lists:keyfind(RechargeConfigID, 1, List) of
		false ->
			NewList = case fun_recharge:check_trible_recharge(Uid, PhoneType) of
				true -> [{RechargeConfigID, 1} | List];
				_ -> [{RechargeConfigID, 2} | List]
			end,
			fun_usr_misc:set_misc_data(Uid, first_recharge, NewList);
		{RechargeConfigID, 1} ->
			NewList = lists:keystore(RechargeConfigID, 1, List, {RechargeConfigID, 2}),
			fun_usr_misc:set_misc_data(Uid, first_recharge, NewList);
		_ -> skip
	end.