-module(fun_agent_mng).
-include("common.hrl").

-export([do_init/0,do_close/0,do_call/1,do_info/1,do_time/1,do_msg/1,get_usrs_by_condition/1,send_count_event/5]).
-export([send_to_agent/2,agent_msg_by_pid/2,get_usrs/0,scene_msg_by_pid/2,send_to_scene/2,start_fly/3,on_usr_ban/1,max_online/0,
		 scramble_activity/0]).
-export([get_global_value/2, set_global_value/2]).

%% ================== 获取和设置全局的key-val格式的数据==================
%% 注意:
%% key的长�varchar(256)
%% val的长�varchar(1024)
get_global_value(Key, Default) ->
	%% 注意这里key转为binary是因为从mysql数据库读出来就是binary
	Key2 = util:to_binary(util:term_to_string(Key)),
	case db:dirty_get(key_val, Key2, #key_val.key_data) of
		[] -> Default;
		[#key_val{val_data = Val}] -> util:string_to_term(util:to_list(Val))
	end.
set_global_value(Key, Val) ->
	Key2 = util:to_binary(util:term_to_string(Key)),
	
	case db:dirty_get(key_val, Key2, #key_val.key_data) of
		[]  -> 
			Rec = #key_val{
				key_data = Key2,
				val_data = util:term_to_string(Val)
			},
			db:insert(Rec);
		[Rec] -> 
			Rec2 = Rec#key_val{
				key_data = Key2,
				val_data = util:term_to_string(Val)
			},
			db:dirty_put(Rec2)
	end.
%% ================== 获取和设置全局的key-val格式的数�==================


send_to_agent(Hid,Msg) ->
	gen_server:cast(Hid, Msg).

get_usrs()	->
	Usr_List=db:dirty_match(ply, #ply{_='_'}),	 
	[Usr#ply.uid || Usr <-Usr_List].

get_usrs_by_condition({0,0,0})->
	Usr_List=db:dirty_match(ply, #ply{_='_'}),	 
	[{Usr#ply.uid,Usr#ply.sid} || Usr <-Usr_List];
get_usrs_by_condition({0,Start,End})->
	Usr_List=db:dirty_select(ply, [{#ply{regtime='$1', _='_'},[{'>','$1', Start},{'<','$1', End}],['$_']}]),	 
	[{Usr#ply.uid,Usr#ply.sid}|| Usr <-Usr_List];
get_usrs_by_condition({Channel,0,0})->
    Usr_List=db:dirty_match(ply, #ply{channel=Channel,_='_'}),	 
	[{Usr#ply.uid,Usr#ply.sid} || Usr <-Usr_List];
get_usrs_by_condition({Channel,Start,End})	->
	Usr_List=db:dirty_select(ply, [{#ply{channel='$1',regtime='$2', _='_'},[{'==','$1', Channel},{'>','$2', Start},{'<','$2', End}],['$_']}]),	 
	[{Usr#ply.uid,Usr#ply.sid}|| Usr <-Usr_List].

do_init()-> 
	srv_loop:init(),
	put(max_plys,0),
	max_online(),
	mod_arena_ranklist:init(),
	ok.

do_close() -> ok.
scramble_activity()->
	case get(scramble_activity) of
		true->?log_trace("----scramble_activity----true-------"),skip;
		_->
			case data_event:get_data(1) of
				#st_event_confg{opentime=[OpenTimeH,OpenTimeM],endtime=[EndTimeH,EndTimeM]}->
					{_Year,_Month,_Day,Hour, Minite,_Second}  = util:get_unixtime_date(),
%% 					?log_trace("----scramble_activity-----------"),
					case (Hour > OpenTimeH orelse  (Hour == OpenTimeH andalso Minite >= OpenTimeM)) andalso ((Hour == EndTimeH andalso Minite =< EndTimeM) orelse(Hour < EndTimeH) ) of
						true->
%% 							?log_trace("----scramble_activity_star----true------"),
%% 							put(scramble_activity,true),
							gen_server:cast({global, scene_mng}, {scramble_activity_star});
						_->skip
					end;
				_->skip
			end
	end,
	erlang:start_timer(60000, self(), {?MODULE, scramble_activity}).

%%不要在scene_mng上直接取数据库的开服时间表
% send_open_svr_time_to_scene_mng() -> 
% 	#opening_server_time{day_time=Time} = util_server:get_server_open_rec(),
% 	gen_server:cast(mod_scene_manager, {send_open_svr_time, Time}).

do_time(_Time) ->
	srv_loop:tick_loop(),
	1000.

on_usr_ban(_Uid) -> skip.

do_call({agent_in,Usr,Sid,Ip,AgentHid,PhoneType,AgentIndex}) ->
	{UChannel,UCreateTime} = case db:getOrKeyFindData(account, Usr#usr.acc_id) of
		[#account{ channel=Channel,create_time=CreateTime}|_] -> {Channel,CreateTime};
		_ -> {0,0}
	end,
	db:dirty_put(#ply{
		hp=Usr#usr.hp,uid = Usr#usr.id,aid = Usr#usr.acc_id, sid=Sid,
		name=Usr#usr.name,camp=Usr#usr.camp,military_lev=Usr#usr.military_lev,
	    prof=Usr#usr.prof,lev=Usr#usr.lev,ip=Ip, 
	    agent_hid=AgentHid,agent_idx=AgentIndex,channel=UChannel,
	    regtime=UCreateTime,paragon_level=Usr#usr.paragon_level,vip=Usr#usr.vip_lev
	    ,phone_type = PhoneType
	}),
	% mod_mail_new:load_mail(Usr#usr.id),
	% fun_recharge:load_recharge_data(Usr#usr.id),
	% put_usr_login_entourage_fetter(Usr#usr.id),
	% fun_five_day:login(Usr#usr.id),
	ok;


do_call({data_count,Msg}) -> fun_s2g_callback:do_call(Msg);
do_call(_Msg) ->?log_trace("----do_call---=~p",[_Msg]), ok.

do_info({timeout, _TimerRef, CallBackInfo}) ->
	case CallBackInfo of
		{Module, Function} ->
			try
				Module:Function()
			catch E:R ->?log_error("timeout error,data=~p,E=~p,R=~p,stack=~p",[CallBackInfo,E,R,erlang:get_stacktrace()])
			end;
		{Module, Function, Args} ->
			try
				Module:Function(Args)
			catch E:R ->?log_error("timeout error,data=~p,E=~p,R=~p,stack=~p",[CallBackInfo,E,R,erlang:get_stacktrace()])
			end;
		_ ->
			?log_warning("unknown timer callback,CallbackInfo=~p", [CallBackInfo])
	end;
do_info(_Info) -> ok.

do_msg({handle_msg,Module,Msg}) -> Module:handle(Msg);
do_msg({global_match_succ,Uid,Bin}) -> fun_match_ex:global_match_succ(Uid,Bin);
do_msg({global_team_leader_match_succ,Uid,Bin}) -> fun_match_ex:global_team_leader_match_succ(Uid,Bin);
do_msg({global_team_member_match_succ,Uid,Bin}) -> fun_match_ex:global_team_member_match_succ(Uid,Bin);
do_msg({global_stop_ready_group,Uid}) -> fun_match_ex:global_stop_ready_group(Uid);
do_msg({global_team_stop_ready_group,Uid}) -> fun_match_ex:global_team_stop_ready_group(Uid);
do_msg({global_match_finish,Uid}) -> fun_match_ex:global_match_finish(Uid);
do_msg({global_team_match_finish,Uid}) -> fun_match_ex:global_team_match_finish(Uid);

do_msg({send_hunstone_info, Uid, Sid, Seq}) ->
	fun_guild:send_hunstone_info(Uid, Sid, Seq);

do_msg({req_get_hunstone, Uid, Sid, Seq, Data}) ->
	fun_guild:req_get_hunstone(Uid, Sid, Seq, Data);

do_msg({exit_war_match,Uid,Seq,ActionID}) ->
	fun_match_ex:req_quit_match(Uid, Seq, 2, ActionID);

do_msg({req_war_match,Uid,Id,Seq}) ->
	fun_match_ex:req_match(Uid, Seq, {battlefeild,Id});
do_msg({order_pay_complete, {OrderId,SourceId,Money,RoleId}}) ->
	?log_trace("lyn_pay_complete,OrderId=~p,SourceId=~p,Money=~p,RoleId=~p", [OrderId,SourceId,Money,RoleId]),
	case fun_plat_interface_lyn:verify_order(OrderId) of  
		{Uid,Type,Price}->
			if
				RoleId == Uid ->
					MoneyNum = util:to_number(Money),
					if
						Price == MoneyNum ->
							?log_trace("verify_order_success  OrderId~p  SourceId~p", [OrderId,SourceId]),
							fun_plat_interface_lyn:remove_order(OrderId), 
							fun_recharge:recharge_action(Uid, OrderId, Price, SourceId, Type);
						true -> ?log_trace("order_pay_complete,check money error,Price = ~p,MoneyNum = ~p",[Price,MoneyNum])
					end;					
				true ->
					?log_trace("verify_order_failed,uid = ~p,roleid=~p",[Uid,RoleId]),
					skip
			end;		
		_R ->
			?log_trace("verify_order_failed,_R = ~p",[_R]),
			skip
	end;

%%专门给平台直接调用过来充�
do_msg({order_gm_pay_complete, {RoleID,PayType,Money,Platform}}) ->
	?log_trace("gm_pay_complete,RoleID,PayType,Money,Platform=~p", [{RoleID,PayType,Money,Platform}]),
	fun_recharge:recharge_action(RoleID, 0, Money, Platform, PayType);	

do_msg({req_gen_order,Uid,Type,Seq}) ->
	case db:dirty_get(ply, Uid)of
		[#ply{sid=Sid}] ->
			case data_charge_config:get_data(Type) of
				#st_charge_config{charge_money=Price}->
					OrderId = fun_plat_interface_lyn:gen_order(Uid, Type, Price),
					Pt = #pt_gen_order{
						type = Type,
						order = OrderId
					},
					?send(Sid,proto:pack(Pt,Seq));
				_ -> skip
			end;
		_ -> skip
	end;
do_msg({data_count,Msg}) ->fun_s2g_callback:do_msg(Msg);

do_msg({save_buffs,Uid,Buffs}) ->
	FunLogout = fun(#scene_buff{type=ThisType}) ->
						case data_buff:get_data(ThisType) of
							#st_buff_config{timeRetain=1}-> true;
							_ -> false
						end
				end,
	LogoutBuffs=lists:filter(FunLogout, Buffs),
	save_off_line_buffs(Uid, LogoutBuffs),
	case db:dirty_get(ply, Uid)  of  
		[#ply{agent_hid=Agent}]->
			FunPassScene = fun(#scene_buff{type=ThisType}) ->
								   case data_buff:get_data(ThisType) of
									   #st_buff_config{sceneRetain=1}-> true;
									   _ -> false
								   end
						   end,
			PassSceneBuffs=lists:filter(FunPassScene, Buffs),
			gen_server:cast(Agent, {save_scene_buff,PassSceneBuffs});
		_->skip
	end;

do_msg({usr_in_scene,Uid,SceneId,SceneType,SceneHid,SceneIdx,Fighting,_Hp_limit}) ->
	case db:dirty_get(ply, Uid) of
		[Ply=#ply{} | _] -> 
			db:dirty_put(Ply#ply{scene_hid=SceneHid,scene_idx = SceneIdx,scene_id=SceneId,scene_type=SceneType,fighting=Fighting});
		_ -> skip
	end;

do_msg({agent_out, Uid}) ->	
	?debug("agent_out uid=~p",[Uid]),
	case db:dirty_get(ply,Uid) of
		[#ply{}=Ply] -> 
			%%通知场景退出游�
			if
				is_pid(Ply#ply.scene_hid) -> gen_server:cast(Ply#ply.scene_hid, {agent_out, logout, Uid});
				true -> 
					skip
			end,
			db:dirty_del(ply,Uid),
			% gen_server:cast(guild_mng, {put_guild_member_lastlogin,Uid}),
			ok;
		_ -> skip
	end;
%%logout save
do_msg({logout_save, Uid, SavePos}) ->
	case db:dirty_get(usr, Uid) of
		[Usr | _] ->			
			db:dirty_put(Usr#usr{save_pos=SavePos});
		_ -> skip
	end;
do_msg({logout_save, Uid, SavePos, ScenePid}) ->
	case db:dirty_get(usr, Uid) of
		[Usr | _] ->			
			db:dirty_put(Usr#usr{save_pos=SavePos ++ "," ++ pid_to_list(ScenePid)});
		_ -> skip
	end;
do_msg({logout_save, Uid,SavePos,CurHp,CurMp}) ->
	case db:dirty_get(usr, Uid) of
		[Usr | _] -> db:dirty_put(Usr#usr{save_pos = SavePos,hp = CurHp,mp = CurMp});
		_ -> skip
	end;
do_msg({logout_save, Uid,SavePos,CurHp,CurMp, ScenePid}) ->
	case db:dirty_get(usr, Uid) of
		[Usr | _] -> db:dirty_put(Usr#usr{save_pos = SavePos ++ "," ++ pid_to_list(ScenePid),hp = CurHp,mp = CurMp});
		_ -> skip
	end;
do_msg({usr_in_scene,Uid,SceneId,SceneType,SceneHid,SceneIdx,Fighting,Hp_limit,CopyTimesList}) ->
%% 	?debug("usr_in_scene uid=~p,SceneId=~p,SceneHid=~p,SceneType=~p,Fighting=~p",[Uid,SceneId,SceneHid,SceneType,Fighting]),
	% ?log_trace("usr_in_scene uid=~p,SceneId=~p,SceneHid=~p,SceneType=~p,Fighting=~p",[Uid,SceneId,SceneHid,SceneType,Fighting]),
	case db:dirty_get(ply, Uid) of
		[Ply | _] -> 
			db:dirty_put(Ply#ply{scene_hid=SceneHid,scene_idx = SceneIdx,scene_id=SceneId,scene_type=SceneType,fighting=Fighting,hp_limit=Hp_limit,copy_times=CopyTimesList});
		_ -> ?log_trace("no ply Uid=~p",[Uid]),skip
	end;
do_msg({updata_property_hplimit,Uid,Hplimit}) ->
%% 	?debug("updata_property_hplimit uid=~p,Hplimit=~p",[Uid,Hplimit]),
	case db:dirty_get(ply, Uid) of
		[Ply | _] -> 
			db:dirty_put(Ply#ply{hp_limit=Hplimit});
		_ -> skip
	end;
do_msg({update_hp,Uid,Hp,{match, _TeamId, _Scene}}) ->
%% 	?debug("update_hp uid=~p,Hp=~p",[Uid,Hp]),
	case db:dirty_get(ply, Uid) of
		[Ply | _] -> 
			db:dirty_put(Ply#ply{hp=Hp});
		_ -> skip
	end;
do_msg({update_hp,Uid,Hp,_SceneData}) ->
%% 	?debug("update_hp uid=~p,Hp=~p",[Uid,Hp]),
	case db:dirty_get(ply, Uid) of
		[Ply | _] -> 
			db:dirty_put(Ply#ply{hp=Hp});
		_ -> skip
	end;
do_msg({updata_fighting,Uid,Fighting}) ->
	%% 	?debug("updata_fighting  uid=~p,Hp=~p",[Uid,Fighting]),
	case db:dirty_get(ply, Uid) of
		[Ply=#ply{}] -> 
			db:dirty_put(Ply#ply{fighting=Fighting}),
			fun_relation_ex:update_fighting(Uid, Fighting);
		_ -> skip
	end;
do_msg({updata_usr_lev,Uid,Lev,_Exp}) ->
%% 	?debug("updata_usr_lev  uid=~p,Hp=~p",[Uid,Lev]),
	case db:dirty_get(ply, Uid) of
		[Ply = #ply{}] ->
			db:dirty_put(Ply#ply{lev=Lev}),
			fun_relation_ex:updata_friend_lev(Uid, Lev),
			fun_guild:updata_guild_member_lev(Uid, Lev);
		_ -> skip
	end;
do_msg({updata_usr_paragon_level,Uid,Lev,_Exp})->
	case db:dirty_get(ply, Uid) of
		[Ply = #ply{lev=Level}] ->
			db:dirty_put(Ply#ply{paragon_level=Lev}),
			fun_relation_ex:updata_friend_lev(Uid, Level),
			fun_guild:updata_guild_member_lev(Uid, Level);
		_ -> skip
	end;
do_msg({updata_usr_vip_level,Uid,Lev,_Exp})->
	case db:dirty_get(ply, Uid) of
		[Ply | _] -> 
			db:dirty_put(Ply#ply{vip=Lev});
		_ -> skip
	end;

do_msg({usr_out_scene,Uid,SceneId}) ->	
%% 	?debug("usr_out_scene uid=~p,SceneId=~p",[Uid,SceneId]),
	case db:dirty_get(ply, Uid) of
		[Ply = #ply{scene_id=SceneId} | _] -> 
			db:dirty_put(Ply#ply{scene_hid=0,scene_idx = 0,scene_id=0});
		_ -> skip
	end;

do_msg({recv, Sid,Uid, {Name,Seq,Pt}}) -> process_pt(Name,Seq,Pt,Sid,Uid);
do_msg({action,Action,Uid,Sid,Seq}) ->
	case Action of
		?ACTION_GUILD_LIST->fun_guild:req_get_guild_list(Uid,Sid,Seq);  
		?ACTION_GUILD_INFO->fun_guild:guild_all_member_info(Sid, Uid, Seq);
		?ACTION_GUILD_COMMONALITY_INFO->
			fun_guild:send_guild_commonality_info_to_sid(Uid,Sid,Seq),
			case fun_guild:get_guild_req_join_list(Uid)	of
				[]->skip;
				_->
					case fun_guild:get_guild_baseinfo(Uid) of
						{ok,GuildId,_}->fun_guild:send_guild_guild_member_verify(GuildId);
						_->skip
					end
			end;
		?ACTION_GUILD_BUILDING_LIST->fun_guild:req_guild_building_list(Uid, Sid, Seq);
		?ACTION_GUILD_DONATION_RECORD->fun_guild:req_donation_record(Uid,Sid,Seq);
		?ACTION_GUILD_COPY_LIST->fun_guild_copy:req_guild_boss_copy_info(Uid, Sid, Seq);
		% ?ACTION_GUILD_COPY_TROPHY->fun_guild_damage:send_damage_reward_to_client(Uid, Sid, Seq);
		?ACTION_REQ_MATCH_READY_CANCEL -> fun_match_ex:req_quit_group(Uid,Seq);
		?ACTION_GUILD_APPLY_FOR_LIST->fun_guild:req_guild_apply_for_member_list(Sid, Uid, Seq);
		?ACTION_REQ_SUBMIT_READY -> fun_match_ex:submit_ready(Uid, Seq);
		?ACTION_SCENE_BRANCHING_INFO->
			case db:dirty_get(ply, Uid) of
				[#ply{scene_type=SceneType,scene_id=SceneId,sid=Sid}]->
					gen_server:cast({global, scene_mng}, {scene_branching_info,Sid,SceneId,SceneType,Seq});
				_->skip
			end;
		?ACTION_REQ_RECHARGE_DATA -> fun_recharge:request_first_recharge_data(Uid,Seq);
		?ACTION_GUILD_POST->fun_guild:get_guild_member_post(Uid,Sid);
		?ACTION_GUILD_IMPEACH_PRESIDENT->fun_guild:req_guild_impeach_president(Sid, Uid, Seq);
		
		% ?ACTION_REQ_OPEN_SVR_FIVE_TIME -> fun_five_day:req_time(Uid, Sid, Seq);
		% ?ACTION_REQ_OPEN_SVR_LIMIT_TIME -> fun_five_day:req_open_svr_limit_time(Uid, Sid, Seq);
		?ACTION_REQ_GUILD_RENT_ENTOURAGE -> fun_entourage_exped:req_exped_entourage_data(Uid, Sid, Seq);
		?ACTION_REQ_REFLUSH_EXPED -> fun_entourage_exped:req_reflush(Uid, Sid, Seq);
		?ACTION_REQ_RENT_ENTOURAGE_LIST -> fun_entourage_exped:req_rent_entourage_info(Uid, Sid, Seq);
		?ACTION_EXTREME_LUXURY_GIFT->fun_activity_treasure:req_extreme_luxury_gift(Uid, Sid, Seq);
		?ACTION_REQ_RECRUITING_MEMBERS ->fun_guild:req_recruiting_members(Uid, Sid, Seq);
		?ACTION_REQ_GUILD_LOG ->fun_guild:req_guild_log(Uid,Sid,Seq);
		?ACTION_REQ_GUILD_IMPEACH ->fun_guild_extra:req_guild_impeach(Uid,Sid,Seq);
		% ?ACTION_REQ_ARENA_SEASON_INFO ->fun_arena_new:req_new_arena_season_info(Uid,Sid,Seq);
		_ -> skip
	end;
do_msg({action_int,Action,Uid,Sid,Seq,Data}) ->
	case Action of				
		?ACTION_REQ_CHANGE_GUILD_NOTICE->fun_guild:req_change_banner(Uid, Sid, Seq, Data);
		?ACTION_GUILD_ROUGH_INFO->fun_guild:send_guild_notice_to_sid(Uid, Sid,Data, Seq);
		?ACTION_REQ_READ_MAIL -> mod_mail_new:req_read_mail(Uid, Sid, Seq, Data); 
		?ACTION_GUILD_QUIT->
			case Data of
				0 ->fun_guild:req_quit_guild(Uid,Sid,Seq);
				_->fun_guild:req_kick_guild(Uid, Data,Sid,Seq)
			end;
		?ACTION_GUILD_COPY_ENTER->fun_guild_copy:req_guild_copy_enter(Uid, Sid, Data, Seq);
		?ACTION_GUILD_COPY_RESET->fun_guild_copy:req_guild_copy_reset(Uid, Sid, Data, Seq);
		?ACTION_RANKLIST->fun_toplist:show_ranklist(Data, Uid, Seq);		

		?ACTION_REQ_INTO_WAR->fun_match_ex:req_or_timeout_into_war({[Uid],Data});
		?ACTION_REQ_INVITE_JOIN_GUILD->fun_guild:invite_join_guild(Uid, Data, Seq);
		?ACTION_GUILD_IMPEACH_PRESIDENT_POLL->fun_guild:req_guild_impeach_president_vote(Sid, Uid, Seq, Data);
		?ACTION_REQ_RENT_ENTOURAGE -> fun_entourage_exped:req_rent_entourage(Uid, Sid, Seq, Data);
		?ACTION_REQ_EXPED_TASK -> fun_entourage_exped:req_exped_task(Uid, Sid, Seq, Data);
		?ACTION_REQ_EXPED_FINISH -> fun_entourage_exped:req_expedition_finish(Uid, Sid, Seq, Data);
		?REQ_GUILD_SET->fun_guild:req_auto_consent_join_guild(Sid, Uid, Data, Seq);
		?REQ_GUILD_TEAM_COPY_INFO_WINKLE->fun_guild_ex:req_winkle_guild_call_upon(Sid, Uid, Data, Seq);
		?ACTION_REQ_ENTER_WORLDBOSS -> fun_worldboss:req_enter_copy(Uid, Sid, Seq, Data);
		?ACTION_REQ_GUILD_IMPEACH_RESULT ->fun_guild_extra:req_guild_impeach_result(Uid,Sid,Seq,Data);
		% ?ACTION_REQ_FETCH_ARNEA_REWARD ->fun_arena_new:req_fetch_season_reward(Uid,Sid,Seq,Data);
		_ -> skip 
	end;
do_msg({action_string,Action,Uid,Sid,Seq,Data})->
	case Action of
		?ACTION_GUILD_SEEK->fun_guild:search_guild(Uid,Sid,Data,Seq);
		?ACTION_GUILD_CHANGE_NOTICE->fun_guild:change_notice(Uid, Sid, Data, Seq);
		?ACTION_CONFIRM_INVITE_JOIN_GUILD->fun_guild:reply_inv_join_guild(Uid, Data,Seq);
		_->skip
	end;
do_msg({action_two_int_d012,Action,Uid,Sid,Data1,Data2,Seq})->
	case Action of
		?ACTION_REQ_VIEW_GUILD_MEMBER_INFO->fun_guild:req_view_member_info(Uid, Sid, Seq, Data1,Data2);
		?ACTION_GUILD_JOIN->fun_guild:req_join_guild(Uid, Sid, Seq, Data1,Data2);
		?ACTION_REPLY_GUILD_ENTRY->fun_guild:reply_req_join_guild(Uid,Data1,Data2,Sid,Seq);
		?ACTION_GUILD_PERM->fun_guild:updata_guild_perm(Uid,Data1,Data2,Sid,Seq);
		?ACTION_GUILD_BUILDING->fun_guild:req_add_guild_building_exp(Uid, Sid, Data1,Data2, Seq);
		?ACTION_GUILD_COPY_APPLY->fun_guild_copy:req_guild_copy_queue_up(Uid, Sid, Data1, Data2, Seq);
		?ACTION_REQ_STOP_MATCH -> fun_match_ex:req_quit_match(Uid,Seq,Data1,Data2);
		?ACTION_REQ_OTHER_USR_INFO -> fun_other_usr_info:req_other_usr_info(Uid, Sid, Seq, Data1, Data2);
		_->skip
	end;

do_msg({pt_action_string_and_data_f032,Action,Uid,Sid,Data,String,Seq})->
	case Action of
		?ACTION_GUILD_CREATE->fun_guild:req_create_guild(Uid,Sid,Seq,String,Data);
		?ACTION_REQ_CHANGE_GUILD_NAME->fun_guild:reset_guild_name(Uid,Sid,Data,String,Seq);
		_->skip
	end;

do_msg({pt_action_data_and_two_int_list_f08d,Action,Uid,Sid,List,Data,Seq})->
	case Action of
		?ACTION_REQ_SET_GUARD_LIST -> fun_arena:req_set_guard_list(Uid,Sid,List,Data,Seq);
		_->skip
	end;

do_msg({pt_arena_challenge_f089,Action,Uid,Sid,Seq,TUid,Type,List,Data})->
	case Action of
		?ACTION_REQ_ENTER_ARENA -> fun_arena:req_enter_arena(Uid,Sid,Seq,TUid,Type,List,Data,false);
		?ACTION_REQ_ARENA_REVENGE -> fun_arena:req_arena_revenge(Uid,Sid,Seq,TUid,Type,List,Data);
		_->skip
	end;

do_msg({create_guild,Uid,Sid,Seq,GuildName,Banner,Notice})->
	fun_guild:req_create_guild(Uid,Sid,Seq,GuildName,Banner,Notice);

do_msg({system_speaker,StringList}) ->
	mod_msg:handle_to_chat_server({send_system_speaker, StringList});
do_msg({system_speaker,StringList,Data}) ->
	mod_msg:handle_to_chat_server({send_system_speaker, StringList, Data});

%%副本结束时将伤害副本进度
% do_msg({guild_copy_damage_progress,Scene,Uid,DamageList,Copy_progress,ItemList,MLHP})->
% 	fun_guild_copy:guild_copy_damage_progress(Scene, Uid, DamageList, Copy_progress,ItemList,MLHP); 

do_msg({change_name, Uid, Name}) ->
	fun_relation_ex:updata_friend_name(Uid, Name),
	fun_guild:update_guild_member(Uid, Name);

do_msg({add_mail_item_return,Uid,Seq,NoAddItemMailData,AddFinishMails}) ->
	mod_mail_new:add_mail_item_return(Uid,Seq,NoAddItemMailData,AddFinishMails);

do_msg({send_all_mail,ConfigID,ItemList}) ->
	
	mod_mail_new:sys_send_public_mail(?MAIL_TITLE,?MAIL_CONTENT,ItemList,?MAIL_TIME_LEN,ConfigID);

do_msg({send_all_mail_info,Title,Content,ItemList}) ->
%% 	?debug("gm_send_all_mail_info,{Title,Content,ItemList,SName}=~p~n",[{Title,Content,ItemList}]),
	mod_mail_new:sys_send_public_mail(Title,Content,ItemList,?MAIL_TIME_LEN);

do_msg({send_kick_mail,Uid}) ->
	mod_mail_new:sys_send_personal_mail(Uid,"伺服器維護通知","系統判斷可能有人使用加速器，導致伺服器連接品質不佳，我們正在處理此問題。感謝理解。",[],?MAIL_TIME_LEN);

do_msg({send_mail,Uid,ConfigID,ItemList}) ->
	mod_mail_new:sys_send_personal_mail(Uid,?MAIL_TITLE,?MAIL_CONTENT,ItemList,?MAIL_TIME_LEN,ConfigID);

do_msg({send_mail_info,Uid,Title,Content,ItemList}) ->
%% 	?debug("gm_send_mail_info,{Title,Content,ItemList,SName}=~p~n",[{Title,Content,ItemList}]),
	mod_mail_new:sys_send_personal_mail(Uid,Title,Content,ItemList,?MAIL_TIME_LEN);

do_msg({req_match, Uid,Seq,DungeonsID}) ->
	fun_match_ex:req_match(Uid, Seq, {dungeons,DungeonsID});

do_msg({req_boss_info_response,Uid,_Sid,Data}) ->
	case db:dirty_get(ply, Uid) of
		[Ply | _] -> 
			?send(Ply#ply.sid,Data);
		_ -> skip
	end;

do_msg({update_boss_info,Data}) ->
	AgentList = db:dirty_match(ply, #ply{_ = '_'}),
	Fun = fun(#ply{sid=Sid}) when erlang:is_pid(Sid) -> ?send(Sid,Data) end,
	lists:foreach(Fun, AgentList);

do_msg({global_arena_result, Result, Uid, Name}) ->
	fun_global_arena:on_arena_result(Result, Uid, Name);

do_msg({complex_arena_result, Result, Uid, Type, Data, Time}) ->
	case Type of
		global_sailing -> fun_server_uncharter_water:arena_result({Result, Uid, Type, Data, util_time:unixtime()});
		_ -> fun_maze:on_complex_arena_result({Result, Uid, Type, Data, Time})
	end;

do_msg({get_maze_fight_result, TargetUid, Data}) ->
	fun_maze:get_maze_fight_result({TargetUid, Data});

do_msg({add_scene_handler,_Scene,_Hid}) ->
	ok;

do_msg({gm_test_recharge,Uid,NRechargeID}) ->
	fun_recharge:gm_recharge_action(Uid,NRechargeID);
do_msg({gm_add_guild_resource,Uid,GuildResNum}) ->
	fun_guild:gm_add_guild_resource(Uid,GuildResNum);
do_msg({gm_add_guild_exp,Uid,Sid,GuildExpNum}) ->
	fun_guild:gm_add_guild_exp(Uid,Sid,GuildExpNum);
do_msg({auto_guild_copy,Uid})->
	fun_guild:auto_refresh_time({Uid,util:get_sid_by_uid(Uid)});

do_msg({create_guild_succ,Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq})->
	fun_guild:create_guild_succ({Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq});

do_msg({change_guild_name_succ,Uid,Sid,Guild,GuildName,BinGuildName,Seq})->
	fun_guild:change_guild_name_succ({Uid,Sid,Guild,GuildName,BinGuildName,Seq});

do_msg({add_resource,Uid,Sid,Num})->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			fun_guild:add_guild_resource(GuildId, Num),
			fun_guild:add_guild_exp(Uid, Sid, GuildId, Num),
			fun_guild:put_usr_donate_time(Uid, GuildId, Num, 0),
			fun_guild:update_ranklist(GuildId),
			fun_guild:send_guild_all_info_to_sid(Uid);
		_->skip
	end;

do_msg({updata_name,Uid,Name})->
	case db:dirty_get(ply, Uid) of
		[Ply = #ply{}]->
			db:dirty_put(Ply#ply{name=util:to_binary(Name)});
		_ -> skip
	end;
do_msg({scramble_close,WinCamp})->
	% ?log_trace("-------scramble_close-----------"),
	Name= 
		if WinCamp == 2-> "破晓";
		   WinCamp == 3->"烈阳";
		   true->""
		end,
	mod_msg:handle_to_chat_server({send_system_msg, [integer_to_list(397),util:to_list(Name)]}),
	put(scramble_activity,false);

do_msg({scramble_activity,State})->
	% ?log_trace("-------scramble_activity-----State=~p---",[State]),
	put(scramble_activity,State);

do_msg({send_guild_call,Uid,SceneType,Pos,ItemId,MinLev})->
	case get(send_call_up) of
		?UNDEFINED->
			put(send_call_up,[{Uid,ItemId,SceneType,Pos,MinLev}]);
		List->
			case lists:keyfind(Uid, 1, List) of
				{Uid,_,_,_,_}->
					put(send_call_up,lists:keyreplace(Uid, 1, List, {Uid,ItemId,SceneType,Pos,MinLev}));
				_->put(send_call_up,lists:append(List,[{Uid,ItemId,SceneType,Pos,MinLev}]))
			end
	end,
	send_guild_call(Uid,ItemId,SceneType,MinLev);
			
do_msg({send_camp_call,Uid,SceneType,Pos,ItemId,MinLev})->
	case get(send_call_up) of
		?UNDEFINED->
			put(send_call_up,[{Uid,ItemId,SceneType,Pos,MinLev}]);
		List->
			case lists:keyfind(Uid, 1, List) of
				{Uid,_,_,_,_}->
					put(send_call_up,lists:keyreplace(Uid, 1, List, {Uid,ItemId,SceneType,Pos,MinLev}));
				_->put(send_call_up,lists:append(List,[{Uid,ItemId,SceneType,Pos,MinLev}]))
			end
	end,
	send_camp_call(Uid, ItemId, SceneType, MinLev);

do_msg({pass_guild_copy,Uid,Scene,TotalDamage,Percent,_WinOrLose})->
     fun_guild_damage:add_usr_damage(Uid,Scene,TotalDamage),
     fun_guild_copy:set_progress_data(Uid,Scene,Percent),
     fun_guild_copy:set_fast_data(Uid,Scene,Percent);

do_msg({update_guild_reward,Uid, Sid, Seq, Old,Reard_id_list,Old_getlist,Rewar_type})->
	fun_guild_copy:update_guild_reward(Uid, Sid, Seq, Old,Reard_id_list,Old_getlist,Rewar_type);

do_msg({find_competitor_from_other_server, FromServerID, FromUid, Rank, FilterList})->
	fun_global_arena:get_data_to_global(FromServerID, FromUid, Rank, FilterList);

do_msg({match_competitor_from_global_succ, Data, Uid})->
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid = Hid}] ->
			mod_msg:handle_to_agent(Hid, fun_global_arena, {enter_arena_scene, Uid, Data});
		_ -> skip
	end;

do_msg({find_competitor_from_global_all_error, Uid})->
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid = Hid}] ->
			mod_msg:handle_to_agent(Hid, fun_global_arena, {find_conpetitor_fail, Uid});
		_ -> skip
	end;

do_msg({update_global_arena_ranklist_from_global, Uid, Data})->
	fun_global_arena_toplist:update_toplist(Uid, Data);

do_msg({leave_global_arena_ranklist_from_global, Uid})->
	fun_global_arena_toplist:leave_toplist(Uid);

do_msg({worship_global_arena_to_global, Uid})->
	fun_global_arena_toplist:update_worship(Uid);

do_msg({find_intrusion_info_from_other_server, EventId, FromUid, NeedSceneLev, FromServerId}) ->
	fun_maze:get_intrusion_info({EventId, FromUid, NeedSceneLev, FromServerId});

do_msg({send_maze_result_from_global, Result, EventId, FromUid, Data}) ->
	fun_maze:get_intrusion_info_result({Result, EventId, FromUid, Data});

do_msg({find_intrusion_info_from_target_server, Type, FromUid, FromServerId, Uid, ServerId}) ->
	fun_maze:get_intrusion_info_to_target_server({Type, FromUid, FromServerId, Uid, ServerId});

do_msg({find_intrusion_arena_result_to_server, Result, Type, Uid, Data}) ->
	fun_maze:get_intrusion_fight_info_result({Result, Type, Uid, Data});

do_msg({req_module_datas, Uid, Sid, Seq}) ->
	fun_guild:req_module_datas(Uid, Sid, Seq);

do_msg(_Msg) ->
	?ERROR("unhandled msg,msg=~p",[_Msg]),
	ok.

send_guild_call(Uid,ItemId,SceneType,MinLev)->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			MatchHead = #guild_member{guild_id='$1', perm = '$2', _ = '_'},
			Guards = [{'==', '$1', GuildId}, {'=<', '$2', MinLev}],
			Name = util:get_name_by_uid(Uid),
			Pt = #pt_call_up_info{call_up_id = 1,uid = ItemId,name = Name,sceneid = SceneType},
			case db:dirty_select(guild_member, [{MatchHead, Guards, ['$_']}]) of
				MemberList when is_list(MemberList) ->
					Fun = fun(#guild_member{uid=Oid})->
								  case db:dirty_get(ply,Oid) of
									  [#ply{lev=Lev,sid=OSid}|_]->
										  if MinLev =< Lev andalso Uid =/= Oid->
												 ?send(OSid,proto:pack(Pt));
											 true->skip
										  end;
									  _->skip
								  end
						  end,
					lists:foreach(Fun, MemberList);
				_ ->[]
			end;
		_->skip
	end.
send_camp_call(Uid,ItemId,SceneType,MinLev)->
	case db:dirty_get(ply,Uid) of
		[#ply{camp=Camp,name=Name}|_]->
			case db:dirty_match(ply, #ply{camp=Camp,_='_'}) of
				PlyList when is_list(PlyList)->
					Pt = #pt_call_up_info{call_up_id = 2,uid = ItemId,name = Name,sceneid = SceneType},
					Fun = fun(#ply{lev=Lev,sid=OSid,uid=Oid})->
						if
							Lev >= MinLev andalso Uid =/= Oid-> ?send(OSid,proto:pack(Pt));
							true -> skip
						end
					end,
					lists:foreach(Fun, PlyList),
					ok;
				_ -> skip
			end;
		_->skip
	end.

process_pt(pt_del_mail_d20d,Seq,Pt,Sid,Uid) -> 
%% 	?debug("del mail Pt = ~p,Sid = ~p,uid=~p",[Pt,Sid,Uid]),
	IDS=Pt#pt_del_mail.mails,
	Mail_List=[Data#pt_public_id_list.id || Data <- IDS],
	mod_mail_new:req_del_mail(Uid, Sid, Seq, Mail_List);
process_pt(pt_read_mail_item_d210,Seq,Pt,Sid,Uid) -> 
%% 	?debug("read mail item Pt = ~p,Sid = ~p,uid=~p",[Pt,Sid,Uid]),
	IDS=Pt#pt_read_mail_item.mails,
	Mail_List=[Data#pt_public_id_list.id || Data <- IDS],
	mod_mail_new:req_read_mail_item(Uid, Sid, Seq, Mail_List);

process_pt(pt_expedition_request_d251,Seq,Pt,Sid,Uid) ->
	ID=Pt#pt_expedition_request.action,
	Data=Pt#pt_expedition_request.datas,
	List=[ {E#pt_public_exped_entourage_list.owner_uid,E#pt_public_exped_entourage_list.entype} || E <- Data],
	fun_entourage_exped:req_expedition_start(Uid,Sid,Seq,ID,List);
process_pt(_PtModule,_Seq,_Pt,_Sid,_Uid) -> ok.

%% start_fly(UsrInfoList,NeedUsrInfo,Scene,SceneData) ->
%% 	?debug("start_fly data = ~p",[{UsrInfoList,NeedUsrInfo,Scene,SceneData}]),
%% 	gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList,NeedUsrInfo,Scene,SceneData}).
start_fly(UsrInfoList,Scene,SceneData) ->
 	% ?debug("start_fly data = ~p",[{UsrInfoList,Scene,SceneData}]),
	gen_server:cast({global, scene_mng}, {start_fly, UsrInfoList,Scene,SceneData}).

agent_msg_by_pid(Uid,Msg)->
	case db:dirty_get(ply,Uid) of	
		[#ply{agent_hid=Hid}] -> send_to_agent(Hid,Msg);
		_ -> skip
	end.	

scene_msg_by_pid(Uid,Msg)->
	case db:dirty_get(ply,Uid) of	
		[#ply{scene_hid=SceneHid}]when SceneHid=/=0 -> send_to_scene(SceneHid,Msg);
		_R-> 
			% ?log("scenehid_exception data=~p,Msg:~p",[_R,Msg]),
			skip
	end.
send_to_scene(SceneHid,Msg) ->
	case SceneHid of
		{global,GlobalSceneHid} -> gen_server:cast({global,global_client_ggb}, {to_global_scene,GlobalSceneHid,Msg});
		_ ->
%% 			fun_agent:send_to_scene({out_fight,get(uid)})
			if
				erlang:is_pid(SceneHid) ->
					gen_server:cast(SceneHid, Msg);
				true -> skip
			end
	end.

save_off_line_buffs(Uid,Buffs)->
		Now=util:longunixtime(),
		case db:dirty_get(save_buff, Uid, #save_buff.uid) of  
			OldBuffs  when  erlang:is_list(OldBuffs)->
				lists:foreach(fun(#save_buff{id=Id})-> db:dirty_del(save_buff, Id)end, OldBuffs);
			_->skip
		end,
	Fun=fun(#scene_buff{type=Type,power=Power,mix_lev=Lev,start=Start,lenth=Length,effect_time=Effect,buff_adder=Adder,from_skill={ST,SL}})-> 
				DBStart=Start div 1000,
				DBLength=Length div 1000,
				DBEffect=Effect div 1000,
				DBNow=Now div 1000,
				if  
					Length==0->
						db:insert(#save_buff{uid=Uid,type=Type,power=Power,mix_lev=Lev,start=DBStart,lenth=DBLength,effect_time=DBEffect,buff_adder=Adder,skill=ST,skill_lev=SL});
					true->
						case data_buff:get_data(Type) of
							#st_buff_config{timesgo=0}-> 
								if  
									Start+Length-Now>0->
										db:insert(#save_buff{uid=Uid,type=Type,power=Power,mix_lev=Lev,start=DBStart,lenth=DBStart+DBLength-DBNow,effect_time=DBEffect,buff_adder=Adder,skill=ST,skill_lev=SL});
									true->skip
								end;
							#st_buff_config{timesgo=1}->
								db:insert(#save_buff{uid=Uid,type=Type,power=Power,mix_lev=Lev,start=DBStart,lenth=DBLength,effect_time=DBEffect,buff_adder=Adder,skill=ST,skill_lev=SL});
							_ -> skip
						end
				
				
				end
		end,
		lists:foreach(Fun, Buffs).

send_count_event(Uid,Event,Sort,Data,Num)->
case  db:dirty_get(ply, Uid) of
	[#ply{agent_hid=AgentHid,sid=Sid}]->
			fun_scene_obj:agent_msg(AgentHid,{count_event,Event,{Sort,Data,Num},Uid,Sid});
		_->skip
%% 	updata_off_count(Uid, Sort, Data, Num)
	end.
% put_usr_login_entourage_fetter(Uid)->
% 	case get(usr_login_entourage_fetter) of
% 		?UNDEFINED->
% 			put(usr_login_entourage_fetter,[Uid]),
% 			fun_agent_mng:agent_msg_by_pid(Uid, {usr_login_entourage_fetter,Uid});
% 		List ->
% 			case lists:member(Uid, List) of
% 				true->skip;
% 				_->
% 					put(usr_login_entourage_fetter,[Uid]),
% 					fun_agent_mng:agent_msg_by_pid(Uid, {usr_login_entourage_fetter,Uid})
% 			end
% 	end.
max_online()->
	Curr = get_ply_num(),
	fun_dataCount_update:max_online(Curr, 0),
	erlang:start_timer(?AUTO_REFRESH_TIME_LONG, self(), {?MODULE, max_online}).

get_ply_num() ->
	UsrList=db:dirty_match(ply, #ply{_='_'}),
	length(UsrList).