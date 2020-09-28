%% @doc 生成item_log.hrl文件
-module (gen_item_log).
-compile([export_all]).


do() ->
	{ok, Pwd} = file:get_cwd(),
	FromoFile = filename:join([Pwd, "include/item_log_define.txt"]),
	{ok, TupleList} = file:consult(FromoFile),

	gen_item_log_hrl(Pwd, TupleList),
	gen_item_log_erl(Pwd, TupleList),
    halt(0).


gen_item_log_hrl(Pwd, TupleList) -> 
	ToFile = filename:join([Pwd, "include/item_log.hrl"]),
	{ok, Fd} = file:open(ToFile, [write, {encoding, utf8}]),
	io:format(Fd, header(), []),
	[write_define(Fd, Id, Define, LogDesc) || {Id, Define, LogDesc} <- TupleList],
	file:close(Fd),
	io:format("gen item_log.hrl success~n"),
	ok.


gen_item_log_erl(Pwd, TupleList) -> 
	ToFile = filename:join([Pwd, "src/item_log.erl"]),
	{ok, Fd} = file:open(ToFile, [write, {encoding, utf8}]),
	io:format(Fd, header(), []),
	io:format(Fd, "-module (item_log).~n", []),
	io:format(Fd, "-include (\"common.hrl\").~n", []),
	io:format(Fd, "-compile([export_all]).~n~n", []),
	[write_get_method(Fd, Define, LogDesc) || {_Id, Define, LogDesc} <- TupleList],
	io:format(Fd, "get(_) -> \"程序未填写\".~n~n", []),
	file:close(Fd),
	io:format("gen item_log.erl success~n"),
	ok.


header() ->
	"%% -*- coding: latin-1 -*-~n%% @doc 物品改变日志定义，此文件是自动生成的，不要在这里面修改，源文件为：item_log_define.txt！~n~n".


write_define(Fd, Id, Define, LogDesc) ->
	io:format(Fd, "-define(~.40s, ~p).\t%% ~ts~n", [Define, Id, LogDesc]).


write_get_method(Fd, Define, LogDesc) ->
	io:format(Fd, "get(?~s) -> \"~ts\";~n", [Define, LogDesc]).

