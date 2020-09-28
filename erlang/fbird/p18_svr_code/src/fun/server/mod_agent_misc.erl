%% 杂项功能整合
-module(mod_agent_misc).
-include("common.hrl").
-export([req_change_name/4]).

req_change_name(Uid, Sid, Name, Seq) ->
	case fun_item:check_name(Name) of
		true ->
			case db:dirty_get(usr, Uid) of
				[Usr = #usr{}]->
					SpendItems = [{?ITEM_WAY_CHANGE_NAME, ?RESOUCE_COIN_NUM, util:get_data_para_num(7)}],
					Succ = fun() ->
						db:dirty_put(Usr#usr{name = util:to_binary(Name)}),
						Pt = #pt_update_name_succeed{name = Name},
						?send(Sid, proto:pack(Pt, Seq)),
						fun_agent:send_to_scene({update_name, Uid, Name}),
						mod_msg:send_to_agnetmng({change_name, Uid, Name}),
						?error_report(Sid, "rename_succeed", Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.