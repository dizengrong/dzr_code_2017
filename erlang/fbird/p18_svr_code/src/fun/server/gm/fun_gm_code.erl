-module(fun_gm_code).
-include("common.hrl").
-export([process/3]).
-export([add_monster/1]).

process(Uid,Sid,String) ->
	StrList = string:tokens(String, " "),
	if
		length(StrList) > 0 ->
			[Cmd | Parms] = StrList,
			process(Uid,Sid,Cmd,Parms);
		true -> skip
	end.

process(Uid,Sid,"additem",[StrType]) -> 
	fun_item_api:check_and_add_items(Uid, Sid, [], [{?ITEM_WAY_GM, util:to_integer(StrType)}]);
process(Uid,Sid,"additem",[StrType,StrNum]) -> 
	fun_item_api:check_and_add_items(Uid, Sid, [], [{?ITEM_WAY_GM, util:to_integer(StrType),util:to_integer(StrNum)}]);
process(Uid,Sid,"additem",[StrType,StrNum,StrLev]) -> 
	fun_item_api:check_and_add_items(Uid, Sid, [], [{?ITEM_WAY_GM, util:to_integer(StrType),util:to_integer(StrNum),[{strengthen_lev, util:to_integer(StrLev)}]}]);
process(Uid,Sid,"setitem",[StrType,StrNum]) -> 
	Type = util:to_integer(StrType),
	Num2 = util:to_integer(StrNum),
	Have = fun_item:get_item_num_by_type(get(uid), Type),
	if
		Have > Num2 ->
			SpendItems = [{?ITEM_WAY_GM, Type, Have - Num2}],
			AddItems   = [];
		Have < Num2 ->
			SpendItems = [],
			AddItems   = [{?ITEM_WAY_GM, Type, Num2 - Have}];
		true -> 
			SpendItems = [],
			AddItems   = []
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems);

process(Uid,Sid,"addexp",[Exp]) -> 
	fun_item_api:check_and_add_items(Uid, Sid, [], [{?ITEM_WAY_GM, ?RESOUCE_EXP_NUM, util:to_integer(Exp)}]);
process(Uid,_Sid,"setproperty",[Property, Value]) ->
	fun_agent_property:gm_set_battle_property(Uid, util:to_integer(Property), util:to_integer(Value));
process(Uid,Sid,"setbarrier",[SceneLev]) ->
	mod_scene_lev:gm_set_scene_lv(Uid, Sid, util:to_integer(SceneLev));
process(Uid,_Sid,"sethp",[Hp]) -> 
	fun_agent:send_to_scene({gm_sethp,Uid,max(1,util:to_integer(Hp))});
process(Uid,_Sid,"addmonster",[StrType]) -> fun_agent:send_to_scene({gm_add_monster,Uid,util:to_integer(StrType)});
process(Uid,_Sid,"addmonster",[StrType,StrNum]) ->
	Num = util:to_integer(StrNum),
	erlang:start_timer(2000, self(), {?MODULE, add_monster, {Uid, util:to_integer(StrType), Num}});
process(Uid,Sid,"addvipexp",[Exp]) -> 
	fun_vip:add_vip_exp(Uid, Sid, util:to_integer(Exp));

process(Uid,Sid,"cleanbag",_) -> fun_item:clean_backpack(Uid, Sid);

process(Uid,_Sid,"mail",[Mail1]) ->
	Mail = util:to_atom(Mail1),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(Mail),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content, [{1828, 2}], ?MAIL_TIME_LEN);
process(Uid,_Sid,"mail",[Mail1, Tuple1]) ->
	Mail = util:to_atom(Mail1),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(Mail),
	Content1 = util:format_lang(util:to_binary(Content), [Tuple1]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content1, [{1828, 2}], ?MAIL_TIME_LEN);
process(Uid,_Sid,"mail",[Mail1, Tuple1, Tuple2]) -> 
	Mail = util:to_atom(Mail1),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(Mail),
	Content1 = util:format_lang(util:to_binary(Content), [Tuple1, Tuple2]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content1, [{1828, 2}], ?MAIL_TIME_LEN);
process(Uid,_Sid,"mail",[Mail1, Tuple1, Tuple2, Tuple3]) -> 
	Mail = util:to_atom(Mail1),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(Mail),
	Content1 = util:format_lang(util:to_binary(Content), [Tuple1, Tuple2, Tuple3]),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content1, [{1828, 2}], ?MAIL_TIME_LEN);

