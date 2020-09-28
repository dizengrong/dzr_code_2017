%% @doc 评级方法
-module (util_grade).
-include ("common.hrl").
-export ([
	% get_reward_by_grade/2, 
	get_godchallenge_damage_grade/2, 
	get_godchallenge_sdamage/1,
	get_grade_lable/1,
	get_godbless_time_grade/2,
	get_godbless_stime/1,
	get_ringsoul_time_grade/2,
	get_ringsoul_stime/1,
	get_demonsquare_kill_grade/2
]).


% get_reward_by_grade(GradeCnfId, GradeLv) ->
% 	#st_grade_set{reward = Rewards} = data_grade_reward:get_grade_set(GradeCnfId),
% 	{Exp, BoxId, _} = lists:keyfind(GradeLv, 3, Rewards),
% 	{Exp, BoxId}.


%% return: {Grade, NextGradeNeedDamge}
get_godchallenge_damage_grade(Layer, Damage) -> 
	{SDamge, ADamge, BDamge, CDamge} = data_godchallenge:damage_rank(Layer),
	if
		Damage >= SDamge -> {?GRADE_S, 0};
		Damage >= ADamge -> {?GRADE_A, SDamge};
		Damage >= BDamge -> {?GRADE_B, ADamge};
		Damage >= CDamge -> {?GRADE_C, BDamge};
		true -> {?GRADE_D, CDamge}
	end.

get_godbless_time_grade(Layer, Time) -> 
	{STime, ATime, BTime, CTime} = data_godbless:damage_rank(Layer),
	if
		Time =< STime -> {?GRADE_S, 0};
		Time =< ATime -> {?GRADE_A, STime};
		Time =< BTime -> {?GRADE_B, ATime};
		Time =< CTime -> {?GRADE_C, BTime};
		true -> {?GRADE_D, CTime}		
	end.

get_ringsoul_time_grade(Layer, Time) -> 
	{STime, ATime, BTime, CTime} = data_ringsoul_graveyard:grade_time(Layer),
	if
		Time =< STime -> {?GRADE_S, 0};
		Time =< ATime -> {?GRADE_A, STime};
		Time =< BTime -> {?GRADE_B, ATime};
		Time =< CTime -> {?GRADE_C, BTime};
		true -> {?GRADE_D, CTime}		
	end.

get_demonsquare_kill_grade(Layer, Kill) -> 
	{SKill, AKill, BKill, CKill} = data_demon_square:grade_time(Layer),
	if
		Kill >= SKill -> {?GRADE_S, 0};
		Kill >= AKill -> {?GRADE_A, SKill};
		Kill >= BKill -> {?GRADE_B, AKill};
		Kill >= CKill -> {?GRADE_C, BKill};
		true -> {?GRADE_D, CKill}
	end.	

get_godchallenge_sdamage(Layer) -> 
	{SDamge, _ADamge, _BDamge, _CDamge} = data_godchallenge:damage_rank(Layer),
	SDamge.

get_godbless_stime(Layer) -> 
	{STime, _ATime, _BTime, _CTime} = data_godbless:damage_rank(Layer),
	STime.

get_ringsoul_stime(Layer) -> 
	{STime, _ATime, _BTime, _CTime} = data_ringsoul_graveyard:grade_time(Layer),
	STime.

%% 根据评级id获取评级label
get_grade_lable(Grade) -> 
	case Grade of
		?GRADE_D -> "D";
		?GRADE_C -> "C";
		?GRADE_B -> "B";
		?GRADE_A -> "A";
		?GRADE_S -> "S"
	end.

