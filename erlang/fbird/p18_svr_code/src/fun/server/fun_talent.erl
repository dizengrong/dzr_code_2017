%% @doc 天赋系统
-module (fun_talent).
-include("common.hrl").
-export([get_prop/1, get_fighting/1]).
-export([transform_2_erl/1, transform_2_sql/1]).
-export([send_info_to_client/3, req_up_awaken/3, req_up_skill/4, req_draw/4]).
-export([check_and_open_skill/1]).
-export([get_talent_effect/2, get_passive_skills/1,get_talent_bag_lev/1]).


%% =============================================================================
transform_2_erl(Rec) ->
	Rec#talent{
		skills = util:string_to_term(util:to_list(Rec#talent.skills))
	}.

transform_2_sql(Rec) ->
	Rec#talent{
		skills = util:term_to_string(Rec#talent.skills)
	}.


get_data(Uid) ->
	case mod_role_tab:lookup(Uid, talent) of
		[] -> 
			#talent{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#talent.uid, Rec).
%% =============================================================================


send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	send_info_to_client(Uid, Sid, Seq, Rec).
send_info_to_client(_Uid, Sid, Seq, Rec) ->
	Pt = #pt_talent_info{
		awaken = Rec#talent.awaken,
		skills = [make_skill_pt(Id, Lv) || {Id, Lv} <- Rec#talent.skills]
	},
	?send(Sid, proto:pack(Pt, Seq)).


make_skill_pt(Id, Lv) ->
	#pt_public_talent_skill_des{
		id = Id,
		lv = Lv
	}.


req_up_awaken(Uid, Sid, Seq) ->
	case check_up_awaken(Uid) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, Rec, Costs} ->
			Costs2 = [{?ITEM_WAY_UP_TALENT_AWAKEN, T, N} || {T, N} <- Costs],
			SuccCallBack = fun() -> 
				req_up_awaken_help(Uid, Sid, Seq, Rec)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs2, [], SuccCallBack, undefined)
	end.


req_up_awaken_help(Uid, Sid, Seq, Rec) -> 
	Rec2 = Rec#talent{awaken = Rec#talent.awaken + 1},
	set_data(Rec2),
	check_and_open_skill(Uid, false),
	send_info_to_client(Uid, Sid, Seq),
	fun_property:updata_fighting(Uid),
	ok.


check_up_awaken(Uid) ->
	#talent{awaken = Awaken, skills = Skills} = Rec = get_data(Uid),
	case Awaken >= data_talent:max_awaken() of
		true -> {error, "error_talent_awaken_full"};
		_ -> 
			NeedSkillLv = data_talent:up_awaken_condition(Awaken),
			case get_total_skill_lv(Skills) >= NeedSkillLv of
				false -> {error, "error_talent_awaken_cond_not_enough"};
				_ -> 
					{ok, Rec, data_talent:up_awaken_cost(Awaken)}
			end
	end.


get_total_skill_lv(Skills) ->
	lists:sum([Lv || {_, Lv} <- Skills]).


req_up_skill(Uid, Sid, Seq, SkillId) ->
	case check_up_skill(Uid, SkillId) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, NewRec, Costs} ->
			Costs2 = [{?ITEM_WAY_UP_TALENT_SKILL, T, N} || {T, N} <- Costs],
			SuccCallBack = fun() -> 
				req_up_skill_help(Uid, Sid, Seq, NewRec)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs2, [], SuccCallBack, undefined)
	end.


req_up_skill_help(Uid, Sid, Seq, NewRec) ->
	set_data(NewRec),
	send_info_to_client(Uid, Sid, Seq),
	fun_property:updata_fighting(Uid),
	fun_agent_passive_skill:update_skills(Uid),
	fun_item:req_item_info(Uid,Sid,Seq),
	ok.


