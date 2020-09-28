%% @doc 购买副本鼓舞的agent相关处理
-module (fun_agent_inspire).
-include("common.hrl").
-export([handle/1]).
-export([req_inspire_buy/4, req_inspire_info/3]).
-export([send_inspire_info_to_client/2]).

handle({req_inspire_buy_get_lv, Lv, Type}) ->
	buy_inspire(get(uid), Lv, Type).


req_inspire_info(Uid, _Sid, _Seq) ->
	[PlyRec | _] = db:dirty_get(ply, Uid),
	case is_pid(PlyRec#ply.scene_hid) of
		true -> 
			mod_msg:handle_to_scene(PlyRec#ply.scene_hid, fun_scene_inspire, {req_inspire_info, Uid});
		false -> skip
	end.


%% 请求购买鼓舞
req_inspire_buy(Uid, _Sid, _Seq, Type) ->
	[PlyRec | _] = db:dirty_get(ply, Uid),
	mod_msg:handle_to_scene(PlyRec#ply.scene_hid, fun_scene_inspire, {req_inspire_buy, Uid, Type}),
	ok.

buy_inspire(Uid, CurrInspire, InspireType) ->
	Sid = get(sid),
	case check_buy_inspire(CurrInspire, InspireType) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, NewInspire, Costs} ->
			SpendItems = [{?ITEM_WAY_BUY_INSPIRE, I, N} || {I, N} <- Costs],
			SuccCallBack = fun() ->
				fun_agent:send_to_scene({update_copy_inspire, Uid, NewInspire, InspireType}),
				send_inspire_info_to_client(Sid, NewInspire)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], SuccCallBack, undefined)
	end,
	ok.

send_inspire_info_to_client(Sid, NewInspire) ->
	Pt = #pt_worldboss_inspire{current_id = NewInspire},
	?send(Sid, proto:pack(Pt)),
	% ?debug("Lv=~p",[Pt2]),
	ok.

check_buy_inspire(CurrInspire, InspireType) ->
	case data_worldboss:get_inspire(CurrInspire + 1,InspireType) of
		{} -> {error, "error_inspire_full"};
		{_, _} -> 
			{Costs, _} = data_worldboss:get_inspire(CurrInspire,InspireType),
			{ok, CurrInspire + 1, Costs}
	end.
