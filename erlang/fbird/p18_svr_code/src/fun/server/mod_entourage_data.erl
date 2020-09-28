%% 英雄阵容，保存各个玩法的玩家英雄阵容,发送玩家的阵容数据
-module(mod_entourage_data).
-include("common.hrl").
-export([get_all_data/1, get_entourage_data/2, set_entourage_data/4, clear_entourage_data/2]).
-export([send_on_battle_heros/3, send_on_battle_heros/4, send_on_scene_heros/4]).

%% =============================================================================
get_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_entourage_list) of
		[] -> #t_entourage_list{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) ->
	mod_role_tab:insert(Rec#t_entourage_list.uid, Rec).
%% =============================================================================
get_all_data(Uid) ->
	Rec = get_data(Uid),
	Rec#t_entourage_list.entourage_list.

get_entourage_data(Uid, Type) ->
	Rec = get_data(Uid),
	case lists:keyfind(Type, 1, Rec#t_entourage_list.entourage_list) of
		{Type, List, ShenqiId} -> {List, ShenqiId};
		_ -> {[], 0}
	end.

set_entourage_data(Uid, List, ShenqiId, Type) ->
	Rec = get_data(Uid),
	NewList = lists:keystore(Type, 1, Rec#t_entourage_list.entourage_list, {Type, List, ShenqiId}),
	NewRec = Rec#t_entourage_list{entourage_list = NewList},
	set_data(NewRec).

clear_entourage_data(Uid, Type) ->
	Rec = get_data(Uid),
	case lists:keymember(Type, 1, Rec#t_entourage_list.entourage_list) of
		true -> 
			NewList = lists:keydelete(Type, 1, Rec#t_entourage_list.entourage_list),
			NewRec = Rec#t_entourage_list{entourage_list = NewList},
			set_data(NewRec);
		_ -> skip
	end.


send_on_battle_heros(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	Fun = fun({Type, List, ShenqiId}) ->
		#pt_public_on_battle_data{
			type      = Type,
			shenqi_id = ShenqiId,
			heros     = util_pt:make_on_battle_pt(List)
		}
	end,
	Pt = #pt_on_battle_heros{
		list = lists:map(Fun, Rec#t_entourage_list.entourage_list)
	},
	?send(Sid, proto:pack(Pt, Seq)).

send_on_battle_heros(Uid, Sid, Seq, Type) ->
	{List, ShenqiId} = get_entourage_data(Uid, Type),
	Pt = #pt_on_battle_heros{
		list = [#pt_public_on_battle_data{type = Type, shenqi_id = ShenqiId, heros = util_pt:make_on_battle_pt(List)}]
	},
	?send(Sid, proto:pack(Pt, Seq)).


send_on_scene_heros(Uid, Sid, Seq, Type) ->
	{List, ShenqiId} = get_entourage_data(Uid, Type),
	List2 = case Type of
		?ON_BATTLE_EXPEDITION ->
			[T || T = {Id, _EType, _Pos} <- List, mod_hero_expedition:get_left_hp_rate(Uid, Id) > 0];
		_ -> List
	end,
	Pt = #pt_on_scene_heros{
		list = [#pt_public_on_battle_data{type = Type, shenqi_id = ShenqiId, heros = util_pt:make_on_battle_pt(List2)}]
	},
	?send(Sid, proto:pack(Pt, Seq)).