check_up_skill(Uid, SkillId) ->
	#talent{skills = Skills} = Rec = get_data(Uid),
	case lists:keyfind(SkillId, 1, Skills) of
		false -> {error, "error_talent_no_skill"};
		{_, Lv} ->
			case Lv >= data_talent:max_skill_lv(SkillId) of
				true -> {error, "error_talent_skill_full"};
				_ -> 
					NewSkills = lists:keystore(SkillId, 1, Skills, {SkillId, Lv + 1}),
					{ok, Rec#talent{skills = NewSkills}, data_talent:up_lv_cost(SkillId, Lv)}
			end
	end.


req_draw(Uid, Sid, Seq, Type) -> 
	case Type of 
		1 -> 
			Id = util:random_by_weight(data_talent:draw_list()),
			IdList = [Id],
			Costs = [{?ITEM_WAY_TALENT_DRAW, ?RESOUCE_COIN_NUM, util:get_data_para_num(1212)}],
			Items = fun_draw:box(data_talent:draw_reward(Id), 0);
		_ ->
			Costs = [{?ITEM_WAY_TALENT_DRAW, ?RESOUCE_COIN_NUM, util:get_data_para_num(1215)}],
			IdList = [util:random_by_weight(data_talent:draw_list()) || _N <- lists:seq(1, 10)],
			Items0 = lists:flatten([fun_draw:box(data_talent:draw_reward(Id), 0) || Id <- IdList]),
			Items = util_list:add_and_merge_list([], Items0, 1, 2)
	end,
	AddItems = [{?ITEM_WAY_TALENT_DRAW, Item, Num} || {Item, Num, _} <- Items],
	SuccCallBack = fun() -> 
		Pt = #pt_talent_draw{draw_id = IdList, items = fun_item_api:make_item_pt_list(Items)},
		?send(Sid, proto:pack(Pt, Seq))
	end,
	fun_item_api:check_and_add_items(Uid, Sid, Costs, AddItems, SuccCallBack, undefined).


check_and_open_skill(Uid) ->
	check_and_open_skill(Uid, true).
check_and_open_skill(Uid, UpdateAttr) -> 
	Barrier = mod_scene_lev:get_curr_scene_lv(Uid),
	case Barrier >= data_talent:min_open_barrier() of
		true ->
			SkillIdList = data_talent:all_skills(),
			#talent{awaken = Awaken, skills = Skills} = Rec = get_data(Uid),
			case length(Skills) == length(SkillIdList) of
				true -> skip;
				_ -> 
					OpenList = check_and_open_skill(Uid, SkillIdList, Skills, Barrier, Awaken, []),
					case OpenList of
						[] -> skip;
						_  -> do_open_skill(Uid, Rec, OpenList, UpdateAttr)
					end
			end;
		_ -> ok
	end.


check_and_open_skill(Uid, [SkillId | Rest], Skills, Barrier, Awaken, Acc) ->
	{NeedBarrier, NeedAwaken} = data_talent:skill_open_condition(SkillId),
	case Barrier >= NeedBarrier andalso Awaken >= NeedAwaken of
		true -> 
			case lists:keymember(SkillId, 1, Skills) of
				true -> 
					check_and_open_skill(Uid, Rest, Skills, Barrier, Awaken, Acc);
				_ -> 
					check_and_open_skill(Uid, Rest, Skills, Barrier, Awaken, [SkillId | Acc])
			end;
		false -> 
			check_and_open_skill(Uid, Rest, Skills, Barrier, Awaken, Acc)
	end;
check_and_open_skill(_Uid, [], _Skills, _Barrier, _Awaken, Acc) -> 
	Acc.


do_open_skill(Uid, Rec, OpenList, UpdateAttr) -> 
	Rec2 = Rec#talent{
		skills = [{S, 0} || S <- OpenList] ++ Rec#talent.skills
	},
	set_data(Rec2),
	case UpdateAttr of
		false -> ok;
		_ -> 
			send_info_to_client(Uid, get(sid), 0),
			fun_property:updata_fighting(Uid),
			ok
	end.


get_prop(Uid) -> 
	#talent{awaken = Awaken} = get_data(Uid),
	{_, Prop} = data_talent:awaken_attr_and_gs(Awaken),
	NewProp = get_talent_effect(Uid, ?TALENT_ADD_PROP),
	Fun = fun(PropList, Acc) -> lists:append(PropList, Acc) end,
	lists:foldl(Fun, Prop, NewProp).

get_fighting(Uid) ->
	#talent{awaken = Awaken, skills = Skills} = get_data(Uid),
	{Fighting1, _} = data_talent:awaken_attr_and_gs(Awaken),
	Fighting2 = lists:sum([data_talent:skill_gs(Id, Lv) || {Id, Lv} <- Skills]),
	Fighting1 + Fighting2.

get_talent_effect(Uid, Type) ->
	#talent{skills = Skills} = get_data(Uid),
	Fun = fun({Id, Lev}, Acc) ->
		case data_talent:get_skill_effects(Id, Lev) of
			{Type1, Effect} ->
				case Type1 == Type of
					true -> [Effect | Acc];
					_ -> Acc
				end;
			_ -> Acc
		end
	end,
	lists:foldl(Fun, [], Skills).

get_talent_bag_lev(Uid) ->
	case get_talent_effect(Uid, ?TALENT_ADD_BAGLEV) of
		[] -> 0;
		EffectList ->
			Fun = fun(Effect, Acc) -> Effect + Acc end,
			lists:foldl(Fun, 0, EffectList)
	end.

get_passive_skills(_Uid) -> [].