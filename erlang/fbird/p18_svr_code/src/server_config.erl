%% @doc 管理服务器配置模块，所有的配置将以键值对的方式存储
%% 除了基本的配置，其他配置将从中心服务器获取“下载”到本地。
%% 将配置做成在程序里自动生成erl这种方式，有如下两点考虑：
%% 	   1）不用建立额外的保存这些配置的地方，直接读取erlang代码就可以获取了
%%     2）考虑到scene节点也会读取配置，但是scene节点不能访问数据库的，
%%        所以配置改变后，需要重新通知scene节点加载配置文件(log节点可以不考虑的)

-module (server_config).

-export ([init/0, init_local/0]).
-export ([get_conf/1]).

-define (CONFIG_MODULE, server_config_gen).


init() ->
	%% todo:去中心服务器获取配置
	{ok, TupleList1} = file:consult("version.txt"),
	{ok, TupleList2} = file:consult("server.config"),
	case lists:keyfind(timezone, 1, TupleList1) of
		false -> 
			halt("timezone is not configured!!!");
		{_, Timezone} -> 
			Timezone2 = calendar:datetime_to_gregorian_seconds({{1970,1,1}, {Timezone,0,0}}),
			TupleList3 = lists:keystore(timezone, 1, TupleList2, {timezone, Timezone}),
			TupleList4 = lists:keystore(timezone_secs, 1, TupleList3, {timezone_secs, Timezone2}),
			{ok, File} = generate(merge_config(TupleList1, TupleList4)),
			c:c(File, [{outdir, "./ebin/"}])
	end,
	ok.

%% 合并配置，version.txt里的配置将会覆盖server.config里的
merge_config(VersionConfigs, BaseConfigs) ->
	merge_config2(VersionConfigs, BaseConfigs).

merge_config2(Acc, [{Key, Val} | Rest]) ->
	case lists:keyfind(Key, 1, Acc) of
		false -> 
			merge_config2([{Key, Val} | Acc], Rest);
		_ -> 
			merge_config2(Acc, Rest)
	end;
merge_config2(Acc, []) -> Acc.


%% 只初始化本地的配置
init_local() ->
	{ok, TupleList1} = file:consult("version.txt"),
	{ok, TupleList2} = file:consult("server.config"),
	{ok, File} = generate(merge_config(TupleList1, TupleList2)),
	c:c(File, [{outdir, "./ebin/"}]),
	ok.


generate(TupleList) ->
	File     = io_lib:format("./~p.erl", [?CONFIG_MODULE]),
	{ok, Fd} = file:open(File, [write]),

	io:format(Fd, content(), [?CONFIG_MODULE]),
	[file:write(Fd, io_lib:format("get(~p) -> ~p;\n", [Key, Val])) || {Key, Val} <- TupleList],
	file:write(Fd, "get(Key) -> {config_not_exists, Key}.\n"),
	file:close(Fd),

	{ok, File}.


content() ->
"%% @doc server setting(This file is generated automaticly)

-module (~p).
-export([get/1]).

".	

%% @doc 获取配置项 
-spec get_conf(Key::atom()) -> any() | {config_key_error, Key::atom()}.
get_conf(servername) -> %% 这个获取游戏服名称的暂时不处理，也许后面就不需要了 
	"todo:servername";
get_conf(Key) -> ?CONFIG_MODULE:get(Key).

