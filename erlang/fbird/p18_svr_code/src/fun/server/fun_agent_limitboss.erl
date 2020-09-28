%% 限时boss个人模块
-module(fun_agent_limitboss).
-include("common.hrl").
-export([handle/1]).
-export([req_buy_times/4,req_limitboss_time/4]).
-export([do_out_copy/2]).
-export([check_data/1]).

-define(SCENE, 500038).

check_data(Uid) ->
	Now = util_time:unixtime(),
	List = get_data(Uid, data),
	case List of
		[Time, BuyTime] -> set_data(Uid,[Time, BuyTime, Now]);
		[_, _, Last] ->
			case check_data_help(Now,Last) of
				true ->
					set_data(Uid,[util:get_data_para_num(1091),0,Now]);
				_ -> skip
			end;
		_ -> skip
	end.

check_data_help(Now,Last) ->
	case fun_system_activity:check_time_help(Now, ?SYSTEM_LIMIT_BOSS) of
		open ->
			{_, {H1, M1, _}} = util_time:seconds_to_datetime(Now),
			{_, {H2, M2, _}} = util_time:seconds_to_datetime(Last),
			case util_time:is_same_day(Now, Last) of 
				true -> 
					#st_activity{time=ActTime} = data_activity:get_data(?SYSTEM_LIMIT_BOSS),
					Fun = fun({Start,End}) ->
						case util_time:check_activity(Start,End,H1,M1) andalso util_time:check_activity(Start,End,H2,M2) of
							true -> false;
							false -> true
						end
					end,
					List = lists:filter(Fun, ActTime),
					?debug("List=~p",[List]),
					case length(List) >= length(ActTime) of
						true -> true;
						_ -> false
					end;
				_ -> true
			end;
		_ -> false
	end.

init_data(Uid) ->
	Now = util_time:unixtime(),
	Rec = #system_activity_usr{
		uid = Uid,
		act_type = ?SYSTEM_LIMIT_BOSS,
		act_data = util:term_to_string([util:get_data_para_num(1091),0,Now])
	},
	Rec.

get_data(Uid) ->
	case db:dirty_get(system_activity_usr, Uid, #system_activity_usr.uid) of
		[] -> init_data(Uid);
		List ->
			case lists:keyfind(?SYSTEM_LIMIT_BOSS, #system_activity_usr.act_type, List) of
				false -> init_data(Uid);
				Rec -> Rec
			end
	end.
get_data(Uid, data) ->
	NewList = case db:dirty_get(system_activity_usr, Uid, #system_activity_usr.uid) of
		[] -> 
			Rec = init_data(Uid),
			Rec#system_activity_usr.act_data;
		List ->
			case lists:keyfind(?SYSTEM_LIMIT_BOSS, #system_activity_usr.act_type, List) of
				false -> 
					Rec = init_data(Uid),
					Rec#system_activity_usr.act_data;
				Rec -> 
					Rec#system_activity_usr.act_data
			end
	end,
	% ?debug("NewList=~p",[NewList]),
	util:string_to_term(util:to_list(NewList)).

set_data(Uid, Val) ->
	Rec = get_data(Uid),
	NewRec = Rec#system_activity_usr{act_data=util:term_to_string(Val)},
	case Rec#system_activity_usr.id of
		0 -> db:insert(NewRec);
		_ -> db:dirty_put(NewRec)
	end.

handle({do_enter_copy, Seq, CopyId, Scene}) -> 
	do_enter_copy(get(uid), Seq, CopyId, Scene);
handle({on_act_open, Uid, Sid}) ->
	Now = util_time:unixtime(),
	set_data(Uid, [util:get_data_para_num(1091), 0, Now]),
	send_times_info_to_client(Uid, Sid, 0).

do_enter_copy(Uid, Seq, CopyId, Scene) ->
	Now = util_time:unixtime(),
	Sid = get(sid),
	case get_left_times(Uid) > 0 of
		false -> ?error_report(Sid, "error_common_no_times", Seq);
		true ->
			#st_scene_config{points = PointList} = data_scene_config:get_scene(Scene),
			InPos = hd(PointList),
			#st_dungeons_config{} = data_dungeons_config:get_dungeons(CopyId),
			UsrInfoList = [{Uid,Seq,InPos,#ply_scene_data{sid = Sid}}],
			put(limit_boss_time, Now + 180),
			gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList,Scene,{scene_data}}),
			do_reduce_copy_times(Uid, Sid, Seq)
	end.

do_out_copy(_Uid,_Now) ->
	todo.

get_left_times(Uid) -> 
	hd(get_data(Uid, data)).

do_reduce_copy_times(Uid, Sid, Seq) ->
	Now = util_time:unixtime(),
	[Time,BuyTime,_] = get_data(Uid, data),
	set_data(Uid,[Time-1,BuyTime,Now]),
	process_enter_copy(Uid, Sid),
	send_times_info_to_client(Uid, Sid, Seq).

send_times_info_to_client(Uid, Sid, Seq) ->
	[Time,BuyTime,_] = get_data(Uid, data),
	Pt = #pt_system_activity_limitboss{times = Time, buy_times = BuyTime},
	% ?debug("pt=~p",[Pt]),
	?send(Sid, proto:pack(Pt, Seq)).

req_limitboss_time(Uid, Sid, Seq, _CopyId) ->
	send_times_info_to_client(Uid, Sid, Seq).

req_buy_times(Uid, Sid, Seq, _CopyId) ->
	[Time,BuyTime,Last] = get_data(Uid, data),
	NewBuyTime = min(BuyTime + 1,data_buy_time_price:get_max_times(?BUY_LIMITBOSS)),
	case data_buy_time_price:get_data(?BUY_LIMITBOSS,NewBuyTime) of
		#st_buy_time_price{cost=Cost} ->
			SpendItems = [{?ITEM_WAY_LIMITBOSS,T,N} || {T,N} <- Cost],
			Succ = fun() ->
				set_data(Uid, [Time+1, BuyTime+1, Last]),
				send_times_info_to_client(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		_ -> skip
	end.

process_enter_copy(Uid, Sid) ->
	fun_task_count:process_count_event(limit_boss,{0,0,1},Uid,Sid).