process(Uid,_Sid,"recharge",[RechargeID]) -> 
	NRechargeID=util:to_integer(RechargeID),
	?DBG(NRechargeID),
	gen_server:cast(agent_mng, {gm_test_recharge,Uid,NRechargeID});
process(Uid,Sid,"sign",[Days]) -> fun_sign:gm_sign(Uid, Sid, util:to_integer(Days));
process(Uid,Sid,"resetpk",[]) -> 
	fun_arena:gm_reset_times(Uid, Sid);
process(Uid,Sid,"minuscreatetime",[Days]) -> 
	fun_seven_day_target:gm_minus_create_time(Uid, Sid, util:to_integer(Days));
process(Uid,Sid,"relifetime",[Time]) -> 
	fun_usr_misc:set_misc_data(Uid, relife_time, util:to_integer(Time)),
	fun_relife:gm_relife(Uid, Sid, 0),
	fun_relife_task:gm_init_relife_task(Uid),
	fun_family:on_pass_copy(Uid);
process(Uid,Sid,"resetquick",[]) -> 
	fun_quick_fight:gm_reset_times(Uid, Sid);
process(Uid,Sid,"resetbuycoin",[]) -> 
	fun_buy_coin:gm_reset_times(Uid, Sid);
process(Uid,Sid,"openbox",[BoxId, Prof]) -> 
	DropList = fun_draw:box(util:to_integer(BoxId), util:to_integer(Prof)),
	fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, DropList),
	ok;
process(Uid,Sid,"openbox",[BoxId, Prof, Times]) -> 
	Fun = fun(_, Acc) ->
		List = fun_draw:box(util:to_integer(BoxId), util:to_integer(Prof)),
		util_list:add_and_merge_list(Acc, List, 1, 2)
	end,
	DropList = lists:foldl(Fun, [], lists:seq(1, util:to_integer(Times))),
	fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, DropList),
	ok;
process(Uid,Sid,"settask",[Step]) -> 
	fun_task_step:gm_set_step(Uid, Sid, util:to_integer(Step));
process(Uid,Sid,"usecard",[Type]) -> 
	fun_charge_active:gm_update_card(Uid, Sid, util:to_integer(Type));
process(Uid,Sid,"addtitleexp",[Exp]) ->
	fun_title:gm_add_exp(Uid, Sid, util:to_integer(Exp));

process(Uid,_Sid,"setguildlv",[Lv]) ->
	fun_guild:gm_set_lv(Uid, util:to_integer(Lv));
	



process(Uid,Sid,"fly",[StrType]) -> 
	Scene=util:to_integer(StrType),
	case data_scene_config:get_scene(Scene) of
		#st_scene_config{sort = ?SCENE_SORT_COPY} ->
			fun_agent:send_to_scene({req_enter_copy_scene, Uid, 0, Scene});
		#st_scene_config{points = PointList} ->
			gen_server:cast({global, agent_mng}, {fly, Sid,Uid,0,{Scene,hd(PointList)}});
		_ -> skip
	end;

process(Uid,_Sid,"addmonsterbuff",[StrType]) ->
	BuffType = util:to_integer(StrType),
	Fun = fun() -> 
		List = fun_scene_obj:get_ml(),
		[fun_scene_obj:update(fun_scene_buff:add_buff(Obj, BuffType, Uid)) || Obj <- List]
	end,
	scene:debug_call(Uid, Fun);

process(Uid,_Sid,"addherobuff",[StrType]) ->
	 fun_agent:handle_to_scene(mod_scene_entourage, {add_all_hero_buff,Uid,util:to_integer(StrType)});

