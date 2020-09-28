%% -*- coding: latin-1 -*-
%% @doc 查看gm命令
-module (gm_codes_handler).
-include("common.hrl").
-compile(export_all).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).


init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) -> 
	Bindings = cowboy_req:get(bindings, Req),
	Req2 = case lists:keyfind(sub, 1, Bindings) of
		false -> 
			show_gm_codes(Req);
		{_, <<"item_type">>} ->
			show_item_type_list(Req)
	end,

	
	{ok, Req2, State}.

	
terminate(_Reason, _Req, _State) ->
	ok.


show_gm_codes(Req) ->
	CmdList = [format_gm_code(Cmd) || Cmd <- gm_code_list:all()],
	[AttrList1, AttrList2] = util_list:divid_list(gm_code_list:attr_list(), 2),
	Dict = [
		{"cmd_list", CmdList},
		{"attr_list1", AttrList1},
		{"attr_list2", AttrList2}
	],
	{ok, Reply} = gm_list:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


format_gm_code({Cmd, Args, Descripte}) ->
	Len = length(Args),
	Args2 = Args ++ ["" || _ <- lists:seq(1, 5 - Len)],
	Args3 = lists:flatten([format_gm_arg(Arg) || Arg <- Args2]),
	list_to_tuple([Cmd] ++ Args3 ++ [Descripte]).

format_gm_arg(Arg) when is_list(Arg) -> 
	[<<"">>, list_to_binary(Arg)];
format_gm_arg(Arg) when is_binary(Arg) -> 
	[<<"">>, Arg];
format_gm_arg({ArgType = item_type, ArgDescripte}) ->
	B1 = ArgType,
	B2 = list_to_binary(ArgDescripte),
	[B1, B2]; 
format_gm_arg({_ArgType, ArgDescripte}) -> 
	B2 = list_to_binary(ArgDescripte),
	[<<"">>, B2].

show_item_type_list(Req) ->
	List = [format_item(Id) || Id <- data_item:all_item_ids()],
	ListOfDivid = [{"sub_list", L} || L <- util_list:divid_list(List, 7)],
	{ok, Reply} = item_type_list:render([{"item_list", ListOfDivid}]),
	{ok, Req2}  = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.

format_item(Id) ->
	#st_item_type{name = Name} = data_item:get_data(Id),
	ItemColor = string:sub_string(Name, 4, 9),
	Name2 = string:sub_string(Name, 11, length(Name) - 3),

	{unicode:characters_to_binary(integer_to_list(Id), utf8), 
	 "#" ++ ItemColor,
	 unicode:characters_to_binary(Name2, utf8, latin1)
	}.

