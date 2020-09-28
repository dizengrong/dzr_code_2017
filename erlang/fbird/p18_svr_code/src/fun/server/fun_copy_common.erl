%% @doc copy副本的一些处理放这里 
-module(fun_copy_common).
-include("common.hrl").
-export([handle/1]).
-export([
	send_guild_copy_result/5, send_result_to_client/9, send_rank_to_client/4,
	send_act_copy_result_to_client/4, send_expedition_result_to_client/3
]).

send_guild_copy_result(Uid, SceneId, BossMaxHp, TotalDamage, Damage) -> 
	case db:dirty_get(ply,Uid) of
		[#ply{agent_hid = AgentHid} | _] ->
			Msg = {guild_copy_result, SceneId, BossMaxHp, TotalDamage, Damage},
			mod_msg:handle_to_agent(AgentHid, ?MODULE, Msg);
		_ -> skip
	end.


% on_copy_result_event(WinOrLose, Scene, Uid, Sid) ->
% 	case WinOrLose of
% 		?COPY_WIN ->
% 			case data_dungeons_config:select(Scene) of
% 				[] -> skip;
% 				[CurrentCopyID] ->
% 					#st_dungeons_config{dungeonsType = T} = data_dungeons_config:get_dungeons(CurrentCopyID),
% 					case T of
% 						?DUNGEONS_TYPE_MILITARY_BOSS ->
% 							fun_relife:do_relife_help(Uid, Sid, 0);
% 							% fun_task_count:process_count_event(pass_military_boss,{0,0,1}, Uid, Sid);
% 						_ -> skip
% 					end
% 			end;
% 		_ -> skip
% 	end.

%% agent消息:打完副本的结果处理
handle({copy_result, WinOrLose, SceneId, Exp, Coin, TotalDamage, DropList, CollectDrops, SendReultPt}) -> 
	Uid = get(uid),
	?debug("SceneId:~p, TotalDamage:~p", [SceneId, TotalDamage]),
	DungeonsId = get_dungeons_id(SceneId),
	?debug("DungeonsId:~p", [DungeonsId]),
	case db:dirty_get(ply,Uid) of
		[#ply{sid=Sid} | _] ->
			DropList2 = case WinOrLose of
				?COPY_WIN ->
					add_win_reward(Uid, Sid, SceneId, Exp, Coin, DropList);
				_ -> DropList
			end,
			fun_entourage:on_combat_data_check(Uid),
			fun_medicine:send_info_to_client(Uid, Sid, 0),
			fun_artifact_fast:req_info(Uid, Sid, 0),
			gen_server:cast({global, family_mng}, {action_int,?ACTION_REQ_HOME_BUILDING_LIST,Uid,Sid,0,Uid}),
			Fun = fun(Ret) ->
				case Ret of
					{T, N, L} -> {T, N, L};
					{T, N} -> {T, N, 0}
				end
			end,
			_RewardList = [Fun(T) || T <- util_list:add_and_merge_list(DropList2, CollectDrops, 1, 2)],
			case SendReultPt of
				true -> 
					send_result_to_client(SceneId, Sid, WinOrLose, Coin, Exp, 0, 0, TotalDamage, DropList2, CollectDrops);
				_ -> skip
			end;
			% on_copy_result_event(WinOrLose, SceneId, Uid, Sid);
		_ -> skip	
	end;
handle({guild_copy_result, WinOrLose, SceneId, Percent, TotalDamage, Damage}) ->
	Uid = get(uid),
	case db:dirty_get(ply,Uid) of
		[#ply{sid=Sid} | _] ->
			DropList = [],
			fun_entourage:on_combat_data_check(Uid),
			fun_medicine:send_info_to_client(Uid, Sid, 0),
			fun_artifact_fast:req_info(Uid, Sid, 0),
			gen_server:cast({global, agent_mng}, {pass_guild_copy,Uid,SceneId,TotalDamage,Percent,WinOrLose}),
			gen_server:cast({global, family_mng}, {action_int,?ACTION_REQ_HOME_BUILDING_LIST,Uid,Sid,0,Uid}),
			send_result_to_client(SceneId, Sid, WinOrLose, 0, 0, Percent, TotalDamage, Damage, DropList);
		_ -> skip
	end.

send_result_to_client(SceneId, Sid, WinOrLose, Coin, Exp, BossMaxHp, TotalDamage, Damage, DropList) ->
	send_result_to_client(SceneId, Sid, WinOrLose, Coin, Exp, BossMaxHp, TotalDamage, Damage, DropList, []).
send_result_to_client(SceneId, Sid, WinOrLose, Coin, Exp, BossMaxHp, TotalDamage, Damage, DropList, CollectDrops) ->
	case SceneId of
		500038 -> ?log_warning("May not send, why? : ~p",[SceneId]);
		_ -> skip
	end,
	Pt = #pt_copy_win{
		winorlose     = WinOrLose,
		coin          = Coin,
		exp           = Exp,
		boss_max_hp   = BossMaxHp,
		total_damage  = TotalDamage,
		damage        = Damage,
		items         = [fun_item_api:make_item_get_pt(R) || R <- DropList],
		collect_drops = [fun_item_api:make_item_get_pt(R) || R <- CollectDrops]
	},
	?send(Sid, proto:pack(Pt)).

send_rank_to_client(_SceneId, _Uid, _Sid, _RankList) -> 
	todo.
	% case false of
	% 	true -> 
	% 		% List = get_rank_list(SceneId, Uid),
	% 		DungeonsId = get_dungeons_id(SceneId),
	% 		T = todo,
	% 		DataType = case T of
	% 			?DUNGEONS_TYPE_BREAK -> ?COPY_DATA_KILL_MONSTER;
	% 			?DUNGEONS_TYPE_STAR -> ?COPY_DATA_KILL_BOSS;
	% 			?DUNGEONS_TYPE_HERO -> ?COPY_DATA_TOTAL_DAMAGE;
	% 			?DUNGEONS_TYPE_GEM -> ?COPY_DATA_MONSTER_WAVE;
	% 			?DUNGEONS_TYPE_COIN -> ?COPY_DATA_COIN;
	% 			?DUNGEONS_TYPE_LIMITBOSS -> ?COPY_DATA_LIMIT_WORLDBOSS;
	% 			?DUNGEONS_TYPE_GUILD -> ?COPY_DATA_GUILD_COPY
	% 		end,
	% 		Pt = #pt_worldboss_damage_rank{
	% 			type = DataType,
	% 			list = [make_rank_pt(Datas) || Datas <- RankList]
	% 		},
	% 		?send(Sid, proto:pack(Pt));
	% 	_ -> skip
	% end.


% make_rank_pt(RankDes) ->
% 	#pt_public_worldboss_damage_info{
% 		rank       = RankDes#pt_public_ranklist.rank,
% 		uid        = RankDes#pt_public_ranklist.uid,
% 		name       = RankDes#pt_public_ranklist.usr_name
% 	}.

