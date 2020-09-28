%%ets
-record(sql_data, {key, opType=add,rec={}}).        %key={Tab,id} opType=change,add,del
-record(config, {key, value}).
-record(sql_config, {key, sql=""}).%key={Tab,Fun}
-record(sql_key_static, {key, max=0}).%key=Tab

-record(cache,  {uid,cached = 0}).
-record(login_ply, {sid=0,uid=0,aid = 0,kick_time=0,phone_type=0}).
-record(ply, {
	uid, aid = 0, sid=0,name="",camp=1,prof=0,lev=0,ip={0,0,0,0},accname="",
	agent_hid=0,agent_idx=0,scene_hid=0,scene_idx = 0,scene_id=0,
	scene_type=0,hp=0,hp_limit=0,fighting=0,military_lev=0,
	channel=0,regtime=0,paragon_level=0,vip=0,copy_times=[],
	temp_team=false,kick_time=0,
	phone_type=0 %% 手机类型，登录时客户端告诉服务端的，值见宏定义：PHONE_TYPE_ANDRIOD
}).
-record(scene,  {id,owner=0, type= 0,module = 0,hid=0,num=0,scene_idx=0,create_time=0,all_time=0,status=0,status_time=0,line =0,num_state =0,wire_size=0,last_allot_time=0}). 

-record(temp_team, {id, leader_id = 0, scene = 0, target = 0, members = []}).
-record(team, {id, leader_id = 0,camp=0, scene = 0, target = 0, members = [], be_req_list = [],max_ply=8,min_lev=1,need_verify=1,min_gs=0}).
-record(team_member, {id, team_id = 0, ask_list = [], req_list = [],be_ask_list = []}). %%ask_list邀请加入，记录的是被邀请的人，req_list申请加入，记录的是申请加入的队伍

-record(mynet_svr, {index,address,port,max_num,cur_num}).
-record(scene_svr, {idx = 0, hid =0,maxscene=0,scene=0}).
-record(login_data, {sid,login_closed = false, aid=0,uid=0,ip=0,usrlist=[],auto_camp=0,phone_type=0}).
-record(login_data_set, {isfull,fighting,scene_type,drop_time,equip_list,task_list,skill_list,pet_list,team_info,ride_info,passive_skill=[],revive_times,copy_times,
		military=0,guild_name="",vip_lev=0,model_clothes=0,paragon_level=0,camp_leader=0,title_id=0,isroyalboxfull=false,inscription_effects=[],tower_layer=0,guild_id=0,climb_tower_boss_num=0,
		flying_shoes=0,boos_die_list=[],barrier_id=0,relife=0}).

-record(enter_scene_data,{usr={},a_hid=0,pos={0,0,0},pro={},h_c_data={},last_buffs=[],login=false,curr_members=no}).

%% 战斗属性，如果增加了属性字段，记得修改fun_property:property_add/2方法
-record(battle_property,{
	atk            = 0,
	hpLimit        = 0,
	mpLimit        = 0,
	realdmg        = 0,
	dmgdown        = 0,
	defignore      = 0,
	def            = 0,
	cri            = 0,
	cridown        = 0,
	hit            = 0,
	dod            = 0,
	cridmg         = 0,
	toughness      = 0,
	blockrate      = 0,
	breakdef       = 0,
	breakdefrate   = 0,
	blockdmgrate   = 0,
	dmgrate        = 0,
	dmgdownrate    = 0,
	contorlrate    = 0,
	contorldefrate = 0,
	movespd        = 0,
	limitdmg       = 0,

	atk_percent            = 0,
	hp_percent             = 0,
	mp_percent             = 0,
	realdmg_percent        = 0,
	dmgdown_percent        = 0,
	defignore_percent      = 0,
	def_percent            = 0,
	cri_percent            = 0,
	cridown_percent        = 0,
	hit_percent            = 0,
	dod_percent            = 0,
	cridmg_percent         = 0,
	toughness_percent      = 0,
	blockrate_percent      = 0,
	breakdef_percent       = 0,
	breakdefrate_percent   = 0,
	blockdmgrate_percent   = 0,
	dmgrate_percent        = 0,
	dmgdownrate_percent    = 0,
	contorlrate_percent    = 0,
	contorldefrate_percent = 0,
	movespd_percent        = 0,
	limitdmg_percent       = 0,
	gs                     = 0,

	dmg_tohuman       = 0,
	dmg_togod         = 0,
	dmg_todevil       = 0,
	hp_stolen         = 0,
	hp_stolen_percent = 0,
	accurate          = 0,
	dmg_pve           = 0,
	dmgdown_pve       = 0,
	dmg_pvp           = 0,
	dmgdown_pvp       = 0,
	recovery          = 0,
	stun_defeat       = 0
}).

