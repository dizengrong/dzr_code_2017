%% @doc 宠物系统
-module (fun_pet).
-include("common.hrl").
-export ([check_active_pet/2, send_info_to_client/3]).
-export ([req_up_lv/4, req_up_stage/3, req_change_follow_pet/4]).
-export ([init_pet_prop/1, init_pet_fighting/1]).

-define (ADD_EXP_BY_DIAMOND, 1).
-define (ADD_EXP_BY_MELTING, 2).

%% =============================================================================
get_pet(Uid) -> 
	case mod_role_tab:lookup(Uid, t_pet) of
		[] -> [];
		[Rec] -> Rec
	end.

set_pet(Uid, Rec) -> 
	mod_role_tab:insert(Uid, Rec).
%% =============================================================================

init_pet_prop(Uid) -> 
	case get_pet(Uid) of 
		[] -> [];
		#t_pet{lv = Lv} -> 
			{_Gs, Attrs} = data_pet:get_lv_attr(Lv),
			Attrs
	end.

init_pet_fighting(Uid) ->
	case get_pet(Uid) of 
		[] -> 0;
		#t_pet{lv = Lv} -> 
			{Gs, _Attrs} = data_pet:get_lv_attr(Lv),
			Gs
	end.

%% 检测开启宠物系统
check_active_pet(Uid, Life) -> 
	case get_pet(Uid) of 
		[] -> 
			ActiveLife = 4,
			case Life >= ActiveLife of
				true -> active_pet(Uid);
				_ -> skip
			end;
		_ -> skip
	end.


active_pet(Uid) -> 
	PetId = 1,
	Rec = #t_pet{
		uid           = Uid,
		pet_id        = PetId,  %% 初始宠物id固定为1
		follow_pet_id = PetId,
		lv            = 1
	},
	set_pet(Uid, Rec),
	send_info_to_client(Uid, get(sid), 0, Rec),
	fun_property:updata_fighting(Uid),
	% fun_agent:send_to_scene({add_scene_pet, Uid, get_obj_instance_id(ID, PetId), PetId}),
	% send_gain_new_pet(Uid, get(sid), 0, PetId),
	ok.


% get_obj_instance_id(ID, PetId) ->
% 	ID * 100 + PetId.


send_info_to_client(Uid, Sid, Seq) ->
	case get_pet(Uid) of 
		[] -> 
			send_info_to_client(Uid, Sid, Seq, #t_pet{});
		Rec -> 
			send_info_to_client(Uid, Sid, Seq, Rec)
	end.

send_info_to_client(_Uid, Sid, Seq, Rec) ->
	Pt = #pt_pet{
		pet_id        = Rec#t_pet.pet_id,
		follow_pet_id = Rec#t_pet.follow_pet_id,
		lv            = Rec#t_pet.lv,
		exp           = Rec#t_pet.exp
	},
	?send(Sid, proto:pack(Pt, Seq)).


