%% 聊天服务进程
-module (fun_chat_server).
-include("common.hrl").

-export([do_init/0,do_info/1,do_msg/1,do_close/0,do_time/1,do_call/1]).


-define(CHAT_RECORD_NAME_NO,"").
-define(CHAT_RECORD_NAME_SYSTEM,"SYSTEM").
-define(CHAT_RECORD_NAME_GM,"GM").
-define(CHAT_PLAT_CHAT_NAME,util:get_data_text(19)).
-define(CHAT_SPEAKER_ITEM,5006).


do_init()->
	Time = util_time:unixtime(),
	{_, {Hour, _, _}} = util_time:seconds_to_datetime(Time),
	put(chat_hour, Hour),
	fun_recent_chat:init_chat(),
	ok.

do_info(Msg)->
	?log_error("do_info,info=~p", [Msg]),
	ok.

do_close()	->
	ok.

do_msg({req_recent_msg,Uid,Sid,Seq}) -> 
	fun_recent_chat:req_recent_msg(Uid, Sid, Seq);

do_msg({req_chat,Uid,Sid,Seq,RecName,Channel,Content}) ->
	req_chat(Uid, Sid, Seq, RecName, Channel, Content, ?NONE);

do_msg({req_chat,Uid,Sid,Seq,RecName,Channel,Content,ClickType}) ->
	req_chat(Uid, Sid, Seq, RecName, Channel, Content, ClickType);

do_msg({global_chat_from_other_server, ServerID, ServerName, Channel, SenderUid, Msg, Pt}) ->
	send_global_chat_from_other_server(ServerID, ServerName, Channel, SenderUid, Msg, Pt);

do_msg({send_private_system_msg, Uid, StringList}) ->
	send_private_system_msg(Uid, StringList);

do_msg({send_reflush_monster_msg, MsgContent, MsgMode}) ->
	send_reflush_monster_msg(MsgContent, MsgMode);

do_msg({send_system_msg, StringList}) ->
	send_system_msg(StringList);
do_msg({send_system_msg, StringList, Who}) ->
	send_system_msg(StringList, Who);

do_msg({send_system_speaker, StringList}) ->
	send_system_speaker(StringList);
do_msg({send_system_speaker, StringList, Data}) ->
	send_system_speaker(StringList, Data);

do_msg({send_system_guild_msg, Uid, StringList}) ->
	send_system_guild_msg(Uid, StringList);

do_msg(Msg) -> 
	?log_error("Msg = ~p",[Msg]).

do_call(_Msg)->
	ok.

do_time(LongNow)->
	Now = LongNow div 1000,
	check_clock(Now),
	1000.

check_clock(Now) ->
	{_, {Hour, _, _}} = util_time:seconds_to_datetime(Now),
	case get(chat_hour) of
		Hour -> skip;
		_ ->
			put(chat_hour, Hour),
			do_hour_loop(Now)
	end.

do_hour_loop(_Now) ->
	fun_recent_chat:store_recent_chat().

%% =============================================================================
%% =============================================================================
get_channel_member(?CHANLE_GUILD, SenderUid, _RecieverName) ->
	case fun_guild:get_guild_baseinfo(SenderUid) of
		{ok, Guildid, _} ->
			List = fun_guild:get_guild_member_uid_list(Guildid),
			Fun = fun(Uid) ->
				case db:dirty_get(ply, Uid) of
					[_] -> true;
					[] -> false
				end
			end,
			lists:filter(Fun, List);
		_ -> []
	end;
