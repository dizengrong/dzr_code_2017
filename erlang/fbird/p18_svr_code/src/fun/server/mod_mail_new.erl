-module (mod_mail_new).
-include ("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([sys_send_personal_mail/5, sys_send_personal_mail/6, gm_usrs_mail/5, gm_usrs_mail/6]).
-export([gm_all_mail/7, gm_all_mail/8, on_login_load_mail/1, gm_code_send_usr_mail/3,gm_code_send_public_mail/2]).
-export([req_read_mail_item/4, req_read_mail/4]).


-define(MAIL_STATE_NOREAD, 0).	%% 未读
-define(MAIL_STATE_READ, 1).	%% 已读未获取附件
-define(MAIL_STATE_GET, 2).	%% 已读已获取

-define(UPDATATIME , (60*60*3)).	%% 更新时间

%%	系统发送个人邮件 
sys_send_personal_mail(Uid, Title, Content, ItemList, DTimeLen) ->
	sys_send_personal_mail(Uid, Title, Content, ItemList, DTimeLen, 0).
sys_send_personal_mail(Uid, Title, Content, ItemList, DTimeLen, ConfigID) ->
	?MODULE ! {sys_send_personal_mail, Uid, Title, Content, ItemList, DTimeLen, ConfigID}.
	
%%	gm发送个人邮件
gm_usrs_mail(Usrs, Title, Content, ItemList, DTimeLen)->
	gm_usrs_mail(Usrs, Title, Content, ItemList, DTimeLen, 0).
gm_usrs_mail(Usrs, Title, Content, ItemList, DTimeLen, ConfigID)->
	?MODULE ! {gm_usrs_mail, Usrs, Title, Content, ItemList, DTimeLen, ConfigID}.

%%	gm发送公用邮件
gm_all_mail(Title, Content, ItemList, DTimeLen, Channel, Start,End) ->
	gm_all_mail(Title, Content, ItemList, DTimeLen, Channel, Start, End, 0).
gm_all_mail(Title, Content, ItemList, DTimeLen, Channel, Start, End, ConfigID) ->
	?MODULE ! {gm_all_mail, Title, Content, ItemList, DTimeLen, Channel, Start, End, ConfigID}.

%%	GM命令
gm_code_send_public_mail(ConfigID,ItemList) ->
	?MODULE ! {gm_code_send_public_mail, ?MAIL_TITLE,?MAIL_CONTENT,ItemList,?MAIL_TIME_LEN,ConfigID}.
gm_code_send_usr_mail(Uid,ConfigID,ItemList)->
	?MODULE ! {gm_code_send_usr_mail, Uid,?MAIL_TITLE,?MAIL_CONTENT,ItemList,?MAIL_TIME_LEN,ConfigID}.

on_login_load_mail(Uid)->
	read_public_mail(Uid),
	req_get_mail(Uid).

%%	返回现在到明天三点的时间差
return_tomorrow_time(Time)->
	Tomorrow = util_time:next_day_zero_clock() + ?UPDATATIME,
	Tomorrow - Time.

%% 	初始化启动一个定时器删除超时邮件
init() -> 
	Interval = return_tomorrow_time(util:unixtime()),
	erlang:start_timer(Interval * 1000 , self(), next_updata_mail),
	ok.




handle_call(Request) ->
	?ERROR("unhandled request:~p", [Request]),
	no_reply.

handle_msg({timeout, _TimerRef, next_updata_mail})->
	Now = util:unixtime(),
	del_time_out_all_mail(Now),
	Time = return_tomorrow_time(Now),
	erlang:start_timer(Time * 1000, self(), next_updata_mail);

handle_msg({sys_send_personal_mail, Uid, Title, Content, ItemList, DTimeLen, ConfigID}) -> 
	case db_api:dirty_read(ply, Uid) of
		[#ply{sid = Sid} | _] ->
			create_personal_mail(true, Uid, Sid, Title, Content, ItemList, DTimeLen, ConfigID);
		_ ->
			create_personal_mail(false, Uid, 0, Title, Content, ItemList, DTimeLen, ConfigID)				
	end;

handle_msg({gm_usrs_mail, Usrs, Title, Content, ItemList, DTimeLen, ConfigID}) -> 
	Fun = fun(Uid)-> 
		case db_api:dirty_read(usr, Uid) of
			[Usr] when erlang:is_record(Usr, usr)->	
				case db_api:dirty_read(ply, Uid ) of
					[#ply{sid = Sid} | _] ->			
						create_personal_mail(true, Uid, Sid, Title, Content, ItemList, DTimeLen, ConfigID);
					_ ->	
						create_personal_mail(false, Uid, 0, Title, Content, ItemList, DTimeLen, ConfigID)						
				end;
			_ -> skip 
		end                 
 	end,
	lists:foreach(Fun, Usrs);

handle_msg({gm_all_mail, Title, Content, ItemList, DTimeLen, Channel, Start, End, ConfigID}) -> 
	Now = util:unixtime(),
	SecTimeLen = DTimeLen * ?ONE_DAY_SECONDS,
	NewItemList = check_item_list(ItemList),
	Rec = #t_mail_public{
					id        = db_uid:new_id(t_mail_public),
					title     = util:to_binary(Title),
					content   = util:to_binary(Content), 
					s_time    = Now, 
					d_time    = Now + SecTimeLen, 
					config_id = ConfigID, 
					item_info = NewItemList,
					channel   = Channel, 
					start_reg = Start, 
					end_reg   = End
					},
	db_api:dirty_write(Rec),
	%%将此邮件发送在线的玩家
	Usr_List = fun_agent_mng:get_usrs_by_condition({Channel, Start, End}),
	Fun = fun({Uid, Sid}) ->
		case db_api:dirty_index_read(t_mail_read_public, Uid, #t_mail_read_public.pid) of
			[RPM = #t_mail_read_public{mail_read_time = Mail_Send_Time} | _] ->
				if
					Now < Mail_Send_Time  -> ?log_error("sys_send_public_mail,time error,Title=~p~~n",[Title]);
					true -> skip
				end,
				db_api:dirty_write(RPM#t_mail_read_public{mail_read_time = Now});
			_ ->
				db_api:dirty_write(#t_mail_read_public{id = db_uid:new_id(t_mail_read_public), pid = Uid, mail_read_time = Now})
		end,
		SendMails = create_mail_by_public_mail(Uid, Rec),
		send_msg(Sid, [SendMails])
	end,			
	lists:foreach(Fun, Usr_List);

handle_msg({recv, Sid, Uid, {Name,Seq,Pt}}) ->	
	process_pt(Name,Seq,Pt,Sid,Uid);


handle_msg({gm_code_send_public_mail, Title, Content, ItemList, DTimeLen, ConfigID}) -> 
	Now = util:unixtime(),
	SecTimeLen = DTimeLen * ?ONE_DAY_SECONDS,
	NewItemList = check_item_list(ItemList),		
	Rec = #t_mail_public{
			title = util:to_binary(Title),
			content = util:to_binary(Content),
			s_time = Now, 
			d_time = Now + SecTimeLen, 
			config_id = ConfigID, 
			item_info = NewItemList
		    },
	db_api:dirty_write(Rec#t_mail_public{id = db_uid:new_id(t_mail_public)}),
	%%将此邮件发送在线的玩家
	Usr_List=fun_agent_mng:get_usrs(),
	Fun = fun(Uid) ->
		case db_api:dirty_index_read(t_mail_read_public, Uid, #t_mail_read_public.pid) of
			[RPM = #t_mail_read_public{mail_read_time = Mail_Send_Time} | _] ->
				if
					Now < Mail_Send_Time -> ?log_error("sys_send_public_mail,time error,Title=~p~~n",[Title]);
					true -> skip
				end,
				db_api:dirty_write(RPM#t_mail_read_public{mail_read_time=Now});
			_ ->
				db_api:dirty_write(#t_mail_read_public{id = db_uid:new_id(t_mail_read_public), pid = Uid, mail_read_time = Now})
		end,
		create_mail_by_public_mail(Uid,Rec)		
	end,			
	lists:foreach(Fun, Usr_List);

handle_msg({gm_code_send_usr_mail, Uid, Title, Content, ItemList, DTimeLen, ConfigID})->
	case db_api:dirty_read(ply, Uid) of
		[#ply{sid = Sid} | _] ->
			create_personal_mail(true, Uid, Sid, Title, Content, ItemList, DTimeLen, ConfigID);
		_ ->
			create_personal_mail(false, Uid, 0, Title, Content, ItemList, DTimeLen, ConfigID)				
	end;



handle_msg(Msg) ->
	?ERROR("unhandled msg:~p", [Msg]),
	ok.

terminate() ->
	ok.

do_loop(_Now) ->
	ok.

%%	获取邮件列表
req_get_mail(Uid)->
	Mails = db_api:dirty_index_read(t_mail, Uid, #t_mail.reciver_id),
	send_msg(util:get_sid_by_uid(Uid), 0, Mails).

%% 创建个人邮件
create_personal_mail(SendClient, Uid, Sid, Title, Content, ItemList, DTimeLen, ConfigID) ->	
	Now = util:unixtime(),
	SecTimeLen = DTimeLen * ?ONE_DAY_SECONDS,
	Rec = #t_mail{
		id         = db_uid:new_id(t_mail),
		reciver_id = Uid, 
		title      = util:to_binary(Title), 
		content    = util:to_binary(Content), 
		s_time     = Now, 
		d_time     = Now + SecTimeLen, 
		state      = 0, 
		config_id  = ConfigID, 
		item_info  = check_item_list(ItemList)
	},	 
	db_api:dirty_write(Rec),
	SendClient andalso send_msg(Sid,[Rec]).

%%	创建公用邮件
create_mail_by_public_mail(Uid, PublicMail) ->
	case PublicMail of
		#t_mail_public{s_time = STime, d_time = DTime, title = Title, content = Content, config_id = ConfigID, item_info = ItemInfo} ->	
			Rec=#t_mail{id = db_uid:new_id(t_mail), reciver_id = Uid, title = util:to_binary(Title), content = util:to_binary(Content), s_time = STime, 
						d_time = DTime, state = 0, config_id = ConfigID, item_info = ItemInfo},
			db_api:dirty_write(Rec),
			Rec;
		_ -> skip	
	end.




send_msg(0, _Mails) -> skip;
send_msg(Sid, Mails) ->
	send_msg(Sid, 0, Mails).
send_msg(Sid, Seq, Mails) ->
	Fun = fun(Rec) ->				
		#pt_public_mail_list{
			mail_id   = Rec#t_mail.id,
			title     = Rec#t_mail.title,
			resoure   = erlang:length(Rec#t_mail.item_info),
			s_time    = Rec#t_mail.s_time,
			config_id = Rec#t_mail.config_id
		}
	end,
	Pt = #pt_req_mail{mails = lists:map(Fun, Mails)},
	?send(Sid, proto:pack(Pt, Seq)).


process_pt(pt_del_mail_d20d, Seq, Pt, Sid, Uid) -> 
	IDS = Pt#pt_del_mail.mails,
	Mail_List = [Data#pt_public_id_list.id || Data <- IDS],
	req_del_mail(Uid, Sid, Seq, Mail_List).


%%删除邮件
req_del_mail(_Uid, _Sid, _Seq, []) -> skip;
req_del_mail(Uid, Sid, Seq, Mail_List) ->		
	Fun=fun(MailID, Ret)->
		%%使用主键查询
		case db_api:dirty_read(t_mail, MailID) of
			[#t_mail{reciver_id = Uid}] ->											
				db_api:dirty_delete(t_mail, MailID),
				Ptm = #pt_public_id_list{id = MailID},
				[Ptm | Ret];			
			_ -> Ret 
		end
	end,
	BinData=lists:foldl(Fun, [], Mail_List),
	Pt=#pt_del_mail{mails = BinData},
	?send(Sid,proto:pack(Pt, Seq)).


%%读取邮件附件
req_read_mail_item(Uid,Sid,Seq,Pt) ->
	IDS=Pt#pt_read_mail_item.mails,
	Mail_List=[Data#pt_public_id_list.id || Data <- IDS],
	read_mail_item(Uid,Sid,Seq,Mail_List).

read_mail_item(_Uid,_Sid,_Seq,[])->skip;
read_mail_item(Uid,Sid,Seq,[MailID | Rest]) ->
	case db_api:dirty_read(t_mail, MailID) of	
		[Rec = #t_mail{reciver_id = Uid, title = Title, item_info = ResoureList1} | _ ] ->								
			if
				erlang:length(ResoureList1) == 0 -> skip;
				true ->
					AddItems = [format_mail_item(I) || I <- ResoureList1],
					AddItems2 = [{{?ITEM_WAY_MAIL_ITEM, util:to_list(Title)}, T, N, B} || {T, N, B} <- AddItems],
					SuccFun = fun() -> 
							db_api:dirty_write(Rec#t_mail{state = ?MAIL_STATE_GET, item_info = []}),
							send_update_msg(Sid, Seq, MailID),
							read_mail_item(Uid,Sid,Seq,Rest)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems2, SuccFun)
			end;						
		_ -> skip
	end.			


%%  发送更新消息  
send_update_msg(Sid, Seq, MailID) ->
	Ptm = #pt_public_update_mails{mail_id = MailID,items = []},
	Pt = #pt_update_mail{update_data = [Ptm]},
	?send(Sid,proto:pack(Pt, Seq)).

%% return:{Type, Num, IsBinding}	
format_mail_item(Item) ->
	case Item of
		?MAIL_RESOURE  ->
			{_ResoureType, _ResoureNum, 0};
		?MAIL_ITEM ->
			?MAIL_ITEM;
		?MAIL_EQUIP ->
			{_Type, _Num, _Is_Binding}
	end.

del_time_out_public_mail(Now)->
	List = db_api:dirty_select(t_mail_public,[{#t_mail_public{d_time='$1', _='_'},[{'<','$1',Now}],['$_']}] ),
	Fun = fun(Mail) ->
		case Mail of
			#t_mail_public{id=ID} ->	db_api:dirty_delete(t_mail_public, ID);
			_ -> ?log_error("del_time_out_public_mail,dirty_select error~n")
		end
	end,
	[Fun(E) || E <- List].


del_time_out_person_mail(Now)->
	Keys = db_api:dirty_all_keys(t_mail),
	Fun = fun(Key)->
			case db_api:dirty_read(t_mail, Key) of
				[#t_mail{id = ID, d_time = Del_time}] when Now > Del_time->
					db_api:dirty_delete(t_mail, ID);
				_->skip
			end
	end,
	[Fun(Key) || Key <- Keys].

%% 读取公共邮件
read_public_mail(Uid)->
	case db_api:dirty_index_read(t_mail_read_public, Uid, #t_mail_read_public.pid) of
		 [RPM=#t_mail_read_public{mail_read_time = ReadTime} | _] ->%%上次读取到哪封全服邮件了
		 	PublicMailList = db_api:dirty_select(t_mail_public,[{#t_mail_public{s_time='$1', _='_'},[{'>','$1',ReadTime}],['$_']}]),
		 	MaxSendTime = usr_get_public_mail(PublicMailList, Uid),
		 			%%更新已经取到哪个时刻的全服邮件了,下次不用再取已经取过的全服邮件
			PublicMailList =/= [] andalso db_api:dirty_write(RPM#t_mail_read_public{mail_read_time=MaxSendTime});
		 _->
		 	PublicMailList = db_api:dirty_match_object(t_mail_public, #t_mail_public{_='_'}),
	 		MaxSendTime = usr_get_public_mail(PublicMailList, Uid),
	 		PublicMailList =/= [] andalso db_api:dirty_write(#t_mail_read_public{id = db_uid:new_id(t_mail_read_public), pid = Uid, mail_read_time = MaxSendTime})
	end.

%% 用户获取公共邮件
usr_get_public_mail([], _Uid) -> skip;
usr_get_public_mail(RecMail, Uid) ->
	Usr = db_api:dirty_read(ply, Uid),
	Fun = fun(PublicMail = #t_mail_public{s_time = S_Time, channel = Channel, start_reg = Start, end_reg = End}, Time) ->
		case  {Channel, Start, End}  of  
			  {0, 0, 0} -> 
			  	create_mail_by_public_mail(Uid, PublicMail);
			  {0, _, _} when Usr#ply.regtime > Start andalso Usr#ply.regtime  < End -> 
			  	create_mail_by_public_mail(Uid,PublicMail);
			  {_, 0, 0}when Usr#ply.channel == Channel -> 
			  	create_mail_by_public_mail(Uid,PublicMail);
			  {_, _, _}when Usr#ply.channel == Channel andalso 
						  Usr#ply.regtime  > Start andalso Usr#ply.regtime  < End ->
				          create_mail_by_public_mail(Uid,PublicMail);
			  _->skip
		end,
		if
			S_Time > Time -> S_Time;
			true -> Time
		end				
	end,
	lists:foldl(Fun,0,RecMail).

req_read_mail(_Uid,Sid,Seq,MailID) ->
	case db_api:dirty_read(t_mail, MailID) of
		[Mail = #t_mail{id = MailID, state = State, item_info = ItemInfo}] ->
			if
				State == ?MAIL_STATE_NOREAD andalso erlang:length(ItemInfo) == 0  ->
					db_api:dirty_write(Mail#t_mail{state = ?MAIL_STATE_GET});
				State == ?MAIL_STATE_NOREAD andalso erlang:length(ItemInfo) > 0  ->
					db_api:dirty_write(Mail#t_mail{state = ?MAIL_STATE_READ});
				true->skip
			end,
			Fun = fun(Item) ->
				{T, Num, _} = format_mail_item(Item),
				#pt_public_item_list{item_id = T,item_num = Num}
			end,
			Pt = #pt_mail_content{
			   mail_id = MailID,
			   title =  Mail#t_mail.title,
			   content = Mail#t_mail.content,
			   items = [Fun(Resoure) || Resoure <- ItemInfo]
			},
			?send(Sid,proto:pack(Pt, Seq));
		_->skip
	end.


check_item_list(ItemList) ->
	Fun = fun (Item) ->
		case Item of
				?MAIL_RESOURE when _ResoureNum > 0 -> 
					true;
				?MAIL_ITEM	when _ItemNum > 0 ->
					true;
				?MAIL_EQUIP when _Num > 0 ->
					true;
				_->
					false
		end
	end,
	lists:filter(Fun, ItemList).


del_time_out_all_mail(Time)->
	del_time_out_public_mail(Time),
	del_time_out_person_mail(Time).
