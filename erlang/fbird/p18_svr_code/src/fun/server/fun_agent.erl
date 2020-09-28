-module(fun_agent).
-include("common.hrl").

-export([on_init/0,on_login/1,on_logout/1,do_msg/1,send_all_usr/2,get_drop_drums_time/1,out_stuck/3,
		 send_to_scene/1,get_alive_buff/0,get_scene_hid/0,get_usr_skills/1, save_guide_code/2]).

-export([is_can_reenter_scene/1,req_online_status/3,do_refrush_day_event_zero/1,handle_to_scene/2]).

-export([req_module_datas/3]).

get_scene_hid() ->
	get(scene_hid).

on_init() ->
	{_Date, {Hour, Min, Sec}} = util_time:seconds_to_datetime(util_time:unixtime()),
	put(agent_hour, Hour),
	put(agent_clock, Sec),
	put(agent_minute,Min),
	put(team_info,{0,0}),
	
	put(check_pt_time,0),
	put(check_pt_no,0),
	put(check_pt_list,[]),
	
	%% open_client_error_report:前端错误上报控制开关(默认开启)
	put(global_tmp, {open_client_error_report, 1}),
	
	ok.
 
on_login(_Sid)->
	Uid = get(uid),
	mod_role_timer_updater:on_login(Uid),
	mod_mail_new:on_login_load_mail(Uid),
	fun_main_task:on_login(Uid),
	mod_guild_technology:on_init(Uid),
	check_buffs(Uid),
	init_day_event(),
	
	mod_role_event:init(Uid),
	?DEBUG_MODE andalso my_debug:check_hero_equips(Uid),
	ok.

handle_to_scene(Module, Msg) ->
	SceneHid = get(scene_hid),
	if
		erlang:is_pid(SceneHid) ->
			gen_server:cast(SceneHid, {handle_msg,Module,Msg});
		true -> skip
	end.

send_to_scene(Msg) ->
	SceneHid = get(scene_hid),
	if
		erlang:is_pid(SceneHid) ->
			gen_server:cast(SceneHid, Msg);
		true -> skip
	end.


get_usr_skills(Uid) ->
	case fun_shenqi:get_used_shenqi(Uid) of
		{0, _} -> 
			[];
		{ShenqiType, Star} -> 
			fun_shenqi:get_shenqi_skills(ShenqiType, Star)
	end.

	
