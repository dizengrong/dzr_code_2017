-module(work_helper_app).
-include("common.hrl").
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/static/[...]", cowboy_static, {dir, "./static", []}},
			{"/", home_handler, []},
			{"/gm_codes[/:sub]", gm_codes_handler, []},
			{"/onlines", onlines_handler, []},
			{"/scenes[/:pid]", scenes_handler, []},
			{"/srv_process[/:pid]", srv_process_handler, []},
			{"/onlines/property/[:uid]", onlines_handler, []},
			{"/onlines/db/[:uid]", onlines_handler, []},
			{"/onlines/agent_dict/[:uid]", onlines_handler, []},
			{"/onlines/scene_dict/[:uid]", onlines_handler, []},
			{"/view_table[/:tab]", view_db_tables_handler, []}
		]}
	]),
	Port = server_config:get_conf(web_port),
	cowboy:start_http(http, 100, [{port, Port}], [{env, [{dispatch, Dispatch}]}]),
	work_helper_sup:start_link().

stop(_State) ->
	ok.
