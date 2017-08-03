%% @author dzr
%% @doc 获取配置的处理
-module(setting).
-include("common.hrl").
-compile([export_all]).

init() ->
	_Ret = ets:new(rsync_setting, [named_table, set, public, {keypos, 1}]),
	% io:format("ets:~p~n", [ets:info(rsync_setting)]),
    {ok, List} = file:consult("config/base.config"),
	[ets:insert(rsync_setting, Tuple) || Tuple <- List],
	{L1, L2} = lists:unzip(List),
	io:format("using setting:~n", []),
	util_format_table:format_as_row(L1, L2),
	check_watch_dirs_exist(watch_dirs()).

check_watch_dirs_exist([]) -> {false, "watch_dirs is empty"};
check_watch_dirs_exist(Dirs) ->
	check_watch_dirs_exist2(Dirs).

check_watch_dirs_exist2([]) -> true;
check_watch_dirs_exist2([Dir | Rest]) ->
	case filelib:is_file(Dir) of
		false -> {false, io_lib:format("watch_dir ~s is not exist", [Dir])};
		true -> check_watch_dirs_exist2(Rest)
	end.

%% @doc Return the list of all directories to watch
-spec watch_dirs() -> list(string()).
watch_dirs() ->
	Dirs = ets:lookup(rsync_setting, watch_dirs),
    [filename:join([Dir]) || {_, Dir} <- Dirs].

ssh_private_key_file() ->
	[{_, File}] = ets:lookup(rsync_setting, private_key_file),
	File.

get_server_ip() ->
	[{_, Ip}] = ets:lookup(rsync_setting, server_ip),
	Ip.

get_user() ->
	[{_, User}] = ets:lookup(rsync_setting, user),
	User.