req_change_follow_pet(Uid, Sid, Seq, NewFollowPet) ->
	case get_pet(Uid) of 
		Rec = #t_pet{pet_id = PetId} when PetId >= NewFollowPet -> 
			Rec2 = Rec#t_pet{follow_pet_id = NewFollowPet},
			set_pet(Uid, Rec2),
			% fun_agent:send_to_scene({del_scene_pet, Uid, get_obj_instance_id(ID, Rec#t_pet.follow_pet_id)}),
			% fun_agent:send_to_scene({add_scene_pet, Uid, get_obj_instance_id(ID, NewFollowPet), NewFollowPet}),
			send_info_to_client(Uid, Sid, Seq, Rec2);
		_ -> 
			?error_report(Sid, "error_no_pet")
	end.


%% 升等级
req_up_lv(Uid, Sid, Seq, Type) -> 
	case checke_up_lv(Uid, Type) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{error, Reason, Datas} -> 
			?debug("Datas:~p", [Datas]),
			?error_report(Sid, Reason, Seq, Datas);
		{ok, Rec, Costs, AddExp} -> 
			SuccCallBack = fun() -> 
				req_up_lv_help(Uid, Sid, Seq, Type, Rec, AddExp)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs, [], SuccCallBack, undefined)
	end.


check_add_cri_exp(?ADD_EXP_BY_DIAMOND, AddExp) ->
	Rate = util:get_data_para_num(1187),
	Added = util:get_data_para_num(1189),
	case util:rand(1, 10000) =< Rate of
		true -> util:floor((Added / 10000) * AddExp);
		_ -> AddExp
	end;
check_add_cri_exp(?ADD_EXP_BY_MELTING, AddExp) ->
	Rate = util:get_data_para_num(1188),
	Added = util:get_data_para_num(1190),
	case util:rand(1, 10000) =< Rate of
		true -> util:floor((Added / 10000) * AddExp);
		_ -> AddExp
	end.


req_up_lv_help(Uid, Sid, Seq, Type, Rec, AddExp) -> 
	AddExp2 = check_add_cri_exp(Type, AddExp),
	[#usr{lev = RoleLv}] = db:dirty_get(usr, Uid),
	Rec2 = do_add_exp(Rec, AddExp2, RoleLv),
	set_pet(Uid, Rec2),
	case AddExp2 > AddExp of
		true -> 
			?error_report(Sid, "pet_exp_attack", Seq, [AddExp2 div AddExp]);
		_ -> skip
	end,
	send_info_to_client(Uid, Sid, Seq, Rec2),
	fun_property:updata_fighting(Uid).


do_add_exp(Rec, AddExp, RoleLv) -> 
	FullLv = data_pet:get_pet_full_lv(),
	MaxLv = data_pet:get_pet_max_lv(Rec#t_pet.pet_id),
	case Rec#t_pet.lv >= FullLv of
		true -> Rec;
		false -> 
			NeedRoleLv = data_pet:up_pet_lv_need_role_lv(Rec#t_pet.lv),
			case RoleLv >= NeedRoleLv of
				true -> 
					case Rec#t_pet.lv >= MaxLv of
						true -> Rec#t_pet{exp = Rec#t_pet.exp + AddExp};
						false -> 
							MaxExp = data_pet:get_lv_up_exp(Rec#t_pet.lv),
							case Rec#t_pet.exp + AddExp >= MaxExp of
								true -> 
									Rec2 = Rec#t_pet{lv = Rec#t_pet.lv + 1, exp = 0},
									LeftExp = AddExp - (MaxExp - Rec#t_pet.exp),
									do_add_exp(Rec2, LeftExp, RoleLv);
								_ ->
									Rec#t_pet{exp = Rec#t_pet.exp + AddExp}
							end
					end;
				_ ->
					Rec#t_pet{exp = Rec#t_pet.exp + AddExp}
			end
	end.
	

checke_up_lv(Uid, Type) ->
	Rec = get_pet(Uid),
	FullLv = data_pet:get_pet_full_lv(),
	if
		Rec == [] ->
			{error, "error_no_pet"};
		Rec#t_pet.lv >= FullLv -> 
			{error, "error_common_reach_max_lv"};
		true -> 
			NeedRoleLv = data_pet:up_pet_lv_need_role_lv(Rec#t_pet.lv),
			[#usr{lev = RoleLv}] = db:dirty_get(usr, Uid),
			case RoleLv >= NeedRoleLv of
				false -> {error, "error_pet_need_player_lv", [NeedRoleLv]};
				_ -> 
					MaxExp = data_pet:get_lv_up_exp(Rec#t_pet.lv),
					MaxLv = data_pet:get_pet_max_lv(Rec#t_pet.pet_id),
					case Rec#t_pet.lv >= MaxLv andalso Rec#t_pet.exp >= MaxExp of
						true -> 
							{error, "error_pet_need_up_stage"};
						_ ->
							{{CostDiamond, AddExp1}, 
							 {CostMelting, AddExp2}} = data_pet:get_lv_up_cost(Rec#t_pet.lv),
							Costs = case Type of
								?ADD_EXP_BY_DIAMOND ->
									AddExp = AddExp1, 
									[{?ITEM_WAY_PET_UP, 5019, CostDiamond}];
								?ADD_EXP_BY_MELTING -> 
									AddExp = AddExp2, 
									[{?ITEM_WAY_PET_UP, 5018, CostMelting}]
							end,
							{ok, Rec, Costs, AddExp}
					end
			end
	end.


%% 升阶
req_up_stage(Uid, Sid, Seq) -> 
	 case checke_up_stage(Uid) of
		{error, Reason} -> 
			?error_report(Sid, Reason);
		{ok, Rec, Costs} -> 
			SuccCallBack = fun() -> 
				req_up_stage_help(Uid, Sid, Seq, Rec)
			end,
			fun_item_api:check_and_add_items(Uid, Sid, Costs, [], SuccCallBack, undefined)
	end.


req_up_stage_help(Uid, Sid, Seq, Rec) -> 
	MaxExp = data_pet:get_lv_up_exp(Rec#t_pet.lv),
	Rec2 = Rec#t_pet{
		pet_id = Rec#t_pet.pet_id + 1, 
		lv     = Rec#t_pet.lv + 1, 
		exp    = max(0, Rec#t_pet.exp - MaxExp)
	},
	set_pet(Uid, Rec2),
	send_info_to_client(Uid, Sid, Seq, Rec2),
	fun_property:updata_fighting(Uid),
	send_gain_new_pet(Uid, Sid, Seq, Rec2#t_pet.pet_id).
	

send_gain_new_pet(_Uid, Sid, Seq, NewPetId) -> 
	Pt = #pt_item_model{item_id = data_pet:get_pet_show_item(NewPetId)},
	?send(Sid, proto:pack(Pt, Seq)).

checke_up_stage(Uid) ->
	Rec = get_pet(Uid),
	FullLv = data_pet:get_pet_full_lv(),
	if
		Rec == [] ->
			{error, "error_no_pet"};
		Rec#t_pet.lv >= FullLv -> 
			{error, "error_common_reach_max_lv"};
		true -> 
			MaxExp = data_pet:get_lv_up_exp(Rec#t_pet.lv),
			MaxLv  = data_pet:get_pet_max_lv(Rec#t_pet.pet_id),
			case Rec#t_pet.lv >= MaxLv andalso Rec#t_pet.exp >= MaxExp of
				false -> 
					{error, "error_pet_need_up_lv"};
				_ ->
					Costs = data_pet:get_lv_stage_cost(Rec#t_pet.pet_id),
					{ok, Rec, [{?ITEM_WAY_PET_UP_STAGE, T, N} || {T, N} <- Costs]}
			end
	end.

