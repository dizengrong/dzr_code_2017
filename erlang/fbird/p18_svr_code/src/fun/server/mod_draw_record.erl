%% 抽奖记录
-module(mod_draw_record).
-include("common.hrl").
-export([add_record/3]).
-export([req_draw_record/4]).

%% =============================================================================
get_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_role_draw_record) of
		[] -> #t_role_draw_record{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	mod_role_tab:insert(Rec#t_role_draw_record.uid, Rec).
%% =============================================================================

req_draw_record(Uid, Sid, Seq, Type) ->
	Rec = get_data(Uid),
	List = case lists:keyfind(Type, 1, Rec#t_role_draw_record.record) of
		{Type, RecordList} -> RecordList;
		_ -> []
	end,
	Pt = #pt_draw_record{
		type        = Type,
		record_list = [#pt_public_draw_record_list{time = Time, item = fun_item_api:make_item_pt_list(ItemList)} || {ItemList, Time} <- List]
	},
	?send(Sid, proto:pack(Pt, Seq)).

add_record(_Uid, [], _Type) -> skip;
add_record(Uid, ItemList, Type) ->
	Rec = get_data(Uid),
	Now = agent:agent_now(),
	RecordList = case lists:keyfind(Type, 1, Rec#t_role_draw_record.record) of
		{Type, RecordList1} -> RecordList1;
		_ -> []
	end,
	NewList = lists:sublist(add_record_help(ItemList, Now, RecordList), 20),
	NewRecordList = lists:keystore(Type, 1, Rec#t_role_draw_record.record, {Type, NewList}),
	NewRec = Rec#t_role_draw_record{record = NewRecordList},
	set_data(NewRec).

add_record_help([], _Now, Acc) -> Acc;
add_record_help([Item | Rest], Now, Acc) ->
	add_record_help(Rest, Now, [{[Item], Now} | Acc]).