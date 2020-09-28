-record(st_scene_config,{id,sort,name,max_agent,full_create,res,life_time,points=[],clipWidth=0,script_scene=0,coordinate=[],mcoordinate=[],end_delay=0}).
-record(st_error_info,{id = 0, name = ""}).
-record(st_fly_point_config,{id,scene,x,y,z,sort,targetScene,targetX,targetY,targetZ,target_pos,needLv,dir,camp}).

-record(st_monster_config,{id=0,name="",level=0,rank_level=0,ai=normal,feel=0,normal_skill=0,skill=[],monster_r=0,corpse_remain_time=0,passive_skill=[],baseMoveSpd=0,bornTime=0,star=0,sex=0,race=0,profession=0}).
-record(st_monster_battle,{atk = 0, hplimit = 0, mplimit = 0, realdmg = 0, dmgdown = 0, defignore = 0, def = 0, cri = 0, cridown = 0, hit = 0, dod = 0, cridmg = 0, toughness = 0, blockrate = 0, breakdef = 0, breakdefrate = 0, blockdmgrate = 0, dmgrate = 0, dmgdownrate = 0, contorlrate = 0, contorldefrate = 0, movespd = 0, limitdmg = 0}).

-record(st_arrow_config,{id=1,speed= 20,add_speed= 20,impactArea= "POINT",areaPara= [0,0,0,0,0,0,0],targetnum = 1,max_effect= 1,one_max_effect= 1,per_time= 0,max_dis= 100,min_dis= 1,arrowWidth= 1,arrowUpHigh= 2,arrowDownHigh= 2}).
-record(st_buff_config,{id=1,sort= "CONTROL",maxmix= 1,bdemage= 2,data1= "0",data2= 0,per_time= 0,act_remove= 0,delayTime=2000,default_time = 1000,default_value= 0,impactArea= "POINT",areaPara= [0,0,0,0,0,0,0],targetNum= 1,riderEnable= "YES",controlSort= "",buffLevel= 9,sceneRetain= 1,dieRetain= 0,dispel= 0,timeRetain= 0,timesgo= 1,targetType ="ENEMY",skilleffectEnable=1,transmitEnable= 0,script="normal"}).
-record(st_skillmain_config,{skillId=0,skillMode="",ai_skill_cast_condition={0},ai_skill_cast_param=[]}).
-record(st_skillperformance_config,{skillId=0,castRange=0,targetType="",skillGroup="",skillType="",castType="",castPoint="",targetnumType="",targetnum=0,impactArea="",areaPara=[],areaCenterRange=0,selfShiftType="",selfShiftRange=0,targetShiftRange=0,aoeEffect=0,arrowEffect=0,time_yz_start=0,time_yz=0,time_bt_start=0,time_bt=0,time_wd_start=0,time_wd=0,kick_type="",kickdistance=0,shiftDirection=0,kickSpeed=0,kickStartTime=0,kickTimes=0,delayTimes=0,aleretTimes=0,buffReleaseType="",skill_ai = {0,0}}).
-record(st_trap_config,{id=1,trap_all_time= 6000,trap_effect_time= 500,impactArea= "CYCLE",areaPara= [4,0,0,0,0,2,2],targetnum = 10,max_effect= 10,one_max_effect= 10,per_time= 500}).
-record(st_skillleveldata_config,{skillId=0,power1=1,power1_add=0,power2=0,power2_add=0,long_suffering=0,threaten=0,targetBuff=[],selfBuff=[],mp=0,cd=1,dmgScript="normal"}).
-record(st_relation_config,{sceneType= 1,relation= 0}).
-record(st_distribution_config,{id=1,sceneId= 2,areaCoordinate= {29,0,50},areaRadii= 50,monsterId= 1,monsterNum= 7,refreshType= "cycle",refreshCycle= 6,refreshTime= ["0"],refreshRange= "allLine",refreshAlertType= "no",alertText= "0",alertMode= 0,dir=0}).
-record(st_item_type,{id=0,sort=0,max=1,name="",req_lev=1,prop=[],spe_prop=[],bind=1,business=0,color=0,price=0,action=0,action_arg=0,action_arg1=0,default_star=0}).
-record(st_ride_info,{type=0,lev=0,next_type=0,explain=0,food=0,exp_add=0,double=0,four=0,speed_buff=0,props=[],gs=0}).
-record(st_ride_growth,{growth_type=1,val1=0,val2=0,crit_rate=0,growth_item=""}).
-record(st_ride_starLev,{id=1,quality=1,starLev=0,att_max=0,def_max=0,hp_max=0,starlev_item_val=0}).
-record(st_ride_equ_info,{type=0,pos=0,quality=0,next_type=0,item=0,num=0,props=[],gs=0}).
-record(st_ride_skin_info,{type=0,props=[],gs=0,hechengID=0,hechengNUM=0}).
-record(st_trials_type,{id=0,times=0,lev=0}).
-record(st_trials_copy,{copy=1,type= 3,diffc=1,lev=10}).
-record(st_dress_suit,{id=0,prof=0,dressid=0,mountid=0,petid=0,prop=[],gs=0}).

