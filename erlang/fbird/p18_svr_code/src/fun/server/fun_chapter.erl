%% @doc 章节模块
-module(fun_chapter).
-include("common.hrl").
-export([req_chapter_rewards/4, req_chapter_info/3]).

%% ===================== 数据操作 =====================
get_data(Uid) ->
	case db:dirty_get(chapter, Uid, #chapter.uid) of
		[]    -> #chapter{uid = Uid};
		[Rec] -> Rec
	end.
set_data(Rec) -> 
	case Rec#chapter.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.
%% ===================== 数据操作 =====================


%%请求章节详情
req_chapter_info(Sid,Uid,Seq)->
	send_info_to_client(Uid, Sid, Seq).

send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	BarrierId = mod_scene_lev:get_winned_scene_lv(Uid),
	FetchedId = Rec#chapter.fetched_id,
	{SceneId,_} = data_chapter:get_reward(FetchedId+1),
	case BarrierId >= SceneId of
		true -> ChapterId = 1;
		_ -> ChapterId = 0
	end,
	Pt = #pt_chapter_info{
		fetched_id        = FetchedId,
		reward_chapter_id = ChapterId
	},
	?send(Sid, proto:pack(Pt,Seq)).


%%请求领取章节奖励
req_chapter_rewards(Sid,Uid,_,Seq)->
	Rec          = get_data(Uid),
	BarrierId    = mod_scene_lev:get_winned_scene_lv(Uid),
	FetchedId = Rec#chapter.fetched_id,
	FetchChapter = FetchedId + 1,
	{SceneId, Reward} = data_chapter:get_reward(FetchChapter),
	case BarrierId >= SceneId of
		true ->
			SuccCallBack = fun() ->
				Rec2 = Rec#chapter{fetched_id = FetchChapter},
				set_data(Rec2),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Reward),
				send_info_to_client(Uid, Sid, Seq)
			end,
			AddItems = [{?ITEM_WAY_CHAPTER, T, N} || {T, N} <- Reward],
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, SuccCallBack, undefined);
		false -> 
			?log_error("has not reward, client must do check before send request")
	end.
