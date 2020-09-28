%%真——功能预告
-module (fun_herald).
-include("common.hrl").
-export([init_step/1,req_info/3,req_reward/4]).

%%数据操作
get_data(Uid) ->
	fun_usr_misc:get_misc_data(Uid, task_step).

set_data(Uid, Val) ->
	fun_usr_misc:set_misc_data(Uid, task_step, Val).

init_step(Uid) ->
	Step = get_data(Uid),
	case Step == 0 of
		true -> set_data(Uid, 1);
		_ -> skip
	end.

req_info(Uid, Sid, Seq) -> 
	Step = get_data(Uid),
	case Step > data_herald:max_id() of
		true -> 
			Status = 2;
		_ ->
			{_, TaskNum, _, NextId} = data_herald:get_data(Step),
			case NextId == 0 of
				true -> Status = 2;
				_ ->
					case mod_scene_lev:get_curr_scene_lv(Uid) >= TaskNum of
						true -> Status = 1;
						_ -> Status = 0
					end
			end
	end,
	Pt = #pt_task_step{
			id = Step,
			status = Status
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_reward(Uid, Sid, Seq, Id) ->
	{_, TaskNum, Reward, NextId} = data_herald:get_data(Id),
	Step = get_data(Uid),
	if Step == Id ->
		case mod_scene_lev:get_curr_scene_lv(Uid) >= TaskNum of
			true ->
				NewId = case NextId == 0 of
					true -> data_herald:max_id() + 1;
					_ -> NextId
				end,
				Fun = fun({T, N}) -> {?ITEM_WAY_TASK_STEP, T, N} end,
				Items = lists:map(Fun, Reward),
				SuccCallBack = fun() ->
					set_data(Uid, NewId),
					fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Reward),
					req_info(Uid, Sid, Seq)
				end,
				fun_item_api:check_and_add_items(Uid, Sid, [], Items, SuccCallBack, undefined);
			_ -> skip
		end;
		true -> skip
	end.