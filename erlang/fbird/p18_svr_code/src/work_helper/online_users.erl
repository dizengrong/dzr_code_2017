%% -*- coding: latin-1 -*-
-module (online_users).
-include("common.hrl").
-compile([export_all]).

-define (PLY_RECORD_FIELDS, record_info(fields, ply)).
-define (BATTLE_RECORD_FIELDS, record_info(fields, battle_property)).
-define (ITEM_RECORD_FIELDS, record_info(fields, item)).


show_online_users(Req) ->
	List = [make_user_des(Rec) || Rec <- db:dirty_match(ply, #ply{_ = '_'})],
	Dict  = [{"online_users", List}, {"user_num", length(List)}],
	{ok, Reply} = tpl_online_users:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.

make_user_des(Rec) ->
	[#account{name = AccountName, password = Pwd}] = db:dirty_get(account, Rec#ply.aid),
	[#usr{create_time = CreateTime}] = db:dirty_get(usr, Rec#ply.uid),
	AccountDatas = [{account_name, AccountName}, {password, Pwd}],
	UsrDatas = [{create_time, util_time:time_to_full_string(CreateTime)}],
	[_RecName | FieldDatas] = tuple_to_list(Rec), 
	[
		{property_url, "/onlines/property/" ++ integer_to_list(Rec#ply.uid)},
		{db_url, "/onlines/db/" ++ integer_to_list(Rec#ply.uid)},
		{agent_dict_url, "/onlines/agent_dict/" ++ integer_to_list(Rec#ply.uid)},
		{scene_dict_url, "/onlines/scene_dict/" ++ integer_to_list(Rec#ply.uid)}
	] ++ UsrDatas ++ AccountDatas ++ lists:zip(?PLY_RECORD_FIELDS, FieldDatas).

show_detail_user(Req, Uid) ->
	case db:dirty_get(usr, util:to_integer(Uid)) of
		[] -> 
			util_cowboy:reply_server_error(Req, "user not exist or not online!");
		[Usr = #usr{name = Name}] ->
			AgentBattle = agent:debug_call(Uid, fun()-> fun_agent_property:get_final_property() end),
			Obj         = scene:debug_call(Uid, fun()-> fun_scene_obj:get_obj(Uid) end),
			SceneBattle = Obj#scene_spirit_ex.final_property,
			[_ | AgentBattle1] = tuple_to_list(AgentBattle), 
			[_ | SceneBattle1] = tuple_to_list(SceneBattle),
			[_ | BuffBattle] = tuple_to_list(#battle_property{}),
			[_ | BuffPerBattle] = tuple_to_list(#battle_property{}),
			Battle = format_battle_property(?BATTLE_RECORD_FIELDS, AgentBattle1, SceneBattle1, BuffBattle, BuffPerBattle, []),
			Fun = fun({BuffType, Attrs}, Acc) -> 
				case format_property(Attrs, []) of
					[T | _] -> [{BuffType, T} | Acc];
					_ -> Acc
				end
			end,
			Dict = [
				{user_name, Name},
				{battle_field_name, ?BATTLE_RECORD_FIELDS}, 
				{battle_property, Battle},
				{buff, [BuffType || #scene_buff{type = BuffType} <- Obj#scene_spirit_ex.buffs]},
				{buff_attrs, lists:foldl(Fun, [], Obj#scene_spirit_ex.buff_property)},
				{all_module_property, get_all_module_property(Usr)},
			    {all_module_fighting, get_all_module_fighting(Usr)}

			],
			{ok, Reply} = tpl_detail_user:render(Dict),
			{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
			Req2
	end.

format_battle_property([], [], [], [],[], Acc) -> Acc;
format_battle_property([Field | Rest1], [AgentVal | Rest2], [SceneVal | Rest3], [BuffVal | Rest4], [BuffPerVal | Rest5], Acc) ->
	FieldName = property_code_list:battle_field_2_name(Field),
	FieldName2 = case lists:keyfind(FieldName, 1, property_code_list:all()) of
		false -> "undefined";
		{_, N} -> N
	end,
	Tuple = {unicode:characters_to_binary(FieldName2, utf8), Field, AgentVal, SceneVal, BuffVal, BuffPerVal},
	format_battle_property(Rest1, Rest2, Rest3, Rest4, Rest5, [Tuple | Acc]).

format_battle([], [], Acc) -> Acc;
format_battle([Field | Rest1], [Val | Rest2], Acc) -> 
	case Val of
		0 -> format_battle(Rest1, Rest2, Acc);
		_ ->
			FieldName = property_code_list:battle_field_2_name(Field),
			FieldName2 = case lists:keyfind(FieldName, 1, property_code_list:all()) of
				false -> "undefined";
				{_, N} -> N
			end,
			Tuple = {unicode:characters_to_binary(FieldName2, utf8), Field, Val},
			format_battle(Rest1, Rest2, [Tuple | Acc])
	end.

format_property([], Acc) -> Acc;
format_property([{PropertyId, Val} | Rest2], Acc) ->
	case Val of
		0 -> format_property(Rest2, Acc);
		_ ->
			FieldName = property_code_list:property_id_2_name(PropertyId),
			FieldName2 = case lists:keyfind(FieldName, 1, property_code_list:all()) of
				false ->
					integer_to_list(PropertyId);
				{_, N} -> N
			end,
			Tuple = {unicode:characters_to_binary(FieldName2, utf8), Val},
			format_property(Rest2, [Tuple | Acc])
	end.


format_equip(E) ->
	Name = util_lang:get_item_name(E#item.type),
	Name2 = unicode:characters_to_binary(Name, utf8, latin1),
	[_ | Datas] = tuple_to_list(E), 
	[{name, Name2}] ++ lists:zip(?ITEM_RECORD_FIELDS, Datas).


get_all_module_property(Usr) -> 
	Uid = Usr#usr.id,

	AllModPropetyList = agent:debug_call(Uid, fun()-> fun_agent_property:all_module_property(Uid) end),
	Fun = fun({Desc, PropertyRec}) -> 
		[_ | PropertyRec2] = tuple_to_list(PropertyRec), 
		{Desc, format_battle(?BATTLE_RECORD_FIELDS, PropertyRec2, [])}
	end,
	[Fun(E) || E <- AllModPropetyList].


get_all_module_fighting(Usr) ->
	_Uid = Usr#usr.id,
	[
		% {unicode:characters_to_binary("总战力", utf8), Fighting}
	].