get_channel_member(?CHANLE_PRIVITE, _SenderUid, RecieverName) ->
	case db:dirty_get(ply, util:to_binary(RecieverName) ,#ply.name) of
		[Rec] -> [Rec#ply.uid];
		[] -> []
	end;
get_channel_member(?CHANLE_WORLD, _SenderUid, _RecieverName) ->
	db:dirty_all_keys(ply);
	% [Rec#ply.uid || Rec <- List];
get_channel_member(?CHANLE_FAMILY, _SenderUid, _RecieverName) ->
	db:dirty_all_keys(ply);
get_channel_member(?CHANLE_SPEAKER, _SenderUid, _RecieverName) ->
	db:dirty_all_keys(ply);
get_channel_member(?CHANLE_SYSTEM, _SenderUid, _RecieverName) ->
	db:dirty_all_keys(ply).
	% [Rec#ply.uid || Rec <- List].

get_guild_id(Uid) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, Guildid, _} -> Guildid;
		[] -> skip
	end.

%% 目前只有世界聊天跨服
%% 其他服发来的跨服聊天
send_global_chat_from_other_server(ServerID, ServerName, Channel, SenderUid, Msg, Pt) when Channel == ?CHANLE_WORLD orelse Channel == ?CHANLE_FAMILY ->
	List = get_channel_member(Channel, SenderUid, undefined),
	[send_chat_msg(Channel, SenderUid, RecieverUid, Pt) || RecieverUid <- List],
	fun_recent_chat:add_channel_msg(Channel, SenderUid, Msg, util_time:unixtime(), ServerID, ServerName),
	ok;
send_global_chat_from_other_server(_ServerID, _ServerName, _Channel, _SenderUid, _Msg, _Pt) -> skip.

do_send_global_chat_to_other_server(Channel, SenderUid, ChatMsg, ClickType) ->
	Pt = packet_data(SenderUid, 0, ChatMsg, ClickType),
	Msg = {global_chat_to_other_server, Channel, SenderUid, ChatMsg, Pt},
	gen_server:cast({global, global_client}, Msg).

req_chat(Uid,Sid,Seq,RecieverName,Channel,Content,ClickType) ->
	case Channel of
		?CHANLE_SYSTEM ->
			do_chat(Channel,Uid,Sid,Seq,RecieverName,Content,ClickType),
			uploadd_chat_content(Channel,Uid,Content);
		_ ->
			case tool:check_str(Content) of 
				true -> 
					do_chat(Channel,Uid,Sid,Seq,RecieverName,Content,ClickType),
					uploadd_chat_content(Channel,Uid,Content);
				_ -> skip
			end
	end.

uploadd_chat_content(Chanle,Uid,Content) ->
	case db:dirty_get(usr, Uid) of
		[#usr{acc_id = AccId}] ->	
			case db:getOrKeyFindData(account, AccId) of
				[#account{name=AccName}|_]->
					?debug("AccName:~p", [AccName]),
					fun_dataCount_update:chat_upload(Chanle,AccName,Uid,Content);
				_ -> skip
			end;	
		_R-> skip
	end.

do_chat(Channel,SenderUid,SenderSid,Seq,RecieverName,Content,ClickType) ->
	List = get_channel_member(Channel, SenderUid, RecieverName),
	case Channel of
		?CHANLE_PRIVITE ->
			if List == [] -> ?error_report(SenderSid,"player_offline",Seq);
				true -> skip
			end,
			RecieverUid = hd(List),
			case fun_relation_ex:check_blacklist(SenderUid, RecieverUid) of
				true -> ?error_report(SenderSid,"is_blacklist",Seq);
				_ -> 
					Msg = get_msg(Channel, SenderUid, RecieverUid, Content),
					Pt = packet_data(SenderUid, Seq, Msg, ClickType),
					send_chat_msg(Channel, SenderUid, RecieverUid, Pt),
					fun_recent_chat:add_channel_msg(Channel, SenderUid, Msg, util_time:unixtime())
			end;
		_ -> 
			Fun = fun(RecieverUid) ->
				case fun_relation_ex:check_blacklist(SenderUid, RecieverUid) of
					true -> false;
					_ -> true
				end
			end,
			List2 = lists:filter(Fun, List),
			Msg = get_msg(Channel, SenderUid, [], Content),
			Pt = packet_data(SenderUid, Seq, Msg, ClickType),
			[send_chat_msg(Channel, SenderUid, RecieverUid, Pt) || RecieverUid <- List2],
			case ClickType of
				?NONE ->
					case Channel of
						?CHANLE_GUILD -> 
							Guildid = get_guild_id(SenderUid),
							Channel2 = {Channel, Guildid},
							fun_recent_chat:add_channel_msg(Channel2, SenderUid, Msg, util_time:unixtime());
						?CHANLE_FAMILY -> skip;
						_ -> 
							fun_recent_chat:add_channel_msg(Channel, SenderUid, Msg, util_time:unixtime())
					end;
				_ -> skip
			end,
			do_send_global_chat_to_other_server(Channel, SenderUid, Msg, ClickType)
	end,
	ok.

get_msg(Channel, SenderUid, RecieverUid, Content) ->
	GuildId = case fun_guild:get_guild_baseinfo(SenderUid) of
		{ok, NewGuildId, _} -> NewGuildId;
		_ -> 0
	end,
	[Rec1] = db:dirty_get(ply, SenderUid),
	SenderName = Rec1#ply.name,
	VipLev = Rec1#ply.vip,
	Military = Rec1#ply.military_lev,
	NewContent = case Channel of
		?CHANLE_SYSTEM -> Content;
		_ -> [Content]
	end,
	case Channel of
		?CHANLE_PRIVITE ->
			case db:dirty_get(ply, RecieverUid) of
				[Rec2] ->
					RecieverName = get_reciever_name(Channel, Rec2#ply.name),
					RecieverUid1 = RecieverUid;
				_ -> 
					RecieverName = [],
					RecieverUid1 = 0
			end;
		_ ->
			RecieverName = get_reciever_name(Channel, 0),
			RecieverUid1 = 0
	end,
	{SenderName, RecieverUid1, RecieverName, VipLev, Channel, NewContent, Military, GuildId}.

send_chat_msg(Channel, SenderUid, RecieverUid, Pt) ->
	case db:dirty_get(ply, RecieverUid) of
		[Rec2] ->
			case Channel of
				?CHANLE_PRIVITE ->
					[Rec1] = db:dirty_get(ply, SenderUid),
					?send(Rec1#ply.sid, Pt); %%当私聊的时候需要对自己也发一条
				_ -> skip
			end,
			?send(Rec2#ply.sid, Pt);
		_ -> skip
	end.

get_reciever_name(?CHANLE_FAMILY, _RecieverName) -> ?CHAT_RECORD_NAME_SYSTEM;
get_reciever_name(?CHANLE_WORLD, _RecieverName) -> ?CHAT_RECORD_NAME_SYSTEM;
get_reciever_name(?CHANLE_SPEAKER, _RecieverName) -> ?CHAT_RECORD_NAME_SYSTEM;
get_reciever_name(?CHANLE_SYSTEM, _RecieverName) -> ?CHAT_RECORD_NAME_SYSTEM;
get_reciever_name(?CHANLE_GUILD, _RecieverName) -> ?CHAT_RECORD_NAME_NO;
get_reciever_name(?CHANLE_PRIVITE, RecieverName) -> RecieverName.

packet_data(Uid,Seq,{Name,RecieverUid,RecName,VipLev,Chanle,Content,Military,GuildId}) ->
	packet_data(Uid,Seq,{Name,RecieverUid,RecName,VipLev,Chanle,Content,Military,GuildId},?NONE).
packet_data(Uid,Seq,{Name,RecieverUid,RecName,VipLev,Chanle,Content,Military,GuildId},ClickType) ->
	Pt=#pt_chat{
		pid = Uid,
		rec_uid = RecieverUid,
		name = Name,
		rec_name = RecName,
		vip_lev = VipLev,
		chanle = Chanle,
		content = Content,
		sender_military = Military,
		sender_camp = 0,
		is_camp_leader =0,
		server_id = db:get_all_config(serverid),
		servre_name = db:get_all_config(servername),
		guild_id = GuildId,
		click_type = ClickType
	},
	proto:pack(Pt, Seq).


send_system_msg(StringList) ->
	Fun = fun(Uid) ->
		case db:dirty_get(ply, Uid) of
			[#ply{sid=Sid,name=CallName} | _] ->
				Data=packet_data(0,0,{?CHAT_RECORD_NAME_SYSTEM,0,CallName,0,?CHANLE_SYSTEM,StringList,0,0}),
				% ?log_trace("----------------Data=~p",[Data]),
				?send(Sid,Data);
			_ -> skip
		end
	end,
	_ = [Fun(Uid) || Uid <- db:dirty_all_keys(ply)].

send_system_msg(StringList,{gm_chat,Uid}) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid,name=CallName} | _] ->
			Data=packet_data(0,0,{?CHAT_PLAT_CHAT_NAME,0,CallName,0,?CHANLE_GM_SYSTEM,StringList,0,0}),
			?send(Sid,Data);
		_ -> skip
	end;
send_system_msg(StringList,gm) ->
	Fun = fun(Uid) ->
		case db:dirty_get(ply, Uid) of
			[#ply{sid=Sid,name=CallName} | _] -> 
				Data=packet_data(0,0,{?CHAT_RECORD_NAME_SYSTEM,0,CallName,0,?CHANLE_SYSTEM,StringList,0,0}),
				?send(Sid,Data);
			_ -> skip
		end
	end,
	_ = [Fun(Uid) || Uid <- db:dirty_all_keys(ply)].


send_system_speaker(StringList) ->
	Fun = fun(Uid) -> 
		case db:dirty_get(ply, Uid) of
			[#ply{sid=Sid,name=CallName} | _] -> 
				Data=packet_data(0,0,{?CHAT_RECORD_NAME_SYSTEM,0,CallName,0,?CHANLE_SPEAKER,StringList,0,0}),
				?send(Sid,Data);
			_ -> skip
		end
	end,
	_ = [Fun(Uid) || Uid <- db:dirty_all_keys(ply)].
send_system_speaker(StringList,{?CHANLE_CAMP,Camp}) ->
	Fun = fun(Uid) ->
		case db:dirty_get(ply, Uid) of
			[#ply{camp=Camp,sid=Sid,name=CallName} | _] -> 
				Data=packet_data(0,0,{?CHAT_RECORD_NAME_SYSTEM,0,CallName,0,?CHANLE_SPEAKER,StringList,0,0}),
				?send(Sid,Data);
			_ -> skip
		end
	end,
	_ = [Fun(Uid) || Uid <- db:dirty_all_keys(ply)];
send_system_speaker(StringList,gm) ->
	Fun = fun(Uid) ->
		case db:dirty_get(ply, Uid) of
			[#ply{sid=Sid,name=CallName} | _] -> 
				Data=packet_data(0,0,{?CHAT_RECORD_NAME_GM,0,CallName,0,?CHANLE_SPEAKER,StringList,0,0}),
				?send(Sid,Data);
			_ -> skip
		end
	end,
	_ = [Fun(Uid) || Uid <- db:dirty_all_keys(ply)];
send_system_speaker(_StringList,_Data) ->
	?log_error("send_system_speaker,_StringList,_Data=~p",[{_StringList,_Data}]),
	ok.

send_reflush_monster_msg(MsgContent,MsgMode) ->
	case MsgMode of
		0 -> %%是系统消息
			send_system_msg([MsgContent]); 
		_ -> %%error_report
			TipsCode=MsgContent,
			AgentList = db:dirty_match(ply, #ply{_ = '_'}),
			Fun = fun(#ply{sid=Sid}) when erlang:is_pid(Sid) ->
						  ?error_report(Sid,TipsCode)
				  end,
			lists:foreach(Fun, AgentList)
	end.

send_private_system_msg(Uid,StringList) ->
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid,name=CallName} | _] ->
			Data=packet_data(0,0,{?CHAT_RECORD_NAME_SYSTEM,0,CallName,0,?CHANLE_SYSTEM,StringList,0,0}),
			?send(Sid,Data);
		_ -> skip
	end.

send_system_guild_msg(Uid,StringList) ->
	case db:dirty_get(ply, Uid) of
		[#ply{}] ->
			Data=packet_data(0,0,{?CHAT_RECORD_NAME_SYSTEM,0,?CHAT_RECORD_NAME_NO,0,?CHANLE_GUILD,StringList,0,0}),
			fun_guild:broadcast_to_members(Uid, Data);
		_ -> skip
	end.