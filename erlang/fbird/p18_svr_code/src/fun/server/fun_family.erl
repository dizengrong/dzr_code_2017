-module(fun_family).
-include("common.hrl").
-export([check_time/1,enable_home/1,on_pass_copy/1,begin_upgrade_building/1,req_building_list/4,on_building_upgrade_complete/1,early_get_hall_reward/1]).
-export([req_upgrade_building/4,refresh_meeting_time/1,req_fast_end/4,init_family/1,check_achieve/2]).
-export([req_meeting/4,req_meeting_help/3,req_hall_reward/4,begin_meeting/4,req_join_meeting/5,on_meeting_complete/1,on_hall_rest_complete/1,get_hall_reward/5]).
-export([req_mine_reward/4,get_mine_reward_complete/2,req_settled_helper/5,settled_commander/5,settled_worker/6,req_remove_commander/4,on_worker_leave_timer/1,req_quick_mine/4,on_quick_mine/1]).
-export([req_study_skill/5,upgrade_institue_skill/3,update_fighting/1,get_prop/1,get_fighting/1]).
-export([join_meeting_from_other_server/1,join_result_from_other_server/1]).
% -export([agnet_check_hero/2]).

-define(MAX_WORK_NUM,3). %% 最大帮佣数量
-define(WORK_NUM_LIST,[1,2,3]). %% 帮佣位置列表

% -define(BUILDING_TYPE_STONE_MINE,	4).	%% 石头矿
% -define(BUILDING_TYPE_LUMBER_MILL,	5).	%% 伐木场
% -define(BUILDING_TYPE_FACTORY,		6).	%% 工厂

-define(LOCK,		0).%% 未解锁
-define(UNLOCK,		1).%% 已解锁

-define(REST,		0).%% 休息
-define(UPGRADE,	1).%% 升级
-define(WORK,		2).%% 工作
-define(GETREWARD,	3).%% 可领奖
-define(CD,			4).%% CD中

-define(is_res_building(Type), Type == ?BUILDING_TYPE_GOLD_MINE
						orelse Type == ?BUILDING_TYPE_FARM_MINE).

-record(hall_data, {friend_list=[],work_end_time=0}).
-record(mine_data, {commander=[],work_list=[],begin_time=0}).
-record(institue_data, {skill_list=[]}).
-record(institue_skill, {status=0,type=0,lev=0}).
-record(settled_info, {id=0,uid=0,name="",hero_id=0,hero_lev=0,fighting=0,leave_time=0}).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%% global function
%%%%%%%%%%%%%%%%%%%%%%%%%%
do_join_meeting_to_global(Uid, TargetServerId, TargetUid, Name) ->
	Msg = {join_meeting_to_other_server, Uid, TargetServerId, TargetUid, Name},
	gen_server:cast({global, global_client}, Msg).