-record(st_relife,{id=1,num=0,sort=3,name="",lev=0,show=0,property=[],skill=[],hero_num=0,gs = 0,add_lev=0,boss_scene=0, rewards=[]}).
 
-record(st_box_config,{boxid=0,next=0,droplistid=0,droprate=0,group=0,droptimes=0}).

-record(st_droplist_config,{next=0,dropcontentid=0,droprate=0,group=0,droptimes=0,droptype=0,calculationtype=0}).
-record(st_rewardrestriction_config,{itemid=5,restrictioncycle= "HOUR",restrictionnum= 10}).
-record(st_entourage_config,{name="",sex=0,race=0,profession=0,basePropList=[],baseMoveSpd=0,deatlagtime=0,attackRange=0,quility=0,max_grade=0,max_star=0}).
-record(st_lost_item_config,{id=1,skill= 1,needItemId= 1,needItemNum= 100,gs= 100,maxLevel= 50,propGroup= [{1,10,5},{2,10,5},{3,10,5},{4,10,5}],actPropup= {115,12,12},actprogs= 30}).
-record(st_scene_item_config,{id=1,touchType= "TOUCH",modelXY= {2,2,2},openTime= 3000,deadTimes= 1000,scripTime= 1000,touchDistance= 3,actionTarget= "player",collideList= [{2,2,0,0}]}).
-record(st_scene_item_dis_config,{id=1,sceneId= 101011,disCoordinate= {29,0,50},sceneItemId= 1,refreshType= "CYCLE",refreshCycle= 6,refreshTime= [900,1200],refreshRange= "ALLLINE",refreshAlertType= "WORLD",alertMode= "DIALOG",alertText= "",actionResult= "REMAIN",connectItemId= 10202,connectType= "OPERATE",connectCameraType= "FOCUS",aiType= "ATTENTION",direction= 180,script= "scene_open_item_0001",scriptTime= 1000,hp= 5,dmgBehit= 1,jumpTime= 1000,conMonsterId= 0,actionType="BLOCK",rewards= 0}).
-record(st_lost_item_num_config,{lv=21,item_num= 105}).
-record(st_entourage_update,{level=0,exp=0}).
-record(st_debris_config,{num= 10,synthesisType= 6}).
-record(st_lev_exp,{need_exp=0}).
-record(st_task,{id=1,step= 3,is_start= 0,prof= 0,taskCamp=0,need_task= 0,need_step= 2,need_lev= 0,auto_accept= 0,task_recommend_friend= 0,targetMonster= [],targetBoxId= 0,npc1= 500001,npc2= 500001,task_sort= 1,condition= [{7001,101011,021050}],reward = [{1,50},{3,25},{4,0},{13,1}],buffid=0,task_scene= 101011,task_pos= {0,0,0}}).
-record(sort_pos,{pos= 0}).
-record(improve_set,{item_improve_lev=0,multy= 0,add_attr= 00,need_item_id= 0,need_item_num= 0,breakItemNum= 1,breakItemId= 0,breakCoin = 0, diamond_improve = 0, diamond_break = 0}).
-record(get_mastery,{id=1,propList= [{0},{0},{0}],openPlyLvl= 1}).
-record(st_mastery_exp,{id=1,lev= 1,item_id= 1,item_num= 1000,needPlayerLevel= 30,gs= 100}).
-record(equipstar_set,{starNum=1,propRate= 0.5,weaponNeedItem= 11,otherNeedItem= 13,needItemNum= 1,needCoin= 1000}).
-record(equ_config,{id=1,ply_lev= 1,att_type= 1,quality= 1,att_val= 2,att_multy= 1821,gs_num= 20,propJob= [3,6,9]}).
-record(pet_set,{id=1,petItemId= 20001,buff1= 0,buff2= 0,hechengID=0,hechengNUM=0}).
-record(passive_skill,{has_buff=[0], selfHpRate=10000, targetHpRate=10000, trigger_type=1011, skill = [], add_self_buff = [], add_all_friend_buff = [], add_other_buff = [], add_all_enemy_buff = [], cd=5000}).
-record(st_gem_config,{gem_Id = 0,gem_Position = 0,gem_order = 0,open_Item= 0,itemNum= 0,upgradeQuantity = [],highUpgrade = [], upgradeLimit = 0, property_type = 0, property_value = 0, gs = 0, lev = 0}).
-record(st_data_signs_reward,{id=1,signRequire=1,signRewardItem=1,signRewardItemNum=0}).
-record(st_data_signs,{id=1,sign_item_type=1,sign_item_num=1,vip_lev=0,times_num=0}).
-record(st_data_actReward,{id=1,requireAct=1,actRewardItem=2000,actRewardItemNum=1}).
-record(st_data_acttivity_num,{id=1,actRewards=1,actTimes=2,actText="000"}).
-record(st_dungeons_config,{id = 0, dungenScene = 0, monsterId = [], bossId = [], nextStage = 0, client_refresh_boss = 0, lvRestriction=0, forceLimitation=0, common_reward=[], time_reward=[], time_box=0}).
-record(st_dungeonsGroup_config,{id=1,normalLevel= 1,hardLevel= 2,heroLevel= 3,freeTimes= 1,openPlayerLevel= 1}).
-record(st_data_guild_copy,{id=1,boss_id=0,copy_id=1,copy_name="",scene_id=1,open_time={0,0,0},open_condition=0,first_struck=[],ranking=[],normal_reward=[]}).
-record(st_data_guild_authority,{id=1,invitation=1,development=1,kickOut=1,approval=1,dissolution=1,open_raid=1,quit=1,promote_president=1,promote_vice_president=1,promote_elders=1,demote_member=1,demote_elders=1}).
-record(st_data_guild_building_level,{id=1,openLevel=1}).
-record(st_data_guild_donation,{id=1,donationItem=1,donationVal=10000,guildResNum=400,number=5}).
-record(st_data_guild_level,{level=1,experience=0,maxPlayers=0,needexp=0}).
-record(st_data_guild_update_add_prop,{technologyId=1,level=1,propid=1,propVal=5,needexp=100}).
-record(titles_set,{id=1,propertyValue= [],permanentPropValue=[],activeGs=30,permanentGs=20,titleRank=1,titleName=""}).
-record(st_title_config,{id=1,titleName="",titleDes="",titleCondition=[],goodsId=0,titleTime=0,
       exp=0,att=[],gs=0}).
