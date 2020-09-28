%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2015-12-4
%% Company : fbird.Co.Ltd
%% Desc : fun_guild
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_guild).
-include("common.hrl").
-export([
	req_create_guild/6,req_join_guild/5,reply_req_join_guild/5,req_quit_guild/3,
	req_kick_guild/4,invite_join_guild/3,get_guild_id_by_guild_name/1,send_guild_guild_member_verify/1,
	reply_inv_join_guild/3,change_notice/4,broadcast_to_members/2,guild_name_by_uid/1,
	req_guild_apply_for_member_list/3,init/0,req_get_guild_list/3,get_guild_req_join_list/1,
	updata_guild_perm/5,req_guild_member_list/3,send_guild_commonality_info_to_sid/3,
	gm/2,send_guild_all_info_to_sid/1,search_guild/4,get_guild_baseinfo/1,
	req_add_guild_building_exp/5,req_guild_building_list/3,guild_building_prop/1,
	get_guild_name_by_uid/1,auto_refresh_time/1,send_guild_notice_to_sid/4,
	guild_all_member_info/3,gm_add_guild_resource/2,gm_add_guild_exp/3,update_guild_member_total_honor/2,
	get_guild_total_honor/1,get_guild_day_total_honor/1,put_guild_member_last_login_time/1,
	del_apply_for_guild_time/0,updata_guild_member_lev/2,add_guild_resource/2,
	add_guild_exp/4,put_usr_donate_time/4,get_guild_member_post/2,update_ranklist/1,
	updata_apply_for_name/2,req_guild_impeach_president_vote/4,req_guild_impeach_president/3,
	guild_member_list/1,del_guild_impeach_president/1,get_guild_member_uid_list/1,
	get_members/1,get_guild_president_uid/1,get_guild_president_name/1,get_event_permission/2,
	req_auto_consent_join_guild/4,del_all_guild_stone_info/0,send_hunstone_info/3, 
	req_get_hunstone/4, handle/1, get_role_guild_id/1, req_recommend_guilds/3,
	get_guild_lev/1, req_change_banner/4, req_view_member_info/5, req_module_datas/3,
	gm_set_lv/2, get_usr_perm/1
]).

-export([create_guild_help/1,create_guild_succ/1,req_recruiting_members/3,get_guild_fighting/1]).
-export([reset_guild_name/5,change_guild_name_help/1,change_guild_name_succ/1,get_guild_name/1, get_guild_id_by_uid/1]).
-export([send_guild_to_sid/4,req_guild_log/3,check_data/2,update_guild_member/2]).
% -export([req_donation_record/3]).

-define(HAS_NOT_REQ, 0).
-define(HAS_REQ, 1).

init() ->
	put(invite_info, []),
	put(request_info, dict:new()),
	ok.

