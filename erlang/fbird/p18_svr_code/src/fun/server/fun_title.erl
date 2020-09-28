-module(fun_title).
-include("common.hrl").
% -export([usr_acquire_title/3,check_count/3,req_title_Lev/3,req_change_title/4,req_title_info/3,get_title_prop/1,get_wear_titles/1,check_own_titles/2,get_fighting/1]).
% -export([get_title_lev/1,check_title_data/2,gm_add_exp/3]).

% check_title_data(Uid, Now) ->
% 	case db:dirty_get(ply, Uid) of
% 		[#ply{sid = Sid}] ->
% 			[check_title_data_help(Uid, Sid, Now, Rec) || Rec <- db:dirty_get(usr_titles, Uid, #usr_titles.uid)];
% 		_ -> skip
% 	end.

% check_title_data_help(Uid, Sid, Now, Rec = #usr_titles{type=TitleId,state=State,days=Long,begintime=BeginTime}) ->
% 	case Long + BeginTime < Now andalso State == 2 andalso Long /= 0 of
% 		true ->
% 			Used1 = get_wear_titles(Uid),
% 			Used = case Used1 == TitleId of
% 				true -> 0;
% 				_ -> Used1
% 			end,
% 			db:dirty_put(Rec#usr_titles{used = 0,state = 3}),
% 			sendtitle2mail(Uid,TitleId),
% 			Ptm1=pt_public_class:title_obj_new(),
% 			Ptm = Ptm1#pt_public_title_obj{
% 				title = TitleId,
% 				lasttime = -1
% 			},
% 			Pt1=pt_ret_titles_e10b:new(),
% 			Pt=Pt1#pt_ret_titles{
% 				used = Used,
% 				titles = [Ptm]
% 			},
% 			?send(Sid,pt_ret_titles_e10b:to_binary(Pt));
% 		_ -> skip
% 	end.

% get_title(Uid, TitleId) ->
% 	List = db:dirty_get(usr_titles, Uid, #usr_titles.uid),
% 	case lists:keyfind(TitleId, #usr_titles.type, List) of
% 		Rec = #usr_titles{} -> Rec;
% 		_ -> []
% 	end. 

% do_condi(Uid,Num,CondiType,TitleId)->
% 	case data_title_config:get_data(TitleId) of
% 		#st_title_config{titleCondition=Condi,titleTime = Day} ->
% 			case get_title(Uid, TitleId) of 
% 				#usr_titles{} -> skip;
% 				_->
% 					case Condi of
% 						[{Type,ConNum}]->
% 							if 
% 								Type == CondiType andalso Num >= ConNum ->
% 									sendtitle1mail(Uid,TitleId),
% 									db:insert(#usr_titles{type = TitleId,uid = Uid,days = Day * 24 * 3600,begintime = 0,state = 1,uidtid = Uid*1000+TitleId});
% 								true -> skip
% 							end;
% 						_ -> skip
% 					end
% 			end
% 	end.

% check_count(pass_copy,Uid,Num)->
% 	%%因为这个配置文件不会变，最多变参数
% 	do_condi(Uid,Num,1,1),
% 	do_condi(Uid,Num,1,2),
% 	do_condi(Uid,Num,1,3),
% 	do_condi(Uid,Num,1,4),
% 	ok;
% check_count(usr_fight,Uid,Num)->
% 	do_condi(Uid,Num,2,5),
% 	do_condi(Uid,Num,2,6),
% 	do_condi(Uid,Num,2,7),
% 	ok;
% check_count(area_season,_Uid,_Ranknum)->
% 	ok;
% check_count(call_hero_count,_Uid,_Num)->
% 	ok;
% check_count(rideskin_count,Uid,Num)->
% 	do_condi(Uid,Num,5,13),
% 	do_condi(Uid,Num,5,14),
% 	ok;
% check_count(hero_count,Uid,Num)->
% 	do_condi(Uid,Num,6,15),
% 	do_condi(Uid,Num,6,16),
% 	ok.

% check_title(Uid,TitleId)->
% 	%%检查是否激活
% 	case get_title(Uid,TitleId) of
% 		[]-> {true,0,0,[]};
% 		Rec = #usr_titles{state=State,days=Day,begintime=Btime} ->
% 			if 
% 				State == 2 -> {false,Day,Btime,Rec};
% 				true-> {true,Day,Btime,Rec}
% 			end
% 	end.

% usr_acquire_title(Title,Uid,Sid)-> 
% 	?debug("use item:~p",[Title]),
% 	case check_title(Uid,Title) of
% 		{true,_,_,_} -> usr_activited_title(Title,Uid,Sid);
% 		{false,Days,Bgntime,Rec}->
% 			?debug("days:~p",[{Days,Bgntime}]),
% 			Now = util:unixtime(),
% 			if 
% 				Days > 0 andalso Days + Bgntime - Now < 0 -> 
% 					usr_activited_title(Title,Uid,Sid),
% 					req_title_info(Uid,Sid,0);
% 				Days > 0 ->
% 					%%加时长
% 					#st_title_config{titleTime=TitleTime} = data_title_config:get_data(Title),
% 					db:dirty_put(Rec#usr_titles{days = Days + TitleTime * 24 * 3600}),
% 					req_title_info(Uid,Sid,0);
% 				true->
% 					%%加经验和等级
% 					#st_title_config{titleTime = TitleTime,exp = Exp} = data_title_config:get_data(Title),
% 					if
% 						Exp > 0 andalso TitleTime == 0 ->
% 							updateUsr(Uid,Sid,Exp),
% 							fun_property:updata_fighting(Uid),
% 						true -> skip
% 					end
% 			end
% 	end.

% %%加经验和等级
% updateUsr(Uid,Sid,AddExp)->
% 	case db:dirty_get(usr,Uid) of
% 		[Usr] ->
% 			#usr{title_exp = TitleExp, title_Lev = Curlev} = Usr,
% 			MaxLev = data_title_lev:get_max(),
% 			{NewLev,NewExp} = get_titlelev_info(Curlev,MaxLev,TitleExp+AddExp),
% 			?debug("Curlev,Lev=~p",[{Curlev,NewLev}]),
% 			#st_title_lev{att=Att1}=data_title_lev:get_data(Curlev),
% 			#st_title_lev{att=Att2}=data_title_lev:get_data(NewLev),
% 			db:dirty_put(Usr#usr{title_exp = NewExp, title_Lev = NewLev}),
% 			Fun = fun({Type,Val}) ->
% 				Add = case lists:keyfind(Type, 1, Att1) of
% 					{Type, OldVal} -> Val - OldVal;
% 					_ -> 0
% 				end,
% 				#pt_public_title_chpprof{type=Type,curnum=Val,addnum=Add}
% 			end,
% 			Ptm = lists:map(Fun, Att2),
% 			Pt1 = pt_usr_title_e10f:new(),
% 			Pt=Pt1#pt_usr_title{
% 				uid = Uid,
% 				titlelev = NewLev,
% 				titleexp = NewExp,
% 				chgProp	 = Ptm
% 			},
% 			?send(Sid,pt_usr_title_e10f:to_binary(Pt));
% 		_ -> skip
% 	end.

% req_title_Lev(Uid,Sid,Seq)->
% 	case db:dirty_get(usr,Uid) of
% 		[#usr{title_exp=TitleExp,title_Lev=TitleLev1}] ->
% 			TitleLev = case TitleLev1 of
% 				0 -> 1;
% 				_ -> TitleLev1
% 			end,
% 			#st_title_lev{att=Prop}=data_title_lev:get_data(TitleLev),
% 			Fun = fun({Type,Val}) ->
% 				#pt_public_title_chpprof{type=Type,curnum=Val}
% 			end,
% 			Ptm = lists:map(Fun,Prop),
% 			Pt1 = pt_usr_title_e10f:new(),
% 			Pt=Pt1#pt_usr_title{
% 				uid = Uid,
% 				titlelev = TitleLev,
% 				titleexp = TitleExp ,
% 				chgProp	 = Ptm
% 			},
%             ?send(Sid,pt_usr_title_e10f:to_binary(Pt,Seq));
% 		_ -> skip
% 	end.

% get_titlelev_info(Lev,MaxLev,Exp)->
% 	#st_title_lev{exp=NeedExp}=data_title_lev:get_data(Lev),
% 	case Lev >= MaxLev of
% 		true -> {MaxLev,NeedExp};
% 		_ ->
% 			case Exp >= NeedExp of
% 				true -> get_titlelev_info(Lev+1,MaxLev,Exp-NeedExp);
% 				_ -> {Lev,Exp}
% 			end
% 	end.

% usr_activited_title(TitleId,Uid,Sid)-> 
% 	case data_title_config:get_data(TitleId) of  
% 		#st_title_config{titleTime=TitleTime}->
% 			%%称号的状态值如下，初始化为0，当给用户发放了物品邮件后，更新为1，激活后为2，当过期时为3。
% 			{LastTime,Begintime}=if 
% 		 		TitleTime > 0 -> {TitleTime*24*3600,util_time:unixtime()};
% 		 		true-> {0,0}
% 		 	end,
% 		 	Used = case get_wear_titles(Uid) of
% 		 		0 -> 0;
% 		 		_ -> 1
% 		 	end, 
% 		 	case get_title(Uid, TitleId) of
% 		 		Rec = #usr_titles{} -> db:dirty_put(Rec#usr_titles{days = LastTime,begintime = Begintime,state = 2,used = Used});
% 		 		_ -> db:insert(#usr_titles{uid=Uid,type=TitleId,used=Used,days=LastTime,begintime = Begintime,state=2,uidtid=Uid*1000+TitleId})
% 		 	end,
% 		 	Pt1 = pt_acquire_new_title_e10a:new(),
% 			Pt=Pt1#pt_acquire_new_title{
% 				title = TitleId,
% 				lasttime = LastTime
% 			},
% 			?send(Sid,pt_acquire_new_title_e10a:to_binary(Pt)),
% 			case Used of
% 				1 ->
% 					Pt21 = pt_use_someone_title_e10c:new(),
% 					Pt2  = Pt21#pt_use_someone_title{
% 						title = TitleId
% 					},
% 					?send(Sid,pt_use_someone_title_e10c:to_binary(Pt2));
% 				_ -> skip
% 			end,
% 			fun_property:updata_fighting(Uid),
% 		_ -> skip
% 	end.

% get_title_prop(Uid)->
% 	List = db:dirty_get(usr_titles, Uid, #usr_titles.uid),
% 	TitleLev = get_title_lev(Uid),
% 	Fun=fun(#usr_titles{type=Id,state=State},Acc)-> 
% 		if
% 			State == 2 ->
% 				case data_title_config:get_data(Id) of  
% 					#st_title_config{att=Prop}->lists:append(Acc,Prop);
% 					_ -> Acc
% 				end;
% 			true -> Acc
% 		 end           
% 	end,
% 	NewList = lists:foldl(Fun,[],List),
% 	case data_title_lev:get_data(TitleLev) of
% 		#st_title_lev{att = Prop1} -> lists:append(NewList, Prop1);
% 		_ -> NewList
% 	end.

% get_fighting(Uid)->
%     List = db:dirty_get(usr_titles, Uid, #usr_titles.uid),
% 	TitleLev = get_title_lev(Uid),
% 	Fun=fun(#usr_titles{type=Id,state=State},Acc)->
% 		if
% 			State == 2 ->
% 				case data_title_config:get_data(Id) of  
% 					#st_title_config{gs=Gs} -> Acc + Gs;
% 					_ -> Acc
% 				end; 
% 			true -> Acc  
% 		end
% 	end,
% 	Gs = lists:foldl(Fun,0,List),
% 	case data_title_lev:get_data(TitleLev) of
% 		#st_title_lev{gs = Gs1} -> Gs + Gs1;
% 		_ -> Gs
% 	end.	

% req_change_title(Uid,Sid,Seq,TitleId1)->
% 	TitleId = case TitleId1 > 0 of
% 		true -> TitleId1;
% 		_ -> 0
% 	end,
% 	List = db:dirty_get(usr_titles, Uid, #usr_titles.uid),
% 	case lists:keyfind(1, #usr_titles.used, List) of
% 		Rec = #usr_titles{} -> db:dirty_put(Rec#usr_titles{used = 0});
% 		_ -> skip
% 	end,
% 	NewTitleId = case TitleId of
% 		0 -> TitleId;
% 		_ ->
% 			case data_title_config:get_data(TitleId) of
% 				#st_title_config{} ->
% 					case lists:keyfind(TitleId, #usr_titles.type, List) of
% 						NewRec = #usr_titles{} -> 
% 							db:dirty_put(NewRec#usr_titles{used = 1}),
% 							TitleId;
% 						_ -> 0
% 					end;
% 				_ -> 0
% 			end
% 	end,
% 	Pt1 = pt_use_someone_title_e10c:new(),
% 	Pt = Pt1#pt_use_someone_title{title = NewTitleId},
% 	?send(Sid,pt_use_someone_title_e10c:to_binary(Pt,Seq)).

% sendtitle1mail(Uid,TitleId) ->
% 	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(title1),
% 	Items = case data_title_config:get_data(TitleId) of  
% 		#st_title_config{goodsId=Type} -> [{Type,1}];
% 		_ -> []
% 	 end,
% 	mod_mail_new:sys_send_personal_mail(Uid, Title, Content, Items, ?MAIL_TIME_LEN).

% sendtitle2mail(Uid,TitleId) ->
% 	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(title2),
% 	TitleName = case data_title_config:get_data(TitleId) of  
% 		#st_title_config{titleName=Name}-> Name;
% 		_->""
% 	 end,
% 	Content2 = util:format_lang(util:to_binary(Content), [TitleName]),
% 	mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, [], ?MAIL_TIME_LEN).

% req_title_info(Uid,Sid,Seq)->
% 	List = db:dirty_get(usr_titles, Uid,#usr_titles.uid),
% 	Used = get_wear_titles(Uid),
% 	Fun=fun(Rec = #usr_titles{type=TitleId,days=Long,begintime=BeginTime,state=State},Acc)->
% 		case State of
% 			2 ->
% 				LastTime = case Long of
% 					0 -> 0;
% 					_ -> Long + BeginTime - util_time:unixtime()
% 				end,
% 				case LastTime < 0 of
% 					true ->
% 				 		db:dirty_put(Rec#usr_titles{used = 0,state = 3}),
% 				 		sendtitle2mail(Uid,TitleId),
% 				 		Acc;
% 					_ ->
% 						Ptm1=pt_public_class:title_obj_new(),
% 						Ptm = Ptm1#pt_public_title_obj{
% 							title = TitleId,
% 							lasttime = LastTime
% 						},
% 						[Ptm | Acc]
% 				end;
% 			_ -> Acc
% 		end
% 	end,
% 	Title_objs = lists:foldl(Fun, [], List),
% 	Pt1=pt_ret_titles_e10b:new(),
% 	Pt=Pt1#pt_ret_titles{
% 		used = Used,
% 		titles = Title_objs
% 	},
% 	?send(Sid,pt_ret_titles_e10b:to_binary(Pt,Seq)).

% get_title_lev(Uid) ->
% 	case db:dirty_get(usr, Uid) of
% 		[#usr{title_Lev = Lev}] -> Lev;
% 		_ -> 0
% 	end.

% %%玩家现在穿戴的称号
% get_wear_titles(Uid)->
% 	List = db:dirty_get(usr_titles, Uid, #usr_titles.uid),
% 	case lists:keyfind(1, #usr_titles.used, List) of
% 		#usr_titles{type=Type} -> Type;
% 		_ -> 0
% 	end.

% check_own_titles(Uid,TitleId) ->
% 	List = db:dirty_get(usr_titles, Uid, #usr_titles.uid),
% 	case lists:keyfind(TitleId, #usr_titles.type, List) of
% 		false -> false;
% 		_ -> true
% 	end.

% gm_add_exp(Uid, Sid, Exp) -> updateUsr(Uid,Sid,Exp).

% % %%添加称号系统公告
% % private_system_msg(Uid,Title)->
% % 	case Title of
% % 		51->send_system_msg(Uid,214);
% % 		52->send_system_msg(Uid,215); 
% % 		53->send_system_msg(Uid,216);
% % 		54->send_system_msg(Uid,217);
% % 		55->send_system_msg(Uid,218);
% % 		_->skip
% % 	end.

% % %%agent发送系统公告
% % send_system_msg(Uid,DataNum)->
% % 		gen_server:cast({global, agent_mng}, {system_speaker,[integer_to_list(DataNum),util:to_list(util:get_name_by_uid(Uid))]}).