-record(st_title_lev,{level=1,exp=0,att=[],gs=0}).
-record(sys_val,{c1=0.1,c2=0.05,time=60*60*24,t2=3600,mail_t=3600*24*15,mail_title="系统邮件",mail_cotent="系统邮件内容",mail_gm_name="系统管理",mail_sound= <<>>,mail_coin=500,
					  mail_buss_title="交易邮件",mail_buss_content="交易完成",cant_words=""}).
-record(mail_content,{id=1,mailName= "竞技场奖",text= "恭喜您本周竞技场排名为#1#，获得竞技场奖励礼"}).
-record(st_dailyReward_config,{day=10,dropContentId= 1}).
-record(st_levelReward_config,{level=10,dropContentId= 1}).
-record(st_storyReward_config,{id=1,rewardItem3= 2005,rewardItem6= 2010,rewardItem9= 2000,needTaskNum= 5,itemNum= 1,isEnd= 0}).
-record(st_archeology_enemy,{id=1,enemyGroup =[1]}).
-record(st_archaeology,{id=1,lev= 1,sceneid= 101011,pos= {20,0,10},rewardBoxId= 1,enemyGroup= [1],enemyRate= 5}).
-record(st_diamon_exp,{lv = 1,needExp= 5,propGrow= 1}).
-record(military_config,{id=1,name= "平民",camp= 2,level= 1,exp= 100,rewardId= 0,prop= [],bekilledRep= 5,gs= 0,skillLevel= 0,skill1= 9014,skill2= 9015,skill3= 9016,item= 5977,itemNum= 3,glod= 1000}).
-record(st_cdkey_box,{id=102,loop = 1,rewards = [{5113,1}],maskpos=1}).
-record(st_onlineReward_config,{id=1,time= 180,boxId= 20002000}).
-record(st_boss_config,{id=1,topRewardId= 20004000,topTenRewardId= 20004100,winnerRewardId= 20004200,distributionId= 8,bossType= "TOGETHER",bossId= 10199,bossnum= 3}).
-record(st_robot,{id=0,name="",level=0,headid=0,entourageList=[],artifact={0,0}}).
-record(st_arenaReward_config,{id=1,rankLevelTarget= 1,rankLevelBegin= 2,rankDiamonReward= 900,rankDailyReward= 23000000,rankWeekReward= 23000023}).
-record(st_achievement,{id=1,type=1,targetType=1,preAchieve=0,targetNum=100,rewardItem=5,rewardNum=10,achievePoint=10,nextAchieve=2}).
-record(st_achieveType,{id=1,totalNum=27}).
-record(st_achieveLevel,{level=1,achievePoint=100,achieveProp=[{101,100},{102,100},{104,1000}],achieveGs=0}).
-record(st_Suit_type,{id=1,suitItem= [2020,2021,2022,2023,2024,4014],suitProp= [{2,101,100},{4,102,100},{6,0,1}]}).
-record(st_peakLev_exp,{max_exp = 10000000,newPeakPoint= 5,propPointLimit= 2}).
-record(st_model_clothes,{id=0,dressitem=0,active_num=0,attribute=[],power=0}).
-record(st_charge_config,{sort = 0, charge_money = 0,diamond = 0, reward = [], first_prize_num = 0, second_prize_num = 0, vip_exp = 0, membership_reward = []}).
-record(st_chargeLevelReward_config,{chargeLevel=1,dropContentId= 20000001,nextId= 2,preId= 0}).
-record(st_chargeLoginReward_config,{chargeLogin=1,dropContentId= 20000001,nextId= 2,preId= 0}).
-record(st_data_bigmap,{id=1,teleportCastType=1,teleportCast=100,unlockValue=0,targetScene=201000,camp1Point=[140,0,80],camp2Point=[140,0,80],camp3Point=[140,0,80],camp4Point=[140,0,80],unlockType="ENTER"}).
-record(st_vip_config,{vip_exp=0,vip_reward=[],daily_reward=[],hero_bags=0}).
-record(st_filiation,{id=1,entourageId=1,targetEntourageId=2,maxLevel=5}).
-record(st_filiationLevel,{filiationId=1,level=1,propType=101,propVal=100,requireTargetLevel=10,requireTargetStarNum=1,upgradeItemType=2,itemNum=100,gs=100}).
-record(st_soulLink,{id=1,unlockCondition=1,unlockNum=20,page=1,orderopen=0}).
-record(st_uselimit_group,{id=1,limitTimes= 5}).
-record(st_data_truck,{id=1,monsterId=100301,activitieid=1,camp=2,number=20000,taskid=11,assistsreward=10000005,killreward=10000005,sceneId=101011,startingPoint=[20,20,30],endPoint=[20,20,30],roadPoint=[20,20,30],depositItemId=1,bubbleID=[50023,50005]}).
-record(st_data_dartactivities,{id=1,opentime=[0,30],endtime=[23,59],camp=2,uesTruckId=[1,2,3],killtruckId=[1,2,3],times=3,twoopentime=[18,00],twoendtime=[17,00]}).
-record(st_starProperty,{starNum = 50,prop= [{101,200},{106,40},{108,40}],gs= 600}).
-record(st_gsReward_config,{id=1,gs=10000,boxId= 20000008}).
-record(st_open_system,{id=1,openTask=0,task_state=0,openLvl=0}).
-record(st_retrieve_system,{id=1,type=1,openlevel=15,opentask=0,step=0,areward=20000001,anumber=1,aspend=200,sreward=20000001,snumber=1,sspend=200}).
-record(st_buyGold_config,{id=1,diamondCost= 10,minutes= 0}).
-record(st_handing,{id=1,times=3,taskid=7001,taskstep=1,scene_item=98000301,buff1=7001,probability1=25,quality1=1,buff2=7002,probability2=25,quality2=2,buff3=7003,probability3=25,quality3=3,buff4=7004,probability4=25,quality4=4,itemid1=2,num1=100,itemid2=3,num2=100}).
-record(st_rechargeDaysReward_config,{id=1,rechargeDays= 0,boxId= 20000008,preid=1}).
-record(st_boos_dekaron,{id=1,needitem=801,monsterlist=[{80101,50},{80102,60},{80103,70},{80104,80},{80105,90}]}).
-record(st_story_copy,{id=6,normal_dungeon=20008,hard_dungeon=21008,consume=12002,normalamount=1,hardamount=2,opentask=1,opentaskstep=128,openlevel=90}).
-record(st_talkring_task,{id=3,task_id=8003,needlevel=40}).
-record(st_war_config,{id=1,name= "",type= 1,num= 8,times= 3,openType= 1,openDate= 0,starttime= {18,00},endtime= {20,00},cycletime= 0,continuetime= 0,scene= 104001,born2= {121,0,186},born3= {133,0,31},randomBorn= [{0}],win= 24000554,lose= 24000559,base= {0},kill= {0},match= 5,needlev= 0}).
-record(st_equipImpReward_config,{id=1,attachAchievement= 178,boxId= 23000000,preId= 0}).
-record(st_heroStarReward_config,{id=1,attachAchievement= 178,boxId= 23000000}).
-record(st_luckyWheelReward_config,{id=1,wheelType= 1,item= 5002,itemNum= 1,condition= 0,rate= 1300,alertType= 0}).
-record(st_war_employment,{id=0,monsterid=0,sort=0,sceneid=0,bornpos={0,0,0},topos=[],employitem_neednum=0,num=0}).
-record(st_royal_box,{id=1,needtime=1,rewardID=23000000,itemType=80910}).
-record(st_weekly,{id=1,amount=70,boxid=24000018}).
-record(st_matching,{id=1,power=2,num=3,sameteammatches=1,outteammatches=1}).
-record(st_welfare_config,{id=1,sort=1,data=50001}).
-record(st_turnCardReward_config,{id=1,diamondCast= 88,needVipLev= 0,lowReward= 237,highReward= 288}).
-record(st_pet_prop,{id=0,petid=0,prop1=0,value1=0,maxvalue1=0,probability1=0,prop2=0,value2=0,maxvalue2=0,probability2=0,prop3=0,value3=0,maxvalue3=0,probability3=0,prop4=0,value4=0,maxvalue4=0,probability4=0,gs1=100,gs2=100,gs3=100,gs4=100}).
-record(st_pet_grow,{id=0,itemid=0,grow=0}).
-record(st_warhelp_config,{id=1,type= 1,monsterId= 100544,point= {99,0,181}}).
-record(st_event_confg,{id=1,opentime=[16,15],endtime=[16,45],victory=23000113,fail=23000112}).
-record(st_relic_level_skill_config,{id=1,relicId= 1,level= 1,skillId= 10011}).
-record(st_carnival_gs_config,{id=1,reward= 24000615}).
-record(st_carnival_hero_config,{id=1,reward= 24000615}).
-record(st_carnival_level_config,{id=1,reward= 24000615}).
-record(st_carnival_warfare_config,{id=1,reward= 24000615}).
-record(st_day_target,{id=1,days=1,typeId=1001,val1=0,val2=10,autoRefresh=0,reward=[]}).
-record(st_day_reward,{id=1,rewardId=20000001,val=2}).
-record(st_exped_task_config,{id=1,min_lev= 0,max_lev= 50,task_star= 1,item_list= [{6,76000},{70007,1}],bonus= 0,time= 3600,heroid= 0,need_num= 1,hero_rate= 0.7,star_rate= 0.3,lev_rate= 00,rate= 0255,rentreward= 24100900}).
-record(st_lightBathConfig,{id=1,item=70007,times=20,loadingTimes=3,exp=25000,effectBuff=8000}).
-record(st_furn_config,{id=1,equipment=1,furn=1,req_prof=3,quality=5,req_lv=70,unlock=3030,unlockNum=5,un_price=100000,furnace=104,baseatt=1500,baseGs=150}).
-record(st_furn_lev_config,{furn=1,level=1,multiple=1,needItemNum=2,needCoin=78000}).
-record(st_inscription_config,{id=1,skilid=110001,unlock=5025,unlockNum=10,un_level=20,un_price=100000,buff_type=0,baseatt=10,grow=1,skillMainId=3,sort="PowerOne"}).
-record(st_inscription_grow,{grow=1,level=1,multiple=1,needItemNum=10,needCoin=10000}).
-record(st_inscription_class,{id=3,in_unlock= 10,shortenCD= 5 }).
-record(st_guild_copy_info,{id=1,days=7,number=10,leaderBossId=[1,2,3,4,5],theLastBoss=6,allReward=[{1,20001},{2,2002},{3,2003}],copyscene=112005}).
-record(st_guild_ranking_rewards,{id=1,ranking=1,reward=2000001}).
-record(st_guild_red_envelope,{id=1,giveNumVal=10,sendReward=20000001,spendItem=3,spend=1000}).
-record(st_climb_tower,{id=1,lev= 1,scene= 101015,first_reward= 20000001,reward= 20000002,gs= 10000}).
-record(st_resolve_type,{itemId= 2185,targetItemId= 3030,targetItemNum= 5}).
-record(st_abyssbox,{id=1,scene=101023,sceneitemdis=[{98000001,50},{98000002,50}],cycle=3600}).
-record(st_hero_mastery,{id=4,property=104}).
-record(st_mastery_grow,{id=1,lev=1,propup=1,medi=[{21,1}],reset=[{5,5}],gs=1}).
-record(st_mastery_level,{level =1,consumable1=[7001,1],consumable2 =[7002,1],gold=5000}).
-record(st_npc_scene,{npc_id=500101,scene=101011,scene_x=161,scene_y=88}).
-record(st_draw_astrict_config,{id=1,sort=2,type=1,times1=20,times2=2}).
-record(st_abyss_config,{sceneid=103001}).
-record(st_relic_recovered,{id=1,relicid= 1,openlv= 30,remaxlv= 100,itemid= 7001}).
-record(st_relic_recovered_lv,{level=1,itemnum= 1,recoverid= 5967,recovernum= 1,proup= 1,price= 10000}).
-record(st_glory_sword,{level=0,val= [{101,0},{102,0},{104,0}],item= 5972,itemnum= 0,price= 0,gs= 0}).
-record(st_dungen_reward,{id=1,time= 3,item_id= 1,item_num= 10000}).
-record(st_military_skill,{skiilid=7014,level=1,nextskill=7014,nextlv=2,item=5977,itemNum=3,glod=1000,ranklv=1,gs=100}).
-record(pet_skill_rate,{id=1,rate= 10000}).
-record(st_buy_time_price,{id=1,sort=0,cost=[],count=0}).
-record(st_equipMake_list,{lv=1,dropId=70000000}).
-record(st_outLineReward,{id=1,time=3600,item_box=90000000}).
-record(st_guildBossAward,{id=1,awardId=21,awardValue=210}).
-record(st_cumulativedamage_config,{iD=1,hurt=0,reward=[]}).
-record(st_eliminate_config,{iD=1,bossID=0,reward=[]}).
-record(st_inspire_config,{iD=2,currency_type=2,currency_num=40,add_value=10}).
-record(st_stroy,{finish_step = 30,reawrd = [{1,500}, {2,500}, {3,500}]}).
-record(st_building, {id = 100001, type = 1, lev = 1, need_scene = 1, need_lev = 1, need_hall_lev = 1, need_coin = 0, need_items = {12,0}, time = 0}).
-record(st_building_hall, {id = 1, base_reward = [], add_reward = [], max_num = 0, work_time = 0, cd = 0}).
-record(st_building_goldfield, {id = 1, product_type = 1, house_num = 1, storage_num = 0, pre_hour_num = 0, one_helper = 0, two_helper = 0, three_helper = 0, work_time = 0}).
-record(st_building_farm, {id = 1, product_type = 1, house_num = 1, storage_num = 0, pre_hour_num = 0, one_helper = 0, two_helper = 0, three_helper = 0, work_time = 0}).
-record(st_dungeon_dificulty, {levPower = 1, atkPower = 1, hpPower = 1, mpPower = 1, realdmgPower = 1, dmgdownPower = 1, defignorePower = 1, defPower = 1, criPower = 1, cridownPower = 1, hitPower = 1, dodPower = 1, cridmgPower = 1, toughnessPower = 1, blockratePower = 1, breakdefPower = 1, breakdefratePower = 1, blockdmgratePower = 1, dmgratePower = 1, dmgdownratePower = 1, contorlratePower = 1, contorldefratePower = 1, movespdPower = 1, limitdmgPower = 1}).
-record(st_worldboss,{need_lv = 0, limit_lv = 0, boss_id = 0, scene = 0, refresh_time = 0, rewards = [], hpUpTime = 0, hpDownTime = 0, hpDayReduce = 0}).

