%% @doc 排行榜模块，使用mnesia的有序集合来实现
-module (mod_rank_service).  %% common_server
-include ("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([delete_rank_data/2, update_rank_data/4, save_all/0]).
-export([clear_all_datas/1, query_rank/2, get_data_by_rank/2, get_rank_all_datas/1]).
-export([get_targets_by_section/3, query_rank_and_score/2]).

-export([req_rank_list/4]).
-export([update_arena/4]).
-export([rank_id_to_type/1]).
-export([max_size/1]).

%% for test
-export ([get_rank_show_pt/1]).

%% 加一个排行榜需要增加一个update_xxx方法 增加一个数据库表定义 并修改如下的方法:
%	rank_id_to_type/1
% 	rank_type_to_id/1
%	is_delay_handle/1
%	rank_data_2_pt/1
%	score_id_field/1
%	rank_index/1
%	make_record/4
rank_id_to_type(?RANKLIST_ARENA) -> ?T_RANK_ARENA;
rank_id_to_type(_) -> no.

rank_type_to_id(?T_RANK_ARENA) -> ?RANKLIST_ARENA;
rank_type_to_id(_) -> no.

%% 如果数据更新频率比较高，就设置为延迟处理，不频繁就不需要了
is_delay_handle(?T_RANK_ARENA) -> true;
is_delay_handle(_) -> false.

%% 清理排行榜
clear_all_datas(RankType) ->
	?MODULE ! {clear_all_datas, RankType}.


%% 根据ScoreId查询它对应的排名
query_rank(RankType, ScoreId) ->
	case db_api:dirty_index_read(RankType, ScoreId, score_id_field(RankType)) of
		[] -> 0;
		[Rec] -> element(rank_index(RankType), Rec)
	end.


%% 根据ScoreId查询它对应的排名和Score
query_rank_and_score(RankType, ScoreId) ->
	case db_api:dirty_index_read(RankType, ScoreId, score_id_field(RankType)) of
		[] -> {0, 0};
		[Rec] ->
			{Score, _} = element(2, Rec),
			{element(rank_index(RankType), Rec), Score}
	end.


%% 根据排名获取对应的数据记录
get_data_by_rank(RankType, Rank) ->
	case db_api:dirty_index_read(RankType, Rank, rank_index(RankType)) of
		[] -> [];
		[Rec] -> Rec
	end.

%% 获取目标所在排行榜位置的前后多少名的其他目标的列表
%% 如目标在100，获取前后10名的，则取区间[90, 99]和[101, 110]
%% todo:这里有一个问题，获取排行榜的大小可能与实际排名的大小不一样，因此获取的排名是有偏差的，但没啥影响
get_targets_by_section(RankType, ScoreId, Section) ->
	Rank = query_rank(RankType, ScoreId),
	?_IF(Rank == 0, Rank2 = db_api:size(RankType), Rank2 = Rank),
	L1 = get_targets_by_section2(RankType, max(1, Rank2 - Section), Rank2 - 1, []),
	L2 = get_targets_by_section2(RankType, Rank2 + 1, min(db_api:size(RankType), Rank2 + Section), []),
	L1 ++ L2.

get_targets_by_section2(RankType, FromRank, ToRank, Acc) when FromRank =< ToRank ->
	Rec = get_data_by_rank(RankType, FromRank),
	ScoreId = element(score_id_field(RankType), Rec), 
	get_targets_by_section2(RankType, FromRank + 1, ToRank, [ScoreId | Acc]);
get_targets_by_section2(_RankType, _FromRank, _ToRank, Acc) -> Acc.


%% 获取改排行榜所有的记录
get_rank_all_datas(RankType) -> 
	%% 有延迟更新的排行榜需要同步所有的更新后再获取所有记录
	case is_delay_handle(RankType) of
		false -> db:load_all(RankType);
		true  -> gen_server:call(?MODULE, {sync_get_all_datas, RankType})
	end.

save_all() ->
	gen_server:call(?MODULE, save_all).

update_arena(Val, Uid, Name, RoleLv) ->
	VipLev = fun_vip:get_vip_lev(Uid),
	update_rank_data(?T_RANK_ARENA, Uid, Val, {Name, RoleLv, VipLev}).

%% =============================================================================
delete_rank_data(RankType, ScoreId) ->
	?MODULE ! {delete_data, RankType, ScoreId}.


update_rank_data(RankType, ScoreId, Score, OtherDatas) ->
	update_rank_data(RankType, ScoreId, Score, OtherDatas, is_delay_handle(RankType)).
%% 对于频繁更新的数据使用DelayHandle来延迟更新，同一个更新将被合并，以减少更新次数
update_rank_data(RankType, ScoreId, Score, OtherDatas, DelayHandle) ->
	?MODULE ! {update_data, RankType, ScoreId, Score, OtherDatas, DelayHandle}.


req_rank_list(Uid, Sid, Seq, RankId) ->
	%% 这里要把获取数据的处理放到排行榜进程里面去处理的原因是：
	%% 玩家在获取数据遍历的时候，可能排行榜数据正在被修改
	?MODULE ! {req_rank_list, Uid, Sid, Seq, RankId}.


get_rank_num2(Uid, Data) ->
	case lists:keyfind(Uid, #pt_public_ranklist.uid, Data) of
		false -> 0;
		#pt_public_ranklist{rank = Rank} -> Rank
	end.


%% 注意:只有排行榜进程才能调用它
get_rank_show_pt(RankType) -> 
	%% 前端请求数据时，首先获取缓存数据，如果不存在或者数据过期了，则重新生成，这样提高效率
	case db:get_temp_data({rank_pt_cache, RankType}) of
		Data when is_list(Data)  ->
			Data;
		_ ->  
			Data = get_rank_show_pt_help(RankType),
			db:set_temp_data({rank_pt_cache, RankType}, Data),
			Data
	end.

% get_rank_show_pt_help(RankType = ?T_RANK_ARENA) ->
% 	Fun = fun(Rec) -> rank_data_2_pt(Rec) end,
% 	db_api:dirty_map_limit(Fun, RankType, ?RANK_DEFAULT_SIZE);
get_rank_show_pt_help(RankType) ->
	Fun = fun(Rec) -> rank_data_2_pt(Rec) end,
	db_api:dirty_map_from_end(Fun, RankType).

rank_data_2_pt(Rec = #ranklist_arena{key = {Score, _}}) ->
	#pt_public_ranklist{
		uid      = Rec#ranklist_arena.uid,
		rank     = Rec#ranklist_arena.rank,
		usr_name = Rec#ranklist_arena.name,
		lev      = Rec#ranklist_arena.lev,
		val      = Score,
		vip_lev  = Rec#ranklist_arena.vip_lev
	};
rank_data_2_pt(_) -> no.


init() -> 
	[set_delay_handle_list(RankType, []) || RankType <- ?ALL_RANK],
	NextZeroLeftSecs = ?ONE_DAY_SECONDS - calendar:time_to_seconds(erlang:time()),
    erlang:send_after(NextZeroLeftSecs*1000, self(), zero_clock_event),
    do_pre_load_player_cache(),
	ok.


handle_call(save_all) -> 
	[handle_delay_datas(RankType) || RankType <- ?ALL_RANK],
	ok;

handle_call({sync_get_all_datas, RankType}) -> 
	handle_delay_datas(RankType),
	db:load_all(RankType);

handle_call(Request) ->
	?ERROR("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.

handle_msg({req_rank_list, Uid, Sid, Seq, RankId}) ->
	RankType = rank_id_to_type(RankId),
	Data = get_rank_show_pt(RankType),
	Pt = #pt_ranklist{
		position   = get_rank_num2(Uid, Data),
		ranklist   = Data,
		ranklistId = RankId
	},
	?send(Sid, proto:pack(Pt, Seq));

%%开服榜有过滤条件
handle_msg({req_open_svr_rank_info, Uid, Sid, Seq, RankType, MinNeed}) ->
	RankId=rank_type_to_id(RankType),
	Data = get_rank_show_pt(RankType),
	NewData=lists:filter(fun(Rec) -> Rec#pt_public_ranklist.val >= MinNeed end, Data),
	Pt = #pt_ranklist{
		position   = get_rank_num2(Uid, NewData),
		ranklist   = NewData,
		ranklistId = RankId
	},
	?send(Sid, proto:pack(Pt, Seq));

handle_msg({update_data, RankType, ScoreId, Score, OtherDatas, DelayHandle}) -> 
	case DelayHandle of
		false -> 
			handle_update_rank_data(RankType, ScoreId, Score, OtherDatas);
		_ ->
			add_to_delay_handle(RankType, ScoreId, Score, OtherDatas)
	end,
	%% 一些排行榜需要实时更新的，在这里添加
	% case RankType == ?T_CONSUME orelse RankType == ?T_RECHARGE of
	% 	true -> 
	% 		case get({is_rank_changed, RankType}) of
	% 			true -> 
	% 				update_changed_rank(RankType);
	% 			_ -> skip
	% 		end;
	% 	_ -> skip
	% end,
	ok;

handle_msg({delete_data, RankType, ScoreId}) -> 
	del_delay_handle_key(RankType, ScoreId),
	case db_api:dirty_index_read(RankType, ScoreId, score_id_field(RankType)) of
		[] -> 
			ignore;
		[OldRec] -> 
			put({is_rank_changed, RankType}, true),
			OldKey = element(2, OldRec),
			db_api:dirty_delete(RankType, OldKey)
	end;

handle_msg({clear_all_datas, RankType}) -> 
	clear_all_datas2(RankType);


handle_msg(zero_clock_event) -> 
	erlang:send_after(?ONE_DAY_SECONDS*1000, self(), zero_clock_event),
	refresh_rank(),
	% [send_rank_reward(RankType) || RankType <- ?ALL_RANK],
	% clear_all_datas2(?T_EXPLOIT),
	do_pre_load_player_cache(),
	ok;

% handle_msg({check_and_update_rank_title, RankType}) ->
% 	RankId = rank_type_to_id(RankType),
% 	case data_rank_reward:get_title(RankId, 1) of
% 		Val when is_tuple(Val) ->  
% 			check_and_update_rank_title(RankType, RankId);
% 		_ -> skip
% 	end;

handle_msg({updata_name_card,Uid,NewName}) ->
	Tabs=mt_merge:get_toplist_rename_tabs(),
	Fun = fun({Tab, UidIndex, NameIndex}) ->
		RecList=db_api:dirty_index_read(Tab, Uid, UidIndex),
		F = fun(Rec) ->
			db_api:dirty_write(setelement(NameIndex, Rec, util:to_list(NewName)))
		end,
		lists:foreach(F, RecList)
	end,
	lists:foreach(Fun, Tabs);

handle_msg(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.

terminate() -> 
	ok.

% send_rank_reward(RankType) ->
% 	RankId = rank_type_to_id(RankType),
% 	case data_rank_reward:get_reward(RankId, 1) of
% 		0 -> skip;
% 		_ -> 
% 			try
% 				Fun = fun(Rec) -> 
% 					Rank = element(rank_index(RankType), Rec),
% 					BoxId = data_rank_reward:get_reward(RankId, Rank),
% 					case BoxId of
% 						0 -> skip;
% 						_ ->
% 							AddItems = fun_draw:box(BoxId, 0),
% 							{Title, Content} = util_lang:get_mail(4),
% 							Title2 = util_str:format_string(Title, [util_lang:get_rank_str(RankType)]),
% 							Content2 = util_str:format_string(Content, [util_lang:get_rank_str(RankType), Rank]),
% 							Uid = element(score_id_field(RankType), Rec),
% 							mod_mail_new:sys_send_personal_mail(Uid, Title2, Content2, AddItems, ?MAIL_TIME_LEN)
% 					end
% 				end,
% 				db_api:dirty_map(Fun, RankType)
% 			catch
% 				E:T ->
% 					?EXCEPTION_LOG(T, E, send_rank_reward, RankType)
% 			end
% 	end.


clear_all_datas2(RankType) ->
	db_api:clear_table(RankType),
	set_delay_handle_list(RankType, []).


max_size(?T_RANK_ARENA) -> data_para:get_data(6);
max_size(_) -> ?RANK_DEFAULT_SIZE.

handle_update_rank_data(RankType, ScoreId, Score1, OtherDatas) ->
	case db_api:dirty_index_read(RankType, ScoreId, score_id_field(RankType)) of
		[] -> %% 不在榜上的处理
			Score = case RankType of
				?T_RANK_ARENA -> 1000 + Score1;
				_ -> Score1
			end,
			case db_api:size(RankType) >= max_size(RankType) of
				true -> 
					MinKey = {MinScore, _} = db_api:dirty_first(RankType),
					case is_score_bigger(RankType, Score, MinScore) of
						true -> 
							put({is_rank_changed, RankType}, true),
							db_api:dirty_delete(RankType, MinKey),
							db_api:dirty_write(make_record(RankType, ScoreId, Score, OtherDatas));
						_ ->
							ignore
					end;
				_ ->
					put({is_rank_changed, RankType}, true),
					db_api:dirty_write(make_record(RankType, ScoreId, Score, OtherDatas))
			end;
		[OldRec] ->
			OldKey = {OldScore, _} = element(2, OldRec),
			Score = case RankType of
				?T_RANK_ARENA -> OldScore + Score1;
				_ -> Score1
			end,
			case is_score_bigger(RankType, Score, OldScore) == true orelse RankType == ?T_RANK_ARENA of
				true -> 
					put({is_rank_changed, RankType}, true),
					db_api:dirty_delete(RankType, OldKey), 
					NewRec = make_record(RankType, ScoreId, Score, OtherDatas),
					RankIndex = rank_index(RankType),
					db_api:dirty_write(setelement(RankIndex, NewRec, element(RankIndex, OldRec)));
				_ -> 
					ignore
			end
	end.


add_to_delay_handle(RankType, ScoreId, Score, OtherDatas) ->
	List = get_delay_handle_list(RankType),
	case lists:keyfind(ScoreId, 1, List) of
		false ->  
			set_delay_handle_list(RankType,[{ScoreId, Score, OtherDatas} | List]);
		{_, OldScore, _} ->
			case RankType of
				?T_RANK_ARENA ->
					List2 = lists:keystore(ScoreId, 1, List, {ScoreId, Score + OldScore, OtherDatas}),
					set_delay_handle_list(RankType, List2);
				_ ->
					case is_score_bigger(RankType, Score, OldScore) of
						true ->
							List2 = lists:keystore(ScoreId, 1, List, {ScoreId, Score, OtherDatas}),
							set_delay_handle_list(RankType, List2);
						_ ->
							ignore
					end
			end
	end.

get_delay_handle_list(RankType) ->
	get({delay_handle_list, RankType}).
set_delay_handle_list(RankType, List) ->
	put({delay_handle_list, RankType}, List).
del_delay_handle_key(RankType, Key) -> 
	List = get_delay_handle_list(RankType),
	case lists:keyfind(Key, 1, List) of
		false ->  ignore;
		_ -> 
			set_delay_handle_list(RankType, lists:keydelete(Key, 1, List))
	end.


%% 排行榜的循环设定的是60秒一次
do_loop(_Now) ->
	refresh_rank(),
	ok.


refresh_rank() ->
	[handle_delay_datas(RankType) || RankType <- ?ALL_RANK],
	[update_changed_rank(RankType) || RankType <- ?ALL_RANK, get({is_rank_changed, RankType}) == true],
	ok.


update_changed_rank(RankType) -> 
	erase({is_rank_changed, RankType}),
	Fun = fun(Rec, Rank) ->
		db_api:dirty_write(setelement(rank_index(RankType), Rec, Rank)),
		Rank - 1
	end,
	db_api:dirty_foldl(Fun, db_api:size(RankType), RankType),
	%% 排名更新了，缓存的rank_pt_cache数据要删掉，这样有玩家再来请求时就会生成新的
	db:del_temp_data({rank_pt_cache, RankType}),
	ok.


handle_delay_datas(RankType) -> 
	List = get_delay_handle_list(RankType),
	set_delay_handle_list(RankType, []),
	[handle_update_rank_data(RankType, ScoreId, Score, OtherDatas) || {ScoreId, Score, OtherDatas} <- List],
	ok.




%% =============================================================================
%% ======== 加了一个新的排行榜后，下面的这些方法都要增加一个新类型的处理 =======
%% 排序需要的分数是属于哪个id的数据的

score_id_field(?T_RANK_ARENA) -> #ranklist_arena.uid;
score_id_field(_) -> ok.

rank_index(?T_RANK_ARENA) -> #ranklist_arena.rank;
rank_index(_) -> ok.

%% ScoreId一般为玩家id或者公会id，这个id越小则说明它越早创建的
%% 所以当Score相同时，取ScoreId的负数表示越早创建的记录会优先排前面
make_record(?T_RANK_ARENA, ScoreId, Score, {Name, Lev, Vip_lev}) -> 
	#ranklist_arena{key = {Score, -ScoreId}, uid = ScoreId, name = Name, lev = Lev, vip_lev=Vip_lev};
make_record(_, _, _, _) -> ok.


%% 有些表可能不是按Score字面大就排前面的，默认是字面大排前面，不过可以在这里根据类型区分
is_score_bigger(_RankType, Score, OldScore) -> 
	Score > OldScore.

%% =============================================================================

%% 获取排行榜前n名(非实时排名，已按排名排序)
% get_top_n(RankType, TopN) when is_atom(RankType) -> 
% 	Fun = fun(Rec) -> Rec end,
% 	case RankType of 
% 		?T_RANK_ARENA -> 
% 			db_api:dirty_map_limit_from_end(Fun, RankType, TopN);
% 		_ ->
% 			db_api:dirty_map_limit(Fun, RankType, TopN)
% 	end.

% 初始化加载排行榜前三十的玩家的缓存数据
% 这样即使这些玩家没有在线，获取他们的数据时也能保证时从缓存里获取
do_pre_load_player_cache() ->
	% List = get_top_n(?T_RANK_FIGHTING, 30),
	% [mod_role_tab:init(element(score_id_field(?T_RANK_FIGHTING), Rec) ) || Rec <- List],
	ok.