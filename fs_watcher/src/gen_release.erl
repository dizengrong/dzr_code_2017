%% @author dzr
%% @doc 生成release文件
-module(gen_release).
-compile([export_all]).

make_win_release() ->
	
	CnfFile = "fs_watcher.rel.config",
	{ok, [{sys, List}]} = file:consult(CnfFile),
	{_, Path} = lists:keyfind(lib_dirs, 1, List),
	{_, Name} = lists:keyfind(boot_rel, 1, List),
	Path2 = filename:join([Path, Name]),
	%% 先删除原有的目录
	case filelib:is_file(Path2) of
		true  -> os:cmd("rd /s /q " ++ path_to_win_style(Path2));
		false -> ignore
	end,

	%% copy文件到lib目录准备gen release
	{ok, SrcDir} = file:get_cwd(),
	Cmd = "xcopy " ++ path_to_win_style(SrcDir) ++ " " ++ path_to_win_style(Path2) ++ "\\ /e",
	io:format("Cmd:~s~n", [Cmd]),
	Ret = os:cmd(Cmd),
	io:format("~n~s~n", [Ret]),

	io:format("start gen target release......~n", []),
	{ok, Server} = reltool:start_server([{config, filename:join([Path2, CnfFile])}]),
	{ok, Spec} = reltool:get_target_spec(Server),

	ReleaseName = Name ++ "_release",
	RelDir = filename:join([Path2, ReleaseName]),
	file:make_dir(RelDir),
	ok = reltool:eval_target_spec(Spec, code:root_dir(), RelDir),

	%% 一些自定义的目录reltool没法copy，自己copy...
	copy_usr_path(Path2, ReleaseName),
	gen_start_bat_file(Name, RelDir),

	io:format("start gen target zip......~n", []),
	file:set_cwd(Path2),
	{Date, _} = calendar:local_time(),
	ZipFilename = Name ++ "_" ++ util_time:date_to_string(Date) ++ ".zip",
	{ok, ZipFile} = zip:zip(ZipFilename, [ReleaseName]),
	os:cmd("move " ++ path_to_win_style(ZipFile) ++ " ..\\"),
	io:format("    ~s~n", [filename:join([Path, ZipFilename])]),

	%% 成功后删除lib目录
	file:set_cwd(Path),
	io:format("delete lib code dir:~s......~n", [Path2]),
	os:cmd("rd /s /q " ++ path_to_win_style(Path2)),

	init:stop(). 

copy_usr_path(Path, ReleaseName) ->
	List = ["config", "script", "cwRsync", "notifu"],
	[copy_usr_path(Path, UsrPath, ReleaseName) || UsrPath <- List],
	ok.

copy_usr_path(Path, UsrPath, ReleaseName) ->
	SrcDir = filename:join([Path, UsrPath]),
	case filelib:is_file(SrcDir) of
		true  -> 
			DestDir = path_to_win_style(filename:join([Path, ReleaseName, UsrPath])),
			Cmd = "xcopy " ++ path_to_win_style(SrcDir) ++ " " ++ DestDir ++ "\\ /e",
			os:cmd(Cmd),
			io:format("    copy usr path:~s~n", [SrcDir]);
		false -> ignore
	end.

gen_start_bat_file(Name, RelDir) ->
	File = filename:join([RelDir, Name ++ ".cmd"]),
	io:format("    gen start bat file:~s~n", [File]),
	{ok, Fd} = file:open(File, [write]),
	file:write(Fd, "title " ++ Name ++ "\n"),
	file:write(Fd, ".\\bin\\erl.exe\npause"),
	file:close(Fd).

path_to_win_style(Path) ->
	Path2 = filename:join([Path]),
	List  = string:tokens(Path2, "/"),
	string:join(List, "\\").

