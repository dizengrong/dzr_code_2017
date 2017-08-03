%% @author dzr
%% @doc 同步处理
-module(rsync_handler).
-include("common.hrl").
-export([init/0, rsync_to_server/1, rsync_from_server/0]).
-export([init_exclude_pattern/0, get_exclude_pattern_re/0]).

rsync_from_server() ->
	Dirs = setting:watch_dirs(),
	init_rsync_from_server(Dirs).

init() ->
	Dirs = setting:watch_dirs(),
	?INFO("init sync from server......"),
	case init_rsync_from_server(Dirs) of 
		true -> 
			?INFO("init sync to server......"),
			case init_rsync_to_server(Dirs) of
				false -> 
					?INFO("init rsync_to_server failed, stop starting!"),
					false;
				true -> true
			end;
		false -> 
			?INFO("init rsync_from_server failed, stop starting!"),
			false
	end.

init_rsync_from_server([]) -> true;
init_rsync_from_server([WatchDir | Rest]) ->
	 case rsync_from_server(WatchDir) of
	 	true  -> init_rsync_from_server(Rest);
	 	false -> false
	 end.

init_rsync_to_server([]) -> true;
init_rsync_to_server([WatchDir | Rest]) ->
	 case rsync_to_server(WatchDir) of
	 	true  -> init_rsync_to_server(Rest);
	 	false -> false
	 end.

%% 同步：本地===>服务器
%% 成功返回:true 失败返回:false
rsync_to_server(WatchDir) ->
	SrcDir   = get_src_path(WatchDir),
	DestDir  = get_dest_path(),
	KeyFile  = setting:ssh_private_key_file(),
	ServerIp = setting:get_server_ip(),
	User     = setting:get_user(),
	Cmd      = ".\\script\\sync_to_server.cmd " ++ 
			   string:join([KeyFile, SrcDir, User, ServerIp, DestDir], " "),
	OutPut   = os:cmd(Cmd),
    % ?INFO("sync ~p to ~p", [SrcDir, DestDir]),
	Time = io_lib:format(" at ~s~n", [util_time:date_to_string(calendar:local_time())]),
    ?INFO(string:join(string:tokens(OutPut, "\n"), "~n") ++ Time),
    is_success(OutPut).

%% 同步：服务器===>本地
%% 成功返回:true 失败返回:false
rsync_from_server(WatchDir) ->
	try
		SrcDir   = get_src_path(WatchDir),
		DestDir  = get_dest_path(),
		KeyFile  = setting:ssh_private_key_file(),
		ServerIp = setting:get_server_ip(),
		User     = setting:get_user(),
		Cmd     = ".\\script\\sync_from_server.cmd " ++ 
				  string:join([KeyFile, User, ServerIp, DestDir, SrcDir], " "),
		?INFO(Cmd),
		OutPut  = string:strip(os:cmd(Cmd), right, $\n),
		Time = io_lib:format(" at ~s~n", [util_time:date_to_string(calendar:local_time())]),
		?INFO(OutPut ++ Time),
		IsSucc = is_success(OutPut),
		case IsSucc of
			true  -> 
				% sync_notify:growl_success("更新成功", "服务器===>本地");
				ok;
			false -> sync_notify:growl_errors("更新失败", "服务器===>本地")
		end,
		IsSucc
	catch 
		Error:Reason -> 
			sync_notify:growl_errors("更新失败", util_list:to_list(Reason)),
			?INFO("rsync_from_server exception, E: ~p, R: ~p, stack:~p", 
										[Error, Reason, erlang:get_stacktrace()]),
			false
	end.

is_success(OutPut) -> 
	List = string:tokens(OutPut, "\n"),
	case List of
		[] -> false;
		_ ->
			LastLine = lists:last(List),
			% ?INFO("LastLine:~p", [LastLine]),
			lists:prefix("total size", LastLine)
	end.

get_src_path(WatchDir) ->
	SrcDir  = filename:join([WatchDir]),
	makesure_dir(normalize_ssh_path(SrcDir)).
get_dest_path() ->
	%% 上传到服务器的上传目录，实际目录为:HOME/rsync_dir/
	DestDir = filename:join(["rsync_dir/"]),
	makesure_dir(DestDir).

makesure_dir(Dir) ->
    case lists:last(Dir) of
        $/ -> Dir; 
        _ -> Dir ++ [$/]
    end.   

normalize_ssh_path(Path) ->
	case os:type() of
		{unix, _} -> Path;
		{win32, _} -> 
			[Ch, $: | Rest] = Path,
			"/cygdrive/" ++ [Ch] ++ Rest;
		_ -> Path
	end.

init_exclude_pattern() ->
	Patterns = get_exclude_pattern_from_file(),
	PatternStr = make_pattern_re(Patterns, ""),
	put(exclude_pattern, PatternStr).

get_exclude_pattern_re() ->
	case get(exclude_pattern) of
		undefined -> "";
		PatternStr -> PatternStr
	end.

make_pattern_re([], [_Ch | Str]) -> 
	string:substr(Str, 1, length(Str) - 1);
make_pattern_re([Pattern | Rest], Str) ->
	Pattern2 = replace_special_char(Pattern),
	make_pattern_re(Rest, Str ++ "|" ++ Pattern2).

replace_special_char(Pattern) ->
	replace_special_char(Pattern, "").
replace_special_char([], Str) -> Str;
replace_special_char([Ch | Rest], Str) ->
	Str2 = case Ch of
		$* -> Str ++ ".";
		$. -> Str ++ "\\.";
		_  -> Str ++ [Ch]
	end,
	replace_special_char(Rest, Str2).

get_exclude_pattern_from_file() ->
	case file:open("config/rsync_exclude.config", [read, raw, {read_ahead, 128}]) of
		{ok, Fd} ->
			List = get_exclude_pattern_from_file(Fd, []),
			file:close(Fd),
			List;
		_ -> []
	end.

get_exclude_pattern_from_file(Fd, List) ->
	case file:read_line(Fd) of
		eof -> List;
		{ok, Line} ->
			Line1 = string:strip(Line, both, $\n),
			Line2 = string:strip(Line1),
			get_exclude_pattern_from_file(Fd, [Line2 | List])
	end.
