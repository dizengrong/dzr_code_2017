%% @doc 坐骑系统
-module(fun_ride).
-include("common.hrl").
-export([init_ride/1, get_ride_info/1, feed_ride/4, send_ride_info_to_client/3]).
-export([get_curr_own_skins/1, add_ride_skin/3, ride_change_skin/4, check_ride_skin/2]).
-export([on_off_ride/4, get_fighting/1, get_ride_skin_gs/1, save_ride_status/2,get_ride_skinstar_gs/1]).
-export([get_pro/1, get_ride_skin_star_prop/1,init_ride_skin_prop/1, ride_equ_up/4, req_active_ride/4,ride_awake/4,ride_foodstar/6,get_ride_skin_num/1]).
-export([check_and_add_default_skin/1]).

%%  初始坐骑
-define(INIT_RIDE,1).
%% 马鞍，马蹄，头盔，护甲，缰绳，脚踏
-define(INIT_MAAN,1).
-define(INIT_MATI,2).
-define(INIT_TOUKUI,3).
-define(INIT_HUJIA,4).
-define(INIT_JIANGSHENG,5).
-define(INIT_JIAOTA,6).

-define (DEFAULT_SKIN, 0).

init_ride(Uid) ->
	Rec = #t_usr_rides{
		uid        = Uid,
		type       = ?INIT_RIDE,
		exp        = 0,
		ride_state = 0,
		currskin   = 0,
		skins      = util:term_to_string([?DEFAULT_SKIN]), 
		eq1        = ?INIT_MAAN,
		eq2        = ?INIT_MATI,
		eq3        = ?INIT_TOUKUI,
		eq4        = ?INIT_HUJIA,
		eq5        = ?INIT_JIANGSHENG,
		eq6        = ?INIT_JIAOTA
	},
	db:insert(Rec).