process(Uid,_Sid,"addbuff",[StrType]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),true});
process(Uid,_Sid,"addbuff",[StrType,"1"]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),false});
process(Uid,_Sid,"addbuff",[StrType,_]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),true});
process(Uid,_Sid,"addbuff",[StrType,"1",StrPower,StrLen]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),util:to_integer(StrPower),util:to_integer(StrLen),true});
process(Uid,_Sid,"addbuff",[StrType,_,StrPower,StrLen]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),util:to_integer(StrPower),util:to_integer(StrLen),false});
process(Uid,_Sid,"addbuff",[StrType,"1",StrPower,StrLen,StrSkill,StrLev]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),util:to_integer(StrPower),util:to_integer(StrLen),util:to_integer(StrSkill),util:to_integer(StrLev),true});
process(Uid,_Sid,"addbuff",[StrType,_,StrPower,StrLen,StrSkill,StrLev]) -> fun_agent:send_to_scene({gm_add_buff,Uid,util:to_integer(StrType),util:to_integer(StrPower),util:to_integer(StrLen),util:to_integer(StrSkill),util:to_integer(StrLev),false});
process(Uid,_Sid,"setpskill",[StrType]) -> fun_agent:send_to_scene({gm_set_passive_skill,Uid,util:to_integer(StrType)});
process(Uid,Sid,"a",[_StrType]) ->gen_server:cast({global, agent_mng}, {ask_recommend_friend_list,Sid,Uid,0});
process(Uid,Sid,"b",[_StrType]) -> gen_server:cast({global, agent_mng}, {req_a_key_add_friends,Sid,Uid,0});
process(Uid,_Sid,"eaddexp",[Num]) ->fun_entourage:entourage_add_exp(Uid, util:to_integer(Num));
% process(Uid,Sid,"dotask",[ID,SStep]) ->
% 	{Task_id,Step}={util:to_integer(ID),util:to_integer(SStep)},
% 	fun_task:gm_code_accept_task(Uid, Sid, Task_id, Step);
process(Uid,Sid,"g1",[StrType]) -> gen_server:cast({global, agent_mng}, {action_string,?ACTION_GUILD_CREATE,Uid,Sid,0,util:to_binary(StrType)});
process(Uid,Sid,"g2",[_StrType]) ->  gen_server:cast({global, agent_mng}, {action,?ACTION_GUILD_COMMONALITY_INFO,Uid,Sid,0});
process(Uid,Sid,"g3",[_StrType]) ->  gen_server:cast({global, agent_mng}, {action,?ACTION_GUILD_INFO,Uid,Sid,0});	
process(_Uid,_Sid,"sendallmail",[ConfigID]) -> gen_server:cast({global, agent_mng}, {send_all_mail,util:to_integer(ConfigID),[]});
process(_Uid,_Sid,"sendallmail",[ConfigID,StrType1,StrNum1]) -> gen_server:cast({global, agent_mng}, {send_all_mail,util:to_integer(ConfigID),[{util:to_integer(StrType1),util:to_integer(StrNum1)}]});
process(Uid,_Sid,"sendmail",[ConfigID]) -> gen_server:cast({global, agent_mng}, {send_mail,Uid,util:to_integer(ConfigID),[]});
process(Uid,_Sid,"sendmail",[ConfigID,StrType1,StrNum1]) -> gen_server:cast({global, agent_mng}, {send_mail,Uid,util:to_integer(ConfigID),[{util:to_integer(StrType1),util:to_integer(StrNum1)}]});

