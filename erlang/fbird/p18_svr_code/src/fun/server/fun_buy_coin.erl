%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-5-13
%% Company : fbird.Co.Ltd
%% Desc : fun_buy_coin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_buy_coin).
-include("common.hrl").
-export([req_buy_coin/3,auto_refresh_time/1,send_buy_coin/4,gm_reset_times/2,refresh_free_time/1,init_buy_coin/1]).

-define(BUY_SUCC,1).

-define(FREE,0).
-define(NOT_FREE,1).

%%请求购买金币
req_buy_coin(Uid,Sid,Seq)->
	Time = fun_vip:get_privilege_added(buygoldtimes, Uid),
	{BuyTime,FreeTime} = get_buy_coin(Uid),
	if FreeTime > 0 ->
		Minutes = util:get_data_para_num(1082),
		GoldReward = get_coin(Uid, Minutes),
		AddItems = [{?ITEM_WAY_BUY_COIN, ?RESOUCE_COPPER_NUM, GoldReward}],
		Succ = fun() ->
			put_buy_coin(Uid,?FREE),
			fun_task_count:process_count_event(task_buy_coin,{0,0,1},Uid,Sid),
			send_buy_coin(Sid,Uid,Seq,?BUY_SUCC)
		end,
		fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
	BuyTime < Time ->
		case data_buyGold_config:get_data(BuyTime+1) of
			#st_buyGold_config{diamondCost= DiamondCost,minutes= Minutes}->
				GoldReward = get_coin(Uid, Minutes),
				AddItems = [{?ITEM_WAY_BUY_COIN, ?RESOUCE_COPPER_NUM, GoldReward}],
				SpendItems = [{?ITEM_WAY_BUY_COIN, ?RESOUCE_COIN_NUM, DiamondCost}],
				Succ = fun() ->
					put_buy_coin(Uid,?NOT_FREE),
					fun_task_count:process_count_event(task_buy_coin,{0,0,1},Uid,Sid),
					send_buy_coin(Sid,Uid,Seq,?BUY_SUCC)
				end,
				fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, Succ, undefined);
			_ -> skip
		end;
	true -> skip
	end.

get_coin(_Uid, _Minutes) -> 0.
	% BarrierId = mod_scene_lev:get_curr_scene_lv(Uid),
	% TotalTimes = get_total_times(Uid),
	% #st_dungeons_config{offLineMoneyGet = BaseCoin, multi = Multi} = data_dungeons_config:get_dungeons(BarrierId),
	% TalEffect = case fun_talent:get_talent_effect(Uid, ?TALENT_ADD_BUY_COIN) of
	% 	[] -> 1;
	% 	EffectList ->
	% 		Fun = fun(Effect, Acc) -> Effect + Acc end,
	% 		1 + (lists:foldl(Fun, 0, EffectList) / 10000)
	% end,
	% util:ceil(util:floor(BaseCoin*(Minutes + min(TotalTimes, util:get_data_para_num(1022)))*Multi)*TalEffect).