get_ride_info(Uid) ->
	[Ride|_] = db:dirty_get(t_usr_rides, Uid, #t_usr_rides.uid),
	Ride#t_usr_rides{skins = util:string_to_term(util:to_list(Ride#t_usr_rides.skins))}.

set_ride_info(NewRide) ->
	NewRide2 = NewRide#t_usr_rides{skins = util:term_to_string(NewRide#t_usr_rides.skins)},
	db:dirty_put(NewRide2).


check_and_add_default_skin(Uid) ->
	Rec = get_ride_info(Uid),
	case lists:member(?DEFAULT_SKIN, Rec#t_usr_rides.skins) of  
		true -> skip;
		_ ->
			NewRec = Rec#t_usr_rides{skins = [?DEFAULT_SKIN | Rec#t_usr_rides.skins]},
			set_ride_info(NewRec)
	end.


%%攻防相加乘以25+生命值
get_ride_skinstar_gs(Uid)->
	Rec=db:dirty_get(usr_rides_skin,Uid,#usr_rides_skin.uid),
	% ?debug("get_ride_skinstar_gs Rec:~p",[Rec]),
	{Att,Def,Hp}=get_ride_skin_val(Rec,0,0,0),
	(Att+Def)*25+Hp.


get_ride_skin_val(Rec,Att,Def,Hp)->
	case Rec of
		undefined->{Att,Def,Hp};
		[]->{Att,Def,Hp};
		[Rec2|Rest]->
			% ?debug("Rest:~p",[Rest]),
			#usr_rides_skin{cur_att = Curatt,cur_def = Curdef,cur_hp = Curhp} = Rec2,
			get_ride_skin_val(Rest,Att+Curatt,Def+Curdef,Hp+Curhp);
		
		_->
			{Att,Def,Hp}
	end.

get_curr_own_skins(Uid) ->
	#usr_rides{skins=Skins} = get_ride_info(Uid),
	Skins.

send_ride_info_to_client(Uid, Sid, Seq)-> 	
	Ride = get_ride_info(Uid),
	Pt1  = pt_ret_ride_info_e111:new(),
	Pt   = Pt1#pt_ret_ride_info{
		ride_type  = Ride#usr_rides.type,
		ride_id    = Ride#usr_rides.id,
		lev        = 0,
		exp        = Ride#usr_rides.exp,
		ride_state = Ride#usr_rides.ride_state,
		fighting   = 0,
		currskin   = Ride#usr_rides.currskin,
		eq1        = Ride#usr_rides.eq1,
		eq2        = Ride#usr_rides.eq2,
		eq3        = Ride#usr_rides.eq3,
		eq4        = Ride#usr_rides.eq4,
		eq5        = Ride#usr_rides.eq5,
		eq6        = Ride#usr_rides.eq6,
		skin       = [make_skin_pt(Uid,S) || S <- Ride#usr_rides.skins]
	},
	?send(Sid,pt_ret_ride_info_e111:to_binary(Pt, Seq)).

%%坐骑升星培养
ride_foodstar(Uid,Sid,Seq,Skinid,Num,FoodType)->
	if FoodType > 0 andalso FoodType < 4 andalso (Num == 1 orelse Num == 10) ->
			#st_ride_growth{val1 = Val1,val2 = Val2,crit_rate = Rate,growth_item = {NeedItemid,NeedItemnum}} = data_ride_growth:get_data(FoodType),
			% ?debug("Skinid,Num,FoodType:~p",[{Skinid,Num,FoodType}]),
			{_Starlev1,Atk1,Def1,Hp1}=case db:dirty_get(usr_rides_skin,Uid*1000+Skinid,#usr_rides_skin.uidskinid) of 
				[#usr_rides_skin{cur_starLev = Starlev,cur_att = Atk,cur_def = Def,cur_hp = Hp}|_]->
					{Starlev,Atk,Def,Hp};
				_ ->{1,0,0,0}
			end,
			ride_foodstar_once(Uid,Sid,Skinid,Num,Val1,Val2,Rate,NeedItemid,NeedItemnum),
			{Starlev2,Atk2,Def2,Hp2}=case db:dirty_get(usr_rides_skin,Uid*1000+Skinid,#usr_rides_skin.uidskinid) of 
				[#usr_rides_skin{cur_starLev = Starlevb,cur_att = Atkb,cur_def = Defb,cur_hp = Hpb}|_]->
					{Starlevb,Atkb,Defb,Hpb};
				_ ->{1,0,0,0}
			end,
			Addatt = Atk2 - Atk1,
			Adddef = Def2 - Def1,
			Addhp = Hp2 - Hp1,
			Pt1     = pt_ret_skin_list_e113:new(),
			SkinsPt = [make_ret_skin_pt(Uid,S,Skinid,Starlev2,Atk2,Def2,Hp2,Addatt,Adddef,Addhp) || S <- [Skinid]],
			%SkinsPt = [make_ret_skin_pt(Uid,S,Skinid,Addatt,Adddef,Addhp) || S <- Skins],
			Pt      = Pt1#pt_ret_skin_list{skins = SkinsPt},				
			?send(Sid,pt_ret_skin_list_e113:to_binary(Pt, Seq)),
			fun_property:updata_fighting(Uid);	
		true -> skip
	end.

ride_foodstar_once(Uid,Sid,Skinid,Num,Val1,Val2,Rate,NeedItemid,NeedItemnum) when Num>0  ->
	Rec = case db:dirty_get(usr_rides_skin,Uid*1000+Skinid,#usr_rides_skin.uidskinid) of 
		[Rec2|_] -> Rec2;
		_ -> #usr_rides_skin{uid=Uid,skin_id=Skinid,uidskinid=Uid*1000+Skinid}
	end,
	#usr_rides_skin{cur_starLev = CurStartLev} = Rec,
	case get_ride_star_config(Skinid, CurStartLev) of
		undefined-> skip;
		{Maxatt,Maxdef,Maxhp,_} ->
			SuccCallBack = fun() ->
				ride_foodstar_once_succeed(Uid,Sid,Val1,Val2,Maxatt,Maxdef,Maxhp,Rate,Rec)	
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [{?ITEM_WAY_FEED_RIDE, NeedItemid, NeedItemnum}], [], SuccCallBack, undefined),
			Num2=Num-1, 
			ride_foodstar_once(Uid,Sid,Skinid,Num2,Val1,Val2,Rate,NeedItemid,NeedItemnum);
		_->skip
	end;
ride_foodstar_once(_Uid,_Sid,_Skinid,0,_Val1,_Val2,_Rate,_NeedItemid,_NeedItemnum)->
	ok.


make_ret_skin_pt(_Uid,Skinid,Skinid2,Starlev,Atk,Def,Hp,Addatt,Adddef,Addhp)->
	Pt = pt_public_class:r_skin_new(),
	Pt2=if Skinid==Skinid2 ->
			Pt#pt_public_r_skin{type = Skinid,cur_starnum=Starlev,cur_atk=Atk,cur_defense=Def,cur_life=Hp,
						add_atk=Addatt,add_defense=Adddef,add_life=Addhp};
		true->
			Pt#pt_public_r_skin{type = Skinid,cur_starnum=Starlev,cur_atk=Atk,cur_defense=Def,cur_life=Hp}
	end,
	Pt2.
	

ride_foodstar_once_succeed(Uid,_Sid,Val1,Val2,Maxatt,Maxdef,Maxhp,Rate,Rec)->
	%#usr_rides{skins = Skins} = get_ride_info(Uid),
	#usr_rides_skin{id=ID,cur_starLev = _CurStartLev,cur_att = Curatt,cur_def = Curdef,cur_hp = Curhp,skin_id=Skinid} = Rec,
	{Addatt,Adddef,Addhp} = cal_starfood_add(Val1,Val2,Curatt,Curdef,Curhp,Maxatt,Maxdef,Maxhp,Rate),
	% ?debug("{Addatt,Adddef,Addhp}:~p",[{Addatt,Adddef,Addhp}]),
	if ID > 0 ->
			db:dirty_put(Rec#usr_rides_skin{
				cur_att = min(Curatt+Addatt, Maxatt),
				cur_def = min(Curdef+Adddef, Maxdef),
				cur_hp = min(Curhp+Addhp, Maxhp),
				start_time = util:unixtime()
			});
		true->
			db:insert(Rec#usr_rides_skin{
						uid=Uid,
						skin_id=Skinid,
						uidskinid=Uid*1000+Skinid,
						cur_att = Curatt+Addatt,
						cur_def = Curdef+Adddef,
						cur_hp = Curhp+Addhp,
						start_time = util:unixtime()
			})
	end.
%%向上取整（Min（参数A， 100 * 属性上限 /（属性上限 + 当前属性 * 参数B））*（1~0.5浮动值））
cal_starfood_add(Val1,Val2,Curatt,Curdef,Curhp,Maxatt,Maxdef,Maxhp,Rate)->
	% ?debug("(Maxatt+Curatt*Val2):~p",[{(Maxatt+Curatt*Val2),Maxatt,Curatt,Val2}]),
	Addatt=util:ceil((util:min(Val1,100*Maxatt/(Maxatt+Curatt*Val2)))*((util:rand(1,5000))/10000+0.5)),
	Adddef=util:ceil((util:min(Val1,100*Maxdef/(Maxdef+Curdef*Val2)))*((util:rand(1,5000))/10000+0.5)),
	Addhp=util:ceil((util:min(Val1,100*Maxhp/(Maxhp+Curhp*Val2)))*((util:rand(1,5000))/10000+0.5))*25,
	Num1=util:rand(1,10000),
	Addatt2=if Num1 > 0 andalso Num1 =< Rate ->
		Addatt*10;
		true->Addatt
	end,
	Num2=util:rand(1,10000),
	Adddef2=if Num2 > 0 andalso Num2 =< Rate ->
		Adddef*10;
		true->Adddef
	end,
	Num3=util:rand(1,10000),
	Addhp2=if Num3 > 0 andalso Num3 =< Rate ->
		Addhp*10;
		true->Addhp
	end,
	Addatt3=if Maxatt > (Addatt2 + Curatt) ->
			Addatt2;
		Maxatt > Curatt ->
			Maxatt - Curatt;
		true -> 0
	end,
	Adddef3=if Maxdef > Adddef2 + Curdef ->
			Adddef2;
		Maxdef > Curdef ->
			Maxdef - Curdef;
		true -> 0
	end,
	Addhp3=if Maxhp > Addhp2 + Curhp ->
			Addhp2;
		Maxhp > Curhp ->
			Maxhp - Curhp;
		true -> 0
	end,
	{Addatt3,Adddef3,Addhp3}.

%%坐骑觉醒
ride_awake(Uid,Sid,Seq,Skinid)->
	#st_ride_skin_info{hechengID = Need_item} = data_ride_skin:get_data(Skinid),
	#st_item_type{color = Color} = data_item:get_data(Need_item),
	#usr_rides{skins = Skins} = get_ride_info(Uid),
	case lists:member(Skinid,Skins) of
		true->
			case db:dirty_get(usr_rides_skin,Uid*1000+Skinid,#usr_rides_skin.uidskinid) of 
				[]->skip;
				[Rec|_]->
					#usr_rides_skin{cur_starLev = CurStartLev,cur_att = CurAtt,cur_def = CurDef,cur_hp = CurHp} = Rec,
					{Need_num,Checkval}=check_ride_awake_condition(Uid,Color,CurStartLev,CurAtt,CurDef,CurHp),
					if Checkval == true ->
						
							SuccCallBack = fun() ->
								Starnum=if CurStartLev==0 ->
										2; 
									true-> 
										CurStartLev+1 
								end,
								db:dirty_put(Rec#usr_rides_skin{cur_starLev = Starnum,start_time = util:unixtime()}),
								Pt1     = pt_ret_skin_list_e113:new(),
								SkinsPt = [make_skin_pt(Uid,S) || S <- [Skinid]],
								%SkinsPt = [make_skin_pt(Uid,S) || S <- Skins],
								Pt      = Pt1#pt_ret_skin_list{skins = SkinsPt},
								fun_property:updata_fighting(Uid),						
								?send(Sid,pt_ret_skin_list_e113:to_binary(Pt, Seq))	
							end,
							fun_item_api:check_and_add_items(Uid, Sid, [{?ITEM_WAY_RIDE, Need_item, Need_num}], [], SuccCallBack, undefined);
						true->skip
					end;
				_->skip
			end;
		_->skip
	end.
get_ride_star_config(Skinid,Starlev)->
	case get({Skinid,Starlev}) of
		undefined->
			#st_ride_skin_info{hechengID = Need_item} = data_ride_skin:get_data(Skinid),
			#st_item_type{color = Color} = data_item:get_data(Need_item),
			Datalist=data_ride_starLev:select_type(Color),
			case Datalist of
				[]->skip;
				_->
					Fun=fun(DataId)->
						#st_ride_starLev{starLev=DataStarLev,att_max=Attmax,def_max=Defmax,hp_max=Hpmax,starlev_item_val=Num} 
							= data_ride_starLev:get_data(DataId),
						if DataStarLev==Starlev ->
								put({Skinid,Starlev},{Attmax,Defmax,Hpmax,Num}),
								true;
							true-> skip
						end
					end,
					lists:foreach(Fun,Datalist)
					
			end;
		_->skip
	end,
	get({Skinid,Starlev}).

%%能否觉醒
check_ride_awake_condition(Uid,Color,CurStartLev,CurAtt,CurDef,CurHp)->
	Datalist=data_ride_starLev:select_type(Color),
	case Datalist of
		[]->{0,false};
		_->
			put({Uid,starlev},0),
			Fun=fun(DataId)->
				#st_ride_starLev{starLev=StarLev,att_max=Attmax,def_max=Defmax,hp_max=Hpmax,starlev_item_val=Num} 
					= data_ride_starLev:get_data(DataId),
				case StarLev==CurStartLev andalso Attmax =< CurAtt andalso Defmax=<CurDef andalso CurHp>=Hpmax of
					true->
						put({Uid,starlev},Num),
						true;
					_-> false
				end
			end,
			Boolval=lists:any(Fun,Datalist),
			Num2=get({Uid,starlev}),
			erase({Uid,starlev}),
			{Num2,Boolval} 
	end.


%% 坐骑喂养
feed_ride(Uid,Sid,Seq,Times) when Times == 1 orelse Times == 10 -> 
	% ?debug("times:~p",[Times]),
	[#usr{lev=UsrLv}] = db:dirty_get(usr, Uid),
	#usr_rides{type = Type,exp=CurExp} = OldRide = get_ride_info(Uid),
	#st_ride_info{exp_add=Exp_add,explain=Explain,food = Food, lev = NeedUsrLev} = data_ride_info:get_data(Type),
	#st_ride_info{explain=Explain2} = data_ride_info:get_data(Type+1),
	SelExp = if CurExp < Explain -> Explain;
				true -> Explain2
			end,
	case UsrLv > NeedUsrLev of
		true ->
			FinalTimes = if
				Times == 10 ->
					if
						SelExp > CurExp -> util:ceil((SelExp-CurExp)/Exp_add);
						true -> 1
					end;
				true -> 1
			end,
			% ?debug("finaltimes=~p",[FinalTimes]),
			case fun_item:get_item_num_by_type(Uid, Food) of  
				TotalFood when TotalFood > 0 ->
					NewTimes = util:min(TotalFood, FinalTimes),
					SuccCallBack = fun() ->
						feed_ride_succ(Uid, Sid, Seq, UsrLv, NewTimes, OldRide)
					end,
					SpendItems = [{?ITEM_WAY_FEED_RIDE, Food, NewTimes}],
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, undefined);
				_ ->
					?error_report(Sid, "not_enough_item", 0, [Food])
			end;
		_ -> 
			?error_report(Sid, "mount_level_up_error")
	end;
feed_ride(_Uid,_Sid,_Seq, Times) -> 
	?log_error("ride feed times param wrong, times:~p", [Times]),
	skip.


feed_ride_succ(Uid, Sid, Seq, UsrLv, NewTimes, OldRide) ->
	#usr_rides{type=Type,exp=OldExp} = OldRide,
	{FinalType,Final_Exp,NewCrit} = process_exp(Type, OldExp, UsrLv, NewTimes, 0),
	NewRide = OldRide#usr_rides{type = FinalType, exp = Final_Exp},
	set_ride_info(NewRide),

	if  
		FinalType=/=Type-> %% 坐骑升级了
			fun_property:updata_fighting(Uid),
			fun_task_count:process_count_event(taks_mount_lev,{0,0,FinalType-Type},Uid,Sid);
		true->skip
	end,
	fun_liveness:do_mount_lv_up(Uid),

	TypeData = make_prop_pt(?RIDE_TYPE, FinalType),
	ExpData  = make_prop_pt(?RIDE_EXP, Final_Exp),
	CritData = make_prop_pt(?EXP_CRIT, NewCrit),
	Props = if  
		NewCrit == 1 -> [TypeData,ExpData,CritData];
		true -> [TypeData,ExpData]
	end,
	send_ride_prop_pt(Sid, Seq, Props).

send_ride_prop_pt(Sid, Seq, Props) ->
	Pt1 = pt_ret_ride_prop_e112:new(),
	Pt = Pt1#pt_ret_ride_prop{props = Props},
	?send(Sid, pt_ret_ride_prop_e112:to_binary(Pt, Seq)).

make_prop_pt(T, Val) ->
	Pt = pt_public_class:prop_entry_new(),
	Pt#pt_public_prop_entry{prop_name = T, num = Val}.


process_exp(Type,OldExp,_UsrLev,0,Crit)->{Type,OldExp,Crit};
process_exp(Type,OldExp,UsrLev,Times,Crit)->
	case  data_ride_info:get_data(Type) of  
		#st_ride_info{exp_add=Exp_add,explain=Explain,double=Double,four=Four,next_type=Next_type,lev=Lev}->
			Random=util:rand(1, 100),
			{Exp_add_Final,NewCrit}=	if   
				Random/100=<Double/100->{Exp_add*2,1};
				Random/100=<(Double+Four)/100->
					{Exp_add*4,1};
				true->{Exp_add,Crit}
			end,
			if 
				(OldExp+Exp_add_Final)>=Explain	->
					if  
						Lev=<UsrLev->
							NewExp = OldExp+Exp_add_Final-Explain,
							process_exp(Next_type,NewExp,UsrLev,Times-1,NewCrit);
						true->
							process_exp(Type,Explain,UsrLev,Times-1,NewCrit)
					end;
				true->
					process_exp(Type,OldExp+Exp_add_Final,UsrLev,Times-1,NewCrit)
			end;
		_->{Type,0,Crit}
	end.

%% 坐骑装备升级
ride_equ_up(_Uid, _Sid, _Seq, _Data) ->
	todo.

check_ride_skin(Uid, Skin)->
	% ?debug("Skin:~p", [Skin]),
	#usr_rides{skins = Skins} = get_ride_info(Uid),
	?_IF(lists:member(Skin, Skins), true, false).

%% 增加坐骑皮肤
add_ride_skin(Uid, Sid, Skin)->
	#usr_rides{skins = Skins} = Ride = get_ride_info(Uid),
	% ?debug("Skin:~p, Skins:~p", [Skin, Skins]),
	case lists:member(Skin, Skins) of  
		true -> skip;
		_ ->
			NewRide = Ride#usr_rides{skins = [Skin | Skins]},
			set_ride_info(NewRide),
			fun_property:updata_fighting(Uid),
			
			Pt1     = pt_ret_skin_list_e113:new(),
			%SkinsPt = [make_skin_pt(Uid,S) || S <- NewRide#usr_rides.skins],
			SkinsPt = [make_skin_pt(Uid,Skin) ],
			Pt      = Pt1#pt_ret_skin_list{skins = SkinsPt},				
			?send(Sid,pt_ret_skin_list_e113:to_binary(Pt))
	end.

make_skin_pt(Uid,Skin) ->	
	Pt = pt_public_class:r_skin_new(),
	Pt2=case db:dirty_get(usr_rides_skin,Uid*1000+Skin,#usr_rides_skin.uidskinid) of 
		[#usr_rides_skin{id = ID,cur_starLev = Starlev,cur_att = Atk,cur_def = Def,cur_hp = Hp}|_]->
			Pt#pt_public_r_skin{id = ID, type = Skin,cur_starnum=Starlev,cur_atk=Atk,cur_defense=Def,cur_life=Hp};
		_ ->Pt#pt_public_r_skin{id = 0, type = Skin}
	end,
	Pt2.

ride_change_skin(Uid,Sid,Seq,Skin)->
	#usr_rides{skins = Skins, currskin = CurrSkin} = Ride = get_ride_info(Uid),
	case Skin == 0 orelse (Skin /= CurrSkin andalso lists:member(Skin, Skins)) of
		true ->
			?debug("change skin"),
			set_ride_info(Ride#usr_rides{currskin = Skin}),
			fun_agent_mng:scene_msg_by_pid(Uid, {update_ride_info, Uid, [{curr_skin, Skin}]}),
			send_ride_prop_pt(Sid, Seq, [make_prop_pt(?CURR_SKIN, Skin)]);
		_ ->
			skip 
	end.

on_off_ride(Uid, _Sid, _Seq,in_fight)->
	case get_ride_info(Uid) of  
		#usr_rides{ride_state=1} ->
			fun_agent_mng:scene_msg_by_pid(Uid, {update_ride_info, Uid, [{ride_state,0}]});
		_->skip
	end;
on_off_ride(Uid, _Sid, _Seq, 1)->
	fun_agent_mng:scene_msg_by_pid(Uid, {update_ride_info, Uid, [{ride_state,1}]});
on_off_ride(Uid, _Sid, _Seq, 0)->
	fun_agent_mng:scene_msg_by_pid(Uid, {update_ride_info, Uid, [{ride_state,0}]});
on_off_ride(_, _, _, _)->skip.

save_ride_status(Uid, Status)->
	Ride = get_ride_info(Uid),
	set_ride_info(Ride#usr_rides{ride_state=Status}).


get_fighting(Uid)->
	#usr_rides{skins = Skins,type=Type,eq1=E1,eq2=E2,eq3=E3,eq4=E4,eq5=E5,eq6=E6} = get_ride_info(Uid),
	#st_ride_info{gs=Gs} = data_ride_info:get_data(Type),  
	Fun=fun(Id,Res)-> 
		#st_ride_equ_info{gs=GS1} = data_ride_equ_info:get_data(Id),
		Res + GS1
	end,
	Gs + lists:foldl(Fun, 0, [E1,E2,E3,E4,E5,E6])+get_ridestar_fighting(Skins).

get_ridestar_fighting(Skins)->
	Fun=fun(ID,Acc) ->
		#st_ride_skin_info{gs=Gs} = data_ride_skin:get_data(ID),
		Gs + Acc
	end,
	lists:foldl(Fun, 0, Skins).	

%% 获取坐骑的属性
get_pro(Uid)->
	#usr_rides{type=Type,eq1=E1,eq2=E2,eq3=E3,eq4=E4,eq5=E5,eq6=E6} = get_ride_info(Uid),
	#st_ride_info{props = Pro1} = data_ride_info:get_data(Type),  
	Fun = fun(Equ,Res)-> 
	    #st_ride_equ_info{props= EProps} = data_ride_equ_info:get_data(Equ),
		EProps ++ Res
	end,
	Eps1=lists:foldl(Fun, [], [E1,E2,E3,E4,E5,E6]),
	Eps2=process(Eps1, []),
	process2(Eps2, Pro1).

%% 获取坐骑皮肤的属性
init_ride_skin_prop(Uid) ->
	case get_ride_info(Uid) of
			#usr_rides{skins = Skins} ->
			Fun=fun(ID,Acc) ->
				#st_ride_skin_info{props=PropList} = data_ride_skin:get_data(ID),
				PropList ++ Acc
			end,
			Props=lists:foldl(Fun, [], Skins),			
			process(Props,[]);
		_ -> []
	end.
get_ride_skin_star_prop(Uid)->
	{Att,Def,Hp}=get_ride_att_def_hp(Uid),	
	[{101,Att},{102,Def},{104,Hp}].

get_ride_att_def_hp(Uid)->
	case db:dirty_get(usr_rides_skin,Uid,#usr_rides_skin.uid) of 
		[]->{0,0,0};
		[RecList] when length(RecList)>0 ->
			Fun=fun(Rec,Acc) ->
				#usr_rides_skin{cur_att = CurAtt,cur_def = CurDef,cur_hp = CurHp} = Rec,
				{AttRet,DefRet,HpRet}=Acc,
				{AttRet+CurAtt,DefRet+CurDef,HpRet+CurHp}
			end,
			lists:foldl(Fun,{0,0,0},RecList);

		_->{0,0,0}
	end.

get_ride_skin_gs(Uid) ->
	case get_ride_info(Uid) of
		#usr_rides{skins = Skins} ->
			Fun=fun(ID,Acc) ->
				#st_ride_skin_info{gs=GS} = data_ride_skin:get_data(ID),
				Acc+GS
			end,							
			lists:foldl(Fun, 0, Skins);
		_ -> []
	end.

process([],Ret)->Ret;
process([{K,V}|D],Ret)->
   New=  case lists:keyfind(K, 1, Ret)   of  
			 {_,Oldv}->  lists:keyreplace(K, 1, Ret, {K,Oldv+V});
			 _->Ret++[{K,V}]
	     end,
	process(D,New).

process2([],Ret)->Ret;
process2([{K,V}|D],Ret)->
	New = case lists:keyfind(K, 1, Ret) of  
		 {_,Oldv}->  
			NewV=    if  
						 Oldv*V/100-Oldv*V div 100>0 -> (Oldv*V div 100)+1+Oldv;
						 true->Oldv*V div 100+Oldv
					 end,		
			 lists:keyreplace(K, 1, Ret, {K,NewV});
		 _->Ret
    end,
	process2(D,New).


%%坐骑激活
req_active_ride(Uid, Sid, _Seq, ID)->
	case data_ride_skin:get_data(ID) of
		#st_ride_skin_info{hechengID=Need_item, hechengNUM=Need_num} ->
			?debug("Need_item,Need_num=~p",[{Need_item, Need_num}]),
			SuccCallBack = fun() ->
				add_ride_skin(Uid, Sid, ID),
				fun_task_count:process_count_event(ride_skin_num,{0,0,get_ride_skin_num(Uid)},Uid,Sid)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [{?ITEM_WAY_RIDE, Need_item, Need_num}], [], SuccCallBack, undefined),
			ok;
		_ -> skip
	end.

get_ride_skin_num(Uid) -> length(get_curr_own_skins(Uid)).