-record(st_building_school, {id = 0, attributes = [], max_lev = 0}).
-record(st_building_school_skill, {id = 0, type = 0, num = 0, need_coin = 0, need_items = [], gs = 0}).

-record(st_random_task, {id = 0, step = 0, condition = {0,0}, type1 = 0, need1 = {1,1}, type2 = 0, need2 = {1,1}, reward1 = [], reward2 = []}).
-record(st_activity, {id = 0, time = []}).
-record(st_limitboss_reward, {id = 0, ranking = {0,0}, reward = [], base_reward = []}).
-record(st_grow_fund, {id = 0, step = 0, need = {0,0}, reward = [], cost = []}).
-record(st_revive, {id = 0, time = 0, cost = []}).

-record(st_player_icon,{id = 0, type = "DEFAULT", occupation = 0, typenum = 0, suit_id = 0, get_item = []}).
-record(st_head_lev,{id = 0, cost = [], prop = [], gs = 0}).
-record(st_head_suit,{id = 0, need_lev = 0, prop = [], gs = 0}).
-record(st_arenaseasonReward_config,{id=0,rankLevel1=0,rankLevel2=0,reward=[]}).
-record(st_arena_season,{id=0,rankLevel1=0,rankLevel2=0,reward=[]}).
-record(st_data_guild_blessing,{id=0,cost=[],reward=[],add_exp=0}).

