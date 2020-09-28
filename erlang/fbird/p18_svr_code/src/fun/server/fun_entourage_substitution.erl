%% @doc 英雄置换
-module (fun_entourage_substitution).
-include("common.hrl").
-export([req_substitution_result/3, req_entourage_substitution/4]).

-define(BOX1_STAR ,4).
-define(BOX2_STAR ,5).

req_entourage_substitution(Uid, Sid, Seq, Eid) ->
	case check_substitution(Uid, Eid) of
		{error, Reason} -> ?error_report(Sid, Reason, Seq);
		{ok, BoxId, NeedNum} ->
			SpendItems = [{100005, NeedNum}],
			{Type, _, _} = hd(fun_draw:box(BoxId)),
			Succ = fun() ->
				put(entourage_substitution, {Eid, Type}),
				Pt = #pt_entourage_substitution_result{etype = Type},
				?send(Sid, proto:pack(Pt, Seq))
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_ENTOURAGE_SUBSTITUTION,
				spend    = SpendItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.

check_substitution(Uid, Eid) ->
	case fun_entourage:get_entourage(Uid, Eid) of
		#item{type = Type, star = Star} ->
			#st_entourage_config{race = Race} = data_entourage:get_data(Type),
			case data_substitution:get_data(Race) of
				[] -> {error, "check_data_error"};
				BoxList ->
					if
						Star == ?BOX1_STAR -> {ok, lists:nth(1, BoxList), data_para:get_data(14)};
						Star == ?BOX2_STAR -> {ok, lists:nth(2, BoxList), data_para:get_data(15)};
						true -> {error, "check_data_error"}
					end
			end;
		_ -> {error, "check_data_error"}
	end.

req_substitution_result(Uid, Sid, Seq) ->
	case get(entourage_substitution) of
		{Eid, Type} ->
			Entourage = #item{} = fun_entourage:get_entourage(Uid, Eid),
			NewEntourage = Entourage#item{type = Type},
			mod_role_tab:insert(Uid, NewEntourage),
			fun_item:send_items_to_sid(Uid, Sid, [NewEntourage], Seq),
			erase(entourage_substitution);
		_ -> skip
	end.