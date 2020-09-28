%% @doc 一些打包协议和协议发送的方法
-module (util_pt).
-include ("common.hrl").
-export ([send_pt_2_online_users/1]).
-export ([make_two_int/1, make_two_int/2, make_id_and_lev/1, make_melee_rank_pt/1]).
-export ([
	make_camp_info_pt/2, make_attr_pt/1, make_damage_list_pt/1, make_damage_list_pt/2, 
	make_on_battle_pt/1, make_item_base_info_pt/1
]).


%% 发送协议给所有的在线玩家
send_pt_2_online_users(PtBin) ->
	Fun = fun(Uid) ->
		case db_api:dirty_read(ply, Uid) of
			[#ply{sid=Sid} | _] -> ?send(Sid, PtBin);
			_ -> skip
		end
	end,
	[Fun(Uid) || Uid <- db:dirty_all_keys(ply)],
	ok.

make_two_int(List) ->
	[make_two_int(Int1, Int2) || {Int1, Int2} <- List].

make_two_int(Int1, Int2) -> 
	#pt_public_two_int{
		data1  = Int1,
		data2  = Int2
	}.	


make_id_and_lev(List) ->
	[make_id_and_lev(D1, D2) || {D1, D2} <- List].

make_id_and_lev(_D1, _D2) -> ok.
	% #pt_public_id_and_lev{
	% 	id  = D1,
	% 	lev  = D2
	% }.	


make_melee_rank_pt({_Uid, _Rank, _Name, _Score}) -> ok.
	% #pt_public_melee_rank_detail{
	% 	rank  = Rank, 
	% 	name  = Name,
	% 	score = Score
	% }.


make_camp_info_pt(_Uid, _Camp) -> ok.
	% #pt_public_camp_info{
	% 	uid  = Uid, 
	% 	camp = Camp
	% }.


make_attr_pt(BattleInfo) ->
	[#pt_public_attr_info{
		attr = F, 
		val = V
	 } || {F, V} <- fun_property:property_get_data_by_type(BattleInfo), V > 0, F /= ?PROPERTY_GS].


make_damage_list_pt(DamageMaps) ->
	make_damage_list_pt(DamageMaps, false).
make_damage_list_pt(DamageMaps, ExcludeMonster) ->
	Fun = fun(K, Maps = #{obj_type := ObjType}, Acc) ->
		case (not ExcludeMonster) orelse (K >= ?ETRG_OFF) of
			true -> 
				Ptm = #pt_public_scene_damage_list{
					id       = K,
					obj_type = util_scene:server_obj_type_2_client_type(ObjType),
					damage   = maps:get(damage, Maps, 0),
					kill_num = maps:get(kill_num, Maps, 0)
				},
				[Ptm | Acc];
			_ -> Acc
		end
	end,
	maps:fold(Fun, [], DamageMaps).


make_on_battle_pt(List) -> 
	[#pt_public_on_battle_heros{
			item_id = Id, 
			type    = EType, 
			pos     = Pos
		} || {Id, EType, Pos} <- List].


make_item_base_info_pt(ItemRec) ->
	#pt_public_item_des{
		id            = ItemRec#item.id,
		bind          = ItemRec#item.bind,
		break_lev     = ItemRec#item.break,
		lev           = ItemRec#item.lev,
		num           = ItemRec#item.num,
		star          = ItemRec#item.star,
		type          = ItemRec#item.type,
		get_time      = ItemRec#item.get_time,
		used_times    = ItemRec#item.owner
	}.