check_data(Uid,Sid) ->
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[] -> skip;
		[#guild_member{guild_id = GuildId}] ->
			case db:dirty_get(guild, GuildId) of
				[#guild{}] -> skip;
				_ -> mod_msg:handle_to_agnetmng(?MODULE, {check_error_data, Uid, Sid})
			end;
		_ -> mod_msg:handle_to_agnetmng(?MODULE, {check_error_data, Uid, Sid})
	end.

%%请求所有公会列表
req_get_guild_list(Uid,Sid,Seq)->
	AllGuildList = get_all_guild_list(Uid),
	send_all_guild_list_to_sid(Uid, Sid, AllGuildList,0, Seq).

%%所有公会列表
get_all_guild_list(Uid)->
	case db:dirty_match(guild,#guild{dissolve_state=0,_='_'}) of
		GuildList when is_list(GuildList) andalso length(GuildList) >0 ->
			Fun = fun(Rec,Acc) ->
				[get_guild_show_info(Uid, Rec) | Acc]
			end,
			lists:foldl(Fun, [], GuildList);
		_->[]
	end.
%%创建公会
req_create_guild(Uid,Sid,Seq,GuildName,Banner,Notice) ->
	case check_create_guild_time(Uid) of
		true->
			case db:dirty_get(ply, Uid) of
				[#ply{name=Name, lev=Level,prof=Prof,camp=Camp,agent_hid=AgentHid}] ->
					case has_guild(Uid) of
						true ->
							?error_report(Sid, "guild_already_owned",Seq);%%已经拥有公会
						_ ->	
							GuildNameLen = length(xmerl_ucs:from_utf8(GuildName)),
							if	
								GuildNameLen > ?MAX_GUILD_NAME_LEN orelse GuildNameLen < ?MIN_GUILD_NAME_LEN ->
									skip;
									% ?error_report(Sid,"guild_error_name",Seq);%%公会名字不合规范
								true ->	
									case tool:check_str(util:to_list(GuildName)) of
										true ->
											BinGuildName = util:to_binary(GuildName),
											case db:dirty_get(guild, BinGuildName, #guild.name) of
												[] ->
													mod_msg:send_to_agent(AgentHid, {create_guild,Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq});
												_ -> ?error_report(Sid, "guild_name_exist",Seq)%%已经有人用了这个公会名字
											end;
										_ -> ?error_report(Sid, "guild_error_name",Seq)%%名字不合规范
									end
							end
					end;
				_ ->skip
			end;
		_ -> ?error_report(Sid, "newguild",Seq)
	end.

create_guild_help({Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq}) ->
	SpendItems = [{?ITEM_WAY_CREATE_GUID, ?RESOUCE_COIN_NUM, util:get_data_para_num(16)}],
	Succ = fun() ->
		mod_msg:send_to_agnetmng({create_guild_succ,Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,Seq})
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined).

create_guild_succ({Uid,Sid,Banner,GuildName,BinGuildName,Notice,Camp,Name,Level,Prof,_Seq}) ->
	[#guild{id=Id}] = db:insert(#guild{name=BinGuildName,level=1,camp=Camp,state=0,banner=Banner,notice=Notice}),
	?debug("Guild create : ~p",[Id]),
	del_apply_for_guild(Uid),
	Member = #guild_member{
		uid=Uid,prof=Prof, guild_id=Id, perm=?PERM_PRESIDENT, 
		name=Name, level=Level,join_time=util:unixtime(),
		contribution_day=util:get_relative_day(?AUTO_REFRESH_TIME)
	},
	add_guild_member(Member),

	send_guild_all_info_to_sid(Uid),
	send_guild_notice_to_sid(Uid, Sid, Id, 0),
	send_guild_to_sid(Uid,Sid,Id,[{util:unixtime(),?SUCCESS_GUILD_CREATE,Uid,0}]),
	GuildMemberList = get_guild_member_info_by_Menber(Uid, Member),
	send_guild_member_list_to_sid(Uid, Sid, GuildMemberList, 0),
	send_guild_name(Uid,Id, BinGuildName),
	fun_dataCount_update:group_reported(Uid, 0, Id, GuildName).
	% ?error_report(Sid, "guild_create_success",Seq).

%%搜索公会
search_guild(Uid,Sid,GuildName,Seq) ->
	List = case catch list_to_integer(GuildName) of
		{'EXIT', _ } -> 
			[];
		GuildId ->
			case db_api:dirty_read(guild, GuildId) of
				[GuildRec] -> 
					[get_guild_show_info(Uid, GuildRec)];
				_ -> []
			end
	end,
	F = fun(Rec) ->
		get_guild_show_info(Uid, Rec)
	end,
	GuildList = List ++ find_guilds_by_name(GuildName),
	send_all_guild_list_to_sid(Uid, Sid, lists:map(F,GuildList),0, Seq).

find_guilds_by_name(GuildName) ->
	db:dirty_match(guild, #guild{name = util:to_binary(GuildName), _ = '_'}).
	% L = db:dirty_match(guild, #guild{_ = '_'}),
	% BinName = util:to_binary(GuildName),
	% F = fun(#guild{name=Name}) ->
	% 	case binary:match(Name, BinName) of
	% 		nomatch -> false;
	% 		_ -> true
	% 	end
	% end,
	% lists:filter(F, L).

%%申请加入公会
req_join_guild(Uid, Sid, Seq, GuildId, FromPanel) ->
	case check_quit_guild(Uid) of
		true->
			case db:dirty_get(ply, Uid) of
				[#ply{name=Name, lev=Level,prof=Prof}] ->
					case has_guild(Uid) of
						true ->
							?error_report(Sid, "guild_already_owned",Seq);%%已经拥有公会
						_ ->
							case db:dirty_get(guild, GuildId) of
								[GuildRec = #guild{id=GuildId}] ->
									ApplyForGuildNum = get_apply_for_guild_num(Uid),
									if 
										ApplyForGuildNum > ?MAX_JOIN_REQ_TIMES -> 
											?error_report(Sid, "guild_apply_req_times_full",Seq,[?MAX_JOIN_REQ_TIMES]);%%请求公会数量已满
										true->
											case judge_already_apply_for_guild(Uid, GuildId) of
												?HAS_REQ -> ?error_report(Sid, "guild_already_applied",Seq);%%请求过这个公会
												_ ->
													case get_member_amount(GuildId) < get_max_member_amount(GuildId) of
														true ->
															add_apply_for_guild(Uid, GuildId, Level, Name, util:get_relative_day(?AUTO_REFRESH_TIME), Prof),
															case FromPanel of
																1 -> 
																	send_all_guild_list_to_sid(Uid, Sid, [get_guild_show_info(Uid, GuildRec)], 0, Seq);
																_ ->
																	Fun = fun(Info) ->
																		make_guild_show_pt(Info)
																	end,
																	Pt3 = #pt_recommend_guild_list{guild_info_list=lists:map(Fun, [get_guild_show_info(Uid, GuildRec)])},
																	?send(Sid,proto:pack(Pt3,Seq))
															end,
															req_guild_apply_for_member_list(Sid,Uid,Seq);
														_ -> ?error_report(Sid, "guild_full",Seq)%%公会人员已满
													end
											end
									end;
								_ ->
									?error_report(Sid, "guild_dont_exist",Seq)%%没有这个公会
							end
					end;
				_ -> skip
			end;
		_ -> ?error_report(Sid, "guild_alert999",Seq)%%踢出公会错误提示
	end.

broadcast_to_members(Uid, Msg) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=_Sid}] ->
			case get_guild_baseinfo(Uid) of
				{ok, GuildId, _} ->
					broadcast_to_members_by_guildid(GuildId, Msg),
					{ok, GuildId};
				_ ->skip
			end;
		_ ->
			skip
	end.

%% %%获取请求加入公会列表
get_guild_req_join_list(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			List = db:dirty_get(apply_for_guild, GuildId, #apply_for_guild.guild_id),
			Fun = fun(#apply_for_guild{uid = GUid, name = Name, level = Level, prof = Prof},Acc) ->
				[{GUid,Name,Level,Prof} | Acc]
			end,
			lists:foldl(Fun, [], List);
		_ -> []
	end.

%%公会所有成员
guild_all_member_info(Sid,Uid,Seq)->
	case get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			GuildMemberList = get_guild_member_info_list(GuildId),
			send_guild_member_list_to_sid(Uid, Sid, GuildMemberList, Seq);
			
		_->skip
	end.

%%回复申请加入公会 %%IsAccept 1 添加成员  其他 不同处理
reply_req_join_guild(Uid, TgtUid, IsAccept,Sid,Seq) ->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case get_event_permission(Uid, ?GUILD_EVENT_APPROVAL) of
				true->
					List = db:dirty_get(apply_for_guild, GuildId, #apply_for_guild.guild_id),
					case TgtUid of
						0 -> [reply_req_join_guild_help(Uid, GuildId, ApplyUid, IsAccept, Sid, Seq, List) || #apply_for_guild{uid = ApplyUid} <- List];
						_ -> reply_req_join_guild_help(Uid, GuildId, TgtUid, IsAccept, Sid, Seq, List)
					end;
					
				_ -> ?error_report(Sid, "guild_no_authority",Seq)%%没有这个权限
			end;
		_ -> ?error_report(Sid, "guild_dont_exist",Seq)%%没有这个公会
	end.

notice_someone_joined_guild(GuildId, Name) ->
	#mail_content{mailName=Title,text=Content} = data_mail:data_mail(5),
	Content2 = util:format_lang(util:to_binary(Content), [util:to_binary(Name)]),
	List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
	Fun = fun(#guild_member{uid = Uid, perm = Perm}) ->
		case Perm == ?PERM_PRESIDENT orelse Perm == ?PERM_OFFICIAL of
			true -> 
				mod_mail_new:sys_send_personal_mail(Uid, Title, Content2, [], ?MAIL_TIME_LEN);
			_ -> skip
		end
	end,
	[Fun(Rec) || Rec <- List].

reply_req_join_guild_help(Uid, GuildId, TgtUid, IsAccept, Sid, Seq, List) ->
	case lists:keyfind(TgtUid, #apply_for_guild.uid, List) of
		#apply_for_guild{id=Id,level=Lev,name=Name,prof=Prof}->
			case IsAccept of
				1 ->
					case db:dirty_get(guild_member, TgtUid, #guild_member.uid) of
						[] ->
							case get_member_amount(GuildId) < get_max_member_amount(GuildId) of
								true ->
									NewMember = #guild_member{
										uid=TgtUid,level=Lev,name=util:to_binary(Name),
										prof=Prof,guild_id=GuildId,perm=?PERM_NORMAL,join_time=util:unixtime(),
										contribution_day=util:get_relative_day(?AUTO_REFRESH_TIME)
									},
									add_guild_member(NewMember),
									
									notice_someone_joined_guild(GuildId, Name),
									del_apply_for_guild(TgtUid),
									GuildMemberList = get_guild_member_info_by_Menber(Uid, NewMember),
									send_guild_all_info_to_sid(TgtUid),
									send_guild_name(TgtUid,GuildId, get_guild_name(GuildId)),
									send_guild_member_list_to_sid(Uid, Sid, GuildMemberList, Seq,1),
									req_guild_apply_for_member_list(Sid,Uid,Seq),

									send_guild_to_sid(Uid,Sid,GuildId,[{util_time:unixtime(),?SUCCESS_GUILD_JION,TgtUid,Uid}]);
								_ ->
									?error_report(Sid, "guild_full",Seq) %%公会成员已满
							end;
						_ ->
							del_apply_for_guild(TgtUid),
							?error_report(Sid, "guild_jion1",Seq) %%公会成员已满
					end;
				_ ->
					case get_event_permission(Uid, ?GUILD_EVENT_APPROVAL) of
						true->
							db:dirty_del(apply_for_guild, Id),
							req_guild_apply_for_member_list(Sid,Uid,Seq);
						_ -> skip
					end
			end;
		_ -> 
			skip
			% ?error_report(Sid, "guild_already_owned",Seq)%%已经拥有公会
	end.

req_module_datas(Uid, Sid, Seq) ->
	case get_event_permission(Uid, ?GUILD_EVENT_APPROVAL) of
		true->
			req_guild_apply_for_member_list(Sid,Uid,Seq);
		_ -> skip
	end.

%%设置自动加入工会
req_auto_consent_join_guild(Sid,Uid,State,Seq)->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,GuildId,_} ->
			case get_event_permission(Uid, ?GUILD_EVENT_APPROVAL) of
				true->
					case db:dirty_get(guild, GuildId) of
						[Guild = #guild{}|_] ->
							db:dirty_put(Guild #guild{state=State}),
							send_guild_commonality_info_to_sid(Uid, Sid, Seq);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

get_guild_name_by_uid(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			get_guild_name(GuildId);
		_-> []
	end.


get_guild_id_by_uid(Uid) ->
	case  get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			GuildId;
		_ -> 0
	end.

get_guild_name(GuildId)->
	case db:dirty_get(guild, GuildId) of
		[Guild|_]->
			util:to_list(Guild#guild.name);
		_->""
	end.

get_guild_id_by_guild_name(GuildName)->
	BinGuildName = util:to_binary(GuildName),
	case db:dirty_get(guild, BinGuildName, #guild.name) of
		[#guild{id=Id}]->Id;
		_->0
	end.

req_recruiting_members(Uid, Sid, Seq) ->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_} ->
			case get_event_permission(Uid, ?GUILD_EVENT_RECRUIT) of
				true ->
					RecName = "", 
					Chanle = ?CHANLE_SYSTEM,
					Content = [integer_to_list(699), util:to_list(get_guild_name(GuildId))],
					mod_msg:handle_to_chat_server({req_chat, Uid, Sid, Seq, RecName, Chanle, Content, ?GUILD}),
					?error_report(Sid, "society34", Seq);
				_ -> skip
			end;
		_ -> skip
	end.


%%退出公会
req_quit_guild(Uid,Sid,Seq) ->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,Perm}->
			case Perm of
				?PERM_PRESIDENT -> dismiss_guild(Uid,Seq);
				_->
					case db:dirty_get(ply, Uid) of
						[#ply{sid=Sid}] ->
							put_quit_guild(Uid),
							send_guild_to_sid(Uid,Sid,GuildId ,[{util_time:unixtime(),?SUCCESS_QUIT_GUILD,Uid,0}]),
							quit_guild_update_ranklist(Uid),
							send_guild_name(Uid,0, ""),
							remove_guild_member(Uid),
							send_guild_commonality_info_to_sid(Uid,Sid,Seq),
							send_guild_all_info_to_sid(Uid),
							?error_report(Sid, "guild_quit", Seq);
						_ -> skip
					end
			end;
		_ -> skip
	end.

%%踢出公会
req_kick_guild(Uid,TgtUid,Sid,Seq) ->
	case check_kick(Uid,TgtUid) of
		{ok, GuildId} ->
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid}] ->
					send_guild_to_sid(TgtUid,Sid,GuildId,[{util_time:unixtime(),?SUCCESS_KICK_GUILD,Uid,TgtUid}]),
					remove_guild_member(TgtUid),
					send_guild_name(TgtUid,0,""),
					put_quit_guild(TgtUid),
					CopyName = get_guild_name(GuildId),
					#mail_content{mailName = Title1, text = Content1} = data_mail:data_mail(6),
					Content12 = util:format_lang(util:to_binary(Content1), [util:to_binary(CopyName)]),
					mod_mail_new:sys_send_personal_mail(TgtUid, Title1, Content12, [], ?MAIL_TIME_LEN),
					send_guild_all_info_to_sid(Uid),
					req_guild_member_list(Uid,Sid,Seq),
					?error_report(Sid, "common_change_succ", Seq),
					case db:dirty_get(ply, TgtUid) of
						[#ply{sid=TargetSid}] ->
							send_guild_commonality_info_to_sid(TgtUid,TargetSid,0);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

check_kick(Uid,TgtUid) ->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,Perm} ->
			case get_guild_baseinfo(TgtUid) of
				{ok,GuildId,TargetPerm} when TargetPerm /= ?PERM_PRESIDENT  ->
					case get_event_permission(Uid, ?GUILD_EVENT_KICKOUT, Perm) of
						true -> {ok, GuildId};
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

%%指令，添加公会资会
gm_add_guild_resource(Uid,GuildResNum) ->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			add_guild_resource(GuildId,GuildResNum),
			send_guild_all_info_to_sid(Uid);
		_ -> skip
	end.
%%指令，添加公会资会
gm_add_guild_exp(Uid,Sid,GuildExpNum) ->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			add_guild_exp(Uid, Sid, GuildId, GuildExpNum),
			send_guild_all_info_to_sid(Uid);
		_ -> skip
	end.		

%%邀请加入公会
invite_join_guild(Uid, TgtUid, Seq) ->
	case get_event_permission(Uid, ?GUILD_EVENT_INVITATION) of
		true->
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid,name=SrcName}] ->
					case db:dirty_get(ply, TgtUid) of
						[#ply{sid=TgtSid, lev=TgtLev, name=Name}] ->
							if
								TgtLev < ?MIN_REQ_LEVEL -> ?error_report(Sid, "not_enough_player_level");%%等级不足
								true ->
							   	case get_guild_baseinfo(TgtUid) of
							   		{ok, _, _} -> ?error_report(Sid,"guild_send3",Seq,[util:to_binary(Name)]); %%已经有了公会
							   		_ ->
										case get_guild_baseinfo(Uid) of
											{ok, GuildId, _} ->
												case get_member_amount(GuildId) < get_max_member_amount(GuildId) of
													true ->
														case db:dirty_get(guild, GuildId) of
															[#guild{name=GuildName}] ->
																InviteInfoList = get(invite_info),
																NewIdList =  case lists:keyfind(GuildId, 1, InviteInfoList) of
																	{GuildId, IdList} ->
																		[{TgtUid, Uid}|lists:keydelete(TgtUid, 1, IdList)];
																	_ ->
																		[{TgtUid, Uid}]
																end,
																InviteInfoListNew = lists:keystore(GuildId, 1, InviteInfoList, {GuildId, NewIdList}),
																put(invite_info, InviteInfoListNew),
																send_invite_join_guild_to_sid(TgtSid, SrcName, GuildName),
																?error_report(Sid, "guild_send1",Seq);%%邀请成功
															_ -> skip
														end;
													_ -> ?error_report(Sid, "guild_full",Seq)%%成员已满
												end;
											_ -> skip
										end
								end
							end;
						_ -> ?error_report(Sid, "player_offline",Seq)
					end;
				_ -> skip
			end;
		_ -> skip
	end.

%%回复邀请加入公会
reply_inv_join_guild(Uid, GuildName, Seq) ->
	BinGuildName = util:to_binary(GuildName),
	case db:dirty_get(guild, BinGuildName, #guild.name) of
		[#guild{id=GuildId}|_]->
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid, name=Name, lev=Level,prof=Prof}] ->
					case check_quit_guild(Uid) of
						true->
							case has_guild(Uid) of
								true -> ?error_report(Sid, "guild_already_owned");%%已经有了公会
								_ ->
									InviteInfoList = get(invite_info),
									case lists:keyfind(GuildId, 1, InviteInfoList) of
										{GuildId, IdList} ->
											case lists:keyfind(Uid, 1, IdList) of
												{Uid, _InvitorId} ->				
													case get_member_amount(GuildId) < get_max_member_amount(GuildId) of
														true ->
															NewMember = #guild_member{
																uid=Uid,level=Level,name=util:to_binary(Name),
																prof=Prof,guild_id=GuildId,perm=?PERM_NORMAL,join_time=util:unixtime(),
																contribution_day=util:get_relative_day(?AUTO_REFRESH_TIME)
															},
															add_guild_member(NewMember),
															GuildName = get_guild_name(GuildId), 
															add_guild_update_ranklist(Uid, GuildName),
															del_apply_for_guild(Uid),
															GuildMemberList = get_guild_member_info_by_Menber(Uid, NewMember),
															send_guild_member_list_to_sid(Uid, Sid, GuildMemberList, Seq,1),
															updata_uid_ranklist(Uid, get_guild_name(GuildId)),
															send_guild_all_info_to_sid(Uid),
															send_guild_name(Uid,0,get_guild_name(GuildId));
														_ ->
															?error_report(Sid, "guild_full")%%成员已满
													end;
												_ -> skip
											end,
											put(invite_info, lists:keyreplace(GuildId, 1, InviteInfoList, {GuildId, lists:keydelete(Uid, 1, IdList)}));
										_ -> skip
									end
							end;
						_ -> ?error_report(Sid, "guild_alert999",Seq)
					end;
				_ ->skip
			end
	end.

%%解散公会
dismiss_guild(Uid,Seq) ->
	case get_event_permission(Uid, ?GUILD_EVENT_DISSOLUTION) of
		true->
			case db:dirty_get(ply, Uid) of
				[#ply{sid=Sid}] ->
					case get_guild_baseinfo(Uid) of
						{ok,GuildId,_}->
							case db:dirty_get(guild_member, GuildId, #guild_member.guild_id) of
								[] ->skip;
								List when length(List) > 1 -> %% 公会里还有其他人，不能解散
									?error_report(Sid, "guild_dissolve_failure");
								_ ->
									send_guild_to_sid(Uid,Sid,GuildId,[{util_time:unixtime(),?SUCCESS_GUILD_DISMISS,Uid,0}]),
									del_apply_for_by_guild(GuildId),
									case db:dirty_get(guild, GuildId) of
										[Guild|_]->
											db:dirty_put(Guild#guild{dissolve_state=1}),
											ok;
										_->skip
									end,
									fun_guild_log:del_data(GuildId),
									remove_guild_member(Uid),
									send_guild_commonality_info_to_sid(Uid,Sid,Seq),
									?error_report(Sid, "guild_dissolve_success", Seq),
									fun_dataCount_update:group_reported(Uid,2, GuildId, "")
								end;
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

%%更改公告
change_notice(Uid, Sid, Text, Seq) ->
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[#guild_member{guild_id=GuildId}] ->
			case get_event_permission(Uid, ?GUILD_EVENT_CHANGE_NAME) of
				true->
					TextLen = length(xmerl_ucs:from_utf8(Text)),
					?debug("TextLen = ~p",[TextLen]),
					if
						TextLen > ?MAX_NOTICE_LEN -> ?error_report(Sid, "notice_word_out", Seq);
						true ->
							case db:dirty_get(guild, GuildId) of
								[Guild = #guild{id = GuildId}] ->
									db:dirty_put(Guild#guild{notice = util:to_binary(Text)}),
									% send_guild_notice_to_sid(Uid, Sid, GuildId, Seq);
									send_guild_commonality_info_to_sid(Uid,Sid,Seq),
									?error_report(Sid, "common_change_succ", Seq);
								_ -> skip
							end
					end;
				_ -> skip
			end;
		_ -> skip
	end.


req_change_banner(Uid, Sid, Seq, NewBanner) ->
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[#guild_member{guild_id=GuildId}] ->
			case get_event_permission(Uid, ?GUILD_EVENT_CHANGE_NAME) of
				true->
					case db:dirty_get(guild, GuildId) of
						[Guild = #guild{id = GuildId}] ->
							db:dirty_put(Guild#guild{banner = NewBanner}),
							send_guild_commonality_info_to_sid(Uid,Sid,Seq),
							?error_report(Sid, "common_change_succ", Seq);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

%% 查看成员具体信息
req_view_member_info(_Uid, Sid, Seq, MemberUid, ClientPanelArg) ->
	case db:dirty_get(guild_member, MemberUid, #guild_member.uid) of
		[#guild_member{guild_id=GuildId, perm=Position, name=UserName}] ->
			List = fun_arena:get_all_on_battled_heros(MemberUid),
			List2 = [util_pt:make_item_base_info_pt(fun_entourage:get_entourage(MemberUid, ItemId)) || {ItemId, _, _} <- List],
			Pt = #pt_guild_view_member_info{
				panel_arg   = ClientPanelArg,
				lv          = util:get_lev_by_uid(MemberUid),
				position    = Position,
				user_name   = UserName,
				guild_name  = get_guild_name(GuildId),
				total_gs    = mod_entourage_property:get_total_gs(MemberUid, [ItemId || {ItemId, _, _} <- List]),
				arena_heros = util_pt:make_on_battle_pt(List),
				heros_infos = List2
			},
			?send(Sid, proto:pack(Pt, Seq));
		_ -> skip
	end.

%%删除公会成员
remove_guild_member(Uid) when erlang:is_integer(Uid)->
	List = db:dirty_get(guild_member,Uid,#guild_member.uid),
	remove_guild_member(List);

remove_guild_member(Member) when erlang:is_record(Member, guild_member)->
	db:dirty_del(guild_member, Member#guild_member.id);

remove_guild_member(MemberList) when is_list(MemberList)->
	lists:foreach(fun(Member)->remove_guild_member(Member) end, MemberList).

put_quit_guild(Uid)->
	Now = util:unixtime(),
	case db:dirty_get(usr, Uid) of
		[Usr|_]->
			db:dirty_put(Usr#usr{quit_guild_time=Now});
		_->skip
	end.

% put_dismiss_guild(Uid)->
% 	Day = util:get_relative_day(?AUTO_REFRESH_TIME),
% 	case db:dirty_get(dismiss_guild, Uid,#dismiss_guild.uid) of
% 		[DismissGuild|_]->
% 			db:dirty_put(DismissGuild#dismiss_guild{day_time=Day});
% 		_->
% 			db:insert(#dismiss_guild{uid=Uid,day_time=Day})
% 	end.

get_dismiss_guild_time(Uid)->
	case db:dirty_get(dismiss_guild, Uid, #dismiss_guild.uid) of
		[#dismiss_guild{day_time=Day}|_]->Day;
		_->0
	end.

check_create_guild_time(Uid)->
	Day = util:get_relative_day(?AUTO_REFRESH_TIME),
	DismissDay = get_dismiss_guild_time(Uid),
	Day > DismissDay.

%%检查变更职职位
check_updata_perm(Uid, TargetFromPerm, TargetToPerm) -> 
	if 
		TargetFromPerm == ?PERM_OFFICIAL andalso TargetToPerm == ?PERM_NORMAL -> %% 罢免官员
			get_event_permission(Uid, ?GUILD_EVENT_DEMOTE_MEMBER);
		TargetFromPerm == ?PERM_OFFICIAL andalso TargetToPerm == ?PERM_PRESIDENT -> %% 转让会长
			get_event_permission(Uid, ?GUILD_EVENT_POINT);
		TargetFromPerm == ?PERM_NORMAL -> %% 任命官员
			get_event_permission(Uid, ?GUILD_EVENT_POINT);
		true -> false
	end.


%%变更职位
updata_guild_perm(Uid,TgtUid,Action,Sid,Seq)->
	case Action of
		1 -> %% 罢免官员
			updata_guild_perm2(Uid,TgtUid,?PERM_NORMAL,Sid,Seq);
		2 -> %% 任命官员
			updata_guild_perm2(Uid,TgtUid,?PERM_OFFICIAL,Sid,Seq);
		3 -> %% 转让会长
			updata_guild_perm2(Uid,TgtUid,?PERM_PRESIDENT,Sid,Seq);
		_ -> 
			?ERROR("client send wrong parameter:~p", [Action])
	end.

updata_guild_perm2(Uid,TgtUid,TgtUpPerm,Sid,Seq) ->
	case get_guild_baseinfo(Uid) of
		{ok, GuildId, _}->
			case get_guild_baseinfo(TgtUid) of
				{ok, GuildId, TgtPerm} -> 
					case check_updata_perm(Uid, TgtPerm, TgtUpPerm) of
						true->
							if 
								TgtUpPerm == ?PERM_PRESIDENT->
									case get_guild_member_info(TgtUid) of
										TgtGuildMember = #guild_member{name = Name} ->
											Rec = TgtGuildMember#guild_member{perm=TgtUpPerm},
											db:dirty_put(Rec),
											case get_guild_member_info(Uid) of
												GuildMember = #guild_member{} ->
													Rec1 = GuildMember#guild_member{perm=?PERM_NORMAL},
													db:dirty_put(Rec1),
													GuildMemberList = get_guild_member_info_by_Menber(Uid, Rec1),
													TgtGuildMemberList = get_guild_member_info_by_Menber(Uid, Rec), 
												  	broadcast_to_members_by_guildid(GuildId, send_guild_member_updata_perm(GuildMemberList++TgtGuildMemberList, Seq)),
													gm_to_members_by_guildid(GuildId,[integer_to_list(150) , util:to_list(Name)]),
													send_guild_to_sid(Uid,Sid,GuildId,[{util_time:unixtime(), ?SUCCESS_GUILD_CHANGE_OWNER, Uid, TgtUid}]),
													fun_dataCount_update:group_reported(Uid, 2, GuildId, Name);
												_ -> skip
											end;
										_ -> skip
									end;
								true ->
									case check_perm_num(GuildId, TgtUpPerm) of
										true->
											case get_guild_member_info(TgtUid) of
												TgtGuildMember = #guild_member{} ->
													Rec = TgtGuildMember#guild_member{perm=TgtUpPerm},
													db:dirty_put(Rec),
													TgtGuildMemberList = get_guild_member_info_by_Menber(Uid, Rec),
													broadcast_to_members_by_guildid(GuildId, send_guild_member_updata_perm(TgtGuildMemberList, Seq)),
													EventLogType = case TgtUpPerm > TgtPerm of
														true -> ?SUCCESS_GUILD_OFFICE_DEMOTE;
														_ -> ?SUCCESS_GUILD_OFFICE_CHANGE
													end,
													send_guild_to_sid(Uid,Sid,GuildId,[{util_time:unixtime(), EventLogType, Uid, TgtUid}]);
												_ -> skip
											end;
										_ -> skip
									end
							end;
						_ -> skip
					end;
				_->skip
			end;
		_ -> skip
	end.

send_guild_member_updata_perm(GuildMemberList,Seq)->
	% id 名字 等级 职务 总贡献 最近在线时间 是否是好友 是否在线
	Fun = fun({MemberId,MemberName,Lev,Perm,Contribution,RecentOnlineTime,FriendsState,OnlineState}) ->		
		#pt_public_guild_member_list{
			contribution=Contribution,friends_state=FriendsState,
			member_id=MemberId,member_name=MemberName,member_post=Perm,
			memberlevel=Lev,online_state=OnlineState,recentOnlineTime=RecentOnlineTime,
			member_vip=fun_vip:get_vip_lev(MemberId),
			member_fighting = fun_property:get_usr_fighting(MemberId)
		}
	end,
	NewGuildList = lists:map(Fun, GuildMemberList),
	Pt2 =#pt_guild_member_info{update_state=1,guild_member_list=NewGuildList},
	proto:pack(Pt2,Seq).

check_perm_num(GuildId,Perm)->
	PermLen = 
		case db:dirty_match(guild_member, #guild_member{guild_id=GuildId,perm=Perm,_='_'}) of
			GuildMember when is_list(GuildMember)->
				length(GuildMember);
			_->0
		end,
	if Perm == ?PERM_OFFICIAL ->
		   PermLen < ?PERM_OFFICIAL_NUM;
	   true->true
	end.

%%检查公会是否退出4小时
check_quit_guild(_Uid)-> true.
	% case db:dirty_get(usr, Uid) of
	% 	[Usr|_]->
	% 		QuitGuildTime = Usr#usr.quit_guild_time,
	% 		QuitGuildTime + ?REQ_QUIT_GUILD =< util:unixtime();
	% 	_->false
	% end.

%%向工会所有人发消息
broadcast_to_members_by_guildid(GuildId, Msg) ->
	Members = get_members(GuildId),
	F = fun(#guild_member{uid=MemberId}) ->
		case db:dirty_get(ply, MemberId) of
			[#ply{sid=TgtSid}] -> 
				?send(TgtSid, Msg);
			_ -> skip
		end
	end,
	lists:foreach(F, Members).


%%向工会所有人发系统消息
gm_to_members_by_guildid(GuildId, Msg) ->
	Members = get_members(GuildId),
	F = fun(#guild_member{uid=MemberId}) ->
		mod_msg:handle_to_chat_server({send_private_system_msg, MemberId, Msg})
	end,
	lists:foreach(F, Members).



%%获取公会等级
get_guild_lev(GuildId)->
	case db:dirty_get(guild, GuildId) of
		[#guild{level = Level}]-> Level;
		_ -> 0
	end.

%%获取公会会长名字
get_guild_president_name(GuildId)->
	List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
	case lists:keyfind(?PERM_PRESIDENT, #guild_member.perm, List) of
		#guild_member{name = Name} -> util:to_list(Name);
		_ -> ""
	end.

%%获取公会会长id
get_guild_president_uid(GuildId)->
	List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
	case lists:keyfind(?PERM_PRESIDENT, #guild_member.perm, List) of
		#guild_member{uid = Uid} -> Uid;
		_ -> 0
	end.

%%获取公会成员
get_guild_member_info(Uid)->
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[Member|_]->Member;
		_->[]
	end.
%%获取公会成员列表
get_guild_member_info_list(GuildId)->
	case db:dirty_get(guild_member, GuildId, #guild_member.guild_id)of
		MemberList when is_list(MemberList) andalso length(MemberList) > 0 ->
			Fun = fun(Member,Acc)->
						  lists:append(Acc, get_guild_member_info_by_Menber(Member#guild_member.uid, Member)) 
				  end,
			lists:foldl(Fun, [], MemberList);
		_->[]
	end.
%%获取工会成员uid列表
get_guild_member_uid_list(GuildId) ->
	case db:dirty_get(guild_member, GuildId, #guild_member.guild_id)of
		MemberList when is_list(MemberList) andalso length(MemberList) > 0 ->
			Fun = fun(Member,Acc)-> lists:append(Acc, [Member#guild_member.uid]) end,
			lists:foldl(Fun, [], MemberList);
		_ -> []
	end.	

add_guild_resource(GuildId,GuildResNum)->
	case db:dirty_get(guild, GuildId) of
		[Guild = #guild{total_honor=Total_honor}|_]->
			GuildNum = Guild#guild.resource,
			case db:dirty_get(guild_member, GuildId,#guild_member.guild_id) of
				[GuildMember]->
						Integral=GuildMember#guild_member.usr_integral,
						db:dirty_put(GuildMember#guild_member{usr_integral =GuildResNum + Integral});
				_->skip
			end,
			db:dirty_put(Guild#guild{resource=GuildResNum + GuildNum,total_honor=Total_honor+GuildResNum});
		_->skip
	end.
%%请求公会建筑列表
req_guild_building_list(Uid,Sid,Seq)->
	case get_guild_baseinfo(Uid) of
		{ok, _GuildId, _} ->
			case db:dirty_get(guild_building, Uid, #guild_building.uid) of
				BuildingList when is_list(BuildingList)->
					NewBuildingList = lists:foldl(fun(Building,Acc)->Acc++[{Building#guild_building.type,Building#guild_building.level,Building#guild_building.exp}] end, [], BuildingList),
					send_guild_building(Sid, NewBuildingList, Seq);
				_->skip
			end;
		_->skip
	end.
					
			
%%公会建筑升级
req_add_guild_building_exp(_Uid,_Sid,_BuildingId,GuildResNum,_Seq) when GuildResNum =< 0 -> skip;
req_add_guild_building_exp(Uid,Sid,BuildingId,GuildResNum,Seq) ->?debug("GuildResNum=~p",[GuildResNum]),
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[Guild_member = #guild_member{guild_id =GuildId,contribution= Resource}|_] ->?debug("Resource=~p",[Resource]),
%% 			case get_event_permission(Uid, Perm) of
%% 				true->
					case db:dirty_get(guild, GuildId) of
						[Guild] ->							
							GuildLev = Guild#guild.level,
							if Resource >= GuildResNum ->
								   case db:dirty_get(guild_building, Uid, #guild_building.uid) of
									   L when length(L) > 0 ->
										   case lists:keyfind(BuildingId, #guild_building.type, L) of
											   GuildBuilding = #guild_building{} ->
												   Lev = GuildBuilding#guild_building.level,
												   Exp = GuildBuilding#guild_building.exp,
												   {NLev,NExp,_ReturnExp} = check_guild_building_exp(Sid,BuildingId,GuildLev,Lev, Exp+ GuildResNum),
												   DoBattle = if
																  NLev == Lev -> normal;
																  NLev>Lev->up;
																  true -> false
															  end,
												   NGuildBuilding = GuildBuilding#guild_building{level = NLev,exp=NExp},
												   db:dirty_put(NGuildBuilding),
												   db:dirty_put(Guild_member#guild_member{contribution=Resource - GuildResNum }),
												   send_guild_building(Sid, [{BuildingId,NLev,NExp}],Seq),
												   send_guild_all_info_to_sid(Uid),
												   ?error_report(Sid,"guild_build_upgrade_success"),
												   case DoBattle of
													   up ->send_agent_guild_prop(Uid);	
													   _ -> skip	
												   end;
											   _ -> ok
										   end;
									   _ -> skip
								   end;
							   true->?error_report(Sid,"guild_build_need_res")
							end;
						_->skip
					end;
%% 				_->skip
%% 			end;
		_->skip
	end.

check_guild_building_exp(Sid,BuildingId,GuildLev,Lev,Exp)->
	case data_guild_update_add_prop:get_data(BuildingId,Lev) of
		#st_data_guild_update_add_prop{needexp = MaxExp} -> 
				case GuildLev of
					NewGuildLev when is_number(NewGuildLev) andalso NewGuildLev > Lev andalso 	MaxExp > Exp ->{Lev,Exp,0};
					NewGuildLev when is_number(NewGuildLev) andalso NewGuildLev  > Lev andalso 	MaxExp =< Exp ->check_guild_building_exp(Sid,BuildingId,GuildLev,Lev + 1,Exp - MaxExp);
					NewGuildLev when is_number(NewGuildLev) andalso NewGuildLev  == Lev andalso MaxExp >= Exp ->{Lev,Exp,0};
					NewGuildLev when is_number(NewGuildLev) andalso NewGuildLev  == Lev andalso MaxExp < Exp ->{Lev,MaxExp,Exp - MaxExp};
					_->{GuildLev,MaxExp,Exp}
				end;
		_ -> 
			case data_guild_update_add_prop:get_data(BuildingId,Lev) of
				#st_data_guild_update_add_prop{needexp = MaxExp} -> 
					{Lev,MaxExp,Exp};
				_->{0,0,0}
			end
	end.

add_guild_exp(_Uid,_Sid,GuildId,Exp)->
	case db:dirty_get(guild, GuildId) of
		[Guild|_] -> 
			Lev = Guild#guild.level,
			{NLev,NExp} = check_exp(Lev,Guild#guild.exp + Exp),

			{NLev1,NExp1}=if  NLev>=?MAX_PLAYER_LEV->{?MAX_PLAYER_LEV,0};
							  true->{NLev,NExp}			
						  end,
			NGuild = Guild#guild{level = NLev1,exp=NExp1},
			db:dirty_put(NGuild);
		_ -> ok
	end.

check_exp(Lev,Exp) -> 
	case data_guild_level:get_data(Lev) of
		#st_data_guild_level{experience = MaxExp} -> 
			if
				MaxExp > Exp ->{Lev,Exp};
				true ->check_exp(Lev + 1,Exp - MaxExp)
			end;
		_R ->
			case data_guild_level:get_data(Lev-1) of
				#st_data_guild_level{experience = MaxExp} -> {Lev-1,MaxExp};
				_->{0,0}
			end
	end.

%%公会建筑物属性更新
guild_building_prop(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,_GuildId,_}->
			case db:dirty_get(guild_building, Uid, #guild_building.uid) of
				List when is_list(List) andalso length(List) >0 ->
					Fun = fun(GuildBuilding,Acc)->
								  lists:append(Acc,[get_data_building_prop(GuildBuilding#guild_building.type, GuildBuilding#guild_building.level)])
						  end,
					lists:foldl(Fun, [], List);
				_->[]
			end;
		_->[]
	end.

get_data_building_prop(BuildingId,Lev)->
	case data_guild_update_add_prop:get_data(BuildingId,Lev) of
		#st_data_guild_update_add_prop{propid=Propid,propVal=PropVal} -> 
			{Propid,PropVal};
		_ -> {0,0}
	end.
						

%%检测是否有公会
has_guild(Uid) ->
	case get_guild_baseinfo(Uid) of
		{ok, _, _} -> true;
		error -> true;
		_ -> false
	end.

%%获取公会基础详情
get_guild_baseinfo(Uid) ->
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[#guild_member{guild_id = GuildId, perm = Perm}] ->
			if
				Perm =/= ?PERM_NULL -> {ok, GuildId, Perm};
				true -> false
			end;
		[] -> false;
		_ -> error
	end.

%%添加公会成员
add_guild_member(Member) ->
	NewId =  case Member#guild_member.id of
		undefined ->
			case db:insert(Member) of
				[#guild_member{id=Id}] -> Id;
				_ ->
					?log_warning("insert guild member error,member=~p", [Member]),
					error
			end;
		_ ->
			db:dirty_put(Member),
			Member#guild_member.id
	end,
	?debug("NewId:~p",[NewId]),
	case Member#guild_member.perm of
		?PERM_NULL ->
			setup_req_timer(NewId, ?REQ_TIMEOUT);
		_ ->
			skip
	end.

%%获取公会总战力
get_guild_fighting(GuildId) ->
	List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
	Fun = fun(#guild_member{uid = Uid},Acc) ->
		Acc + fun_property:get_usr_fighting(Uid)
	end,
	lists:foldl(Fun, 0, List). 

%%公会人数
get_member_amount(GuildId) ->
	length(get_members(GuildId)).

%%获取该公会成员列表
get_members(GuildId)->
	case db:dirty_get(guild_member, GuildId, #guild_member.guild_id) of
		GuildMemberList when is_list(GuildMemberList)->GuildMemberList;
		_->[]
	end.

%%获取该公会的最大人数
get_max_member_amount(GuildId) ->
	case db:dirty_get(guild, GuildId) of
		[Guild|_]->
			Level = Guild#guild.level,
			data_guild:get_max_member(Level);
		_ -> 0
	end.

%%设置请求计时器
setup_req_timer(Id, Timeout) ->
	TimerRef = erlang:start_timer(Timeout*1000, self(), {?MODULE, on_request_timeout, Id}),
	Dict = get(request_info),
	case dict:find(Id, Dict) of
		{ok, Ref} ->
			erlang:cancel_timer(Ref);
		_ ->
			skip
	end,
	NewDict = dict:store(Id, TimerRef, Dict),
	put(request_info, NewDict).

%%获取玩家权限
get_usr_perm(Uid) ->
	case get_guild_baseinfo(Uid) of
		{ok, _, Perm}-> Perm;
		_ -> 0
	end.

%%获取事件的权限
get_event_permission(Uid,Event)->
	case get_guild_baseinfo(Uid) of
		{ok, _, Perm}->
			data_guild:is_permit(Perm,Event) == 1;
		_->false
	end.

get_event_permission(_Uid,Event,Perm)->
	data_guild:is_permit(Perm,Event) == 1.


req_guild_member_list(Uid,Sid,Seq)->
	MemberList = guild_member_list(Uid),
	Fun=fun(Menber,Acc)->
				List = get_guild_member_info_by_Menber(Uid, Menber),
				lists:append(Acc, List)
		end,
	NewMemberList = lists:foldl(Fun, [], MemberList),
	send_guild_member_list_to_sid(Uid,Sid,NewMemberList,Seq).
%%获取一个人的成员详细信息
get_guild_member_info_by_Menber(_Uid,Member)->
	Lev = Member#guild_member.level,
	Contribution = Member#guild_member.contribution,
	LastLoginTime =  util:get_last_logout_time_by_uid(Member#guild_member.uid),
	%%公会是否为好友判断去掉，改为默认
	RelationState = 1,
	OnlineState = util:get_usr_online(Member#guild_member.uid),
	[{Member#guild_member.uid,Member#guild_member.name,Lev+util:get_paragon_level_by_uid(Member#guild_member.uid),Member#guild_member.perm,Contribution,LastLoginTime,RelationState,OnlineState}].


put_guild_member_last_login_time(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_match(guild_member, #guild_member{guild_id=GuildId,uid=Uid,_='_'}) of
				[Member|_]->
					db:dirty_put(Member#guild_member{last_login_time=util:unixtime()});
				_->skip
			end;
		_->skip
	end.
%%获取公会成员列表
guild_member_list(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			get_members(GuildId);
		_->[]
	end.
req_guild_apply_for_member_list(Sid,Uid,Seq)->
	NotGuildMemberList =  get_guild_req_join_list(Uid),
	send_members_entry_to_sid(Sid, Seq, NotGuildMemberList).

%%退出工会
quit_guild_update_ranklist(_Uid)-> skip.

%%添加工会
add_guild_update_ranklist(_Uid,_GuildName) -> skip.

update_ranklist(_GuildId) -> skip.

updata_uid_ranklist(_Uid,_GuildName) -> skip.

%%以捐献次数
get_usr_donate_time(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId, _}->
			case db:dirty_match(guild_member,#guild_member{uid=Uid,guild_id=GuildId,_='_'}) of
				[GuildMemberm|_]->
					{GuildMemberm#guild_member.contribution_time, GuildMemberm#guild_member.contribution};
				_->{0, 0}
			end;
		_->{0, 0}
	end.
put_usr_donate_time(Uid,GuildId,GuildResNum,Num)->
	case db:dirty_match(guild_member,#guild_member{uid=Uid,guild_id=GuildId,_='_'}) of
		[GuildMemberm = #guild_member{contribution_time=ContributionTime,contribution=Contribution,total_honor_day=TotalHonorDay}|_]->
			db:dirty_put(GuildMemberm#guild_member{contribution_time=ContributionTime+Num,total_honor_day=TotalHonorDay+GuildResNum,contribution=Contribution+GuildResNum});
		_->skip
	end.

guild_name_by_uid(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_get(guild, GuildId) of
				[Guild|_]-> util:to_list(Guild#guild.name);
				_-> ""
			end;
		_->""
	end.

%%发送所有公会列表
send_all_guild_list_to_sid(_Uid,Sid,GuildList,State,Seq)->
	Fun = fun(Info) ->
		make_guild_show_pt(Info)
	end,
	NewGuildList = lists:map(Fun, GuildList),
	Pt3 = #pt_all_guild_list_info{guild_state=State,guild_info_list=NewGuildList},
	?send(Sid,proto:pack(Pt3,Seq)).

make_guild_show_pt({GuildId,GuildName,_Camp,_PresidentName,MemberAmount,GuildLevel,ReqState,_Ranking,_TotalHonor,Banner}) ->
	#pt_public_guild_info_list{
		guild_id=GuildId,
		guild_level=GuildLevel,
		guild_name=GuildName,
		member_amount=MemberAmount,
		president_name="",
		req_state=ReqState,
		banner=Banner
	}.

%%发送公会成员列表
send_guild_member_list_to_sid(_Uid,Sid,GuildMemberList,Seq)->
	send_guild_member_list_to_sid(_Uid,Sid,GuildMemberList,Seq,0).
send_guild_member_list_to_sid(_Uid,Sid,GuildMemberList,Seq,UpdateState)->
	% id 名字 等级 职务 总贡献 最近在线时间 是否是好友 是否在线
	Fun = fun({MemberId,MemberName,Lev,Perm,Contribution,RecentOnlineTime,FriendsState,OnlineState}) ->		
		#pt_public_guild_member_list{
			contribution=Contribution,friends_state=FriendsState,member_id=MemberId,member_name=MemberName,
			member_post=Perm,memberlevel=Lev,online_state=OnlineState,recentOnlineTime=RecentOnlineTime,
			member_vip=fun_vip:get_vip_lev(MemberId),
			member_fighting = fun_property:get_usr_fighting(MemberId)
		}
	end,
	NewGuildList = lists:map(Fun, GuildMemberList),
	Pt2 =#pt_guild_member_info{update_state=UpdateState,guild_member_list=NewGuildList},
	?send(Sid,proto:pack(Pt2,Seq)).

%%发送公告
send_guild_notice_to_sid(Uid,Sid,GuildID,Seq)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_get(guild, GuildId) of
				[Guild|_]->
					Notice = Guild#guild.notice,
					Pt1 = #pt_guild_notice{data=Notice},
					?send(Sid,proto:pack(Pt1,Seq));
				_ -> skip
			end;
		_ ->
			case db:dirty_get(guild, GuildID) of
				[Guild|_]->
					Notice = Guild#guild.notice,
					Pt1 = #pt_guild_notice{data=Notice},
					?send(Sid,proto:pack(Pt1,Seq));
				_ -> skip
			end
	end.

%%发送公会公共信息
send_guild_commonality_info_to_sid(Uid,Sid,Seq)->
	%% 公会ID 公会名称 会长名字 公会排名 等级 人数 公会总资金 公会经验 捐献次数 公会战力
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_get(guild, GuildId) of
				[Guild|_] when Guild#guild.dissolve_state == 0 ->
					send_guild_info_to_client(Uid, Guild, Sid, Seq);
				_->
					Pt2 = #pt_guild_commonality{
						guild_id=0,member_amount=0,lev=0,
						guild_name= "",donation_times=0,guild_exp=0
					},
					?send(Sid,proto:pack(Pt2,Seq))
			end;
		_->
			Pt2 = #pt_guild_commonality{
				guild_id=0,member_amount=0,lev=0,
				guild_name= "",donation_times=0,guild_exp=0
			},
			?send(Sid,proto:pack(Pt2,Seq))
	end.

send_guild_info_to_client(Uid, Guild, Sid, Seq) ->
	GuildId        = Guild#guild.id,
	MemberAmount   = get_member_amount(GuildId),
	{DonationTimes, Donation} = get_usr_donate_time(Uid),
	Pt2 = #pt_guild_commonality{
		guild_id       = GuildId,
		banner         = Guild#guild.banner,
		member_amount  = MemberAmount,
		lev            = Guild#guild.level,
		guild_name     = util:to_list(Guild#guild.name),
		donation_times = DonationTimes,
		my_donation    = Donation,
		guild_exp      = Guild#guild.exp,
		guild_state    = Guild#guild.state,
		notice = Guild#guild.notice
	},
	?send(Sid,proto:pack(Pt2,Seq)).


%%发送公会公共信息
send_guild_all_info_to_sid(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			Members = get_members(GuildId),
			[Guild | _] = db:dirty_get(guild, GuildId),
			F = fun(#guild_member{uid=MemberId}) ->
				case db:dirty_get(ply, MemberId) of
					[#ply{sid=TgtSid}] -> 
						send_guild_info_to_client(MemberId, Guild, TgtSid, 0);
					_ -> skip
				end
			end,
			lists:foreach(F, Members);
		_->skip
	end.

req_guild_log(Uid,Sid,_Seq) ->
	case get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			Fun = fun(#{uid := TUid, be_uid := TBUid, type := Type, time := Time}) ->
				{Time,Type,TUid,TBUid}
			end,
			NewList = lists:map(Fun, fun_guild_log:get_log(GuildId)),
			send_guild_to_sid(Uid,Sid,GuildId,NewList,?ALL_GUILD_LOG);
		_ -> skip
	end.

%%返回客户端成功操作
send_guild_to_sid(Uid,Sid,GuildId,List)->
	send_guild_to_sid(Uid,Sid,GuildId,List,?PART_GUILD_LOG).
send_guild_to_sid(_Uid,_Sid,GuildId,List,Type)->
	case Type of
		?ALL_GUILD_LOG -> skip;
		?PART_GUILD_LOG ->
			send_guild_operation(List),
			fun_guild_log:add_log(GuildId, List)
	end,
	Fun = fun({Time,ID,TUid,BTUid}) ->
		Name = case db:dirty_get(usr, TUid) of
			[] -> util:to_list(TUid);
			[#usr{name = Name1}] -> Name1
		end,
		BName = case db:dirty_get(usr, BTUid) of
			[] -> util:to_list(BTUid);
			[#usr{name = BName1}] -> BName1
		end,
		#pt_public_guild_operation_list{time = Time, type = ID, be_name = BName, name = Name}
	end,
	NewSuccessList = lists:map(Fun, List),
	Pt2 = #pt_guild_succeed{type = Type, guild_operation_list = NewSuccessList},
	broadcast_to_members_by_guildid(GuildId, proto:pack(Pt2)).

send_guild_operation(List) ->
	Fun = fun({_,Type,Uid,_}) ->
		case db:dirty_get(ply, Uid) of
			[#ply{sid = Sid}] ->
				Pt = #pt_guild_operation{operation_type=Type},
				?send(Sid, proto:pack(Pt));
			_ -> skip
		end
	end,
	lists:foreach(Fun, List).

%%邀请加入公会
send_invite_join_guild_to_sid(Sid,Name,GuildName)->
	send_invite_join_guild_to_sid(Sid,0,Name,GuildName).
send_invite_join_guild_to_sid(Sid,Seq,Name,GuildName)->
	Pt2 = #pt_invite_join_guild{guild_name=GuildName,usr_name=Name},
	?send(Sid,proto:pack(Pt2,Seq)).

%%新成员验证列表
send_members_entry_to_sid(Sid,Seq,List)->
	Fun = fun({Uid,Name,Lev,Prof}) ->		
		#pt_public_guild_members_entry_list{
			lev=Lev,name=Name,prof=Prof,uid=Uid,
			fighting=fun_property:get_usr_fighting(Uid)
		}
	end,
	NewSuccessList = lists:map(Fun, List),
	Pt2 = #pt_members_entry{guild_members_entry_list=NewSuccessList},
	?send(Sid,proto:pack(Pt2,Seq)).


%%公会建筑
send_guild_building(Sid,List,Seq)->
	%%科技：id �等级 ，当前经验�
	Fun = fun({Id,Lev,Exp}) ->		
		#pt_public_guild_building_list{building_exp=Exp,building_id=Id,building_lev=Lev}		  
	end,
	BuildingList = lists:map(Fun, List),
	Pt2 = #pt_guild_building_list{guild_building_list=BuildingList},
	?send(Sid,proto:pack(Pt2,Seq)).


send_guild_name(Uid,_GuildId,Name)->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid,scene_hid=SceneHid}|_]->
			if SceneHid =/=0->
				   Pt1 = #pt_guild_name{guild_name=Name},
				   ?send(Sid,proto:pack(Pt1));
			   true->?log_trace("----send guild name scene scene_hid == 0-----")
			end;
		_->skip
	end.

send_guild_guild_member_verify(GuildId)->
	Members = get_members(GuildId),
	F = fun(#guild_member{uid=MemberId}) ->
		case get_event_permission(MemberId, ?GUILD_EVENT_APPROVAL) of
			true -> true;
			_ -> false
		end			
	end,
	PermissionMembers=lists:filter(F, Members),
	F1 = fun(#guild_member{uid=MemberId}) ->
		case db:dirty_get(ply, MemberId) of
			[#ply{sid=TgtSid}] -> 
				req_guild_apply_for_member_list(TgtSid,MemberId,0);
				% Pt1 = #pt_guild_member_verify{},
				% ?send(TgtSid, proto:pack(Pt1));
			_ -> skip
		end
	end,
	lists:foreach(F1, PermissionMembers).

gm(Uid,Num)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			add_guild_resource(GuildId, Num);
		_->skip
	end.

send_agent_guild_prop(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			Members = get_members(GuildId),
			F = fun(#guild_member{uid=MemberId}) ->
						case db:dirty_get(ply, MemberId) of
							[#ply{agent_hid=AgentHid}] ->
								gen_server:cast(AgentHid, {guild_prop,MemberId});
							_ -> skip
						end
				end,
			lists:foreach(F, Members);
		_->skip
	end.

auto_refresh_time({Uid,Sid}) ->
	TadayTime=util:get_relative_day(?AUTO_REFRESH_TIME),
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_match(guild_member, #guild_member{uid=Uid,guild_id=GuildId,_='_'}) of
				[GuildMember=#guild_member{contribution_day=ContributionDay}] ->
					if TadayTime > ContributionDay ->
							db:dirty_put(GuildMember#guild_member{contribution_day=TadayTime,total_honor_day=0,contribution_time=0,
																  salary_get_state=0});
					   true->skip
					end,
					erlang:start_timer(?AUTO_REFRESH_TIME_LONG, self(), {?MODULE, auto_refresh_time, {Uid,Sid}});
				_->
					erlang:start_timer(?AUTO_REFRESH_TIME_LONG, self(), {?MODULE, auto_refresh_time, {Uid,Sid}})
			end;
		_->erlang:start_timer(?AUTO_REFRESH_TIME_LONG, self(), {?MODULE, auto_refresh_time, {Uid,Sid}})
	end.

update_guild_member_total_honor(_Uid,_HonorNum)->ok.

%%获取公会的荣誉总值
get_guild_total_honor(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_get(guild, GuildId) of
				[#guild{total_honor=TotalHonor}|_] ->TotalHonor;
				_->0
			end;
		_->0
	end.

%%获取公会当天的荣誉总值
get_guild_day_total_honor(Uid)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			TadayTime=util:get_relative_day(?AUTO_REFRESH_TIME),
			Members = get_members(GuildId),
			F = fun(#guild_member{total_honor_day=TotalHonorDay,total_honor_num=TotalHonorNum},Acc) ->
						if TotalHonorDay == TadayTime->Acc+TotalHonorNum;
						   true->Acc
						end
				end,
			lists:foldl(F,0,Members);
		_->skip
	end.

add_apply_for_guild(Uid,GuildId,Lev,Name,Times,Prof)->
	List = db:dirty_get(apply_for_guild,GuildId,#apply_for_guild.guild_id),
	case lists:keyfind(Uid, #apply_for_guild.uid, List) of
		#apply_for_guild{} -> skip;
		_ -> db:dirty_put(#apply_for_guild{id=get_apply_for_guild_id(),guild_id=GuildId,level=Lev,name=Name,prof=Prof,times=Times,uid=Uid})
	end.

del_apply_for_by_guild(GuildId)->
	case db:dirty_get(apply_for_guild,GuildId,#apply_for_guild.guild_id) of
		ApplyFor when is_list(ApplyFor) andalso length(ApplyFor) >0 ->
			lists:foreach(fun(#apply_for_guild{id=Id})->db:dirty_del(apply_for_guild, Id) end, ApplyFor);
		_ -> skip
	end.
%%获取申请公会的数量
get_apply_for_guild_num(Uid)->
	length(db:dirty_get(apply_for_guild, Uid, #apply_for_guild.uid)).

%%判断该公会是否已申请
judge_already_apply_for_guild(Uid,GuildId)->
	List = db:dirty_get(apply_for_guild, GuildId, #apply_for_guild.guild_id),
	case lists:keyfind(Uid, #apply_for_guild.uid, List) of
		false -> ?HAS_NOT_REQ;
		_ -> ?HAS_REQ
	end.

%%删除申请公会
del_apply_for_guild_time() ->
	TadayTime=util:get_relative_day(?AUTO_REFRESH_TIME),
	case db:dirty_match(apply_for_guild, #apply_for_guild{_='_'}) of 
		ApplyForGuildList when is_list(ApplyForGuildList)->  
			Fun = fun(ApplyForGuild)->
						 ApplyForGuildTimes = ApplyForGuild#apply_for_guild.times,
						 if TadayTime > ApplyForGuildTimes->
								db:dirty_del(apply_for_guild, ApplyForGuild#apply_for_guild.id);
							true->skip
						 end
				  end,
			lists:foreach(Fun, ApplyForGuildList),
			erlang:start_timer(?AUTO_REFRESH_TIME_LONG, self(), {?MODULE, del_apply_for_guild_time});
		_->
			erlang:start_timer(?AUTO_REFRESH_TIME_LONG, self(), {?MODULE, del_apply_for_guild_time})
	end.
del_apply_for_guild	(Uid)->
	case db:dirty_get(apply_for_guild, Uid, #apply_for_guild.uid) of  
		ApplyForGuildList when is_list(ApplyForGuildList)->  
			Fun = fun(#apply_for_guild{id=Id})->
				db:dirty_del(apply_for_guild, Id)
			end,
			lists:foreach(Fun, ApplyForGuildList);
		_->skip
	end.

get_apply_for_guild_id()->
	case get(apply_for_guild_id) of
		?UNDEFINED->
			put(apply_for_guild_id,2),
			1;
		ApplyGuildId when is_number(ApplyGuildId)->
			put(apply_for_guild_id,ApplyGuildId+1),
			ApplyGuildId
	end.

updata_guild_member_lev(Uid,Lev)->
	case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			case db:dirty_match(guild_member, #guild_member{uid=Uid,guild_id=GuildId,_='_'}) of
				[GuildMember|_] ->
					db:dirty_put(GuildMember#guild_member{level=Lev});
				_->skip
			end;
		_->skip
	end.

get_guild_member_post(Uid,Sid)->
	Post = case get_guild_baseinfo(Uid) of
		{ok,GuildId,_}->
			List = db:dirty_get(guild_member, GuildId, #guild_member.guild_id),
			case lists:keyfind(Uid, #guild_member.uid, List) of
				#guild_member{perm=Perm} -> Perm;
				_ -> 0
			end;
		_ -> 0
	end,
	send_guild_post(Sid, Post),
	ok.
	

send_guild_post(Sid,Post)->
	Pt1 = #pt_guild_post{post_id=Post},
	?send(Sid,proto:pack(Pt1)).	


updata_apply_for_name(Uid,Name)->
	case db:dirty_match(apply_for_guild, #apply_for_guild{uid=Uid,_='_'}) of
		ApplyForGuild when is_list(ApplyForGuild)->
			Fun = fun(ApplyFor)->
						  db:dirty_put(ApplyFor#apply_for_guild{name=Name})
				  end,
			lists:foreach(Fun, ApplyForGuild);
		_->skip
	end.

%%发送魂石界面信息
send_hunstone_info(Uid, Sid, Seq)->
	case get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			case db:dirty_match(guild_stone, #guild_stone{guild=GuildId, _='_'}) of
				List when List =/=[] ->
					My_type = case db:dirty_get(guild_stone, Uid, #guild_stone.uid) of
								  [#guild_stone{req_stone=My}] ->My;
								  _->0
							  end,
					Fun = fun(#guild_stone{get_num=Num, req_stone=Type, uid=Target_id}) ->
								  #pt_public_guild_stone_list{type=Type, target_name=util:get_name_by_uid(Target_id), num=Num, target_id=Target_id}	end,
					Info = lists:map(Fun, List),
					Ptm = #pt_req_guild_stone_info{type=0, can_get=My_type, stone_list=Info},
					?send(Sid, proto:pack(Ptm, Seq));
				_->skip
			end;
		_->skip
	end.

%%请求获赠魂石
req_get_hunstone(Uid, Sid, Seq, Type)->
	case get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			All_Stone = data_entourage:get_all_soul_id(),
			case lists:member(Type, All_Stone) of
				true ->
					case db:dirty_get(guild_stone, Uid, #guild_stone.uid) of
						[] ->
							db:insert(#guild_stone{guild=GuildId, uid=Uid, req_stone=Type}),
							Info = #pt_public_guild_stone_list{type=Type, target_name=util:get_name_by_uid(Uid), num=0, target_id=Uid},
							Ptm = #pt_req_guild_stone_info{type=1, can_get=Type, stone_list=[Info]},
							?send(Sid, proto:pack(Ptm, Seq));
						_->skip
					end;
				_->skip
			end;
		_->skip
	end.

%%零点清空魂石信息
del_all_guild_stone_info()->
	case	db:dirty_match(guild_stone, #guild_stone{_='_'}) of
		List when List =/=[] ->
			Fun = fun(#guild_stone{id=ID})->
						  db:dirty_del(guild_stone, ID)	end,
			lists:map(Fun, List);
		_->skip
	end.

%%agent
handle({donation_hunstone, Uid, Sid, SpendItems, AddItems, Seq, Target_id, Type, Info, Num})->
	SuccCallBack = fun()->
	   Name = util:get_name_by_uid(Uid),
	   mod_mail_new:sys_send_personal_mail(Target_id, "魂石获赠", "玩家" ++ Name ++"向您赠送魂石", [{Type,1}], 7),
	   mod_msg:handle_to_agnetmng(?MODULE, {donation_hunstone_succ, Uid, Sid, Seq, Info, Num}),
	   fun_task_count:process_count_event(guild_donation_hunstone, {0, 0, 1}, Uid, Sid)	
	end,
	fun_item_api:check_and_add_items(Uid, Sid, SpendItems, AddItems, SuccCallBack, undefined);

%%agent_mng
handle({check_error_data, Uid, _Sid}) ->
	quit_guild_update_ranklist(Uid),
	send_guild_name(Uid,0, ""),
	remove_guild_member(Uid),
	send_guild_all_info_to_sid(Uid),
	fun_agent_mng:agent_msg_by_pid(Uid,{uodata_property,Uid});

handle({donation_hunstone_succ, Uid, Sid, Seq, Info, Num})->
	db:dirty_put(Info#guild_stone{get_num=Num+1}),
	send_hunstone_info(Uid, Sid, Seq);

handle(Msg) -> ?debug("--------------error=~p",[Msg]).


%% 现在是花钱改名
reset_guild_name(Uid,Sid,ItemType,GuildName,Seq) ->
	case db:dirty_get(ply, Uid) of
		[#ply{agent_hid=AgentHid}] ->
			case get_guild_baseinfo(Uid) of
				{ok, GuildId, _} ->
					BinGuildName = util:to_binary(GuildName),
					case db:dirty_get(guild, GuildId) of
						[Guild = #guild{name = OldName}]->
							case BinGuildName == OldName of
								true -> skip;
								_ ->
									GuildNameLen = length(xmerl_ucs:from_utf8(GuildName)),
									if
										GuildNameLen > ?MAX_GUILD_NAME_LEN orelse GuildNameLen < ?MIN_GUILD_NAME_LEN ->
											?error_report(Sid,"guild_error_name",Seq);%%公会名字不合规范
										true ->	
											case tool:check_str(util:to_list(GuildName)) of
												true ->
													case db:dirty_get(guild, BinGuildName, #guild.name) of
														[] -> mod_msg:send_to_agent(AgentHid, {change_guild_name,Uid,Sid,ItemType,Guild,GuildName,BinGuildName,Seq});
														_ -> ?error_report(Sid, "guild_name_exist",Seq)%%已经有人用了这个公会名字
													end;
												_ -> ?error_report(Sid, "guild_error_name",Seq)%%名字不合规范
											end
									end
							end;
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

change_guild_name_help({Uid,Sid,_ItemType,Guild,GuildName,BinGuildName,Seq}) ->
	SpendItems = [{?ITEM_WAY_CHANGE_GUILD_NAME,?RESOUCE_COIN_NUM,util:get_data_para_num(17)}],
	Succ = fun() ->
		mod_msg:send_to_agnetmng({change_guild_name_succ,Uid,Sid,Guild,GuildName,BinGuildName,Seq})
	end,
	fun_item_api:check_and_add_items(Uid,Sid,SpendItems,[],Succ,undefined).

change_guild_name_succ({Uid,Sid,Guild,GuildName,BinGuildName,Seq}) ->
	Id = Guild#guild.id,
	db:dirty_put(Guild#guild{name=BinGuildName}),
	send_guild_all_info_to_sid(Uid),
	send_guild_to_sid(Uid,Sid,Id,[{util_time:unixtime(), ?SUCCESS_GUILD_CHANGE_NAME, Uid, 0}]),
	send_guild_name(Uid,Id, BinGuildName),
	fun_dataCount_update:group_reported(Uid, 0, Id, GuildName),
	?error_report(Sid,"common_change_succ",Seq).

update_guild_member(Uid, Name) ->
	case db:dirty_get(guild_member, Uid, #guild_member.uid) of
		[Rec = #guild_member{}] ->
			NewRec = Rec#guild_member{name = util:to_binary(Name)},
			db:dirty_put(NewRec);
		_ -> skip
	end.

req_guild_impeach_president(_Sid, _Uid, _Seq) -> ok.

					
	
req_guild_impeach_president_vote(_Sid, _Uid, _Seq, _Sort) -> ok.
	
del_guild_impeach_president(_Uid) -> ok.
	



get_role_guild_id(Uid) ->
	case get_guild_baseinfo(Uid) of
		{ok, GuildId, _} -> GuildId;
		_ -> 0
	end.


req_recommend_guilds(Uid, Sid, Seq) ->
	GuildList = get_recommend_guilds(Uid, db_api:dirty_all_keys(guild), 3, []),
	Fun = fun(Info) ->
		make_guild_show_pt(Info)
	end,
	Pt3 = #pt_recommend_guild_list{guild_info_list=lists:map(Fun, GuildList)},
	?send(Sid,proto:pack(Pt3,Seq)).

get_recommend_guilds(_Uid, [], _Num, Acc) -> 
	Acc; 
get_recommend_guilds(Uid, FromIdList, Num, Acc) when Num > 0 -> 
	{Id, LeftIdList} = util_list:rand_taken(FromIdList),
	case db_api:dirty_read(guild, Id) of
		[Rec = #guild{dissolve_state=0}] ->
			MaxMemberSize = data_guild:get_max_member(Rec#guild.level),
			MemberSize = get_member_amount(Id),
			case MaxMemberSize > MemberSize of
				true -> 
					GuildInfo = get_guild_show_info(Uid, Rec),
					get_recommend_guilds(Uid, LeftIdList, Num - 1, [GuildInfo | Acc]);
				_ -> 
					get_recommend_guilds(Uid, LeftIdList, Num, Acc)
			end;
		_ -> 
			get_recommend_guilds(Uid, LeftIdList, Num, Acc)
	end;
get_recommend_guilds(_Uid, _FromIdList, _Num, Acc) -> 
	Acc. 


get_guild_show_info(Uid, GuildRec) ->
	Id = GuildRec#guild.id,
	MemberSize = get_member_amount(Id),
	{
		Id, GuildRec#guild.name, GuildRec#guild.camp, "guild_owner_name", MemberSize, 
		GuildRec#guild.level, judge_already_apply_for_guild(Uid, Id), 
		0, 0, GuildRec#guild.banner
	}.


gm_set_lv(Uid, Lv) -> 
	case get_guild_id_by_uid(Uid) of
		0 -> skip;
		GuildId ->
			case db_api:dirty_read(guild, GuildId) of
				[Rec] ->
					db_api:dirty_write(Rec#guild{level = min(data_guild:max_lv(), Lv)}),
					send_guild_all_info_to_sid(Uid);
				_ -> 
					skip
			end
	end.

