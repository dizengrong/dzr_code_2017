%% @doc 生成makeifle文件
-module (gen_makefile).
-compile([export_all]).

do() ->
	{ok, Pwd} = file:get_cwd(),
	do(Pwd),
    halt(0).

do(Path) ->
	Filename = filename:join([Path, "Makefile"]),
	{ok, FileIO} = file:open(Filename, [write]),
	DirList = get_erl_file_dir_list(Path),

	file:write(FileIO, "\nSRC_DIRS := "),
	[file:write(FileIO, Dir ++ "/*.erl \\\n\t\t\t") || Dir <- DirList],
	
	file:write(FileIO, "\ninclude ./include.mk\n\n"),

	Str1 = "$(EBIN_DIR)/%.$(EMULATOR): $(hrl) ",
	Str2 = "/%.erl \n\t$(ERLC) $(ERLC_FLAGS) -o $(EBIN_DIR) $<\n",
	[file:write(FileIO, Str1 ++ Dir ++ Str2) || Dir <- DirList],

	file:close(FileIO),
	ok.


get_erl_file_dir_list(Dir) ->
	Fun = fun(Filename, Acc) ->
		Folder = filename:dirname(Filename),
		case lists:member(Folder, Acc) == false andalso is_erl_code_dir(Folder) of
			true -> 
				Acc2 = [Folder | Acc],
				io:format("~p~n", [Folder]);
			false -> 
				Acc2 = Acc
		end,
		Acc2
	end,
	filelib:fold_files(Dir, ".*.erl", true, Fun, []).

is_erl_code_dir(Dir) -> 
	case lists:suffix("/proto_def", Dir) of
		true -> false;
		_ -> 
			case file:list_dir(Dir) of
				{ok, Filenames} ->
					Fun = fun(File) -> filename:extension(File) == ".erl" end,
					lists:any(Fun, Filenames);
				_ -> false
			end
	end.

