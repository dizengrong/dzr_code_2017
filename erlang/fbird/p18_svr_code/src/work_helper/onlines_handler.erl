%% -*- coding: utf-8 -*-
-module (onlines_handler).
-include("common.hrl").
-compile(export_all).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) -> 
	% Bindings = cowboy_req:get(bindings, Req),
	Path = cowboy_req:get(path, Req),
	% ?DEBUG("Req:~p", [Req]),
	Req2 = case Path of
		<<"/onlines">> -> 
			online_users:show_online_users(Req);
		_ -> 
			[_, SubPath, Uid0] = string:tokens(binary_to_list(Path), "/"),
			Uid = util:to_integer(Uid0),
			case SubPath of
				"property" -> 
					online_users:show_detail_user(Req, Uid);
				"db" -> 
					show_db(Req, Uid);
				"agent_dict" ->
					show_agent_dict(Req, Uid);
				"scene_dict" ->
					show_scene_dict(Req, Uid)
			end
	end,
	{ok, Req2, State}.

	
terminate(_Reason, _Req, _State) ->
	ok.


show_agent_dict(Req, Uid) ->
	Process = my_debug:get_player_agent_pid(Uid),
	Dict = get_process_info_dict(Process),
	{ok, Reply} = tpl_process_info:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


show_scene_dict(Req, Uid) ->
	Process = my_debug:get_player_scene_pid(Uid),
	Dict = get_process_info_dict(Process),
	{ok, Reply} = tpl_process_info:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


get_process_info_dict(Process) ->
	[
		{process, util_str:term_to_str(Process)},
		{process_info, util_str:format_string("~p~n", [recon:info(Process)])}
	].


show_db(Req, Uid) -> 
	Tables = [
		usr, 
		% t_role_attr, t_stage, t_usr_promotion, t_role_worldboss, t_card, 
		% t_godchallenge, t_field_battle,
		% t_task,
		item
	],
	List = [get_tab_data(Tab, Uid) || Tab <- Tables],
	Dict = [
		{"tables", List}
	],
	{ok, Reply} = page_role_tables:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


get_tab_data(Tab, Uid) -> 
	[
		Tab,
		get_tab_record_attrs(Tab),
		get_tab_data_help(Tab, Uid)
	].



get_tab_data_help(Tab = item, Uid) ->
	[tl(tuple_to_list(R))  || R <- db_api:dirty_index_read(Tab, Uid, #item.uid)];
% get_tab_data_help(Tab = t_field_battle, Uid) ->
% 	[begin R2 = R#t_field_battle{targets = util_str:term_to_str(R#t_field_battle.targets)}, tl(tuple_to_list(R2)) end || R <- db_api:dirty_read(Tab, Uid)];
get_tab_data_help(Tab, Uid) ->
	[tl(tuple_to_list(R))  || R <- db_api:dirty_read(Tab, Uid)].

get_tab_record_attrs(Tab) ->
	List = mod_tab_config:all_disc_tabs(),
	#tab_config{attrs = Attrs} = lists:keyfind(Tab, #tab_config.tab_name, List),
	Attrs.


format_process(Process) ->
	case Process of
		[$< | _] -> Process;
		_ -> util_misc:list_2_atom(Process)
	end.

