-module(fun_quick_fight).

-include("common.hrl").

-export([req_quick_fight_info/4,req_quick_fight/3,auto_refresh_time/1,gm_reset_times/2]).

-define(QUICK_FIGHT_BUFF_ID,1003).
-define(REQ_UI_INFO,1).
-define(REQ__QUICK_FIGHT,2).

-define(BASE_FIGHT_TIME, 120).
-define(MAX_FOREVER_ADD_TIME, 120).

get_max_times(Uid) ->
	fun_vip:get_privilege_added(quickCombatNum, Uid).

get_data(Uid) ->
	case db:dirty_get(quick_fight, Uid, #quick_fight.uid) of
		[] -> 
			#quick_fight{uid =Uid,forever_add_time=0,fight_times=0}; 
		[Rec] -> Rec
	end.
set_data(Rec) ->
	case Rec#quick_fight.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.	

gm_reset_times(Uid, _Sid) ->
	case db:dirty_get(quick_fight, Uid, #quick_fight.uid) of
		[Rec=#quick_fight{} | _] ->			
			db:dirty_put(Rec#quick_fight{fight_times=0});
		_ -> skip
	end.

auto_refresh_time(Uid) ->
	Quick_fight  = get_data(Uid),
	Quick_fight2 = Quick_fight#quick_fight{fight_times = 0},
	set_data(Quick_fight2).


req_quick_fight_info(Uid,Sid,Seq,Req_type) ->
	case Req_type of
		?REQ_UI_INFO ->
			#quick_fight{fight_times=Cur_times,forever_add_time=Old_num} = get_data(Uid),
			update_to_usr(Uid,Sid,Seq,Cur_times,get_max_times(Uid),Old_num);
		?REQ__QUICK_FIGHT ->req_quick_fight(Uid,Sid,Seq)
	end.

req_quick_fight(Uid,Sid,Seq) ->
	case db:dirty_get(usr, Uid) of
		[#usr{}|_] ->
			MaxTimes = get_max_times(Uid),
			Quick_fight=#quick_fight{fight_times=Cur_times,forever_add_time=Old_num} = get_data(Uid),
			if
				Cur_times < MaxTimes ->
					Times = min(data_buy_time_price:get_max_times(100), Cur_times + 1),
					case data_buy_time_price:get_data(100,Times) of
						#st_buy_time_price{cost=Cost} ->
							TimeSpan = ?BASE_FIGHT_TIME + Old_num,
							{Exp,Coin,_Res,Items} = mod_off_line:get_off_line_award(Uid,TimeSpan,1,0),
							AddItems = [{?RESOUCE_COPPER_NUM,Coin},{?RESOUCE_EXP_NUM,Exp} | Items],
							AddItems1 = case fun_gm_activity_ex:find_open_activity(?GM_ACTIVITY_LITERATURE_COLLECTION) of
 								{true, _} -> make_drop_item(Uid, Sid, TimeSpan * 10, []);
 								_ -> []
 							end,
							AddItems2 = [{?ITEM_WAY_QUICK_FIGHT, AddItemType,AddNum} || {AddItemType,AddNum} <- AddItems],
							SpendItems = [{?ITEM_WAY_QUICK_FIGHT, T, N} || {T, N} <- Cost],
							NewAddItems = lists:append(AddItems1, AddItems2),
							Succ = fun() ->
								NewNum = min(?MAX_FOREVER_ADD_TIME,Old_num+1),
								set_data(Quick_fight#quick_fight{forever_add_time=NewNum,fight_times =Cur_times+1}),
								update_to_usr(Uid,Sid,Seq,Cur_times+1,MaxTimes,Old_num),
								fun_task_count:process_count_event(task_quick_fight,{0,0,1},Uid,Sid),
								gm_act_week_task:handle_task(Uid, Sid, ?WEEK_TASK_QUICK_FIGHT, 1)
							end,
							fun_item_api:check_and_add_items(Uid, Sid, SpendItems, NewAddItems, Succ, undefined);
						_ -> skip
					end;
				true -> skip
			end;
		_ -> skip
	end.
 
update_to_usr(Uid,Sid,Seq,FightTimes,MaxTimes,Forever_times) ->
	TimeSpan = (?BASE_FIGHT_TIME+Forever_times),
	SceneLev = mod_scene_lev:get_curr_scene_lv(Uid),
	{Exp,Coin,Res,Items} = mod_off_line:get_off_line_award(Uid,TimeSpan,SceneLev,0),
	% ?debug("Items:~p", [Items]),
	Pt = #pt_update_quick_fight_info{
		surplus_times = FightTimes,
		max_times     = MaxTimes,
		forever_times = Forever_times,
		reward_exp    = Exp,
		reward_copper = Coin,
		reward_res    = Res,
		reward_item   = lists:map(fun fun_item_api:make_item_get_pt/1, Items)
	},
	?send(Sid,proto:pack(Pt, Seq)).

make_drop_item(_Uid, _Sid, 0, Acc) -> Acc;
make_drop_item(Uid, Sid, Times, Acc) ->
	List = gm_act_literature_collection:do_collect_drop(),
	make_drop_item(Uid, Sid, Times - 1, lists:append(List, Acc)).