-define (PROPERTY_FIELDS, record_info(fields, battle_property)).

-record(scene_spirit_ex,{
	id,
	sort=0,
	name="no",
	pos={0,0,0},
	dir=180,
	camp=1,
	speed=100,
	hp=0,
	mp=0,
	die=false,
	stifle=0,
	buffs=[],
	cds=[],
	move_data=0,
	demage_data=0,
	skill_data=0,
	skill_aleret_data=0,
	base_property = #battle_property{},		%% 人物在场景中的基础属性(由玩家进程传入的玩家最终属性)
	final_property = #battle_property{}, 	%% 最终属性(buff加的属性以base_property为基础来计算，buff移除时属性再从这里减去)
	buff_property = [], 					%% buff加的属性:[{BuffId, [{属性id, 属性值}]}]
	data = {}, 
	delete_state =0,
	passive_skill_data = [],
	map_cell = no,
	off_line=false
}).


-record(scene_item_ex,{type=0
					   ,length,high=0,width=0
					   ,create_time=0,all_time=0
					   ,action=no
					   ,del=false
					   ,ontime_check=0
					   ,trigger_list=[]
					   ,send_client=true}).

-record(scene_monster_ex, {
	type=0,
	lev=0,
	sex = 0,
	race = 0,
	profession = 0,
	max_hp=0,
	ai_module=0,
	ai_data=0,
	ai_time =0,
	ontime_start=0,
	ontime_check=0,
	ontime_off=0,
	script=0,
	allow_control=true,
	partrol_point={0,0,0},
	still_partrol_point=[],
	con_scene_item=0,
	reflush_pos_id=0,
	owner = 0,
	last_killer = 0,
	first_killer=0,
	demage_list=[],
	send_client=true,
	master=0,
	scale = 1 %% 怪物大小缩放比例，1表示没有缩放
}).

-record(scene_robot_ex,{
	prof=0,
	lev=0,
	paragon_level=0,
	guild_name="",
	pk_lev=0,
	military_lev=0,
	model_clothes_id=0,
	battle_entourage=[],
	skill_list=[],
	equip_list=[],
	fighting=0,
	ai_module=0,
	ai_data=0,
	ai_time=0,
	shenqi_skill={0,0},
	buff_skill=[], %%开战后会直接使用
	near_skill=[], %%距敌人距离小于等于3的时候使用
	normal_skill=[], %%距离敌人距离小于等于5的时候使用
	far_skill=[], %%距离敌人距离小于等于8的时候使用
	gener_skill=[]
}).

-record(scene_usr_ex,{
	hid,
	sid,
	prof=0,
	lev=0,
	guild_name="",
	mount=0,
	mount_level=0,
	hate_per=0,
	interrupt_effects=[],
	mp=0,max_mp=0,
	pk_lev=0,
	titlie=0,
	usr_equ=0,
	used_skill=[],
	box=0,
	target=0,
	allow_control=true,
	vip=0,
	usr_state=0,
	military_lev=0,
	denation=0,
	battle_entourage =[],
	pet_list=[],
	skill_list=[],
	task_list=[],
	equip_list=[],
	drop_drums_time=0,
	fighting=0,
	team_id,
	team_leader,
	copy_out={0,{0,0,0}},
	backpack_is_full=false,
	team_info=[],
	curr_members={0,[]},
	revive_times={0,0},
	copy_times=[],
	ride=0,
	paragon_level=0,
	model_clothes=0,
	demage_list=[],
	penta_kill=0, %%5杀认证
	penta_kill_time=0,
	monster_list=[],
	fatigue=0,
	camp_leader=0, %%变更意义为阵营官职,0为平民,1为首领,2为副官,
	check_pt_time,
	check_pt_no,
	check_pt_list,
	title_id=0,
	royal_box_full=false,
	last_pt=0,
	inscription_effects=[],
	guild_id=0,
	boos_die_list=[],
	barrier_id = 0, %% 当前关卡
	worldboss_inspire = 0,
	relife = 0  %% 转身等级
}).