process(Uid,Sid,"gs5",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_GUILD_COPY_ENTER,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"gs6",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_GUILD_COPY_RESET,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"gs7",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_GUILD_COPY_DAMAGE,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"gs8",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_GUILD_COPY_APPLY,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"gs9",[StrType,SceneId]) ->  gen_server:cast({global, agent_mng}, {action_two_int_d012,?ACTION_GUILD_CHANGE_NOTICE,Uid,Sid,0,util:to_integer(StrType),util:to_integer(SceneId)});
process(Uid,Sid,"r1",[StrType]) -> gen_server:cast({global, agent_mng}, {action_int,?ACTION_RANKLIST,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"i1",[StrType]) -> fun_item:req_equipment_inherit(Sid, Uid, util:to_integer(StrType), 0);

process(Uid,Sid,"o1",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_USE_INFO_EQUIP,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"o2",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_USE_INFO_PROP,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"o3",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_USE_INFO_ENTOURAGE,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,Sid,"o4",[StrType]) ->  gen_server:cast({global, agent_mng}, {action_int,?ACTION_USE_INFO_LOST_ITEM,Uid,Sid,0,util:to_integer(StrType)});
process(Uid,_Sid,"addcampdata",_) -> gen_server:cast({global, agent_mng}, {gm_add_camp_vote_data,Uid});
process(Uid,_Sid,"addgr",[StrNum]) -> gen_server:cast({global, agent_mng}, {gm_add_guild_resource,Uid,util:to_integer(StrNum)});
process(Uid,Sid,"addge",[StrNum]) -> gen_server:cast({global, agent_mng}, {gm_add_guild_exp,Uid,Sid,util:to_integer(StrNum)});
process(Uid,_Sid,"add_guild_resource",[Num]) -> 
	GuildResNum = util:to_integer(Num),
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_get(guild, GuildId) of
				[Guild|_]->
					GuildNum = Guild#guild.resource,
					case db:dirty_get(guild_member, GuildId,#guild_member.guild_id) of
						[GuildMember]->
								Integral=GuildMember#guild_member.usr_integral,
								db:dirty_put(GuildMember#guild_member{usr_integral =GuildResNum + Integral});
						_->skip
					end,
					db:dirty_put(Guild#guild{resource=GuildResNum + GuildNum});
				_->skip
			end;
		_->skip
	end;

process(_Uid,_Sid,"ban",[StrUid]) -> gen_server:call({global, agent_mng}, {data_count,{usr_ban,util:to_integer(StrUid),"impl",60}});
process(_Uid,_Sid,"gm1",[Data1,Data2]) -> fun_gm_operation:start_sethonor(util:to_integer(Data1),util:to_integer(Data2));
process(_Uid,_Sid,"gm2",[Data1,Data2]) -> fun_gm_operation:start_sethonor(util:to_integer(Data1),util:to_integer(Data2));
process(Uid,Sid,"update_achieve",[StrType,StrNum]) -> fun_achieve:update_achieve(Uid, Sid, util:to_integer(StrType), util:to_integer(StrNum));
process(Uid,Sid,"add_achieve",[StrType,StrNum]) -> fun_achieve:update_achieve(Uid, Sid, util:to_integer(StrType), util:to_integer(StrNum));
process(Uid,Sid,"tobeleader",_) -> 
	gen_server:cast({global, agent_mng}, {gm_chg_camp_leader,Uid,Sid});
process(Uid,Sid,"tobecommander",_) -> 
	gen_server:cast({global, agent_mng}, {gm_chg_camp_deputy,Uid,Sid});

process(_Uid,_Sid,"xz",[Num]) ->
	case db:dirty_get(opening_server_time, 1) of
		[DrawAstrict = #opening_server_time{}|_]->
			db:dirty_put(DrawAstrict#opening_server_time{draw_astrict=util:to_integer(Num)});
		_->skip
	end;

process(_Uid,_Sid,"stopggb",[]) -> 
	stop_ggb_battle();
process(Uid,Sid,"startggb",[]) -> 
	start_ggb_battle(Uid,Sid);
	
process(_Uid,Sid,"wm1",[_Num]) ->
	gen_server:cast({global, agent_mng}, {action,?ACTION_EXTREME_LUXURY_GIFT,get(uid),Sid,0});
process(Uid,Sid,"wm2",[Num]) ->
	fun_activity_treasure:req_treasure_extract(Uid, Sid, util:to_integer(Num), 0);
process(Uid,Sid,"wm3",[_Num]) ->
	gen_server:cast({global, agent_mng}, {ask_recommend_friend_list,Sid,Uid,0});

process(_Uid,_Sid,_Cmd,_Parms) -> ok.



add_monster({Uid, MonsterType, LeftNum}) ->
	case LeftNum > 100 of
		true ->
			[fun_agent:send_to_scene({gm_add_monster,Uid,MonsterType}) || _ <- lists:seq(1, 100)],
			erlang:start_timer(2000, self(), {?MODULE, add_monster, {Uid, MonsterType, LeftNum - 100}});
		_ ->
			[fun_agent:send_to_scene({gm_add_monster,Uid,MonsterType}) || _ <- lists:seq(1, LeftNum)]
	end.


start_ggb_battle(Uid,Sid) -> 
	?debug("test_ggb_battle"),
	GuildId1 = 1,
	GuildId2 = 2,
	ServerID = db:get_all_config(serverid),
	Key         = {guild_battle, 1, ?GGB_BATTLE_SCENE},
	SceneData   = {1, [
						{{ServerID,GuildId1}, get_battle_member(GuildId1, 11)}, 
						{{ServerID,GuildId2}, get_battle_member(GuildId2, 12)}
					  ]
				  },
	gen_server:cast({global, scene_mng}, {create_scene, ?GGB_BATTLE_SCENE, Key, SceneData}),

	timer:sleep(1000),
	process(Uid,Sid,"fly",[?GGB_BATTLE_SCENE]),
	ok.


get_battle_member(GuildId, Camp) -> 
	List  = fun_guild:get_members(GuildId),
	List2 = [begin 
		{Rec, EntourageData} = fun_arena:get_ply_data(Uid),
		?debug("EntourageData:~p", [EntourageData]),
		{Rec#scene_spirit_ex{camp = Camp, hp = Rec#scene_spirit_ex.hp + 99}, EntourageData}
		end || #guild_member{uid=Uid} <- List], 
	List2.


stop_ggb_battle() -> 
	fun_scene_mng:set_guild_scene_to_kick_state(?GGB_BATTLE_SCENE).