-record(st_global_arena,{rank = 0, need_honor = 0, win_honor = 0, defeat_honor = 0}).
-record(st_global_arena_daily,{condition = 0, reward = [], count = 0}).
-record(st_global_arena_rank_reward,{rank = 0, condition = 0, reward = []}).
-record(st_global_arena_worship,{time = 0, reward = []}).

-record(st_data_ship,{id=0,cost=[],sailing_time=0,reward=[],points=0,reward_plunder1=0,reward_plunder2=0,extra_plunder=0,final_reward=[]}).

-record(st_maze,{id=0,type=0,prob=0,need=0}).
-record(st_maze_event,{id=0,type=0,prob=0,need=0,monster=[],cost=[],reward=[],box=0}).

-record(st_inspire,{id=0,cost=[],buff={0,0},type=0}).

-record(st_melleboss,{boss_id = 0, need_relife = 0, scene = 0, refresh_time = 0, re_scene_time = 0, difficulty2 = [], difficulty3 = [], reward_box = {}}).

-record(st_random_package,{id = 0, dioamnd = 0, scene_lev = 0, vip = 0, time = 0, reward = []}).

-record(st_item_exchange,{id = 0, item = [], cost = []}).
-record(st_arena_store,{id = 0, item = [], cost = [], daily_limit = 0, need_rank = 0}).
-record(st_arena_task,{type = 0, count = 0, reward = []}).

