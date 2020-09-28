%% -*- coding: utf-8 -*-
-module (view_db_tables_handler).
-include ("common.hrl").
-compile(export_all).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-define (NUM_PER_PAGE, 30).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) -> 
	Bindings = cowboy_req:get(bindings, Req),
	Req2 = case lists:keyfind(tab, 1, Bindings) of
		false -> 
			show_all_tables(Req);
		{_, Tab0} ->
			Tab = util:to_atom(Tab0),
			{Page, Req1} = cowboy_req:qs_val(<<"page">>, Req),
			show_table_data(Req1, Tab, Page)
	end,
	{ok, Req2, State}.

	
terminate(_Reason, _Req, _State) ->
	ok.


show_all_tables(Req) ->
	List = [Tab || #tab_config{tab_name = Tab} <- mod_tab_config:all_disc_tabs()],
	ListOfList = util_list:divid_list_by_num(List, 10),
	Dict = [{"tables", ListOfList}, {"col_num", lists:seq(1, 10)}, {"table_num", length(List)}],
	{ok, Reply} = page_all_tables:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


show_table_data(Req, Tab, Page) -> 
	case Page of
		undefined -> Page2 = 1;
		_ -> Page2 = util:to_integer(Page)
	end,
	Rec = lists:keyfind(Tab, #tab_config.tab_name, mod_tab_config:all_disc_tabs()),
	TableSize = db_api:size(Tab),
	Datas = get_tab_all_datas(Tab),
	PageSize = util:ceil(TableSize / ?NUM_PER_PAGE),
	Start = 1 + (Page2 - 1) * ?NUM_PER_PAGE,
	Dict = [
		{"table_size", TableSize},
		{"page", Page2},
		{"page_size_list", lists:seq(1, PageSize)},
		{"fields", Rec#tab_config.attrs},
		{"datas", lists:sublist(Datas, Start, ?NUM_PER_PAGE)}
	],
	{ok, Reply} = page_table_content:render(Dict),
	{ok, Req2} = cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Reply, Req),
	Req2.


% get_tab_all_datas(Tab = t_field_battle) -> 
% 	[begin R2 = R#t_field_battle{targets = util_str:term_to_str(R#t_field_battle.targets)}, tl(tuple_to_list(R2)) end || R <- db:load_all(Tab)];
get_tab_all_datas(Tab) -> 
	[tl(tuple_to_list(R))  || R <- db:load_all(Tab)].

