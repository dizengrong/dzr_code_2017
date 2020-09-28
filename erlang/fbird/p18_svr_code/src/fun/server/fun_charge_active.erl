-module(fun_charge_active).
-include("common.hrl").
-export([update_charge_reward_schedule/3,add_charge_rewards/2,send_info_to_client/2,req_info/3,gm_update_card/3]).

-define(CARD_LIST, [?CHARGE_ACTIVE_WEEK_CARD,?CHARGE_ACTIVE_MONTH_CARD,?CHARGE_ACTIVE_LIVE_CARD]).

gm_update_card(Uid, _Sid, Type) ->
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	case lists:keyfind(Type,#usr_charge_active.sort,List) of
		#usr_charge_active{schedule=Sc} = Old ->
			db:dirty_put(Old#usr_charge_active{schedule=max(0,Sc-3600*24)}),
			update_charge_reward_schedule(Uid, Type, 0);
		_ -> skip
	end.

req_info(Uid, Sid, _Seq) ->
	send_info_to_client(Uid, Sid).

send_info_to_client(Uid, Sid) ->
	[send_info_to_client(Uid, Sid, Type) || Type <- ?CARD_LIST].
send_info_to_client(Uid, Sid, Type) ->
	Time=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Time),
	Today=Time-(3600*H+60*M+S),
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	case lists:keyfind(Type, #usr_charge_active.sort, List) of
		#usr_charge_active{schedule=Sc} ->
			Res=((Sc-Today)div(3600*24)),
			case Type of
				?CHARGE_ACTIVE_WEEK_CARD -> Date = Res;
				?CHARGE_ACTIVE_MONTH_CARD -> Date = Res;
				?CHARGE_ACTIVE_LIVE_CARD -> Date = Sc
			end,
			Pt = #pt_charge_card{
				sort=Type,
				date=Date
			},
			?send(Sid,proto:pack(Pt));
		_ -> 
			Pt = #pt_charge_card{
				sort=Type,
				date=-1
			},
			?send(Sid,proto:pack(Pt))
	end.