add_win_reward(Uid, Sid, SceneId, Exp, Coin, DropList) ->
	case data_dungeons_config:select(SceneId) of
		[_DungeonsId]->
			fun_resoure:add_resoure(Uid, ?RESOUCE_COPPER_NUM, Coin, ?ITEM_WAY_COPY_RESULT),
			fun_resoure:add_resoure(Uid, ?RESOUCE_EXP_NUM, Exp, ?ITEM_WAY_COPY_RESULT),
			AddItems = [{?ITEM_WAY_COPY_RESULT,Type,Num,[{strengthen_lev,Lev}]} || {Type,Num,Lev} <- DropList],
			DungeonType = todo,
			case length(AddItems) > fun_item:get_buy_remain_num(Uid) of
				true -> 
					case DungeonType of
						?DUNGEONS_TYPE_NORMAL ->
							#mail_content{mailName=Title,text=Text} = data_mail:data_mail(copy_reward),
							mod_mail_new:sys_send_personal_mail(Uid,Title,Text,DropList,?MAIL_TIME_LEN);
						_ ->
							#mail_content{mailName=Title,text=Text} = data_mail:data_mail(dungeon_reward),
							mod_mail_new:sys_send_personal_mail(Uid,Title,Text,DropList,?MAIL_TIME_LEN)
					end;
				_ -> fun_item_api:check_and_add_items(Uid, Sid, [], AddItems)
			end,
			send_other_reward(Uid, SceneId),
			DropList;
		_->skip
	end.

get_dungeons_id(SceneId) ->
	hd(data_dungeons_config:select(SceneId)).

send_other_reward(Uid, Scene) ->
	case get_dungeons_id(Scene) + 1 == get_dungeons_id(util:get_data_para_num(1151)) of
		true ->
			case fun_usr_misc:get_misc_data(Uid, pass_copy) of
				0 ->
					Prof = util:get_prof_by_uid(Uid),
					Reward = fun_draw:box(util:get_data_para_num(1234), Prof),
					fun_usr_misc:set_misc_data(Uid, pass_copy, 1),
					#mail_content{mailName=Title,text=Text} = data_mail:data_mail(good_reputation),
					mod_mail_new:sys_send_personal_mail(Uid,Title,Text,Reward,?MAIL_TIME_LEN);
				_ -> skip
			end;
		_ -> skip
	end.


send_act_copy_result_to_client(Sid, Result, OtherReward, EnsureReward) ->
	DamageList = fun_scene_skill:get_scene_damage_list(),
	TreatList = fun_scene_skill:get_scene_treat_list(),
	Pt = #pt_act_copy_scene_result{
		result         = Result,
		ensure_rewards = [fun_item_api:make_item_get_pt(R) || R <- EnsureReward],
		other_rewards  = [fun_item_api:make_item_get_pt(R) || R <- OtherReward],
		damage_list    = util_pt:make_damage_list_pt(DamageList, true),
		treat_list     = util_pt:make_damage_list_pt(TreatList, true)
	},
	?send(Sid, proto:pack(Pt)).


send_expedition_result_to_client(Sid, Result, AddItems) ->
	DamageList = fun_scene_skill:get_scene_damage_list(),
	TreatList = fun_scene_skill:get_scene_treat_list(),
	AddItems2 = ?_IF(Result == ?COPY_WIN, AddItems, []),
	Pt = #pt_hero_expedition_scene_result{
		result      = Result,
		rewards     = [fun_item_api:make_item_get_pt(R) || R <- AddItems2],
		damage_list = util_pt:make_damage_list_pt(DamageList),
		treat_list  = util_pt:make_damage_list_pt(TreatList)
	},
	?send(Sid, proto:pack(Pt)).