send_join_result_to_from_server(IsSucc, FromServerID, FromUid) ->
	Msg = {join_result_to_from_server, IsSucc, FromServerID, FromUid},
	gen_server:cast({global, global_client}, Msg).
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% family_mng function
%%%%%%%%%%%%%%%%%%%%%%%%%%
check_time(Now) ->
	List = db:dirty_match(home_building, #home_building{_='_'}),
	Fun = fun(#home_building{id=BuildingId,type=Type,upgrade_end_time=UpgradeEndTime,rest_end_time=RestEndTime,data=Data}) ->
		if UpgradeEndTime > Now orelse UpgradeEndTime == 0 -> skip;
			true -> 
				on_building_upgrade_complete(BuildingId)
		end,
		if  RestEndTime > Now orelse RestEndTime == 0 -> skip;
			true -> on_hall_rest_complete(BuildingId)
		end,
		Rec = deserialize_data(Data),
		case Type of
			?BUILDING_TYPE_HALL -> 
				if Rec#hall_data.work_end_time > Now orelse Rec#hall_data.work_end_time == 0 -> skip;
					true -> on_meeting_complete(BuildingId)
				end;
			?BUILDING_TYPE_GOLD_MINE -> 
				List1 = Rec#mine_data.work_list,
				[check_work_leave(BuildingId, List1, Now, Id) || Id <- ?WORK_NUM_LIST];
			?BUILDING_TYPE_FARM_MINE -> 
				List1 = Rec#mine_data.work_list,
				[check_work_leave(BuildingId, List1, Now, Id) || Id <- ?WORK_NUM_LIST];
			_ -> skip
		end
	end,
	lists:foreach(Fun, List).

check_work_leave(BuildingId, List, Now, Id) ->
	case lists:keyfind(Id, #settled_info.id, List) of
		#settled_info{uid=Uid,leave_time=LeaveTime} ->
			case LeaveTime > Now of
				true -> skip;
				_ -> on_worker_leave_timer({Uid, BuildingId})
			end;
		_ -> skip
	end.

enable_home(Uid) -> active_buildings(Uid).

req_building_list(Uid, Sid, TargetUid, Seq) ->
	Ret = db:dirty_get(home_building, TargetUid, #home_building.uid),
	% ?debug("Uid:~p",[Uid]),
	% ?debug("TargetUid:~p",[TargetUid]),
	case length(Ret) > 0 of
		true -> 
			Fun = fun(Home = #home_building{id=Id,type=Type,lev=Lev,status=Status,upgrade_end_time=UpgradeEndTime,rest_end_time=RestEndTime,data=Data}) ->
				Rec = deserialize_data(Data),
				Now = util_time:unixtime(),
				case Type of
					?BUILDING_TYPE_HALL ->
						#st_building_hall{base_reward=RewardList, add_reward=AddRrwardList} = data_building_hall:get_data(Lev),
						PartNum = length(Rec#hall_data.friend_list),
						Fun1 = fun({Type1, Num}) -> {Type1, Num * PartNum} end,
						NewList = lists:map(Fun1, AddRrwardList),
						Status1 = Status,
						AddItems = lists:append(RewardList,NewList),
						Num = length(Rec#hall_data.friend_list),
						NameList = [#pt_public_friend_name_list{name=util:to_list(Name)} || Name <- Rec#hall_data.friend_list],
						NewRewardList = fun_item_api:make_item_pt_list(AddItems),
						Commander = [],
						WorkList = [],
						GetTime = 0,
						QuickMine = 0,
						InstitueSkillList = [],
						WorkEndTime = Rec#hall_data.work_end_time;
					?BUILDING_TYPE_INSTITUE ->
						% ?debug("Rec=~p",[Rec]),
						Num = 0,
						Status1 = Status,
						NewRewardList = [],
						WorkEndTime = 0,
						Commander = [],
						WorkList = [],
						GetTime = 0,
						QuickMine = 0,
						NameList = [],
						SkillList = Rec#institue_data.skill_list,
						Fun = fun(#institue_skill{status=SkillStatus,type=SkillType,lev=SkillLev}) ->
							#pt_public_institue_skill_list{
								status = SkillStatus,
								skill_id = SkillType,
								skill_lev = SkillLev
							}
						end,
						InstitueSkillList = lists:map(Fun, SkillList);
					_ -> 
						BeginTime = Rec#mine_data.begin_time,
						CommanderList = Rec#mine_data.commander,
						OriWorkList = Rec#mine_data.work_list,
						case Type of
							?BUILDING_TYPE_GOLD_MINE ->
								#st_building_goldfield{house_num=MaxHouse,storage_num=StorageNum,pre_hour_num=PreHourNum,one_helper=OneHelper,two_helper=TwoHelper,three_helper=ThreeHelper} = data_building_goldfield:get_data(Lev),
								QuickMine = 0;
							?BUILDING_TYPE_FARM_MINE ->
								#st_building_farm{house_num=MaxHouse,storage_num=StorageNum,pre_hour_num=PreHourNum,one_helper=OneHelper,two_helper=TwoHelper,three_helper=ThreeHelper} = data_building_farm:get_data(Lev),
								QuickMine = fun_usr_misc:get_misc_data(Uid, buy_farm_times)
						end,
						WorkTimes1 = work_times(Now, BeginTime,PreHourNum,StorageNum),
						WorkTimes = case WorkTimes1 >= 0 of
							true -> WorkTimes1;
							_ -> 
								NewRec = Rec#mine_data{begin_time = Now},
								NewData = serialize_data(NewRec),
								db:dirty_put(Home#home_building{data = NewData}),
								0
						end,
						case Status == ?UPGRADE of
							true -> 
								GetTime = 0,
								WorkEndTime = 0,
								Status1 = Status;
							_ -> 
								% ?debug("WorkTimes=~p",[WorkTimes]),
								case WorkTimes > 0 of
									true -> Status1 = ?GETREWARD;
									_ -> Status1 = ?WORK
								end,
								case WorkTimes >= MaxHouse of
									true -> 
										WorkEndTime = 0,
										GetTime = MaxHouse;
									_ -> 
										WorkEndTime = util:ceil(end_one_time(Now, BeginTime, PreHourNum, StorageNum)),
										GetTime = WorkTimes
								end
						end,
						% ?debug("Type=~p",[Type]),
						% ?debug("WorkTimes=~p",[GetTime]),
						% ?debug("Status=~p",[Status1]),
						% ?debug("WorkEndTime=~p",[WorkEndTime]),
						Num = 0,
						InstitueSkillList = [],
						NewRewardList = [],
						NameList = [],
						case length(OriWorkList) of
							1 -> Add_Ratio2 = OneHelper;
							2 -> Add_Ratio2 = TwoHelper;
							3 -> Add_Ratio2 = ThreeHelper;
							_ -> Add_Ratio2 = 0
						end,
						Fun2 = fun(#settled_info{id=RId,uid=RUid,name=RName,hero_id=RHeroType,hero_lev=RHeroLev,fighting=RFighting,leave_time=RLeaveTime}) ->
							% ?debug("Uid=~p",[RUid]),
							#pt_public_help_work_list{
								id=RId,
								uid=RUid,
								name=RName,
								hero_id=RHeroType,
								hero_lev=RHeroLev,
								fighting=RFighting,
								leave_time=RLeaveTime,
								add_ratio=util:floor(calc_worker_ratio_add(RFighting) * 10000) + Add_Ratio2
							}
						end,
						Commander = lists:map(Fun2, CommanderList),
						WorkList = lists:map(Fun2, OriWorkList)
				end,
				case UpgradeEndTime =/= 0 andalso UpgradeEndTime >= Now of
					true -> 
						NeedItemNum1 = util:ceil((UpgradeEndTime - Now) / 60),
						case NeedItemNum1 == 0 of
							true -> NeedItemNum = NeedItemNum1 + 1;
							_ -> NeedItemNum = NeedItemNum1
						end;
					_ -> 
						#st_building{time = NeedTime} = get_building_config(Type, Lev),
						NeedItemNum1 = util:ceil(NeedTime / 60),
						case NeedItemNum1 == 0 of
							true -> NeedItemNum = NeedItemNum1 + 1;
							_ -> NeedItemNum = NeedItemNum1
						end
				end,
				% ?debug("id=~p,type=~p",[Id,Type]),
				#pt_public_home_building_base_info{
					id               = Id,
					type             = Type,
					level            = Lev,
					status           = Status1,
					friend_num       = Num,
					get_num          = GetTime,
					friend_list      = NameList,
					reward           = NewRewardList,
					need_num         = NeedItemNum*util:get_data_para_num(1056),
					upgrade_end_time = UpgradeEndTime,
					work_end_time    = WorkEndTime,
					rest_end_time    = RestEndTime,
					commander        = Commander,
					work_list        = WorkList,
					quick_mine_time  = QuickMine,
					institue_skill   = InstitueSkillList
				}
			end,
			BuildingList = lists:map(Fun, Ret),
			?send(Sid, proto:pack(#pt_home_building_list{uid=TargetUid,building_list=BuildingList}, Seq));
		_ -> 
			TargetUid =/= Uid andalso ?error_report(Sid, "haoyoujiayuanweikaiqi")
	end.

begin_upgrade_building({BuildingId, Seq}) ->
	Now = util:unixtime(),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{uid=Uid,type=Type,lev=Lev,upgrade_end_time=0}] ->
			#st_building{time=NeedTime} = get_building_config(Type, Lev),
			NewEndTime = Now + NeedTime,
			if 
				NeedTime > 0 ->
					% ?debug("upgrade_start1----------------"),
					db:dirty_put(Rec#home_building{status=?UPGRADE,upgrade_end_time = NewEndTime}),
					case db:dirty_get(ply, Uid) of
						[#ply{sid=Sid}] ->
							% ?debug("upgrade_start2----------------"),
							req_building_list(Uid, Sid, Uid, Seq);
						_ -> skip
					end;
				true ->
					on_building_upgrade_complete(BuildingId)
			end;
		_ -> skip
	end.
on_building_upgrade_complete(BuildingId) ->
	% ?debug("---on_building_upgrade_complete,~p",[BuildingId]),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type=Type,status=Status,uid=Uid,lev=Lev,data=Data,rest_end_time=RestEndTime}] ->
			Rec1 = deserialize_data(Data),
			case Type of
				?BUILDING_TYPE_HALL ->
					case Status == ?GETREWARD orelse RestEndTime > 0 of
						true -> Status1 = ?CD;
						_ -> Status1 = ?REST
					end,
					NewRec1 = Rec1#hall_data{friend_list=[]};
				?BUILDING_TYPE_INSTITUE -> 
					Status1 = ?REST,
					NewRec1 = Rec1;
				_ ->
					Now = util_time:unixtime(),
					Status1 = ?WORK,
					NewRec1 = Rec1#mine_data{begin_time=Now}
			end,
			NewRec = Rec#home_building{status=Status1,lev=Lev+1,upgrade_end_time=0,data=serialize_data(NewRec1)},
			db:dirty_put(NewRec),
			process_on_upgrade_complete(NewRec),
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid,agent_hid=Hid}] ->
					mod_msg:send_to_agent(Hid,{on_upgrade_complete, Uid, Sid, Type, Lev+1}),
					req_building_list(Uid, Sid, Uid, 0);
				_ -> skip
			end;
		_ -> skip
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% agent function
%%%%%%%%%%%%%%%%%%%%%%%%%%
check_achieve(Uid, Sid) ->
	List = db:dirty_get(home_building, Uid, #home_building.uid),
	BuildingList = [?BUILDING_TYPE_HALL,?BUILDING_TYPE_GOLD_MINE,?BUILDING_TYPE_FARM_MINE,?BUILDING_TYPE_INSTITUE],
	Fun = fun(Type) ->
		case lists:keyfind(Type, #home_building.type, List) of
			#home_building{lev=Lev} ->
				fun_task_count:process_count_event(family_building,{0,Type,Lev},Uid,Sid);
			_ -> skip
		end
	end,
	lists:foreach(Fun, BuildingList).

init_family(Uid) ->
	case db:dirty_get(home_building, Uid, #home_building.uid) of
		[] -> gen_server:cast({global,family_mng}, {enable_home, Uid});
		_ -> skip
	end.

req_upgrade_building(_Uid, _Sid, BuildingId, Seq) ->
	% ?debug("upgrade----------------"),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type=Type,lev=Lev}] ->
			case get_building_config(Type, Lev+1) of
				false -> skip;
				_ ->
					Status = Rec#home_building.status,
					case Type of
						?BUILDING_TYPE_HALL ->
							case Status == ?UPGRADE orelse Status == ?WORK of
								false ->
									check_upgrade_building(Rec, Seq);
								_ -> skip
							end;
						_ -> 
							case Status == ?UPGRADE of
								false ->
									check_upgrade_building(Rec, Seq);
								_ -> skip
							end
					end
			end;
		_ -> skip
	end.

req_fast_end(Uid, Sid, BuildingId, Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{type=Type,lev=Lev,status=Status,upgrade_end_time=EndTime}] ->
			case get_building_config(Type, Lev+1) of
				false -> skip; 
				_ ->
					#st_building{need_scene=NeedSceneLev,need_lev=NeedPlayerLev,need_hall_lev=NeedHallLev} = get_building_config(Type, Lev),
					case db:dirty_get(ply, Uid) of
						[#ply{lev=PlayerLev}] ->
							case check_upgrade(Uid,Sid,NeedHallLev,PlayerLev,NeedPlayerLev,NeedSceneLev) of
								true ->
									case Type of
										?BUILDING_TYPE_HALL ->
											case Status =/= ?WORK of
												true -> 
													fast_end(Uid, Sid, BuildingId, Type, Lev, EndTime, Seq);
												_ -> skip
											end;
										_ -> 
											fast_end(Uid, Sid, BuildingId, Type, Lev, EndTime, Seq)
									end;
								_ -> skip
							end;
						_ -> skip
					end
			end;
		_ -> skip
	end.

early_get_reward(Uid, Sid, BuildingId, Seq) -> 
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type = Type}] ->
			case Type of
				?BUILDING_TYPE_HALL ->
					gen_server:cast({global, family_mng}, {on_early_get_hall_reward, {Uid, Sid, BuildingId, Seq}});
				?BUILDING_TYPE_INSTITUE -> skip;
				_ -> get_mine_reward(Uid, Sid, Rec)
			end;
		_ -> skip
	end.

early_get_hall_reward({Uid, Sid, BuildingId, Seq}) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{}] ->
			process_on_get_reward(Uid, Sid, Rec, Seq);
		_ -> skip
	end.

get_mine_reward(Uid, Sid, #home_building{type=Type,lev=Lev,data=Data}) when ?is_res_building(Type) ->
	#mine_data{begin_time=Time,commander=List1,work_list=List2} = deserialize_data(Data),
	Now = util_time:unixtime(),
	case Type of
		?BUILDING_TYPE_GOLD_MINE ->
			#st_building_goldfield{product_type=ItemType,house_num=HouseNum,storage_num=StorageNum,pre_hour_num=PreHourNum,one_helper=OneHelper,two_helper=TwoHelper,three_helper=ThreeHelper} = data_building_goldfield:get_data(Lev);
		?BUILDING_TYPE_FARM_MINE ->
			#st_building_farm{product_type=ItemType,house_num=HouseNum,storage_num=StorageNum,pre_hour_num=PreHourNum,one_helper=OneHelper,two_helper=TwoHelper,three_helper=ThreeHelper} = data_building_farm:get_data(Lev)
	end,
	MaxNum = HouseNum * StorageNum,
	NowNum = ((Now-Time) div 60) * PreHourNum,
	case NowNum >= MaxNum of
		true -> AddNum = MaxNum;
		_ -> AddNum = NowNum
	end,
	case lists:keyfind(Uid,#settled_info.uid,List1) of
		#settled_info{uid=Uid,fighting=FightScore} ->
			Add_Ratio1 = calc_worker_ratio_add(FightScore);
		_ -> Add_Ratio1 = 0
	end,
	case length(List2) of
		1 -> Add_Ratio2 = OneHelper / 10000;
		2 -> Add_Ratio2 = TwoHelper / 10000;
		3 -> Add_Ratio2 = ThreeHelper / 10000;
		_ -> Add_Ratio2 = 0
	end,
	NewAddNum = util:floor(AddNum * (1+Add_Ratio1+Add_Ratio2)),
	AddItems1 = [{ItemType, NewAddNum}],
	AddItems = [{?ITEM_WAY_HOME_BUILDING_GATHER, ItemType, NewAddNum}],
	case NewAddNum > 0 of
		false -> Succ = undefined;
		_ -> 
			Succ = fun() ->
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems1)
			end
	end,
	fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined).

fast_end(Uid, Sid, BuildingId, Type, Lev, EndTime, Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{status=Status}] ->
			Now = util_time:unixtime(),
			case EndTime == 0 of
				false -> 
					SpendItems = [],
					NewEndTime1 = util:ceil((EndTime - Now) / 60),
					case NewEndTime1 == 0 of
						true -> NewEndTime = NewEndTime1 + 1;
						_ -> NewEndTime = NewEndTime1
					end;
				_ -> 
					#st_building{time = NeedTime, need_coin = NeedCoin, need_items = NeedItems1} = get_building_config(Type, Lev),
					SpendItems = lists:append(NeedItems1,[{?RESOUCE_COPPER_NUM, NeedCoin}]),
					NewEndTime1 = util:ceil(NeedTime / 60),
					case NewEndTime1 == 0 of
						true -> NewEndTime = NewEndTime1 + 1;
						_ -> NewEndTime = NewEndTime1
					end
			end,
			NeedItems = lists:append([{?RESOUCE_COIN_NUM, util:ceil(NewEndTime * util:get_data_para_num(1056))}],SpendItems),
			NewNeedItems = [{?ITEM_WAY_HOME_BUILDING_FAST_UPGRADE, ItemType, Amount} || {ItemType, Amount} <- NeedItems],
			SuccCb = fun() -> 
				case (Type == ?BUILDING_TYPE_HALL andalso Status == ?GETREWARD) orelse ?is_res_building(Type) of
					true -> early_get_reward(Uid, Sid, BuildingId, Seq);
					_ -> skip
				end,
				gen_server:cast({global, family_mng}, {on_building_upgrade_complete, BuildingId}) 
			end,
			fun_item_api:check_and_add_items(Uid, Sid, NewNeedItems, [], SuccCb, undefined);
		_ -> skip
	end.

check_upgrade_building(#home_building{id=BuildingId,uid=Uid,type=Type,lev=Lev,status=Status}=Rec, Seq) ->
	case is_upgrading(Rec) of
		false ->
			case get_building_config(Type, Lev) of
				#st_building{need_scene=NeedSceneLev,need_lev=NeedPlayerLev,need_hall_lev=NeedHallLev,need_coin=NeedCoin,need_items=NeedItems} ->
					case db:dirty_get(ply, Uid) of
						[#ply{sid=Sid,lev=PlayerLev}] ->
							case check_upgrade(Uid,Sid,NeedHallLev,PlayerLev,NeedPlayerLev,NeedSceneLev) of
								true ->
									% ?debug("upgrade_start----------------"),
									NeedItems1 = lists:append(NeedItems,[{?RESOUCE_COPPER_NUM,NeedCoin}]),
									NewNeedItems = [{?ITEM_WAY_HOME_BUILDING_UPGRADE, ItemType, Amount} || {ItemType, Amount} <- NeedItems1],
									Succ = fun() ->
										case (Type == ?BUILDING_TYPE_HALL andalso Status == ?GETREWARD) orelse ?is_res_building(Type) of
											true -> early_get_reward(Uid, Sid, BuildingId, Seq);
											_ -> skip
										end,
										gen_server:cast({global, family_mng}, {upgrade_home_building, {BuildingId, Seq}})
									end,
									fun_item_api:check_and_add_items(Uid, Sid, NewNeedItems, [], Succ, undefined);
								_ -> false
							end;
						_ -> false
					end;
				_ -> false
			end;
		_ -> false
	end.

check_upgrade(Uid,Sid,NeedHallLev,PlayerLev,NeedPlayerLev,NeedSceneLev) ->
	case PlayerLev >= NeedPlayerLev of
		true ->
			case mod_scene_lev:get_curr_scene_lv(Uid) >= NeedSceneLev of
				true ->
					case get_hall_level(Uid) >= NeedHallLev of
						true -> true;
						_ -> ?error_report(Sid, "zhizhengtingdengjibuzu"), false
					end;
				_ -> ?error_report(Sid, "error_pre_copy_not_reached"), false
			end;
		_ -> ?error_report(Sid, "not_enough_player_level"), false
	end.


on_pass_copy(Uid) ->
	case mod_scene_lev:get_curr_scene_lv(Uid) >= util:get_data_para_num(1025) of
		true ->
			gen_server:cast({global,family_mng}, {enable_home, Uid});
		_ -> skip
	end.

refresh_meeting_time(Uid) ->
	fun_usr_misc:set_misc_data(Uid, buy_farm_times, 0),
	fun_usr_misc:set_misc_data(Uid, meeting_times, 0).

% agnet_check_hero(Uid, Sid) ->
% 	case db:dirty_get(entourage_info, Uid, #entourage_info.pid) of
% 		[] -> skip;
% 		EntourageList -> 
% 			[check_hero(Uid, Sid, HeroType) || #entourage_info{type=HeroType} <- EntourageList]
% 	end.

% check_hero(Uid, Sid, HeroType) -> 
% 	Entourage=#entourage_info{active_type=ActiveType,settle_uid=TargetUid} = fun_entourage:get_entourage(Uid,HeroType),
% 	case ActiveType == ?ENTOURAGE_SETTLED of
% 		true ->
% 			List = db:dirty_get(home_building, TargetUid, #home_building.uid),
% 			Fun = fun(#home_building{type=Type,data=Data}) ->
% 				case Type == ?BUILDING_TYPE_GOLD_MINE orelse Type == ?BUILDING_TYPE_FARM_MINE of
% 					true -> 
% 						Rec = deserialize_data(Data),
% 						WorkList = Rec#mine_data.work_list,
% 						case lists:keyfind(HeroType, #settled_info.hero_id, WorkList) of
% 							#settled_info{hero_id = HeroType} -> true;
% 							_ -> false
% 						end;
% 					_ -> false
% 				end
% 			end,
% 			NewList = lists:filter(Fun, List),
% 			case length(NewList) == 0 of
% 				true -> 
% 					NewRec = Entourage#entourage_info{active_type=?ENTOURAGE_ACTIVATE,settle_uid=0},
% 					db:dirty_put(NewRec),
% 					fun_entourage:request_entourage_info(Uid, Sid, 0, HeroType);
% 				_ -> skip
% 			end;
% 		_ -> skip
% 	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hall function
%%%%%%%%%%%%%%%%%%%%%%%%%%
req_meeting(Uid, Sid, BuildingId, Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type = Type}] when Type == ?BUILDING_TYPE_HALL ->
			case is_upgrading(Rec) == false andalso is_rest(Rec) == false of
				true -> 
					gen_server:cast({global,family_mng}, {begin_meeting, Uid, Sid, BuildingId, Seq});
				_ -> skip
			end;
		_ -> skip
	end.

req_meeting_help(Uid, Sid, Seq) ->
	case fun_gm_operation:check_shutup(Sid,Uid,Seq) of
		true ->
			RecName = "", 
			Chanle = ?CHANLE_FAMILY,
			Content = util:get_data_text(67),
			mod_msg:handle_to_chat_server({req_chat, Uid, Sid, Seq, RecName, Chanle, Content, ?FAMILY}),
			?error_report(Sid, "fasongyaoqing", Seq);
		_ -> skip
	end.


begin_meeting(Uid, Sid, BuildingId, Seq) ->
	Now = util:unixtime(),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{lev=Lev,data = Data}] ->
			Rec1 = deserialize_data(Data),
			#st_building_hall{work_time=NeedTime} = data_building_hall:get_data(Lev),
			NewEndTime = Now + NeedTime,
			if 
				NeedTime > 0 ->	
					NewRec = Rec1#hall_data{work_end_time=NewEndTime},
					db:dirty_put(Rec#home_building{status=?WORK,data = serialize_data(NewRec)}),
					case db:dirty_get(ply, Uid) of
						[#ply{sid=Sid}] ->
							req_building_list(Uid, Sid, Uid, Seq);
						_ -> skip
					end;
				true -> skip
			end;
		_ -> skip
	end.

on_meeting_complete(BuildingId) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{uid=Uid,data=Data}] ->
			Rec1 = deserialize_data(Data),
			NewRec1 = Rec1#hall_data{work_end_time=0},
			NewRec = Rec#home_building{status=?GETREWARD,data=serialize_data(NewRec1)},
			db:dirty_put(NewRec),
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid}] ->
					req_building_list(Uid, Sid, Uid, 0);
				_ -> skip
			end;
		_ -> skip
	end.

req_join_meeting(Uid, Sid, TargetUid, TargetServerId, Seq) ->
	Time = fun_usr_misc:get_misc_data(Uid, meeting_times),
	MaxJoin = util:get_data_para_num(1054),
	case Time < MaxJoin of
		true ->
			case db:dirty_get(usr, TargetUid) of
				[#usr{}] ->
					List = db:dirty_get(home_building, TargetUid, #home_building.uid),
					[FriendRec] = db:dirty_get(ply, Uid),
					Name = FriendRec#ply.name,
					AgentPid = FriendRec#ply.agent_hid,
					case lists:keyfind(?BUILDING_TYPE_HALL, #home_building.type, List) of
						Rec = #home_building{id=BuildingId,lev=Lev,status=Status,data=Data} ->
							Rec1 = deserialize_data(Data),
							FriendList = Rec1#hall_data.friend_list,
							case Uid =/= TargetUid of
								true -> 
									case  Status == ?WORK of
										true ->
											case data_building_hall:get_data(Lev) of
												#st_building_hall{max_num=MaxNum} ->
													case length(FriendList) < MaxNum  of
														true -> join_meeting({BuildingId,Time,MaxJoin,Uid,FriendList,Rec,Rec1,TargetUid,Sid,Seq,MaxNum,Name,AgentPid});
														_ -> skip
													end;
												_ -> skip
											end;
										_ -> skip
									end;
								_ -> ?error_report(Sid, "zijixiezhuziji", Seq)
							end;
						_ -> skip
					end;
				_ ->
					[#usr{name = Name}] = db:dirty_get(usr, Uid),
					do_join_meeting_to_global(Uid, TargetServerId, TargetUid, Name)
			end;
		_ -> ?error_report(Sid, "yihuicishubuzu")
	end.

join_meeting({BuildingId,Time,MaxJoin,Uid,FriendList,Rec,Rec1,_TargetUid,Sid,Seq,MaxNum,Name,AgentPid}) ->
	case Time < MaxJoin of
		true ->
			% ?debug("FriendList:~p",[FriendList]),
			case lists:member(util:to_binary(Name), FriendList) of
				false ->
					NewFriendList = lists:append(FriendList,[util:to_binary(Name)]),
					NewRec1 = Rec1#hall_data{friend_list=NewFriendList},
					NewRec = Rec#home_building{data=serialize_data(NewRec1)},
					mod_msg:send_to_agent(AgentPid, {on_join_meeting, Uid, Time + 1}),
					db:dirty_put(NewRec),
					gen_server:cast(AgentPid, {add_resoure,Uid,[{?RESOUCE_FRIENDSHIP_POINT_NUM, util:get_data_para_num(1055)}], ?ITEM_WAY_JOIN_MEETING_REWARD}),
					?error_report(Sid, "canyuyihui", Seq, [MaxJoin-Time-1, util:get_data_para_num(1055)]),
					case length(NewFriendList) >= MaxNum of
						true -> on_meeting_complete(BuildingId);
						_ -> skip
					end;
				_ -> ?error_report(Sid, "yijingcangyuyihui")
			end;
		_ -> ?error_report(Sid, "yihuicishubuzu")
	end.

join_meeting_from_other_server({FromServerID, FromServerName, FromUid, Uid, FromName}) ->
	List = db:dirty_get(home_building, Uid, #home_building.uid),
	IsSucc = case lists:keyfind(?BUILDING_TYPE_HALL, #home_building.type, List) of
		Rec = #home_building{id=BuildingId,lev=Lev,status=Status,data=Data} ->
			Rec1 = deserialize_data(Data),
			FriendList = Rec1#hall_data.friend_list,
			case Uid =/= FromUid of
				true -> 
					case  Status == ?WORK of
						true ->
							case data_building_hall:get_data(Lev) of
								#st_building_hall{max_num=MaxNum} ->
									case length(FriendList) < MaxNum  of
										true -> 
											join_meeting_from_other_server_help({BuildingId,Uid,FriendList,Rec,Rec1,MaxNum,FromName,FromServerName});
										_ -> {false, "server_prompt"}
									end;
								_ -> {false, "server_prompt"}
							end;
						_ -> {false, "server_prompt"}
					end;
				_ -> {false, "zijixiezhuziji"}
			end;
		_ -> {false, "server_prompt"}
	end,
	?debug("IsSucc:~p",[IsSucc]),
	send_join_result_to_from_server(IsSucc, FromServerID, FromUid).

join_result_from_other_server({IsSucc, Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid, agent_hid = Hid}] -> 
			case IsSucc of
				{true, _} ->
					Time = fun_usr_misc:get_misc_data(Uid, meeting_times),
					MaxJoin = util:get_data_para_num(1054),
					mod_msg:send_to_agent(Hid, {on_join_meeting, Uid, Time + 1}),
					mod_msg:send_to_agent(Hid, {add_resoure,Uid,[{?RESOUCE_FRIENDSHIP_POINT_NUM, util:get_data_para_num(1055)}], ?ITEM_WAY_JOIN_MEETING_REWARD}),
					?error_report(Sid, "canyuyihui", 0, [MaxJoin-Time - 1, util:get_data_para_num(1055)]);
				{false, Reason} -> ?error_report(Sid, Reason)
			end;
		_ -> skip
	end.

join_meeting_from_other_server_help({BuildingId,_Uid,FriendList,Rec,Rec1,MaxNum,FromName,FromServerName}) ->
	NewName = "[" ++ FromServerName ++ "]" ++ FromName,
	case lists:member(util:to_binary(NewName), FriendList) of
		false ->
			NewFriendList = lists:append(FriendList,[util:to_binary(NewName)]),
			NewRec1 = Rec1#hall_data{friend_list=NewFriendList},
			NewRec = Rec#home_building{data=serialize_data(NewRec1)},
			db:dirty_put(NewRec),
			case length(NewFriendList) >= MaxNum of
				true -> on_meeting_complete(BuildingId);
				_ -> skip
			end,
			{true, succ};
		_ -> {false, "yijingcangyuyihui"}
	end.

req_hall_reward(Uid, Sid, BuildingId, Seq) ->
	?debug("BuildingId~p",[BuildingId]),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{status=Status}] ->
			case Status == ?GETREWARD of
				true ->
					process_on_get_reward(Uid, Sid, Rec, Seq);
				_ -> skip
			end;
		_ -> skip
	end.

on_hall_rest_complete(BuildingId) ->
	Now = util_time:unixtime(),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{uid=Uid,upgrade_end_time=Time}] ->
			case Time - Now > 0 of
				true -> Status = ?UPGRADE;
				_ -> Status = ?REST
			end,
			NewRec = Rec#home_building{status=Status,rest_end_time=0},
			db:dirty_put(NewRec),
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid}] ->
					req_building_list(Uid, Sid, Uid, 0);
				_ -> skip
			end;
		_ -> skip
	end.

process_on_get_reward(Uid, Sid, Rec=#home_building{type=Type,lev=Lev,data=Data,status=Status}, Seq) ->
	case Type == ?BUILDING_TYPE_HALL andalso Status == ?GETREWARD of
		true ->
			Now = util_time:unixtime(),
			#st_building_hall{cd=NeedTime} = data_building_hall:get_data(Lev),
			EndTime = Now+NeedTime,
			Rec1 = deserialize_data(Data),
			#st_building_hall{base_reward=RewardList, add_reward=AddRrwardList} = data_building_hall:get_data(Lev),
			NameList = Rec1#hall_data.friend_list,
			PartNum = length(Rec1#hall_data.friend_list),
			Fun = fun({Type1, Num}) -> {Type1, Num * PartNum} end,
			NewList = lists:map(Fun, AddRrwardList),
			AddItems1 = lists:append(RewardList,NewList),
			AddItems = util_list:add_and_merge_list([], AddItems1, 1, 2),
			NewAddItems = [{?ITEM_WAY_HOME_BUILDING_GATHER, ItemType, Amount} || {ItemType, Amount} <- AddItems],
			NewRec1 = Rec1#hall_data{friend_list=[]},
			NewRec = Rec#home_building{status=?CD,rest_end_time=EndTime,data=serialize_data(NewRec1)},
			db:dirty_put(NewRec),
			case db:dirty_get(ply, Uid) of
				[#ply{agent_hid=Hid}] ->
					mod_msg:send_to_agent(Hid, {on_get_hall_reward, Uid, Sid, AddItems, NewAddItems, NameList});
				_ -> skip
			end,
			req_building_list(Uid, Sid, Uid, Seq);
		_ -> skip
	end.

get_hall_reward(Uid, Sid, AddItems, NewAddItems, NameList) ->
	Succ = fun() -> 
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems, NameList)
	end,
	fun_item_api:check_and_add_items(Uid, Sid, [], NewAddItems, Succ, undefined).

is_rest(#home_building{rest_end_time=Time}) ->
	Time > 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% mine function
%%%%%%%%%%%%%%%%%%%%%%%%%%
req_mine_reward(Uid, Sid, BuildingId, Seq) ->
	Now = util_time:unixtime(),
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{uid=Uid,lev=Lev,type=Type,data=Data}] when ?is_res_building(Type) ->
			Rec1 = deserialize_data(Data),
			BeginTime = Rec1#mine_data.begin_time,
			List1 = Rec1#mine_data.commander,
			List2 = Rec1#mine_data.work_list,
			case Type of
				?BUILDING_TYPE_GOLD_MINE ->
					#st_building_goldfield{product_type=ItemType,storage_num=StorageNum,pre_hour_num=PreHourNum,one_helper=OneHelper,two_helper=TwoHelper,three_helper=ThreeHelper} = data_building_goldfield:get_data(Lev);
				?BUILDING_TYPE_FARM_MINE ->
					#st_building_farm{product_type=ItemType,storage_num=StorageNum,pre_hour_num=PreHourNum,one_helper=OneHelper,two_helper=TwoHelper,three_helper=ThreeHelper} = data_building_farm:get_data(Lev)
			end,
			case work_times(Now, BeginTime,PreHourNum,StorageNum) > 0 of
				true ->
					case lists:keyfind(Uid,#settled_info.uid,List1) of
						#settled_info{uid=Uid,fighting=FightScore} ->
							Add_Ratio1 = calc_worker_ratio_add(FightScore);
						_ -> Add_Ratio1 = 0
					end,
					case length(List2) of
						1 -> Add_Ratio2 = OneHelper / 10000;
						2 -> Add_Ratio2 = TwoHelper / 10000;
						3 -> Add_Ratio2 = ThreeHelper / 10000;
						_ -> Add_Ratio2 = 0
					end,
					NewAddNum = util:floor(StorageNum * (1+Add_Ratio1+Add_Ratio2)),
					AddItems = [{?ITEM_WAY_HOME_BUILDING_GATHER, ItemType, NewAddNum}],
					Succ = fun() -> 
						gen_server:cast({global, family_mng}, {get_mine_reward, {BuildingId, Seq}}),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, [{ItemType, NewAddNum}]) 
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

get_mine_reward_complete(BuildingId, Seq) ->
	Now = util_time:unixtime(),
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{uid=Uid,lev=Lev,type=Type,data=Data}] when ?is_res_building(Type) ->
			Rec1 = deserialize_data(Data),
			BeginTime = Rec1#mine_data.begin_time,
			case Type of
				?BUILDING_TYPE_GOLD_MINE ->
					#st_building_goldfield{house_num=HouseNum,storage_num=StorageNum,pre_hour_num=PreHourNum} = data_building_goldfield:get_data(Lev);
				?BUILDING_TYPE_FARM_MINE ->
					#st_building_farm{house_num=HouseNum,storage_num=StorageNum,pre_hour_num=PreHourNum} = data_building_farm:get_data(Lev)
			end,
			WorkTime = work_times(Now,BeginTime,PreHourNum,StorageNum),
			case WorkTime >= HouseNum of
				true -> 
					NewTime = util:floor((HouseNum - 1) * StorageNum / PreHourNum * 3600),
					NewBeginTime = Now - NewTime;
				_ -> NewBeginTime = BeginTime + util:floor(StorageNum / PreHourNum * 3600)
			end,
			NewRec1 = Rec1#mine_data{begin_time = NewBeginTime},
			db:dirty_put(Rec#home_building{data=serialize_data(NewRec1)}),
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid}] ->
					req_building_list(Uid, Sid, Uid, Seq);
				_ -> skip
			end;
		_ -> skip
	end.

req_settled_helper(Uid, Sid, BuildingId, HeroType, Seq) -> 
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{uid=TargetUid}] ->
			case get_info(Uid, HeroType) of
				{ok, _, _HeroInfo} ->
					% case HeroInfo#entourage_info.active_type == ?ENTOURAGE_ACTIVATE of
					% 	true ->
							case Uid == TargetUid of
								true ->
									gen_server:cast({global, family_mng}, {settled_commander, {Uid, Sid, BuildingId, HeroType, Seq}});
								_ -> 
									AddItems = [{?ITEM_WAY_HOME_BUILDING_GATHER, ?RESOUCE_FRIENDSHIP_POINT_NUM, util:get_data_para_num(1055)}],
									Succ = fun() -> 
										gen_server:cast({global, family_mng}, {settled_worker, {Uid, Sid, TargetUid, BuildingId, HeroType, Seq}})
									end,
									fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined)
							end;
						_ -> skip
				% 	end;
				% _ -> skip
			end;
		_ -> skip
	end.

settled_commander(Uid, Sid, BuildingId, HeroType, _Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type=Type,data=Data}] when ?is_res_building(Type) ->
			Rec1 = deserialize_data(Data),
			% ?debug("List=~p",[Rec1#mine_data.commander]),
			case db:dirty_get(ply, Uid) of
				[#ply{agent_hid=Hid}] ->
					List = Rec1#mine_data.commander,
					case lists:keyfind(Uid, #settled_info.uid, List) of
						#settled_info{hero_id=HeroType1} ->
							mod_msg:send_to_agent(Hid, {on_hero_leave, Uid, Uid, Sid, HeroType1});
						_ -> skip
					end,
					case get_info(Uid, HeroType) of
						{ok, Name, _HeroInfo} ->
							mod_msg:send_to_agent(Hid, {on_hero_settled, Uid, Sid, HeroType, Type}),
							Commander = #settled_info{
											uid=Uid,
											name=Name,
											hero_id=HeroType
											% hero_lev=HeroInfo#entourage_info.lev,
											% fighting=HeroInfo#entourage_info.fighting
							},
							NewRec1 = Rec1#mine_data{commander=[Commander]},
							NewRec = Rec#home_building{data=serialize_data(NewRec1)},
							db:dirty_put(NewRec);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

settled_worker(Uid, Sid, TargetUid, BuildingId, HeroType, Seq) -> 
	Now = util_time:unixtime(), 
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{type=Type,lev=Lev,data=Data}] when ?is_res_building(Type) ->
			case Type of
				?BUILDING_TYPE_GOLD_MINE -> #st_building_goldfield{work_time=WorkTime} = data_building_goldfield:get_data(Lev);
				?BUILDING_TYPE_FARM_MINE -> #st_building_farm{work_time=WorkTime} = data_building_farm:get_data(Lev)
			end,
			Rec1 = deserialize_data(Data),
			List = Rec1#mine_data.work_list,
			case length(List) < ?MAX_WORK_NUM of
				true ->
					case lists:keyfind(Uid, #settled_info.uid, List) of
						false ->
							case get_info(Uid, HeroType) of
								{ok, Name, HeroInfo} ->
									[set_worker(Uid, Sid, BuildingId, Name, HeroType, HeroInfo, Now, WorkTime, Id) || Id <- ?WORK_NUM_LIST],
									req_building_list(Uid, Sid, TargetUid, Seq);
								_ -> skip
							end;
						_ -> ?error_report(Sid, "yiyouyingxiongruzhu")
					end;
				_ -> skip
			end;
		_ -> skip
	end.

set_worker(Uid, Sid, BuildingId, Name, HeroType, _HeroInfo, Now, WorkTime, Id) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type=Type,data=Data}] when ?is_res_building(Type) ->
			Rec1 = deserialize_data(Data),
			List = Rec1#mine_data.work_list,
			case lists:keyfind(Uid, #settled_info.uid, List) == false andalso lists:keyfind(Id, #settled_info.id, List) == false of
				true -> 
					Work = #settled_info{
								id = Id,
								uid=Uid,
								name=Name,
								hero_id=HeroType,
								% hero_lev=HeroInfo#entourage_info.lev,
								% fighting=HeroInfo#entourage_info.fighting,
								leave_time=Now+WorkTime
					},
					NewList = lists:keystore(Id, #settled_info.id, List, Work),
					NewRec1 = Rec1#mine_data{work_list=NewList},
					NewRec = Rec#home_building{data=serialize_data(NewRec1)},
					db:dirty_put(NewRec),
					case db:dirty_get(ply, Uid) of
						[#ply{agent_hid=Hid}] ->
							mod_msg:send_to_agent(Hid, {on_hero_settled, Uid, Sid, HeroType, Type});
						_ -> skip
					end;
				_ -> 
					skip
			end;
		_ -> skip
	end.

on_worker_leave_timer({Uid, BuildingId}) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{uid=TargetUid,type=Type,data=Data}] when ?is_res_building(Type) ->
			Rec1 = deserialize_data(Data),
			List = Rec1#mine_data.work_list,
			#settled_info{hero_id=HeroType} = lists:keyfind(Uid, #settled_info.uid, List),
			NewList = lists:keydelete(Uid, #settled_info.uid, List),
			NewRec1 = Rec1#mine_data{work_list=NewList},
			NewRec = Rec#home_building{data=serialize_data(NewRec1)},
			db:dirty_put(NewRec),
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid,agent_hid=Hid}] ->
					mod_msg:send_to_agent(Hid, {on_hero_leave, Uid, TargetUid, Sid, HeroType});
				_ -> skip
			end;
		_ -> skip
	end.

req_remove_commander(Uid, Sid, BuildingId, Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{type=Type,data=Data}] when ?is_res_building(Type) ->
			Rec1 = deserialize_data(Data),
			List = Rec1#mine_data.commander,
			% ?debug("List=~p,uid=~p",[List,Uid]),
			Commander = lists:keyfind(Uid, #settled_info.uid, List),
			% ?debug("Commander=~p",[Commander]),
			HeroType = Commander#settled_info.hero_id,
			NewRec1 = Rec1#mine_data{commander=[]},
			NewRec = Rec#home_building{data=serialize_data(NewRec1)},
			db:dirty_put(NewRec),
			case db:dirty_get(ply, Uid) of
				[#ply{agent_hid=Hid}] ->
					mod_msg:send_to_agent(Hid, {on_hero_leave, Uid, Uid, Sid, HeroType});
				_ -> skip
			end,
			req_building_list(Uid, Sid, Uid, Seq);
		_ -> skip
	end.

req_quick_mine(Uid, Sid, BuildingId, Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{lev=Lev,type=Type}] when Type == ?BUILDING_TYPE_FARM_MINE ->
			case Type of
				?BUILDING_TYPE_GOLD_MINE -> 
					#st_building_goldfield{product_type=GetType,storage_num=GetNum} = data_building_goldfield:get_data(Lev),
					Time = min(fun_usr_misc:get_misc_data(Uid, buy_farm_times)+1, data_buy_time_price:get_max_times(?BUY_QUICK_FARM));
				?BUILDING_TYPE_FARM_MINE -> 
					#st_building_farm{product_type=GetType,storage_num=GetNum} = data_building_farm:get_data(Lev),
					Time = min(fun_usr_misc:get_misc_data(Uid, buy_farm_times)+1, data_buy_time_price:get_max_times(?BUY_QUICK_FARM))
			end,
			?debug("Time=~p",[fun_usr_misc:get_misc_data(Uid, buy_farm_times)]),
			case data_buy_time_price:get_data(?BUY_QUICK_FARM, Time) of
				#st_buy_time_price{cost = Cost} ->
					case db:dirty_get(ply, Uid) of
						[#ply{agent_hid=Hid}] ->
							mod_msg:send_to_agent(Hid, {on_quick_mine, Uid, Sid, Time, GetType, GetNum, Cost, Seq});
						_ -> skip
					end,
					req_building_list(Uid, Sid, Uid, Seq);
				_ -> skip
			end;
		_ -> skip
	end.

on_quick_mine({Uid, Sid, Time, GetType, GetNum, Cost, _Seq}) ->
	Succ = fun() ->
		fun_usr_misc:set_misc_data(Uid, buy_farm_times, Time),
		fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, [{GetType, GetNum}])
	end,
	NeedItem = [{?ITEM_WAY_QUICK_MINE, T, N} || {T, N} <- Cost],
	AddItem = [{?ITEM_WAY_QUICK_MINE, GetType, GetNum}],
	fun_item_api:check_and_add_items(Uid, Sid, NeedItem, AddItem, Succ, undefined).
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Institue function
%%%%%%%%%%%%%%%%%%%%%%%%%%
req_study_skill(Uid, Sid, BuildingId, SkillId, Seq) -> 
	case db:dirty_get(home_building, BuildingId) of
		[#home_building{lev=Lev,type=Type,data=Data}] when Type == ?BUILDING_TYPE_INSTITUE ->
			Rec1 = deserialize_data(Data),
			SkillList = Rec1#institue_data.skill_list,
			#st_building_school{max_lev=MaxLev} = data_building_school:get_data(Lev),
			case lists:keyfind(SkillId, #institue_skill.type, SkillList) of
				#institue_skill{type=SkillId,status=Status,lev=SkillLev} when Status == ?UNLOCK ->
					case SkillLev >= MaxLev of
						false ->
							#st_building_school_skill{need_coin=NeedCoin,need_items=NeedItems} = data_building_school_skill:get_data(SkillId, SkillLev),
							NeedItems1 = lists:append(NeedItems,[{?RESOUCE_COPPER_NUM,NeedCoin}]),
							NewNeedItems = [{?ITEM_WAY_HOME_INSTITUE_SKILL_UPGRADE, ItemType, Amount} || {ItemType, Amount} <- NeedItems1],
							Succ = fun() ->
								gen_server:cast({global, family_mng}, {on_institue_skill_upgrade, {BuildingId, SkillId, Seq}})
							end,
							fun_item_api:check_and_add_items(Uid, Sid, NewNeedItems, [], Succ, undefined);
						_ -> ?error_report(Sid, "shuxingyanxi")
					end;
				_ -> skip
			end;
		_ -> skip
	end.

init_skill(SkillId) ->  #institue_skill{type = SkillId, status = ?LOCK}.

active_institue(Uid) ->
	BuildingList = db:dirty_get(home_building, Uid, #home_building.uid),
	case lists:keyfind(?BUILDING_TYPE_INSTITUE, #home_building.type, BuildingList) of
		Rec = #home_building{} ->
			active_institue2(Rec);
		_ -> skip
	end.
active_institue2(#home_building{id=BuildingId,uid=Uid,lev=Lev,type=Type}) when Type == ?BUILDING_TYPE_INSTITUE -> 
	#st_building_school{attributes=List1} = data_building_school:get_data(Lev),
	[unlock_skill(BuildingId, SkillId) || SkillId <- List1],
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid}] ->
			req_building_list(Uid, Sid, Uid, 0);
		_ -> skip
	end.

unlock_skill(BuildingId, SkillId) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{data=Data}] ->
			Rec1 = deserialize_data(Data),
			List = Rec1#institue_data.skill_list,
			case lists:keyfind(SkillId, #institue_skill.type, List) of
				Tuple = #institue_skill{type=SkillId} ->
					case Tuple#institue_skill.status == ?LOCK of
						true ->
							NewTuple = Tuple#institue_skill{status=?UNLOCK},
							NewList = lists:keystore(SkillId, #institue_skill.type, List, NewTuple),
							NewRec1 = Rec1#institue_data{skill_list=NewList},
							NewRec = Rec#home_building{data=serialize_data(NewRec1)},
							db:dirty_put(NewRec);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

upgrade_institue_skill(BuildingId, SkillId, Seq) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec = #home_building{uid=Uid,type=Type,data=Data,lev=ScLev}] when Type == ?BUILDING_TYPE_INSTITUE ->
			case data_building_school:get_data(ScLev) of
				#st_building_school{max_lev = MaxLev} ->
					Rec1 = deserialize_data(Data),
					SkillList = Rec1#institue_data.skill_list,
					case lists:keyfind(SkillId, #institue_skill.type, SkillList) of
						Tuple = #institue_skill{type=SkillId,lev=Lev,status=Status} ->
							case Status == ?UNLOCK andalso Lev < MaxLev of
								true ->
									NewTuple = Tuple#institue_skill{lev=Lev+1},
									NewList = lists:keystore(SkillId, #institue_skill.type, SkillList, NewTuple),
									NewRec1 = Rec1#institue_data{skill_list=NewList},
									NewRec = Rec#home_building{data=serialize_data(NewRec1)},
									db:dirty_put(NewRec),
									case db:dirty_get(ply, Uid) of
										[#ply{sid=Sid,agent_hid=Hid}] ->
											req_building_list(Uid, Sid, Uid, Seq),
											mod_msg:send_to_agent(Hid, {upgrade_institue_skill, Uid});
										_ -> skip
									end;
								_ -> skip
							end;
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

update_fighting(Uid) -> 
	fun_property:updata_fighting(Uid).

get_prop(Uid) ->
	BuildingList = db:dirty_get(home_building, Uid, #home_building.uid), 
	case lists:keyfind(?BUILDING_TYPE_INSTITUE, #home_building.type, BuildingList) of
		#home_building{data=Data} ->
			Rec = deserialize_data(Data),
			List = Rec#institue_data.skill_list,
			Fun = fun(#institue_skill{lev=Lev,type=SkillId},Acc) ->
				case Lev > 0 of
					true ->
						case data_building_school_skill:get_data(SkillId,Lev) of
							#st_building_school_skill{type=PropType,num=Num} ->
								lists:append(Acc,[{PropType,Num}]);
							_ -> Acc
						end;
					_ -> Acc
				end
			end,
			lists:foldl(Fun, [], List);
		_ -> []
	end.

get_fighting(Uid) ->
	BuildingList = db:dirty_get(home_building, Uid, #home_building.uid), 
	case lists:keyfind(?BUILDING_TYPE_INSTITUE, #home_building.type, BuildingList) of
		#home_building{data=Data} ->
			Rec = deserialize_data(Data),
			List = Rec#institue_data.skill_list,
			Fun = fun(#institue_skill{lev=Lev,type=SkillId},Acc) ->
				case Lev > 0 of
					true ->
						case data_building_school_skill:get_data(SkillId,Lev) of
							#st_building_school_skill{gs=Gs} ->
								Acc+Gs;
							_ -> Acc
						end;
					_ -> Acc
				end
			end,
			lists:foldl(Fun, 0, List);
		_ -> 0
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% inside function
%%%%%%%%%%%%%%%%%%%%%%%%%%
serialize_data(Data) ->
	util:to_binary(util:term_to_string(Data)).

deserialize_data(Data) ->
	util:string_to_term(util:to_list(Data)).

add_new_building(Uid, Type) ->
	BuildingList = db:dirty_get(home_building, Uid, #home_building.uid),
	case lists:keyfind(Type, #home_building.type, BuildingList) of
		false -> add_new_building2(Uid, Type);
		_ -> skip
	end.

add_new_building2(Uid, ?BUILDING_TYPE_INSTITUE) ->
	SkillList = [init_skill(SkillId) || SkillId <- data_building_school:get_skill_list()],
	db:insert(#home_building{uid=Uid,type=?BUILDING_TYPE_INSTITUE,lev=1,status=?REST,data=serialize_data(#institue_data{skill_list=SkillList})}),
	active_institue(Uid);
add_new_building2(Uid, Type) when ?is_res_building(Type) ->
	db:insert(#home_building{uid=Uid,type=Type,lev=1,status=?WORK,data=serialize_data(#mine_data{begin_time=util_time:unixtime()})});
add_new_building2(Uid, ?BUILDING_TYPE_HALL) ->
	db:insert(#home_building{uid=Uid,type=?BUILDING_TYPE_HALL,lev=1,status=?REST,data=serialize_data(#hall_data{})}).

active_buildings(Uid) -> 
	BuildingList = db:dirty_get(home_building, Uid, #home_building.uid),
	[Rec] = db:dirty_get(usr, Uid),
	case lists:keyfind(?BUILDING_TYPE_HALL, #home_building.type, BuildingList) of
		#home_building{lev = HallLev} ->
			IdList = data_building_unlock:get_building_list(),
			Fun = fun(Type) ->
				case data_building_unlock:get_data(Type) of
					{_,_,_,NeedPlayerLev,_,NeedHallLev} ->
						case Rec#usr.lev >= NeedPlayerLev andalso HallLev >= NeedHallLev of
							true -> 
								add_new_building(Uid, Type);
							_ -> 
								skip
						end;
					_ -> skip
				end
			end,
			lists:foreach(Fun, IdList);
		_ -> active_hall(Uid)
	end.

active_hall(Uid) ->
	[Rec] = db:dirty_get(usr, Uid),
	case data_building_unlock:get_data(?BUILDING_TYPE_HALL) of
		{_,_,_,NeedPlayerLev,_,_} ->
			case Rec#usr.lev >= NeedPlayerLev of
				true -> 
					add_new_building(Uid, ?BUILDING_TYPE_HALL);
				_ -> skip
			end;
		_ -> skip
	end.

get_building_config(Type, Lev) ->
	case data_building:get_id_by_type(Type, Lev) of
		Id when Id > 0 -> data_building:get_data(Id);
		_ -> false
	end.

get_hall_level(Uid) ->
	case lists:keyfind(?BUILDING_TYPE_HALL, #home_building.type, db:dirty_get(home_building, Uid, #home_building.uid)) of
		#home_building{lev=Lev} -> Lev;
		_ -> 0
	end.

process_on_upgrade_complete(#home_building{type=?BUILDING_TYPE_HALL, uid=Uid}) ->
	active_buildings(Uid);
process_on_upgrade_complete(#home_building{type=Type}) when ?is_res_building(Type) ->
	skip;
process_on_upgrade_complete(Rec=#home_building{type=?BUILDING_TYPE_INSTITUE}) ->
	active_institue2(Rec);
process_on_upgrade_complete(_) -> skip.

is_upgrading(BuildingId) when is_integer(BuildingId) ->
	case db:dirty_get(home_building, BuildingId) of
		[Rec] -> is_upgrading(Rec);
		_ -> false
	end;
is_upgrading(#home_building{upgrade_end_time=Time}) ->
	Time > 0.

calc_worker_ratio_add(FightScore) ->
	cfg_formula:calc_home_worker_ratio_add(FightScore).

work_times(Now, BeginTime,PreHourNum,StorageNum) ->
	util:floor((Now-BeginTime) / 3600 * PreHourNum / StorageNum).

end_one_time(Now, BeginTime,PreHourNum,StorageNum) ->
	Time = Now-BeginTime,
	PreTime = StorageNum / PreHourNum * 3600,
	case Time =< PreTime of
		true -> PreTime - Time;
		_ -> end_one_time(Time - PreTime, PreTime)
	end.

end_one_time(Time, PreTime) ->
	case Time =< PreTime of
		true -> PreTime - Time;
		_ -> end_one_time(Time - PreTime, PreTime)
	end.

get_info(_Uid, _HeroType) -> false.
	% case db:dirty_get(usr, Uid) of
	% 	[#usr{name=Name}] ->
	% 		case fun_entourage:get_entourage(Uid, HeroType) of
	% 			Info = #entourage_info{} -> {ok, Name, Info};
	% 			_ -> false
	% 		end;
	% 	_ -> false
	% end.