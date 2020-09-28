%% @doc 找出不要的模块
-module (find_unused_mod).
-compile([export_all]).


delete_client_pt() ->
	{ok, Fd} = file:open("F:/p17/unused_pt.txt", [read]),
	delete_client_pt2(Fd, file:read_line(Fd)).

delete_client_pt2(_Fd, eof) ->
	skip;
delete_client_pt2(Fd, {ok, Line}) -> 
	Dir = server_config:get_conf(client_pt_dir),
	F = filename:join(Dir, string:strip(Line, both, $\n) ++ ".cs"),
	file:delete(F),
	io:format("delete ~s~n", [F]),
	delete_client_pt2(Fd, file:read_line(Fd)).

get_all_ptc() ->
	{ok, AllPtcFile} = file:list_dir("src/proto_def"),
	[list_to_atom(filename:rootname(filename:basename(F))) || F <- AllPtcFile].


start() ->
	SrcModDir = "src/pt",
	{ok, AllModFile} = file:list_dir(SrcModDir),
	DirList = get_src_dir_list(),
	AllErlFiles = get_all_erl_files(DirList, AllModFile),
	io:format("~p~n", [AllErlFiles]),

	mod_job_manager:init(),
	ListOfList = util_list:divid_list(AllModFile, 4),
	[mod_job_manager:add_worker(find_worker, fun() -> [do_find(filename:rootname(F), AllErlFiles) || F <- Files] end) || Files <- ListOfList],
	mod_job_manager:start_and_wait(find_worker),
	io:format("finished~n"),
	ok.


get_all_erl_files(DirList, ExceptFile) ->
	get_all_erl_files(DirList, ExceptFile, []).
get_all_erl_files([Dir | Rest], ExceptFile, Acc) -> 
	ErlFiles = filelib:wildcard(Dir ++ "/*.erl"),
	Fun = fun(E, Acc2) -> 
		case lists:member(filename:basename(E), ExceptFile) of
			true -> Acc2;
			_    -> [E | Acc2]
		end
	end,
	Acc2 = lists:foldl(Fun, [], ErlFiles) ++ Acc,
	get_all_erl_files(Rest, ExceptFile, Acc2);
get_all_erl_files([], _ExceptFile, Acc) -> 
	Acc. 


do_find(Pt, []) -> 
	% file:delete(filename:join("src/config/data", Pt ++ ".erl")),
	io:format("~s unused~n", [Pt]),
	ok;
do_find(Pt, [ErlFile | Rest]) -> 
	case catch file:open(ErlFile, [read]) of
		{ok, Fd} -> 
			case do_find_help(Pt, Fd, file:read_line(Fd)) of
				false -> 
					file:close(Fd),
					do_find(Pt, Rest);
				_ -> 
					file:close(Fd),
					ok
			end;
		_ ->
			do_find(Pt, Rest)
	end.


do_find_help(_Pt, _Fd, eof) -> 
	false;
do_find_help(Pt, Fd, {ok, Line}) -> 
	case string:str(Line, Pt) of
		0 -> do_find_help(Pt, Fd, file:read_line(Fd));
		_ -> true
	end.


get_src_dir_list() ->
	[	
		"f:/p17/server",
		"f:/p17/server/src/common",
		"f:/p17/server/src/fun/gm_activity",
		"f:/p17/server/src/fun/ai",
		"f:/p17/server/src/fun/count",
		"f:/p17/server/src/fun/dataCountService",
		"f:/p17/server/src/fun/program_config",
		"f:/p17/server/src/fun/scene_sort",
		"f:/p17/server/src/fun/sdk",
		"f:/p17/server/src/fun/server",
		"f:/p17/server/src/fun/task",
		"f:/p17/server/src/logger",
		"f:/p17/server/src",
		"f:/p17/server/src/network",
		"f:/p17/server/src/pt",
		"f:/p17/server/src/rank",
		"f:/p17/server/src/server/agent_ctr",
		"f:/p17/server/src/server/db",
		"f:/p17/server/src/server/db/update_mnesia",
		"f:/p17/server/src/server/scene_ctr",
		"f:/p17/server/src/test",
		"f:/p17/server/src/tools",
		"f:/p17/server/src/util"
	].