-record(scene_entourage_ex,{
	type = 0,
	lev = 0,
	star = 0,
	sex = 0,
	race = 0,
	profession = 0,
	awake_lv = 0,
	skills = [],
	general_skill=[],
	owner_id=0,
	target=0,
	is_robot=false,
	ai_module=0,
	ai_data=0,
	ai_time=0,
	last_pt=0
}).

-record(scene_model_ex,{model_sort=0,prof=0,equip_list=[],source_uid=0,model_clothes=0}).

-record(skill_aleret_data,{start_time = 0,all_time = 0,point = 0,skill_data = 0}).
-record(move_data,{start_time = 0,all_time = 0,to_pos = 0,move_speed = 0,next = 0}).
-record(skill_data,{start_time = 0,yz_start = 0, yz_time = 0,bt_start = 0, bt_time = 0,wd_start = 0 ,wd_time = 0 ,move_sort = 0,move_speed = 0,move_data = 0}).
-record(demage_data,{start_time = 0, jz_time = 0,move_start = 0,move_sort = 0,move_speed = 0,move_data = 0}).

-record(scene_cd,{type=0,start=0,lenth=0}).
-record(scene_buff,{type=0,sort=0,power=0,mix_lev=0,start=0,lenth=0,effect_time=0,buff_adder=0,from_skill={0,0,0}}).
-record(ai_data, {id=0,type=0,scene=0,x=0,y=0,z=0,status=0,target=0,move_dir=no,move_time=0,
					still_partrol_points=[],create_time=0}).
-record(robot_ai_data, {id=0,scene=0,x=0,y=0,z=0,status=0,target=0,move_dir=no,move_time=0,create_time=0,cast_skill_time=0,used_gener_skill=[]}).
-record(relation_record,{uid=0,sort=0,relation_uid=0,relation_name="",time=0,name=""}).
-record(apply_for_guild, {id=0,uid=0, guild_id=0,level=0,name="",prof=0,times=0}).
-record(system_msg,{uid=0, arena_top_ten=0,arena_top_three=0,arena_top_two=0,arena_top_one=0}).
-record(war_usr_data,{uid=0,score = 0,kills=0,continuekill=0,kadd=0,speed=0,km=0,ku=0,kc=0}).
-record(war_camp_data,{camp=0,score = 0,cpl=0,prev=0,km=0,ku=0,kc=0}).
-record(notice_data,{id=0,startTime=0,endTime=0,frequency=0,text=""}).
-record(war_battlers,{uid=0,info=0,scene=0,owner=0}).
-record(speediness_team,{uid=0,time=0,teamName ="",lev=0,gs=0,population=0}).
-record(guild_team,{uid=0,guild_id =0,lev=0,gs=0,post=0,state=0,name="",prof=0}).
-record(guild_copy_team,{uid=0,guild_id=0,scene_id=0,min_gs=0,min_lev=0,min_post=0,state=0,call_upon_state=0}).

% -record(entourage, {id=0,type=0,lev=0,exp=0,star=0,equip_list=[]}).

%% 创建场景时，传递的玩家参数
-record (ply_scene_data, {
	sid,
	agent_pid 	%% 玩家进程pid，在跨服场景传送中会用到
}).


-record (api_item_args, {
	way             = 0, 		%% 物品日志
	spend           = [],		%% 消耗
	add             = [],		%% 增加
	succ_fun        = undefined,%% 成功回调
	fail_fun        = undefined,%% 失败回调
	send_error_tips = true		%% 是否发送错误提示
}).

