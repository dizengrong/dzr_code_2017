%% @doc 日志app
-module(log_app).

-behaviour(application).

-include("common.hrl").

-export([start/2, stop/1]). 


start(_, _) ->
	init_logger(),
	{ok, SupPid} = log_sup:start_link(),
	{ok, SupPid}.
  

stop(_State) -> 
	ok.


init_logger() ->
	Path = server_config:get_conf(log_path),
	filelib:ensure_dir(Path),
	LogLv = case ?DEBUG_MODE of
		true  -> ?LOG_LV_DEBUG;
		false -> server_config:get_conf(log_level)
	end,
	srv_loglevel:set(LogLv),
	LogFile = util_server:get_log_filename(),
    error_logger:add_report_handler(srv_logger_h, LogFile),
	%% must delete this handler!!!
	error_logger:delete_report_handler(error_logger),
	ok.


