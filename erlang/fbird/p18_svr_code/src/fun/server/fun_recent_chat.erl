%% @doc 最近聊天消息的处理
-module (fun_recent_chat).
-include("common.hrl").
-export ([add_channel_msg/4,add_channel_msg/6,get_channel_msg/1]).
-export ([req_recent_msg/3]).
-export ([do_expire/1]).
-export ([init_chat/0,store_recent_chat/0]).

-define(MAX_RECENT_MSG_LEN, 50).
-define(EXPIRE_TIME, 		3*24*3600).

%% 注意：recent_chat表本身是一个已排序的ordered_set，dirty_get出来的数据是倒叙排列的
%% 只要不修改已插入的记录，这个顺序是有保证的

init_chat() ->
	% List = db:dirty_match(recent_chat, #recent_chat{_='_'}),
	% put(recent_chat_temp, List),
	ok.

get_channel_msg(Channel) ->
	List = get(recent_chat_temp),
	Channel2 = util:term_to_bitstring(Channel),
	Fun = fun(#recent_chat{channel = Channel1}) ->
		Channel1 == Channel2
	end,
	lists:filter(Fun, List).

delete_recent_chat(#recent_chat{id = Id}) ->
	List = get(recent_chat_temp),
	NewList = lists:keydelete(Id, #recent_chat.id, List),
	db:dirty_del(recent_chat, Id),
	put(recent_chat_temp, NewList).

add_recent_chat(Rec) ->
	List = get(recent_chat_temp),
	put(recent_chat_temp, [Rec | List]).

store_recent_chat() ->
	% List = get(recent_chat_temp),
	% NewList = [store_recent_chat_help(Rec) || Rec <- List],
	% put(recent_chat_temp, NewList),
	ok.

% store_recent_chat_help(Rec = #recent_chat{id = Id}) ->
% 	case Id of
% 		0 ->
% 			[NewRec] = db:insert(Rec),
% 			NewRec;
% 		_ -> Rec
% 	end.

% add_channel_msg(Channel, SenderUid, Msg, Time) when Channel == ?CHANLE_WORLD ->
% 	Channel2 = util:term_to_bitstring(Channel),
% 	Rec = #recent_chat{
% 		channel     = Channel2,
% 		sender      = SenderUid,
% 		server_name = db:get_all_config(servername),
% 		msg         = util:term_to_string(Msg),
% 		time        = Time
% 	},
% 	gen_server:cast({global, global_client}, {add_global_chat, Rec});
add_channel_msg(Channel, SenderUid, Msg, Time) ->
	add_channel_msg(Channel, SenderUid, Msg, Time, undefined, undefined).
add_channel_msg(Channel, SenderUid, Msg, Time, ServerID, ServerName) ->
	NewServerID = case ServerID of
		undefined -> db:get_all_config(serverid);
		_ -> ServerID
	end,
	NewServerName = case ServerName of
		undefined -> db:get_all_config(servername);
		_ -> ServerName
	end,
	Channel2 = util:term_to_bitstring(Channel),
	List = get_channel_msg(Channel),
	case length(List) >= ?MAX_RECENT_MSG_LEN of
		true -> 
			ExpireRec = lists:last(List), 
			delete_recent_chat(ExpireRec);
		_ -> skip
	end,
	Rec = #recent_chat{
		channel     = Channel2,
		sender      = SenderUid,
		server_id	= NewServerID,
		server_name = NewServerName,
		msg         = util:term_to_string(Msg),
		time        = Time
	},
	add_recent_chat(Rec).

%% 删除超过一定时间的消息
do_expire(Now) ->
	List = db:dirty_match(recent_chat, #recent_chat{_ = '_'}),
	[do_expire_help(Now, Rec) || Rec <- List],
	ok.

do_expire_help(Now, Rec) ->
	case Now > Rec#recent_chat.time + ?EXPIRE_TIME of
		true -> db:dirty_del(recent_chat, Rec#recent_chat.id);
		_ -> skip
	end.

get_recent_chat_list(Uid) ->
	List1 = get_channel_msg(?CHANLE_WORLD),
	List2 = case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			get_channel_msg({?CHANLE_GUILD, GuildId});
		_ -> []
	end,
	Fun = fun(A, B) -> A#recent_chat.id >= B#recent_chat.id end,
	List3 = lists:merge(Fun, List1, List2),
	List4 = lists:sublist(List3, ?MAX_RECENT_MSG_LEN),
	List4.


%% 请求最近的聊天消息
req_recent_msg(Uid, Sid, Seq) ->
	List = lists:reverse(get_recent_chat_list(Uid)),
	Pt = #pt_recent_chat{msgs = [make_msg_pt(Rec) || Rec <- List]},
	?send(Sid, proto:pack(Pt, Seq)),
	ok.

make_msg_pt(Rec) ->
	{
		Name,
		RecUid, 
		RecName, 
		VipLev, 
		Chanle, 
		Content, 
		Military,
		GuildId
	} = case util:string_to_term(util:to_list(Rec#recent_chat.msg)) of
		{Name1, RecUid1, RecName1, VipLev1, Chanle1, Content1, Military1, GuildId1} -> {Name1, RecUid1, RecName1, VipLev1, Chanle1, Content1, Military1, GuildId1};
		{Name1, RecUid1, RecName1, VipLev1, Chanle1, Content1, Military1} -> {Name1, RecUid1, RecName1, VipLev1, Chanle1, Content1, Military1, 0}
	end,
	Channel = case Chanle of
		{Channel2, _} -> Channel2;
		Channel2 -> Channel2
	end,
	#pt_public_recent_chat_msg{
		pid             = Rec#recent_chat.sender,
		rec_uid 		= RecUid,
		name            = Name,
		rec_name        = RecName,
		vip_lev         = VipLev,
		chanle          = Channel,
		content         = Content,
		sender_military = Military,
		sender_camp     = 0,
		is_camp_leader  = 0,
		guild_id 		= GuildId,
		server_id  		= Rec#recent_chat.server_id,
		server_name		= Rec#recent_chat.server_name
	}.
