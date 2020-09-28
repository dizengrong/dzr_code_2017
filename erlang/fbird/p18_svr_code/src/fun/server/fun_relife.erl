%% 转生
-module(fun_relife).
-include("common.hrl").
-export([req_relife/3,check_can_relife/1,get_relife_property/2,get_relife_gs/1,get_data/1]).
-export([req_enter_military_copy/3, do_relife_help/3]).
-export([gm_relife/3]).

%%数据操作
get_data(Uid) ->
	fun_usr_misc:get_misc_data(Uid, relife_time).

get_list_data(Uid) ->
	fun_usr_misc:get_misc_data(Uid, relife_task).

set_data(Uid, Val) ->
	fun_usr_misc:set_misc_data(Uid, relife_time, Val).

get_relife_property(Uid, Prof) ->
	Time = get_data(Uid),
	% ?debug("Time=~p,Prof=~p",[Time,Prof]),
	Id = data_relife:get_id_by_sort(Time, Prof),
	#st_relife{property=ProList} = data_relife:get_data(Id),
	ProList.

req_enter_military_copy(Uid, Sid, Seq) ->
	[#usr{prof=Prof}|_] = db:dirty_get(usr, Uid),
	Time = get_data(Uid),
	Id = data_relife:get_id_by_sort(Time, Prof),
	#st_relife{boss_scene=SceneID} = data_relife:get_data(Id),
	?debug("SceneID:~p", [SceneID]),
	case SceneID > 0 of
		true ->
			fun_agent:send_to_scene({req_enter_copy_scene, Uid, Seq, SceneID}); 
			% case fun_relife_task:is_task_finished(Uid, pass_military_boss) of
			% 	true -> 
			% 		fun_agent:send_to_scene({req_enter_copy_scene, Uid, Seq, SceneID});
			% 	_ -> skip
			% end;
		_ -> 
			do_relife_help(Uid, Sid, Seq)
	end.

req_relife(Uid, Sid, Seq) -> 
	case check_can_relife(Uid) of
		true -> 
			req_enter_military_copy(Uid, Sid, Seq);
			% do_relife_help(Uid, Sid, Seq);
		_ -> skip
	end.

do_relife_help(Uid, Sid, Seq) ->
	?debug("do_relife_help"),
	[#usr{prof=Prof}|_] = db:dirty_get(usr, Uid),
	NewTime = get_data(Uid) + 1,
	Id = data_relife:get_id_by_sort(NewTime, Prof),
	#st_relife{show=ShenqiId,lev=AddLev,num=Num} = data_relife:get_data(Id),
	case ShenqiId == 0 of
		true -> do_relife_help2(Uid, Sid, Seq, AddLev, NewTime);
		_ ->
			{AddItems, _} = data_shenqi:get_active_data(ShenqiId),
			AddItems2 = [{?ITEM_WAY_RELIFE, T, N} || {T, N} <- AddItems],
			Succ = fun() ->
				fun_usr_head:req_rebirth_add_head(Uid,Sid,Seq,{Prof,Num}),
				do_relife_help2(Uid, Sid, Seq, AddLev, NewTime)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [], AddItems2, Succ, undefined)
	end,
	ok.

do_relife_help2(Uid, Sid, Seq, AddLev, NewTime) ->
	[Usr=#usr{lev=Lev,exp=Exp, paragon_level = PLev}] = db:dirty_get(usr, Uid),
	NewLev1 = Lev+AddLev,
	MaxLv = data_legendary_level:get_mex_lev(PLev),
	case NewLev1 > MaxLv of
		true -> NewLev = MaxLv;
		_ -> NewLev = NewLev1
	end,
	Pt = #pt_relife_succeed{
		time = NewTime
	},
	?send(Sid, proto:pack(Pt, Seq)),
	set_data(Uid, NewTime),
	fun_relife_task:init_relife_task(Uid),
	fun_relife_task:req_relife_task(Uid, Sid, Seq),
	NewUsr = Usr#usr{lev = NewLev},
	db:dirty_put(NewUsr),
	fun_pet:check_active_pet(Uid, NewTime),
	case db:dirty_get(ply, Uid) of
		[#ply{sid=Sid} | _] -> 
			gen_server:cast({global, agent_mng},{updata_usr_lev,Uid,NewLev,Exp}),
			fun_agent:send_to_scene({hp_mp_prop_update, Uid,hplimit,mplimit}),
			fun_dataCount_update:lev_change(Lev, NewLev),
			fun_agent:send_to_scene({update_lev,Uid,NewLev}),
			fun_learn_skill:learn_skill(Uid,Sid), 
			fun_agent_property:send_update_base(Uid,[{?PROPERTY_LEV,util:ceil(NewLev)}]),
			fun_resoure:send_resource_to_client(Uid,[{?RESOUCE_EXP_NUM,util:ceil(Exp)}]),
			fun_gem:add_lev_gem(Uid, Sid, NewLev),
			fun_task_count:process_count_event(usr_levup, {0,0,NewLev}, Uid, Sid),
			fun_task_count:process_count_event(usr_add_levup, {0,0,NewLev-Lev}, Uid, Sid),
			fun_task_count:process_count_event(achieve_lev,{0,0,NewLev},Uid,Sid);
		_ -> skip
	end,
	fun_agent:send_to_scene({update_relife, Uid, NewTime}),
	[#usr{prof=Prof}|_] = db:dirty_get(usr, Uid),
	Id = data_relife:get_id_by_sort(NewTime, Prof),
	case data_relife:get_data(Id) of
		#st_relife{rewards = Rewards} ->
			Rewards2 = [{?ITEM_WAY_RELIFE_REWARDS, I, N} || {I, N} <- Rewards], 
			FailFun = fun() -> 
				#mail_content{mailName = Title, text = Content} = data_mail:data_mail(change_award),
				mod_mail_new:sys_send_personal_mail(Uid, Title, Content, Rewards, ?MAIL_TIME_LEN)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [], Rewards2, undefined, FailFun);
		_ -> skip
	end,
	ok.

gm_relife(Uid, Sid, Seq) ->
	do_relife_help(Uid, Sid, Seq).

check_can_relife(Uid) ->
	[Rec] = db:dirty_get(usr, Uid),
	Prof = Rec#usr.prof,
	Lev = Rec#usr.lev,
	Time = get_data(Uid),
	case Time < data_relife_task:max_time() of
		true ->
			Id = data_relife:get_id_by_sort(Time, Prof),
			if Id > 0 ->
				#st_relife{lev=NeedLev} = data_relife:get_data(Id),
				case Lev >= NeedLev of
					true -> 
						List = get_list_data(Uid),
						Fun = fun({_,_,Status}) ->
							case Status == 1 of
								true -> true;
								_ -> false
							end
						end,
						NewList = lists:filter(Fun, List),
						% ?debug("List:~p, NewList:~p", [List, NewList]),
						case length(List) == length(NewList) of
							true -> true;
							_ -> false
						end; 
					_ -> false
				end;
				true -> false
			end;
		_ -> false
	end.

get_relife_gs(Uid) ->
	[Rec] = db:dirty_get(usr, Uid),
	Time = get_data(Uid),
	Prof = Rec#usr.prof,
	Id = data_relife:get_id_by_sort(Time, Prof),
	case data_relife:get_data(Id) of
		#st_relife{gs=Gs} -> Gs;
		_ -> 0
	end.