check_buffs(Uid)->
	Now=util:longunixtime(),
	Buffs = fun_agent_buff:get_buffs(Uid),
	Fun = fun(#save_buff{type=Type,power=Power,mix_lev=Lev,start=DBStart,lenth=DBLength,effect_time=DBEffect,buff_adder=Adder},Res)->
		Start  = DBStart*1000,
		Effect = DBEffect*1000,
		Length = DBLength*1000,
		if  
			Length==0->[#scene_buff{type=Type,power=Power,mix_lev=Lev,start=Start,lenth=Length,effect_time=Effect,buff_adder=Adder} | Res];
			true->
				case data_buff:get_data(Type) of
					#st_buff_config{timesgo=0}-> [#scene_buff{type=Type,power=Power,mix_lev=Lev,lenth=Length,effect_time=Effect,buff_adder=Adder} | Res];
					#st_buff_config{timesgo=1}-> 
						if  
							Start+Length>Now->[#scene_buff{type=Type,power=Power,mix_lev=Lev,start=Start,lenth=Length,effect_time=Effect,buff_adder=Adder} | Res];
							true->Res
						end;
					_->Res
				end 
		end
	end,
	NewBuff = lists:foldl(Fun, [], Buffs),
	put(save_buff,NewBuff).

% get_del_move_buff()->
% 	case get(del_move_sand_buff) of
% 		List when is_list(List)->List;
% 		_->[]
% 	end. 
   
get_alive_buff()->
	case get(save_buff)  of  
		SaveBuffs  when  erlang:is_list(SaveBuffs)->
			erase(save_buff),
			Now=util:longunixtime(),
			Fun=fun(#scene_buff{start=Start,lenth=Length,type=Type}=Old,Res)-> 
						       if  
									Length==0->Res++[Old#scene_buff{start=Now,lenth=Length}];
									true->
										case data_buff:get_data(Type) of
											#st_buff_config{timesgo=0}-> 
												if
													Start == 0 -> Res++[Old#scene_buff{start=Now,lenth=Length}];
													true -> Res++[Old#scene_buff{start=Now,lenth=Start+Length-Now}]
												end;
											#st_buff_config{timesgo=1}-> 
												if  
													Start+Length>Now->Res++[Old#scene_buff{start=Now,lenth=Start+Length-Now}];
													true->Res
												end;
											_->Res
										end 
								end
						end,
			
			lists:foldl(Fun, [], SaveBuffs);
		_->[]
	end.	

on_logout(Uid) ->
	[Usr=#usr{}] =  db:dirty_get(usr, Uid),
	Now=agent:agent_now(),
	db:dirty_put(Usr#usr{last_logout_time = Now}),
	ok.


do_msg({handle_msg,Module,Msg}) -> Module:handle(Msg);

do_msg({usr_revive_new, Uid, Time, Type}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			ReviveTimes = case Type of
				1 -> 0;
				_ -> 0
			end,
			Pt = #pt_revive_info_new{
				type = Type,
				countdown = Time,
				times = ReviveTimes
			},
			?send(Sid,proto:pack(Pt));
		_ -> skip
	end;

do_msg({usr_revive, Uid, Time}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] ->
			ReviveTimes = fun_usr_misc:get_misc_data(Uid, revive),
			Pt = #pt_revive_times{
				countdown = Time,
				times = ReviveTimes
			},
			?send(Sid,proto:pack(Pt));
		_ -> skip
	end;

do_msg({achieve_arena_rank, Rank, RankUp, Uid, Sid}) ->
	fun_task_count:process_count_event(achieve_arena_rank, {0, RankUp, Rank}, Uid, Sid);

do_msg({no_last_scene}) ->
	put(no_last_scene,true);
do_msg({start_fly, Sid,_Uid,Seq, SceneId,{Scene,Pos},PlyData}) ->
	{X,Y,Z} = Pos,
	%% 	?debug("start_fly data = ~p",[{Sid,_Uid,Seq, SceneId,{Scene,Pos}}]),
	% ?log_trace("start_fly data = ~p",[{Sid,_Uid,Seq, SceneId,{Scene,Pos}}]),
	
	put(fly_scene_id,SceneId),
	put(fly_scene_pos,Pos),
	put(fly_scene_type,Scene),
	case PlyData of  
		{war_camp,Camp}->put(war_camp,Camp);
		_->skip
	end,
	Pt = #pt_req_load_scene{
		scene = Scene,
		x = X,
		y = Y,
		z = Z
	},
	?send(Sid,proto:pack(Pt, Seq)),
	ok;
do_msg({start_global_fly, Sid,_Uid,Seq, SceneId,{Scene,Pos},PlyData}) ->
	{X,Y,Z} = Pos,
	%% 	?debug("start_fly data = ~p",[{Sid,_Uid,Seq, SceneId,{Scene,Pos}}]),
	?log_trace("start_global_fly data = ~p",[{Sid,_Uid,Seq, SceneId,{Scene,Pos}}]),
	
	put(fly_scene_id,{global,SceneId}),
	put(fly_scene_pos,Pos),
	put(fly_scene_type,Scene),
	case PlyData of  
		{war_camp,Camp}->put(war_camp,Camp);
		_->skip
	end,
	Pt = #pt_req_load_scene{
		scene = Scene,
		x = X,
		y = Y,
		z = Z
	},
	?send(Sid,proto:pack(Pt, Seq)),
	ok;
	
do_msg({recv_pt, Sid, Name, Seq, Pt}) ->
	case fun_agent_pt_post:fill_pt(pt_code_id:pack_code(element(1, Pt))) of
		scene -> 
			send_to_scene({recv, Sid,get(uid), {Name,Seq,Pt}});
		agent -> 
			fun_pt_router:process_pt(Name,Seq,Pt,Sid);
		agent_mng ->
			gen_server:cast({global, agent_mng}, {recv, Sid,get(uid), {Name,Seq,Pt}});
		relation_mng ->
			gen_server:cast(relation_mng, {recv, Sid,get(uid), {Name,Seq,Pt}});
		mod_mail ->
			case Name of
				pt_read_mail_item_d210 -> 
					mod_mail_new:req_read_mail_item(get(uid), Sid, Seq, Pt);
				_ -> 
					gen_server:cast(mod_mail_new, {recv, Sid,get(uid), {Name,Seq,Pt}})
			end;
		_ -> skip
	end;
do_msg({upadate_scene_hid,_Scene, SceneHid}) ->
	?debug("upadate_scene_hid,SceneHid = ~p",[SceneHid]),
	put(scene_hid,SceneHid);

do_msg({save_scene_buff,Buffs}) ->
	put(save_buff,Buffs);


do_msg({curr_pos_save, SavePos}) ->
	case db:dirty_get(usr, get(uid)) of
		[Usr | _] -> db:dirty_put(Usr#usr{save_pos = SavePos});
		_ -> skip
	end;
do_msg({hp_mp_save, CurHp,CurMp}) ->
	case db:dirty_get(usr, get(uid)) of
		[Usr | _] -> db:dirty_put(Usr#usr{hp = CurHp,mp = CurMp});
		_ -> skip
	end;

do_msg({update_curr_members,TeamID,Usrs}) ->
	put(curr_members,{TeamID,Usrs});

do_msg({pick_drop_enter_backpack,Uid,NewPick}) ->
	case db:dirty_get(ply,Uid) of
		[#ply{sid=Sid}] ->
			Fun = fun({State,ItemType,ItemNum,_ItemBind,ItemLev},Acc)->
				case State of
					0 -> [{?ITEM_WAY_SCENE_DROP,ItemType,ItemNum,[{strengthen_lev, ItemLev}]} | Acc];
					_ ->
						case fun_resoure:check_resouce(ItemType) of
							true-> [{?ITEM_WAY_SCENE_DROP,ItemType,ItemNum,[{strengthen_lev, ItemLev}]} | Acc];
							_-> Acc
						end
				end
			end,
			AddItems = lists:foldl(Fun, [], NewPick),
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems);
		_ -> skip
	end;

do_msg({drop_drums_time,Uid,Time})->  
	[Usr | _] = db:dirty_get(usr,Uid),
	db:dirty_put(Usr#usr{drop_drums_time = Time});

% do_msg({usr_acquire_title,Title})->
% 	fun_title:usr_acquire_title(Title, get(uid), get(sid));

do_msg({usr_x_y_z,_OSid,Sid,Uid,_Oid,SceneType,Pos,Seq})->
	gen_server:cast({global, agent_mng}, {fly, Sid,Uid,Seq, {SceneType,Pos}});	
do_msg({add_mail_item,Seq,MItemData})->	
	Uid=get(uid),
	case db:dirty_get(ply,Uid) of
		[#ply{sid=Sid} | _] ->
			Fun=fun(Data,{MRet1,MRet2}) ->
				case Data of
					{MailID,ItemList} ->
						AddItems = [{?ITEM_WAY_MAIL_ITEM, Type, Num,[{strengthen_lev, Lev}]} || {Type, Num, Lev} <- ItemList],
						Succ = fun() -> ok end,
						Fail = fun() -> {stop,no_pos} end,
						Reason = fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, Fail),
						% ?debug("Mail : ~p",[Reason]),
						case Reason of
							{stop,no_pos}-> {[{MailID, ItemList} | MRet1], MRet2};
							_ -> {MRet1, [{MailID, ItemList} | MRet2]}
						end;
					_ -> ?log_error("add_mail_item data error,data=~p~n",[Data]),{MRet1,MRet2}
				end
			end,
			{NoAddItemMailData,AddFinishMails}=lists:foldl(Fun, {[],[]}, MItemData),
			if
				erlang:length(NoAddItemMailData) > 0 -> ?error_report(Sid,"bag_full");
				true -> skip
			end,
			gen_server:cast({global, agent_mng}, {add_mail_item_return,Uid,Seq,NoAddItemMailData,AddFinishMails});
		_ -> skip	
	end;

do_msg({count_event,Event,{Sort,Data,Num},Uid,Sid})->
	fun_task_count:process_count_event(Event, {Sort,Data,Num}, Uid, Sid);


do_msg({save_ride_status,Uid,Data})->fun_ride:save_ride_status(Uid, Data);
do_msg({in_fight})->
%% 	?debug("in_fight"),
	case get(in_fight) of  
		{?FALSE,_Time} ->
			 put(in_fight,{?TRUE,util:unixtime()+?LEAVE_FIGHT_TIME}),
             fun_ride:on_off_ride(get(uid), get(sid), 0, in_fight);
		{?TRUE,_Time} ->
			
			 put(in_fight,{?TRUE,util:unixtime()+?LEAVE_FIGHT_TIME});
		 _->skip
	end;

do_msg({reenter_limitboss_not_ok, _Scene, _ToPos})-> 
	mod_transfer:agent_enter_scene(0);

do_msg({reenter_limitboss_ok, Scene, ToPos})-> 
	mod_msg:send_to_agnetmng({fly, get(sid), get(uid), 0, {Scene, ToPos}});

do_msg({add_exped_entourage_exp,Uid,EnExpList,BinData})->
	case db:dirty_get(ply,Uid) of
		[#ply{sid=Sid} | _] ->
			Fun=fun(Data) ->
					case Data of
						{Type,Num} ->
							if
								Num >= 0 ->
									fun_entourage:fight_add_exp(Uid, Sid, Type, Num);
								true -> skip
							end;							
						_ -> skip
					end
				end,
			lists:foreach(Fun, EnExpList),
			?send(Sid,BinData);%%发送英雄远征的奖励信息		
		_ -> skip	
	end;		
	
do_msg({get_cdkey_info,Data})->
	fun_cdkey:check_use(Data);

do_msg({be_praise,Uid,Sid})->
	fun_task_count:process_count_event(be_praise,{0,0,1},Uid,Sid);
do_msg({do_praise,Uid,Sid})->
	fun_task_count:process_count_event(do_praise,{0,0,1},Uid,Sid);

% do_msg({day_first_recharge,Uid,_Num})-> 
% 	fun_charge_active:add_charge_rewards(Uid, ?CHARGE_EVERYDAY_REWARD),
%     fun_charge_active:add_charge_rewards(Uid, ?CHARGE_CONTINUE_REWARD);

do_msg({add_resoure,Uid,List,Way}) ->
	Sid = get(sid),
	Args = #api_item_args{
		way = Way,
		add = List
	},
	fun_item_api:add_items(Uid, Sid, 0, Args);

do_msg({on_start_activity_help,Uid,ActType}) ->
	case fun_gm_activity_ex:find_open_activity(ActType) of
		{true, ActivityRec} ->
			fun_usr_misc:set_misc_data(Uid, first_recharge, [ActivityRec#gm_activity.act_id]);
		_ -> skip
	end;

do_msg({on_usr_recharge,Uid,RechargeDiamond,RechargeConfigID})->
	% fun_task_count:process_count_event(recharge,{0,0,RechargeDiamond},Uid,util:get_sid_by_uid(Uid)),
	fun_gm_activity_ex:on_recharge(Uid, RechargeDiamond, RechargeConfigID);

do_msg({first_recharge,Uid,RechargeConfigID,PhoneType})->
	fun_recharge:first_recharge_help(Uid,RechargeConfigID,PhoneType),
	% case data_charge_config:get_web_config_id(RechargeConfigID) of
	% 	0 -> skip;
	% 	RechargeConfigID1 -> fun_recharge:first_recharge_help(Uid,RechargeConfigID1,PhoneType)
	% end,
	ok;

do_msg({recharge_activity,Uid,Sort})-> 
	case Sort of
		?RECHARGE_SORT_WEEK ->
			fun_charge_active:add_charge_rewards(Uid, ?CHARGE_ACTIVE_WEEK_CARD);
		?RECHARGE_SORT_MONTH ->
			fun_charge_active:add_charge_rewards(Uid, ?CHARGE_ACTIVE_MONTH_CARD);
		?RECHARGE_SORT_LIVE ->
			fun_charge_active:add_charge_rewards(Uid, ?CHARGE_ACTIVE_LIVE_CARD);		
		?RECHARGE_SORT_FUND ->
			fun_charge_active:add_charge_rewards(Uid, ?CHARGE_ACTIVE_LEV_REWARD);
		_ -> skip	
	end,
	case db:dirty_get(ply, Uid) of
		[#ply{sid = Sid}] -> fun_item:req_item_info(Uid,Sid,0);
		_ -> skip
	end;
do_msg({first_recharge_activity,Uid,_Len,VipExp,_Money})->	
	fun_vip:add_vip_exp(Uid, util:get_sid_by_uid(Uid), VipExp),
	% fun_task_count:process_count_event(task_recharge,{0,0,1},Uid,util:get_sid_by_uid(Uid)),
	% fun_first_extend_recharge:put_recharge_time(Uid,Money),
	ok;

do_msg({create_guild,Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq})->
	fun_guild:create_guild_help({Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq});

do_msg({change_guild_name,Uid,Sid,ItemType,Guild,GuildName,BinGuildName,Seq})->
	fun_guild:change_guild_name_help({Uid,Sid,ItemType,Guild,GuildName,BinGuildName,Seq});

do_msg({check_buff,Uid,Data,BuffType,State})->
	Sid = util:get_sid_by_uid(Uid),
	case State of
		true->
			fun_item_action:add_buff(Uid, Sid, Data, BuffType,0);
		_->
			?error_report(Sid,"buff_exist")
	end;

do_msg({light_bath,NewAddExp})->
	fun_resoure:add_exp(get(uid), NewAddExp, 0);

do_msg({war_activity,Uid, WarId,Time})->
	fun_dataCount_update:war_activity(Uid, WarId,Time);
do_msg({camp_kill,AtkOid,AtkName, DefOid,DefName})->
	fun_dataCount_update:camp_kill(AtkOid,AtkName, DefOid,DefName);
do_msg({usr_login_entourage_fetter,_Uid})-> ok;

do_msg({check_guild_inspire,Uid,ScenePid}) ->
	fun_guild_copy:check_guild_inspire(Uid,ScenePid);

do_msg({check_and_add_items,Uid, Sid,SpendItems,Additem,SuccCallBack,FailCallBack}) ->
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems,Additem,SuccCallBack,FailCallBack);

do_msg({upgrade_institue_skill, Uid}) ->
	fun_family:update_fighting(Uid);

do_msg({on_get_hall_reward, Uid, Sid, AddItems, NewAddItems, NameList}) ->
	fun_family:get_hall_reward(Uid, Sid, AddItems, NewAddItems, NameList);

do_msg({on_upgrade_complete, Uid, Sid, Type, Lev}) ->
	fun_task_count:process_count_event(family_building,{0, Type, Lev},Uid,Sid),
	Name = case data_building_unlock:get_data(Type) of
		{_,_,Name1,_,_,_} -> Name1;
		_ -> ""
	end,
	?error_report(Sid, "shengjichenggong", 0, [Name]),
	?send(Sid, proto:pack(#pt_building_upgrade_complete{id=Type}));

do_msg({world_boss, Uid, Sid}) ->
	fun_task_count:process_count_event(world_boss,{0,0,0},Uid,Sid);

do_msg({on_join_meeting, Uid, Time}) ->
	fun_usr_misc:set_misc_data(Uid, meeting_times, Time);

do_msg({on_hero_leave, Uid, TargetUid, Sid, HeroType}) ->
	fun_entourage:hero_leave(Uid, TargetUid, Sid, HeroType);

do_msg({on_hero_settled, Uid, Sid, HeroType, Type}) ->
	fun_entourage:hero_settled(Uid, Sid, HeroType, Type);
  
do_msg({on_quick_mine, Uid, Sid, Time, GetType, GetNum, NeedType, NeedNum, Seq}) ->
	fun_family:on_quick_mine({Uid, Sid, Time, GetType, GetNum, NeedType, NeedNum, Seq});

do_msg(_Msg) ->
	?debug("unhandled msg,msg=~p", [_Msg]),
	ok.

send_all_usr(Uid,Data)->
	send_to_scene({send_all_usr, Uid,Data}).
%% 	case get(scene_hid) of				
%% 		SceneHid when erlang:is_pid(SceneHid) -> gen_server:cast(SceneHid, {send_all_usr, Uid,Data});
%% 		_ -> skip
%% 	end.

is_can_reenter_scene(Scene) ->
	case data_dungeons_config:select(Scene) of
		[] -> false;
		_ -> true
	end.

% set_guide_code(undefined,_Seq,_Data) -> skip;
% set_guide_code(Uid,_Seq,Data) ->
% 	case db:dirty_get(usr, Uid) of
% 		[Usr] -> db:dirty_put(Usr#usr{guide_code = Data});
% 		_ -> skip
% 	end.

get_drop_drums_time(Uid)->
	case db:dirty_get(usr, Uid) of
		[Usr|_]->
			Usr#usr.drop_drums_time;
		_->0
	end.

init_day_event() ->
	Uid = get(uid),
	[Usr | _] = db:dirty_get(usr, Uid),
	case util_time:is_same_day(util_time:unixtime(), Usr#usr.last_logout_time) of
		true  -> skip;
		false -> 
			do_refrush_day_event_zero(Uid)
	end,
	NextZeroLeftSecs = 24*3600 - calendar:time_to_seconds(erlang:time()),
	role_loop:add_callback(NextZeroLeftSecs + 1, ?MODULE, do_refrush_day_event_zero, Uid),
	ok.

do_refrush_day_event_zero(Uid) ->
	NextZeroLeftSecs = 24*3600 - calendar:time_to_seconds(erlang:time()),
	role_loop:add_callback(NextZeroLeftSecs + 1, ?MODULE, do_refrush_day_event_zero, Uid),

	util_misc:safe_exe_fun(fun() -> fun_arena:refresh_times(Uid) end),
	util_misc:safe_exe_fun(fun() -> fun_store:refresh_data(Uid) end),
	util_misc:safe_exe_fun(fun() -> fun_daily_task:refresh_data(Uid) end),
	util_misc:safe_exe_fun(fun() -> fun_sign:refresh_data(Uid) end),
	util_misc:safe_exe_fun(fun() -> fun_activity_copy:refresh_times(Uid) end),
	util_misc:safe_exe_fun(fun() -> fun_vip:refresh_daily_reward(Uid) end),
	ok.

%%脱离卡死
out_stuck(Uid,Sid, Seq)->
	case db:dirty_get(ply,Uid) of
		[#ply{scene_type=SceneType}|_]->
			case data_scene_config:get_scene(SceneType) of 
				#st_scene_config{points = PointList}->
					gen_server:cast({global, agent_mng}, {fly, Sid,Uid,Seq,{SceneType,hd(PointList)}});
				_->skip
			end;
		_R->skip
	end.

req_online_status(Sid, Seq, TargetUid) ->
	IsOnline = 
	case db:dirty_get(ply, TargetUid) of
		[#ply{}] -> 1;
		_ -> 0
	end,
	?send(Sid, proto:pack(#pt_online_status{uid=TargetUid,is_online=IsOnline}, Seq)).

req_module_datas(Uid, Sid, Seq) ->
	send_server_time(Sid, Seq),
	% send_server_open_day(Sid, Seq),

	util_misc:safe_exe_fun(fun() -> fun_item:req_item_info(Uid,Sid,Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_draw:send_draw_info_to_client(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_activity_copy:req_copy_times(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> mod_entourage_data:send_on_battle_heros(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_relation_ex:send_friend_to_sid(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_relation_ex:send_apply_to_sid(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_main_task:send_info_to_client(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_daily_task:send_info_to_client(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> fun_sign:send_info_to_client(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> send_guide_codes(Uid, Sid, Seq) end),
	util_misc:safe_exe_fun(fun() -> mod_guild_technology:req_info(Uid, Sid, Seq) end),
	gen_server:cast(agent_mng, {req_module_datas, Uid, Sid, Seq}),
	ok.

send_server_time(Sid, Seq) ->
	Pt = #pt_system_time{
		time_zone = server_config:get_conf(timezone),
		time = util_time:unixtime()
	},
	% ?debug("Pt = ~p",[Pt]),
	?send(Sid,proto:pack(Pt, Seq)).

% send_server_open_day(Sid,Seq)->
% 	Pt = #pt_open_svr_dayinfo{open_svr_day=util_server:get_server_open_days()},
% 	?send(Sid,proto:pack(Pt, Seq)).

send_guide_codes(Uid, Sid, Seq) ->
	Pt = #pt_guide_info{list = fun_usr_misc:get_data_ex(Uid, guide_codes, [])},
	?send(Sid, proto:pack(Pt, Seq)).


save_guide_code(Uid, Code) ->
	List = fun_usr_misc:get_data_ex(Uid, guide_codes, []),
	case lists:member(Code, List) of
		false -> 
			fun_usr_misc:set_data_ex(get(uid), guide_codes, [Code | List]);
		_ -> skip
	end.

