%% @doc 购买副本鼓舞的场景相关处理
-module (fun_scene_inspire).
-include("common.hrl").
-export ([handle/1, on_usr_enter/1, update_inspire_lv/3]).


set_inspire_lv(Uid, Lv) ->
	erlang:put({inspire_lv, Uid}, Lv).
get_inspire_lv(Uid) -> 	
	case erlang:get({inspire_lv, Uid}) of
		undefined -> 0;
		Lv -> Lv
	end.


on_usr_enter(Uid) ->
	%% 玩家重新进入场景鼓舞等级清零
	set_inspire_lv(Uid, 0),
	do_send_inspire_info(Uid),
	ok.


do_send_inspire_info(Uid) ->
	Obj = fun_scene_obj:get_obj(Uid),
	Sid = Obj#scene_spirit_ex.data#scene_usr_ex.sid,
	Lv = get_inspire_lv(Uid),
	fun_agent_inspire:send_inspire_info_to_client(Sid, Lv).


handle({req_inspire_info, Uid}) ->
	do_send_inspire_info(Uid);

handle({req_inspire_buy, Uid, Type}) ->
	Obj = fun_scene_obj:get_obj(Uid),
	Lv = get_inspire_lv(Uid),
	mod_msg:handle_to_agent(Obj#scene_spirit_ex.data#scene_usr_ex.hid, fun_agent_inspire, {req_inspire_buy_get_lv, Lv, Type}).
	
update_inspire_lv(Uid, NewInspire, InspireType) ->
	set_inspire_lv(Uid, NewInspire),
	{_, {BuffId, Power}} = data_worldboss:get_inspire(NewInspire,InspireType),
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr = #scene_spirit_ex{} ->
			Usr2 = fun_scene_obj:put_usr_spc_data(Usr, worldboss_inspire, NewInspire),
			fun_scene_obj:update(fun_scene_buff:add_buff(Usr2, BuffId, Power, 3600*1000, Uid));
		_ -> skip
	end.