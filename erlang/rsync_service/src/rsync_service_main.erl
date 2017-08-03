-module (rsync_service_main).
-compile ([export_all]).

start() ->
	ok = application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowlib),
	ok = application:start(cowboy),
	ok = application:start(rsync_service),
	ok. 
