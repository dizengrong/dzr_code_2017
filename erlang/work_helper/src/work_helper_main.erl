-module (work_helper_main).
-compile ([export_all]).

start() ->
	ok = application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowlib),
	ok = application:start(cowboy),
	ok = application:start(work_helper),
	ok. 