-record(st_entourage_challenge,{chapter = 0, level = 0, difficulty = 0, pre_condition = [], is_end = 0, scene = 0}).

-record(st_legendary_level,{need_lev = 0, need_exp = 0, need_gs = 0, need_legendary_point = 0, need_legendary_equipment = {0,0}}).
-record(st_legendary_exp_info,{need_item = [], add_exp = 0, max_times = 0}).

-record(st_god_costume,{suit = 0, limit = 0, pos_type = 0}).
-record(st_god_costume_upgrade,{lev = 0, nece_cost = [], non_cost = []}).

-record(st_parallel_config,{id=1,scene=100101,parallel=190101,inpoint=[0,0,0],outpoint=[0,0,0],type="SINGLE",performance="NONE"}).
-record(st_entourage_skill,{id=0, skill = [], passive_skill = [], prop = []}).

-record(st_item_suit,{id=0,suit_list=[]}).
-record(st_shenqi,{type=0,max_star=0,god_power, attr1, attr2, attr3, attr4}).

-record(st_draw_config,{one_cost = [], ten_cost = [], first = 0, one_box = 0, ten_box = 0, one_energy = 0, ten_energy = 0, cd = 0}).

-record(st_store_config,{cells = [], refresh = 0, refresh_cost = [], refresh_time = 0}).
-record(st_cell_config,{item_id = 0, cost = [], item_num = 0, limit = 0, need = "NO", need_lev = 0}).

-record(st_activity_copy,{type = 0, need_lv = 0, monster, monsterReward, ensureReward, monsterAdd, scene}).



