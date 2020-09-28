-module (work_helper_main).
-include("common.hrl").
-compile ([export_all]).

start() ->
	case code:which(cowboy) of
		non_existing -> ?debug("no ranch find, work helper will not start....");
		_ -> 
			WebPort = server_config:get_conf(web_port),
			case is_integer(WebPort) of
				true ->  
    				start_help(),
    				?INFO("start work helper....");
    			_ -> 
    				?INFO("web port is not configured, work helper will not start....")
    		end
    end.

start_help() ->
	application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowlib),
	ok = application:start(cowboy),
	ok = application:start(work_helper),
	?DEBUG_MODE andalso compile_tpl(false),
	ok. 


stop() ->
	application:stop(work_helper),
	application:stop(ranch),
	ok.


compile_tpl() ->
	compile_tpl(true).
compile_tpl(FromShell) ->
	% {_, Path} = lists:keyfind(source, 1, ?MODULE:module_info(compile)),
	% Path = "./src/work_helper",
	% TplPath = filename:join([filename:dirname(Path), "tpl"]),
	TplPath = "./src/work_helper/tpl",
	{ok, List} = file:list_dir(TplPath),
	% BeamPath = filename:dirname(code:which(?MODULE)),
	BeamPath = "./ebin",
	[compile_tpl_help(BeamPath, TplPath, F) || F <- List],
	FromShell andalso init:stop(),
	ok.

compile_tpl_help(BeamPath, Dir, File) ->
	F = filename:join([Dir, File]),
	Ret = erlydtl:compile_file(F, util:list_to_atom2(filename:rootname(File)) , [{out_dir, BeamPath}]),
	io:format("compile tpl:~p, result:~w~n", [File, Ret]),
	ok.

