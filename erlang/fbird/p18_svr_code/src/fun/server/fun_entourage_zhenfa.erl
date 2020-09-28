%% @doc 英雄阵法
-module (fun_entourage_zhenfa).
-include("common.hrl").
-export ([reset_zhenfa/1, get_actived_zhenfa/1, get_monster_zhenfa/1, get_entourage_zhenfa/1]).

-define (ZHENFA_RACE, 1). 	%% 种族类型阵法
-define (ZHENFA_PROF, 2).	%% 职业类型阵法


%% 必须在玩家进程里调用
get_actived_zhenfa(Uid) -> 
	case get(actived_zhenfa) of
		undefined -> 
			List = cacl_active_zhenfa(fun_entourage:get_battle_entourage(Uid)),
			put(actived_zhenfa, List),
			List;
		List -> List
	end.

reset_zhenfa(OnBattleList) ->
	List = cacl_active_zhenfa(OnBattleList),
	put(actived_zhenfa, List).


%% 根据出战列表获取激活的阵法id列表
cacl_active_zhenfa(OnBattleList) ->
	OnBattleList2 = [Type || {_, Type, _} <- OnBattleList],
	L1 = get_race_zhenfa(OnBattleList2),
	L2 = get_prof_zhenfa(OnBattleList2),
	L1 ++ L2.

get_race_zhenfa(OnBattleList) ->
	Fun = fun(Type, NeedRace) ->
		case data_entourage:get_data(Type) of
			#st_entourage_config{race = NeedRace} -> true;
			_ -> false
		end
	end,
	List = data_zhenfa:get_active_condition(?ZHENFA_RACE),
	get_matched_zhenfa_help(List, OnBattleList, Fun).


get_prof_zhenfa(OnBattleList) ->
	MatchFun = fun(Type, NeedProf) ->
		case data_entourage:get_data(Type) of
			#st_entourage_config{profession = NeedProf} -> true;
			_ -> false
		end
	end,
	List = data_zhenfa:get_active_condition(?ZHENFA_PROF),
	get_matched_zhenfa_help(List, OnBattleList, MatchFun).


get_matched_zhenfa_help([{ZhenfaId, Conditions} | Rest], OnBattleList, Fun) ->
	case is_condition_matched(Conditions, OnBattleList, Fun) of
		false -> 
			get_matched_zhenfa_help(Rest, OnBattleList, Fun);
		_ ->
			[ZhenfaId]
	end;
get_matched_zhenfa_help([], _OnBattleList, _Fun) ->
	[].

is_condition_matched([{Need, NeedNum} | Rest], OnBattleList, MatchFun) ->
	Fun = fun(Type, Acc) ->
		case MatchFun(Type, Need) of
			true -> Acc + 1;
			_ -> Acc
		end
	end,
	case lists:foldl(Fun, 0, OnBattleList) >= NeedNum of
		true -> 
			is_condition_matched(Rest, OnBattleList, MatchFun);
		_ -> false
	end;
is_condition_matched([], _OnBattleList, _MatchFun) -> 
	true.

%% =============================================================================

get_monster_zhenfa(Monsters) ->
	RaceZhenfa = case get_monster_race_zhenfa(Monsters) of
		[] -> 0;
		[Id1] -> Id1
	end,
	ProfZhenfa = case get_monster_prof_zhenfa(Monsters) of
		[] -> 0;
		[Id2] -> Id2
	end,
	{RaceZhenfa, ProfZhenfa}.


get_monster_race_zhenfa(OnBattleList) ->
	Fun = fun(Type, NeedRace) ->
		case data_monster:get_monster(Type) of
			#st_monster_config{race = NeedRace} -> true;
			_ -> false
		end
	end,
	List = data_zhenfa:get_active_condition(?ZHENFA_RACE),
	get_matched_zhenfa_help(List, OnBattleList, Fun).


get_monster_prof_zhenfa(OnBattleList) ->
	MatchFun = fun(Type, NeedProf) ->
		case data_monster:get_monster(Type) of
			#st_monster_config{profession = NeedProf} -> true;
			_ -> false
		end
	end,
	List = data_zhenfa:get_active_condition(?ZHENFA_PROF),
	get_matched_zhenfa_help(List, OnBattleList, MatchFun).

get_entourage_zhenfa(EntourageList) ->
	RaceZhenfa = case get_entourage_race_zhenfa(EntourageList) of
		[] -> 0;
		[Id1] -> Id1
	end,
	ProfZhenfa = case get_entourage_prof_zhenfa(EntourageList) of
		[] -> 0;
		[Id2] -> Id2
	end,
	{RaceZhenfa, ProfZhenfa}.


get_entourage_race_zhenfa(OnBattleList) ->
	Fun = fun(Type, NeedRace) ->
		case data_entourage:get_data(Type) of
			#st_entourage_config{race = NeedRace} -> true;
			_ -> false
		end
	end,
	List = data_zhenfa:get_active_condition(?ZHENFA_RACE),
	get_matched_zhenfa_help(List, OnBattleList, Fun).


get_entourage_prof_zhenfa(OnBattleList) ->
	MatchFun = fun(Type, NeedProf) ->
		case data_entourage:get_data(Type) of
			#st_entourage_config{profession = NeedProf} -> true;
			_ -> false
		end
	end,
	List = data_zhenfa:get_active_condition(?ZHENFA_PROF),
	get_matched_zhenfa_help(List, OnBattleList, MatchFun).