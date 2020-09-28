%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-1-29
%% Company : fbird.Co.Ltd
%% Desc : fun_other_usr_info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_other_usr_info).
-include("common.hrl").
-export([req_other_usr_info/5]).

%% 查看其他玩家信息
req_other_usr_info(Uid, Sid, Seq, TUid, ClientPanelArg) ->
	case db:dirty_get(usr, TUid) of
		[#usr{name=UserName}] ->
			List = fun_arena:get_all_on_battled_heros(TUid),
			List2 = [util_pt:make_item_base_info_pt(fun_entourage:get_entourage(TUid, ItemId)) || {ItemId, _, _} <- List],
			Pt = #pt_other_usr_info{
				panel_arg   = ClientPanelArg,
				lv          = util:get_lev_by_uid(TUid),
				position    = fun_guild:get_usr_perm(TUid),
				is_friend   = ?_IF(fun_relation_ex:check_is_friend(Uid, TUid), 1, 0),
				user_name   = UserName,
				guild_name  = fun_guild:get_guild_name_by_uid(TUid),
				total_gs    = mod_entourage_property:get_total_gs(TUid, [ItemId || {ItemId, _, _} <- List]),
				arena_heros = util_pt:make_on_battle_pt(List),
				heros_infos = List2
			},
			?send(Sid, proto:pack(Pt, Seq));
		_ -> skip
	end.