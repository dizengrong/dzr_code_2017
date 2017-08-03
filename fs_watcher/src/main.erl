-module (main).
-compile ([export_all]).

start() ->
	% ok = lager:start(),	%% 启动日志app
	ok = application:start(fs_watcher),
	ok. 
