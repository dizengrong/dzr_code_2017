-module(fun_revive).
-include("common.hrl").
-export([req_revive/3,req_not_revive/3,day_refresh/1]).
-export([req_revive_new/4,req_not_revive_new/4]).
-export([handle/1]).

handle({revive_in_place_new, Uid}) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{pos=Pos} ->
			fun_interface:do_reborn_usr({Uid, Pos});
		_ -> skip
	end;

handle({revive_not_place_new, Uid, _Scene, Type}) ->
	case Type of
		1 ->
			case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
				#scene_spirit_ex{pos=Pos} ->
					fun_interface:do_reborn_usr({Uid, Pos});
				_ -> skip
			end;
		_ -> skip
	end.

req_revive(Uid, Sid, _Seq) ->
	ReviveTimes = fun_usr_misc:get_misc_data(Uid, revive),
	?debug("ReviveTimes=~p",[ReviveTimes]),
	case data_revive:get_data(ReviveTimes+1) of
		#st_revive{cost = Cost} ->
			MaxTime = fun_vip:get_privilege_added(revive_times, Uid),
			case ReviveTimes < MaxTime of
				true ->
					?debug("------------------Revive"),
					SpendItems = [{?ITEM_WAY_REVIVE, T, N} || {T, N} <- Cost],
					Succ = fun() ->
						fun_usr_misc:set_misc_data(Uid, revive, ReviveTimes+1),
						[#ply{scene_hid = Hid}] = db:dirty_get(ply, Uid),
						mod_msg:send_to_scene(Hid, {revive_in_place, Uid, Sid})
					end,
					fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

req_not_revive(Uid, _Sid, _Seq) ->
	case db:dirty_get(ply, Uid) of
		[#ply{scene_type = Scene, scene_hid = Hid}] ->
			mod_msg:send_to_scene(Hid, {revive_not_place, Uid, Scene});
		_ -> skip
	end.

day_refresh(Uid) ->
	fun_usr_misc:set_misc_data(Uid, revive, 0).

req_revive_new(Uid, Sid, Seq, Type) ->
	case check_revive(Uid, Type) of
		{ok, SpendItems} ->
			Succ = fun() ->
				[#ply{scene_hid = Hid}] = db:dirty_get(ply, Uid),
				mod_msg:handle_to_scene(Hid, ?MODULE, {revive_in_place_new, Uid})
			end,
			fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
		{error, Reason} -> ?error_report(Sid, Reason, Seq)
	end.

req_not_revive_new(Uid, _Sid, _Seq, Type) ->
	case db:dirty_get(ply, Uid) of
		[#ply{scene_type = Scene, scene_hid = Hid}] ->
			mod_msg:handle_to_scene(Hid, ?MODULE, {revive_not_place_new, Uid, Scene, Type});
		_ -> skip
	end.

check_revive(_Uid, Type) ->
	case Type of
		1 ->
			SpendItems = [{?ITEM_WAY_REVIVE, ?RESOUCE_COIN_NUM, util:get_data_para_num(1213)}],
			{ok, SpendItems};
		_ -> {error, error}
	end.