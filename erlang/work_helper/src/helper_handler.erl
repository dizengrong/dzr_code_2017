%% -*- coding: utf-8 -*-
%% @doc 
-module(helper_handler).
-include("common.hrl").

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
	% ?INFO("Req:~p", [Req]),
	Bindings = cowboy_req:get(bindings, Req),
	Action = lists:keyfind(req_action, 1, Bindings),
	?INFO("req_action:~p", [Action]),
	Req2 = case Action of
		false -> 
			reply_server_error(Req, "rout config error");
		{_, <<"gm_cmd_list">>} ->
			gm_cmd_list(Req);
		{_, <<"item_type">>} ->
			show_item_type_list(Req);
		{_, <<"scene_type">>} ->
			show_scene_type_list(Req);
		{_, <<"skill_type">>} ->
			show_skill_type_list(Req);
		{_, _} ->
			reply_server_error(Req, io_lib:format("action not handled:~p", [Action]))
	end,
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

reply_server_error(Req, Reason) ->
	{ok, Req2} = cowboy_req:reply(400, [
		{<<"content-type">>, <<"text/html">>}
	], Reason, Req),
	Req2.

gm_cmd_list(Req) ->
	Ret = erlydtl:compile_file("work_helper/tpl/gm_list.tpl", gm_list, [{out_dir,"work_helper/tpl"}]),
	?INFO("Ret:~p", [Ret]),
	
	CmdList = [format_gm_code(Cmd) || Cmd <- gm_code_list:all()],
	PropertyList = format_property_code(property_code_list:all(), []),
	Dict = [
		{"cmd_list", CmdList}, 
		{"property_list", PropertyList}, 
		{"color_list", format_all_colors()}
	],
	{ok, Reply} = gm_list:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.

format_property_code([], Acc) ->
	lists:reverse(Acc);
format_property_code([{Id1, Name1}, {Id2, Name2} | Rest], Acc) ->
	T = {
	 unicode:characters_to_binary(integer_to_list(Id1), utf8), 
	 unicode:characters_to_binary(Name1, utf8),
	 unicode:characters_to_binary(integer_to_list(Id2), utf8), 
	 unicode:characters_to_binary(Name2, utf8)
	},
	format_property_code(Rest, [T | Acc]);
format_property_code([{Id1, Name1}], Acc) ->
	T = {
	 unicode:characters_to_binary(integer_to_list(Id1), utf8), 
	 unicode:characters_to_binary(Name1, utf8),
	 unicode:characters_to_binary("", utf8), 
	 unicode:characters_to_binary("", utf8)
	},
	lists:reverse([T | Acc]).

format_gm_code({Cmd, Args, Descripte}) ->
	Len = length(Args),
	Args2 = Args ++ ["" || _ <- lists:seq(1, 5 - Len)],
	Args3 = lists:flatten([format_gm_arg(Arg) || Arg <- Args2]),
	list_to_tuple([Cmd] ++ Args3 ++ [unicode:characters_to_binary(Descripte, utf8)]).

format_gm_arg(Arg) when is_list(Arg) -> 
	[<<"">>, unicode:characters_to_binary(Arg, utf8)];
format_gm_arg(Arg) when is_binary(Arg) -> 
	[<<"">>, unicode:characters_to_binary(Arg, utf8)];
format_gm_arg({ArgType = item_type, ArgDescripte}) ->
	B1 = unicode:characters_to_binary(atom_to_list(ArgType), utf8),
	B2 = unicode:characters_to_binary(ArgDescripte, utf8),
	[B1, B2]; 
format_gm_arg({ArgType = scene_type, ArgDescripte}) ->
	B1 = unicode:characters_to_binary(atom_to_list(ArgType), utf8),
	B2 = unicode:characters_to_binary(ArgDescripte, utf8),
	[B1, B2]; 	
format_gm_arg({ArgType = skill_type, ArgDescripte}) ->
	B1 = unicode:characters_to_binary(atom_to_list(ArgType), utf8),
	B2 = unicode:characters_to_binary(ArgDescripte, utf8),
	[B1, B2]; 	
format_gm_arg({_ArgType, ArgDescripte}) -> 
	B2 = unicode:characters_to_binary(ArgDescripte, utf8),
	[<<"">>, B2].

show_item_type_list(Req) ->
	Ret = erlydtl:compile_file("work_helper/tpl/item_type_list.tpl", item_type_list, [{report_errors,true},{out_dir,"work_helper/tpl"}]),
	?INFO("compile Ret:~p", [Ret]),
	List = [format_item(Id) || Id <- data_item:get_all()],
	ListOfDivid = [{"sub_list", L} || L <- util_list:divid_list(List, 6)],
	{ok, Reply} = item_type_list:render([{"item_list", ListOfDivid}]),
	{ok, Req2}  = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.

format_item(Id) ->
	#st_item_type{name = Name} = data_item:get_data(Id),
	{unicode:characters_to_binary(integer_to_list(Id), utf8), 
	 unicode:characters_to_binary(Name, utf8)
	}.

format_all_colors() ->
	List = [
		{1, "白色", "white"}, 
		{2, "绿色", "green"}, 
		{3, "蓝色", "blue"}, 
		{4, "紫色", "purple"}, 
		{5, "橙色", "orange"}, 
		{6, "红色", "red"}
	],
	[format_color(C, N, C2) || {C, N, C2} <- List].

format_color(ColorId, ColorName, Color) -> 
	{unicode:characters_to_binary(integer_to_list(ColorId), utf8), 
	 unicode:characters_to_binary(ColorName, utf8),
	 unicode:characters_to_binary(Color, utf8)
	}.

show_scene_type_list(Req) ->
	erlydtl:compile_file("work_helper/tpl/scene_type_list.tpl", scene_type_list, [{out_dir,"work_helper/tpl"}]),
	List = data_scene_config:select_preset_Value(0) ++ data_scene_config:select_preset_Value(1),
	List2 = [format_scene(Id) || Id <- List],
	{ok, Reply} = scene_type_list:render([{"scene_list", List2}]),
	{ok, Req2}  = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.

format_scene(Id) ->
	#st_scene_config{name = Name, in_x = InX, in_z = InZ} = data_scene_config:get_data(Id),
	{unicode:characters_to_binary(integer_to_list(Id), utf8), 
	 unicode:characters_to_binary(Name, utf8),
	 unicode:characters_to_binary(integer_to_list(InX), utf8),
	 unicode:characters_to_binary(integer_to_list(InZ), utf8)
	}.

show_skill_type_list(Req) ->
	erlydtl:compile_file("work_helper/tpl/skill_type_list.tpl", skill_type_list, [{out_dir,"work_helper/tpl"}]),
	List = [format_skill(Id) || Id <- data_skillmain:get_all()],
	ListOfDivid = [{"sub_list", L} || L <- util_list:divid_list(List, 6)],
	{ok, Reply} = skill_type_list:render([{"skill_list", ListOfDivid}]),
	{ok, Req2}  = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.

format_skill(Id) ->
	#st_skillmain_config{skillName = Name} = data_skillmain:get_skillmain(Id),
	{unicode:characters_to_binary(integer_to_list(Id), utf8), 
	 unicode:characters_to_binary(Name, utf8)
	}.