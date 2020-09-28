-module(fun_download_reward).
-include("common.hrl").
-export([req_reward/4, req_info/3]).

-define(NOTGETREWARD,0).
-define(GETREWARD,1).

req_reward(Aid, Uid, Sid, Seq) ->
	Acc = fun_acc_misc:get_misc_data(Aid, download_reward),
	?debug("Acc=~p",[Acc]),
	{ID,Items} = data_download_reward:get_data(1),
	case Acc of
		?NOTGETREWARD ->
			AddItems = [{?ITEM_WAY_DOWNLOAD_REWARD,Type,Num} || {Type,Num} <- Items],
			case length(AddItems) > fun_item:get_buy_remain_num(Uid) of
				true -> ?error_report(Sid,"task_bag",Seq);
				_ ->
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems),
					fun_acc_misc:set_misc_data(Aid, download_reward, ?GETREWARD)
			end;
		_ -> skip
	end,
	Pt = #pt_download_reward{id = ID, state = fun_acc_misc:get_misc_data(Aid, download_reward)},
	?send(Sid, proto:pack(Pt,Seq)).


req_info(Aid, _Uid, Sid) ->
	State = fun_acc_misc:get_misc_data(Aid, download_reward),
	{ID, _Items} = data_download_reward:get_data(1),
	Pt = #pt_download_reward{id = ID, state = State},
	?send(Sid, proto:pack(Pt)).

