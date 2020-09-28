%% @doc 元素珠系统
-module (fun_element_pearl).
-include("common.hrl").
-export ([req_active/4, send_info_to_client/3, req_up_lv/4]).
-export([get_prop/1, get_fighting/1, get_passive_skills/1]).


%% =============================================================================
get_data(Uid) -> 
	case fun_agent_ets:lookup(Uid, pearl) of
		[] -> #pearl{uid = Uid};
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	fun_agent_ets:insert(Rec#pearl.uid, Rec).
%% =============================================================================

get_pearl_lv(#pearl{ele1 = Lv}, 1) -> Lv;
get_pearl_lv(#pearl{ele2 = Lv}, 2) -> Lv;
get_pearl_lv(#pearl{ele3 = Lv}, 3) -> Lv;
get_pearl_lv(#pearl{ele4 = Lv}, 4) -> Lv;
get_pearl_lv(#pearl{ele5 = Lv}, 5) -> Lv.

set_pearl_lv(Rec, 1, Lv) -> Rec#pearl{ele1 = Lv};
set_pearl_lv(Rec, 2, Lv) -> Rec#pearl{ele2 = Lv};
set_pearl_lv(Rec, 3, Lv) -> Rec#pearl{ele3 = Lv};
set_pearl_lv(Rec, 4, Lv) -> Rec#pearl{ele4 = Lv};
set_pearl_lv(Rec, 5, Lv) -> Rec#pearl{ele5 = Lv}.


get_active_cost(5) -> [];
get_active_cost(PearlId) -> 
	[{?ITEM_WAY_PEARL_ACTIVE, T, N} || {T, N} <- data_element_pearl:active_cost(PearlId)].

	

req_active(Uid, Sid, Seq, PearlId) -> 
	?debug("PearlId:~p", [PearlId]),
	Rec = get_data(Uid),
	case check_active(Rec, PearlId) of
		true -> 
			Costs = get_active_cost(PearlId),
			SuccCallBack = fun() -> 
				req_active_help(Uid, Sid, Seq, Rec, PearlId)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs, [], SuccCallBack, undefined);
		_ ->
			?log_error("Already actived")
	end.


check_active(Rec, PearlId) when PearlId =< 4 ->
	get_pearl_lv(Rec, PearlId) == 0;
check_active(Rec, _PearlId) ->
	#pearl{ele5 = E5, ele4 = E4, ele3 = E3, ele2 = E2, ele1 = E1} = Rec,
	E5 == 0 andalso (E4 + E3 + E2 + E1) >= 4.


is_all_actived(Rec) -> 
	#pearl{ele4 = E4, ele3 = E3, ele2 = E2, ele1 = E1} = Rec,
	(E4 + E3 + E2 + E1) >= 4.


get_all_base_min_lv(Rec) -> 
	#pearl{ele4 = E4, ele3 = E3, ele2 = E2, ele1 = E1} = Rec,
	lists:min([E4, E3, E2, E1]).


req_active_help(Uid, Sid, Seq, Rec, PearlId) -> 
	Rec2 = set_pearl_lv(Rec, PearlId, 1),
	set_data(Rec2),
	send_info_to_client(Uid, Sid, Seq, Rec2),
	fun_property:updata_fighting(Uid),
	fun_agent_passive_skill:update_skills(Uid),
	ok.


send_info_to_client(Uid, Sid, Seq) ->
	Rec = get_data(Uid),
	send_info_to_client(Uid, Sid, Seq, Rec).
send_info_to_client(_Uid, Sid, Seq, Rec) ->
	Pt = #pt_ele_pearl_info{
		ele1 = Rec#pearl.ele1,
		ele2 = Rec#pearl.ele2,
		ele3 = Rec#pearl.ele3,
		ele4 = Rec#pearl.ele4,
		ele5 = Rec#pearl.ele5
	},
	?send(Sid, proto:pack(Pt, Seq)).


req_up_lv(Uid, Sid, Seq, PearlId) -> 
	case check_up(Uid, PearlId) of
		{error, Reason, Datas} -> 
			?error_report(Sid, Reason, Seq, Datas);
		{error, Reason} -> 
			?debug("Reason:~s", [Reason]),
			?error_report(Sid, Reason);
		{ok, Rec, Costs} -> 
			Costs2 = [{?ITEM_WAY_PEARL_UP_LV, T, N} || {T, N} <- Costs],
			SuccCallBack = fun() -> 
				req_up_lv_help(Uid, Sid, Seq, PearlId, Rec)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs2, [], SuccCallBack, undefined)
	end.


req_up_lv_help(Uid, Sid, Seq, PearlId, Rec) ->
	Lv = get_pearl_lv(Rec, PearlId),
	Rec2 = set_pearl_lv(Rec, PearlId, Lv + 1),
	set_data(Rec2),
	send_info_to_client(Uid, Sid, Seq, Rec2),
	fun_property:updata_fighting(Uid),
	fun_agent_passive_skill:update_skills(Uid),
	ok.


check_up(Uid, PearlId) ->
	Rec = get_data(Uid),
	case is_all_actived(Rec) of 
		false -> {error, "error_pearl_up_not_open"};
		_ ->
			Lv = get_pearl_lv(Rec, PearlId),
			case Lv >= data_element_pearl:max_pearl_lv(PearlId) of
				true -> {error, "error_pearl_lv_full"};
				_ ->
					case check_up_help(Rec, PearlId) of
						true ->
							Costs = data_element_pearl:up_cost(PearlId, Lv),
							{ok, Rec, Costs};
						Ret -> Ret
					end
			end
	end.


check_up_help(Rec, PearlId) when PearlId == 5 ->
	NeedAllLv = data_element_pearl:up_condition(PearlId, get_pearl_lv(Rec, PearlId)),
	case get_all_base_min_lv(Rec) >= NeedAllLv of
		false -> {error, "error_pearl_up_cond_not_reach2", [NeedAllLv]};
		_ -> true
	end;
check_up_help(Rec, PearlId) ->
	NeedRoleLv = data_element_pearl:up_condition(PearlId, get_pearl_lv(Rec, PearlId)),
	[#usr{lev = RoleLv}] = db:dirty_get(usr, Rec#pearl.uid),
	case RoleLv >= NeedRoleLv of
		false -> {error, "error_pearl_up_cond_not_reach", [NeedRoleLv]};
		_ -> true
	end.


get_prop(Uid) -> 
	#pearl{ele5 = E5, ele4 = E4, ele3 = E3, ele2 = E2, ele1 = E1} = get_data(Uid),
	{Prop1, _} = data_element_pearl:lv_attr_and_gs(1, E1),
	{Prop2, _} = data_element_pearl:lv_attr_and_gs(2, E2),
	{Prop3, _} = data_element_pearl:lv_attr_and_gs(3, E3),
	{Prop4, _} = data_element_pearl:lv_attr_and_gs(4, E4),
	{Prop5, _} = data_element_pearl:lv_attr_and_gs(5, E5),
	Prop1 ++ Prop2 ++ Prop3 ++ Prop4 ++ Prop5.


get_fighting(Uid) ->
	#pearl{ele5 = E5, ele4 = E4, ele3 = E3, ele2 = E2, ele1 = E1} = get_data(Uid),
	{_, Gs1} = data_element_pearl:lv_attr_and_gs(1, E1),
	{_, Gs2} = data_element_pearl:lv_attr_and_gs(2, E2),
	{_, Gs3} = data_element_pearl:lv_attr_and_gs(3, E3),
	{_, Gs4} = data_element_pearl:lv_attr_and_gs(4, E4),
	{_, Gs5} = data_element_pearl:lv_attr_and_gs(5, E5),
	Gs1 + Gs2 + Gs3 + Gs4 + Gs5.


get_passive_skills(Uid) ->
	#pearl{ele5 = E5, ele4 = E4, ele3 = E3, ele2 = E2, ele1 = E1} = get_data(Uid),
	List = [{1, E1}, {2, E2}, {3, E3}, {4, E4}, {5, E5}],
	List2 = [{Id, Lv} || {Id, Lv} <- List, Lv > 0],
	get_passive_skills2(List2, []).

get_passive_skills2([{PearlId, Lv} | Rest], Acc) ->
	SkillId = data_element_pearl:skill_id(PearlId),
	get_passive_skills2(Rest, [{SkillId, Lv, 0} | Acc]);
get_passive_skills2([], Acc) -> Acc.