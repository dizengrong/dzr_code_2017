%% @doc 处理离线需要保存的buff
-module (fun_agent_buff).
-include("common.hrl").
-export ([get_buffs/1, set_buffs/2]).

%% =============================================================================
get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_save_buff) of
		[] -> #t_save_buff{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_save_buff.uid, Rec).

set_buffs(Uid, SaveBuffs) ->
	case SaveBuffs of
		[] -> skip;
		_  -> set_data(#t_save_buff{uid = Uid, buffs = SaveBuffs})
	end.

get_buffs(Uid) ->
	Rec = get_data(Uid),
	Rec#t_save_buff.buffs.
%% =============================================================================
