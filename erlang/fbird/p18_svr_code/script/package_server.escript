#!/usr/bin/env escript
%% 服务器打包处理

-define (GAME_NAME, "p18").

main([Version0, AgentName, Lang0, TimeZone0, CodeGitHash, ConfigGitHash]) -> 
	code:add_path("./ebin/"),
	Version = case lists:prefix("origin/", Version0) of
		true -> string:sub_string(Version0, 8);
		_ -> Version0
	end,
	[Lang | _] = string:split(Lang0, ":"),
	[TimeZone | _] = string:split(TimeZone0, ":"),
	write_version_file(Version, AgentName, Lang, TimeZone, CodeGitHash, ConfigGitHash),

	os:cmd("chmod +x server_ctrl.sh"),
	NowStr = util_time:local_time_file_str(),
	Files  = "static/css/ script/ ebin/ ebin_lib/ deps/bin/cerl_map_api.so server.config.sample version.txt server_ctrl.sh",
	Cmd    = "zip -x ebin/server_config_gen.beam -r ~s.~s.~s.~s.~s.~s.zip ~s",
	Cmd2   = util_str:format_string(Cmd, [?GAME_NAME, AgentName, Version, Lang, TimeZone, NowStr, Files]),
  	io:format("~s~n", [Cmd2]),
	os:cmd(Cmd2).


write_version_file(Version, AgentName, Lang, TimeZone, CodeGitHash, ConfigGitHash) ->
	{ok, Fd} = file:open("version.txt", [write]),
	file:write(Fd, util_str:format_string("{agent_name, \"~s\"}.\n", [AgentName])),
	file:write(Fd, util_str:format_string("{server_version, \"~s\"}.\n", [Version])),
	file:write(Fd, util_str:format_string("{language, ~s}.\n", [Lang])),
	file:write(Fd, util_str:format_string("{timezone, ~s}.\n", [TimeZone])),
	file:write(Fd, util_str:format_string("{code_git_hash, \"~s\"}.\n", [CodeGitHash])),
	file:write(Fd, util_str:format_string("{config_git_hash, \"~s\"}.\n", [ConfigGitHash])),
	file:close(Fd),
	ok.