%%获取金币次数
get_buy_coin(Uid)->
	case db:dirty_get(buy_coin, Uid,#buy_coin.uid) of
		[#buy_coin{free_buy_coin=FreeTime,times=Times}] -> {Times,FreeTime};
		_ -> {0,0}
	end.

get_total_times(Uid) ->
	case db:dirty_get(buy_coin, Uid,#buy_coin.uid) of
		[#buy_coin{total_times=T}|_]->T;
		_ -> 0
	end.

get_retime(Uid) ->
	case db:dirty_get(buy_coin, Uid,#buy_coin.uid) of
		[#buy_coin{free_re_time=T}] -> T + util:get_data_para_num(1080) * 3600;
		_ -> 0
	end.

%%put金币次数
put_buy_coin(Uid,?FREE)->
	Now = util:unixtime(),
	TadayTime=util:get_relative_day(?AUTO_REFRESH_TIME),
	case db:dirty_get(buy_coin, Uid,#buy_coin.uid) of
		[BuyCoin = #buy_coin{free_buy_coin=Times,free_re_time=ReTime}]->
			case Times == util:get_data_para_num(1081) of
				true -> NewTime = Now;
				_ -> NewTime = ReTime
			end,
			TotalTimes = min(BuyCoin#buy_coin.total_times+1, util:get_data_para_num(1022)),
			db:dirty_put(BuyCoin#buy_coin{total_times=TotalTimes,free_buy_coin=Times-1,free_re_time=NewTime});
		_ -> 
			db:insert(#buy_coin{total_times=1,times=0,uid=Uid,day_time=TadayTime,free_buy_coin=util:get_data_para_num(1081)-1,free_re_time=Now})
	end;
put_buy_coin(Uid,?NOT_FREE)->
	case db:dirty_get(buy_coin, Uid,#buy_coin.uid) of
		[BuyCoin = #buy_coin{times=Times}]->
			TotalTimes = min(BuyCoin#buy_coin.total_times+1, util:get_data_para_num(1022)),
			db:dirty_put(BuyCoin#buy_coin{total_times=TotalTimes,times=Times+1});
		_ -> skip
	end.
	
gm_reset_times(Uid, _Sid) ->
	case db:dirty_get(buy_coin, Uid, #buy_coin.uid) of
		[Rec=#buy_coin{} | _] ->			
			db:dirty_put(Rec#buy_coin{times=0});
		_ -> skip
	end.

send_buy_coin(Sid,Uid,Seq,Status)->
	{BuyTime,FreeTime} = get_buy_coin(Uid),
	TotalTimes = get_total_times(Uid),
	case FreeTime > 0 of
		true -> Minutes = util:get_data_para_num(1082);
		_ -> #st_buyGold_config{minutes= Minutes} = data_buyGold_config:get_data(BuyTime+1)
	end,
	case FreeTime >= util:get_data_para_num(1081) of
		true -> ReTime = 0;
		_ -> ReTime = get_retime(Uid)
	end,
	Pt = #pt_buy_coin{free_times=FreeTime,re_time=ReTime,total_times=TotalTimes,buy_coin_time=BuyTime,coin=get_coin(Uid, Minutes),status=Status},
	?send(Sid,proto:pack(Pt, Seq)).


%%每天更新签到状态
auto_refresh_time(Uid) ->
	TadayTime=util:get_relative_day(?AUTO_REFRESH_TIME),
	case db:dirty_get(buy_coin, Uid,#buy_coin.uid) of  
		[BuyCoin = #buy_coin{}] ->  
			db:dirty_put(BuyCoin#buy_coin{times=0,day_time=TadayTime});
		_ -> skip
	end.	

refresh_free_time(Uid) ->
	Now = util:unixtime(),
	CD = util:get_data_para_num(1080) * 3600,
	case db:dirty_get(buy_coin, Uid, #buy_coin.uid) of
		[BuyCoin = #buy_coin{free_buy_coin=Times,free_re_time=LastTime}] ->
			case Now >= LastTime + CD andalso Times < util:get_data_para_num(1081) of
				true ->
					db:dirty_put(BuyCoin#buy_coin{free_buy_coin=Times+1,free_re_time=Now}),
					refresh_free_time(Uid);
				_ -> skip
			end;
		_ -> skip
	end.

init_buy_coin(Uid) ->
	Now = util:unixtime(),
	TadayTime=util:get_relative_day(?AUTO_REFRESH_TIME),
	case db:dirty_get(buy_coin, Uid, #buy_coin.uid) of
		[#buy_coin{}] -> refresh_free_time(Uid);
		_ -> db:insert(#buy_coin{total_times=0,times=0,uid=Uid,day_time=TadayTime,free_buy_coin=util:get_data_para_num(1081),free_re_time=Now})
	end.