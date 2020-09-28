%% @doc 乱斗boss的玩家个人模块
-module (fun_agent_meleeboss).
-include("common.hrl").
-export([handle/1]).
-export([get_data/1,set_data/1]).
-export([req_meleeboss_info/3,req_buy_meleeboss_times/3,req_attact_meleeboss_owner/3]).
-export([req_enter_copy/5]).
-export([refresh_data/1]).

init_data(Uid) ->
	#usr_melleboss{
		uid   = Uid,
		times = util:get_data_para_num(1211)
	}.

get_data(Uid) ->
	case fun_agent_ets:lookup(Uid, usr_melleboss) of
		[Rec = #usr_melleboss{}] -> Rec;
		_ -> init_data(Uid)
	end.

set_data(Rec) -> fun_agent_ets:insert(Rec#usr_melleboss.uid, Rec).

handle({on_get_owner, Uid, Sid}) ->
	fun_task_count:process_count_event(melle_boss,{0,0,1},Uid,Sid).

req_meleeboss_info(Uid, Sid, Seq) ->
	mod_msg:handle_to_agnetmng(system_melleboss, {req_meleeboss_info, Uid, Sid, Seq}).

req_buy_meleeboss_times(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	case Rec#usr_melleboss.buy_times >= fun_vip:get_privilege_added(melleboss_times, Uid) of
		true -> skip;
		_ ->
			Times = min(Rec#usr_melleboss.buy_times + 1, data_buy_time_price:get_max_times(?BUY_MELEEBOSS)),
			#st_buy_time_price{cost = Cost} = data_buy_time_price:get_data(?BUY_MELEEBOSS, Times),
			SpendItems = [{?ITEM_WAY_MELLEBOSS, T, N} || {T, N} <- Cost],
			Succ = fun() ->
				NewRec = Rec#usr_melleboss{
					times 	  = Rec#usr_melleboss.times + 1,
					buy_times = Rec#usr_melleboss.buy_times + 1
				},
				set_data(NewRec),
				% ?debug("Rec = ~p",[NewRec]),
				req_meleeboss_info(Uid, Sid, Seq)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined)
	end.

req_attact_meleeboss_owner(Uid, _Sid, _Seq) ->
	[PlyRec] = db:dirty_get(ply, Uid),
	mod_msg:handle_to_scene(PlyRec#ply.scene_hid, fun_scene_melleboss, {req_attact_meleeboss_owner, Uid}),
	ok.

req_enter_copy(Uid, Sid, BossId, Diff, Seq) ->
	case check_enter(Uid, BossId) of
		{error, Reason} -> ?debug("Reason:~p", [Reason]),
			?error_report(Sid, Reason, Seq);
		{ok, Scene} ->
			do_enter_copy(Uid, Seq, Scene, Diff)
	end.

do_enter_copy(Uid, Seq, Scene, Diff) ->
	#st_scene_config{points = PointList} = data_scene_config:get_scene(Scene),
	InPos = hd(PointList),
	case db:dirty_match(scene, #scene{type = Scene, _='_'}) of
		[#scene{hid = Hid}] ->
			mod_msg:handle_to_scene(Hid, fun_scene_melleboss, {save_diff, Uid, Diff});
		_ -> ?debug("usr other id")
	end,
	UsrInfoList = [{Uid,Seq,InPos,#ply_scene_data{}}],
	SceneData = {melle_boss},
	gen_server:cast({global, scene_mng}, {start_fly,UsrInfoList,Scene,SceneData}).

check_enter(Uid, BossId) ->
	St = data_melleboss:get_boss(BossId),
	BossRec = system_melleboss:get_boss_rec(BossId),
	case fun_usr_misc:get_misc_data(Uid, relife_time) >= St#st_melleboss.need_relife of
		true ->
			case util_time:unixtime() >= BossRec#melleboss_state.next_revive_time of
				true ->
					UsrNum = case db:dirty_match(scene, #scene{type = St#st_melleboss.scene, _='_'}) of
						[#scene{num = Num}] -> Num;
						_ -> 0
					end,
					#st_scene_config{max_agent = Max} = data_scene_config:get_scene(St#st_melleboss.scene),
					case UsrNum >= Max of
						true -> {error, "snatchBoss3"};
						_ -> {ok, St#st_melleboss.scene}
					end;
				_ -> {error, "boss_no_resurrection"}
			end;
		_ -> {error, "insufficient_level"}
	end.

refresh_data(Uid) ->
	Rec = get_data(Uid),
	NewRec = Rec#usr_melleboss{
		times 	  = util:get_data_para_num(1211),
		buy_times = 0
	},
	set_data(NewRec).