add_charge_rewards(Uid, ?CHARGE_ACTIVE_WEEK_CARD)->
	Time=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Time),
    Today=Time-3600*H-60*M-S,
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	% ?debug("List:~p~n",[List]),
	case lists:keyfind(?CHARGE_ACTIVE_WEEK_CARD,#usr_charge_active.sort,List) of
		#usr_charge_active{schedule=Schedule} = Old ->
			db:dirty_put(Old#usr_charge_active{schedule=Schedule+7*3600*24}),
			send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_WEEK_CARD),
			fun_task_count:process_count_event(task_week_card,{0,0,1},Uid,util:get_sid_by_uid(Uid));
		_ ->
			db:insert(#usr_charge_active{uid=Uid,sort=?CHARGE_ACTIVE_WEEK_CARD,time=Today,schedule=Today+6*3600*24,last_reward=?FALSE_OF_INT}),
			update_charge_reward_schedule(Uid, ?CHARGE_ACTIVE_WEEK_CARD,1),
			fun_task_count:process_count_event(task_week_card,{0,0,1},Uid,util:get_sid_by_uid(Uid))
	end;
add_charge_rewards(Uid, ?CHARGE_ACTIVE_MONTH_CARD)->
	Time=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Time),
    Today=Time-3600*H-60*M-S,
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	% ?debug("List:~p~n",[List]),
	case lists:keyfind(?CHARGE_ACTIVE_MONTH_CARD,#usr_charge_active.sort,List) of
		#usr_charge_active{schedule=Schedule} = Old ->
			db:dirty_put(Old#usr_charge_active{schedule=Schedule+30*3600*24}),
			send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_MONTH_CARD),
			fun_task_count:process_count_event(task_month_card,{0,0,1},Uid,util:get_sid_by_uid(Uid));
		_ ->
			db:insert(#usr_charge_active{uid=Uid,sort=?CHARGE_ACTIVE_MONTH_CARD,time=Today,schedule=Today+29*3600*24,last_reward=?FALSE_OF_INT}),
			update_charge_reward_schedule(Uid, ?CHARGE_ACTIVE_MONTH_CARD,1),
			fun_task_count:process_count_event(task_month_card,{0,0,1},Uid,util:get_sid_by_uid(Uid))
	end;
add_charge_rewards(Uid, ?CHARGE_ACTIVE_LIVE_CARD)->
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	% ?debug("List:~p~n",[List]),
	case lists:keyfind(?CHARGE_ACTIVE_LIVE_CARD,#usr_charge_active.sort,List) of
		false ->
			db:insert(#usr_charge_active{uid=Uid,sort=?CHARGE_ACTIVE_LIVE_CARD,time=util:unixtime(),schedule=1,last_reward= 0}),
			fun_task_count:process_count_event(task_live_card,{0,0,1},Uid,util:get_sid_by_uid(Uid)),
			update_charge_reward_schedule(Uid, ?CHARGE_ACTIVE_LIVE_CARD,1);
		_ -> skip
	end;
add_charge_rewards(_,_) -> ok.

get_card_reward(RewardList) ->
	Fun = fun({T,_}) ->
		T /= 30
	end,
	lists:filter(Fun, RewardList).

update_charge_reward_schedule(Uid, ?CHARGE_ACTIVE_WEEK_CARD,_Data)->
	Time=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Time),
	Today=Time-(3600*H+60*M+S),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(week_bonus),
	RechargeConfigID = data_charge_config:select_id_by_sort(?CHARGE_ACTIVE_WEEK_CARD),
	#st_charge_config{membership_reward=RewardList} = data_charge_config:get_data(hd(RechargeConfigID)),
	Reward = get_card_reward(RewardList),
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	% ?debug("List1:~p~n",[List]),
	case lists:keyfind(?CHARGE_ACTIVE_WEEK_CARD,#usr_charge_active.sort,List) of  
		#usr_charge_active{id=Id,schedule=Sc} = Old ->
			case Sc =< Today of
				true ->
					db:dirty_del(usr_charge_active, Id),
					send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_WEEK_CARD),
					mod_mail_new:sys_send_personal_mail(Uid,Title,Content,Reward,?MAIL_TIME_LEN);
				_ ->
					db:dirty_put(Old#usr_charge_active{time=Today,last_reward=?FALSE_OF_INT}),
					send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_WEEK_CARD),
					mod_mail_new:sys_send_personal_mail(Uid,Title,Content,Reward,?MAIL_TIME_LEN)
				end;
		_-> send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_WEEK_CARD)
	end;
update_charge_reward_schedule(Uid, ?CHARGE_ACTIVE_MONTH_CARD,_Data)->
	Time=util:unixtime(),
	{_,{H,M,S}}=util:unix_to_localtime(Time),
	Today=Time-(3600*H+60*M+S),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(monthly_bonus),
	RechargeConfigID = data_charge_config:select_id_by_sort(?CHARGE_ACTIVE_MONTH_CARD),
	#st_charge_config{membership_reward=RewardList} = data_charge_config:get_data(hd(RechargeConfigID)),
	Reward = get_card_reward(RewardList),
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	% ?debug("List1:~p~n",[List]),
	case lists:keyfind(?CHARGE_ACTIVE_MONTH_CARD,#usr_charge_active.sort,List) of  
		#usr_charge_active{id=Id,schedule=Sc} = Old ->
			case Sc =< Today of
				true ->
					db:dirty_del(usr_charge_active, Id),
					send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_MONTH_CARD),
					mod_mail_new:sys_send_personal_mail(Uid,Title,Content,Reward,?MAIL_TIME_LEN);
				_ ->
					db:dirty_put(Old#usr_charge_active{time=Today,last_reward=?FALSE_OF_INT}),
					send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_MONTH_CARD),
					mod_mail_new:sys_send_personal_mail(Uid,Title,Content,Reward,?MAIL_TIME_LEN)
				end;
		_-> send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_MONTH_CARD)
	end;
update_charge_reward_schedule(Uid, ?CHARGE_ACTIVE_LIVE_CARD,_Data)->
	List = db:dirty_get(usr_charge_active, Uid, #usr_charge_active.uid),
	% ?debug("List:~p~n",[List]),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(lifetime_bonus),
	case lists:keyfind(?CHARGE_ACTIVE_LIVE_CARD,#usr_charge_active.sort,List) of  
		#usr_charge_active{schedule=Sc}=Old ->
			db:dirty_put(Old#usr_charge_active{schedule=Sc+1}),
			RechargeConfigID = data_charge_config:select_id_by_sort(?CHARGE_ACTIVE_LIVE_CARD),
			?debug("RechargeConfigID=~p",[hd(RechargeConfigID)]),
			#st_charge_config{membership_reward=RewardList} = data_charge_config:get_data(hd(RechargeConfigID)),
			Reward = get_card_reward(RewardList),
			send_info_to_client(Uid, get(sid), ?CHARGE_ACTIVE_LIVE_CARD),
			mod_mail_new:sys_send_personal_mail(Uid,Title,Content,Reward,?MAIL_TIME_LEN);
		_-> skip
	end;
update_charge_reward_schedule(_,_,_)->ok.