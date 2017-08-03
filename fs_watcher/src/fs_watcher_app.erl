%%%-------------------------------------------------------------------
%% @doc fs_watcher public API
%% @end
%%%-------------------------------------------------------------------

-module(fs_watcher_app).
-include("common.hrl").

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1, test/0]).

%%====================================================================
%% API
%%====================================================================
start() -> 
	start(undefined, undefined).
start(_StartType, _StartArgs) ->
	case setting:init() of
		{false, Reason} ->
			{ok, Cwd} = file:get_cwd(),
			CnfFile = filename:join([Cwd, "config/base.config"]),
			io:format("start failed for reason:~s~n", [Reason]),
			io:format("please check your config file at:~s~n", [CnfFile]),
			init:stop();
		true ->
			case makesure_server_in_known_hosts() of
				ok ->
					case rsync_handler:init() of
						false -> 
							init:stop();
						_ ->
							Ret = fs_watcher_sup:start_link(),
							sync_notify:growl_success("fs_watcher启动成功！"),
							Ret
					end;
				{error, Reason} ->
					io:format("start failed for reason:~p~n", [Reason])
			end
	end.

makesure_server_in_known_hosts() ->
	User  = string:strip(os:cmd("echo %username%"), both, $\n),
	User2 = string:strip(User, both, $\r),
	Path  = filename:join(["c:\\", "Users", User2, "\.ssh"]),
	case filelib:ensure_dir(Path) of
		ok -> 
			File = filename:join([Path, "known_hosts"]),
			Ip   = setting:get_server_ip(),
			case check_has_sync_server(File, Ip) of
				true  -> ok;
				false -> 
					Str = "\n" ++ Ip ++ " " ++ get_sync_server_key(),
					{ok, FD} = file:open(File, [append]),
					ok = file:write(FD, Str),
					ok = file:close(FD)
			end,
			ok;
		{error, Reason} -> {error, "known_hosts dir not find:" ++ Reason}
	end.

check_has_sync_server(File, Ip) ->
	{ok, FD} = file:open(File, [read]),
	Ret = check_has_sync_server2(FD, Ip),
	ok  = file:close(FD),
	Ret.
check_has_sync_server2(FD, Ip) ->
	case file:read_line(FD) of
		eof -> false;
		{error, _Reason} -> false;
		{ok, Line} ->
			% ?INFO(Line),
			case lists:prefix(Ip, Line) of
				false -> check_has_sync_server2(FD, Ip);
				true -> true
			end
	end.

get_sync_server_key() ->
	"ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBE3ajkY9qMgpTWrgViSkHuqXYbNrzv0i4awo4qbKPqNs7Ji7xtGJokun1Km4fBRfJ3Jt3t0naMZ+ZzUVw48jnJ8=".

%%----------- ---------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
test() -> ok.
