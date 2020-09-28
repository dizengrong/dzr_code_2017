%% @doc 生成erlang协议
-module (gen_protocol_of_erl).
-compile([export_all]).

-define (PROTO_CODE, "./src/pt/pt_code_id.erl").
-define (PROTO_CODE_HRL, "./include/proto_code.hrl").

-define (ONE_PT_HRL_FILE, "./include/pt.hrl").
-define (PROTO_READ_COMMON_FILE, "./src/pt/proto_read_common.erl").
-define (PROTO_WRITE_COMMON_FILE, "./src/pt/proto_write_common.erl").
-define (PROTO_PACK_FILE, "./src/pt/proto_pack.erl").
-define (PROTO_UNPACK_FILE, "./src/pt/proto_unpack.erl").


do(GameProtos, CommonProtos) -> 
	gen_erlang_proto_hrl(GameProtos ++ CommonProtos),
	gen_erlang_common_pt_file(CommonProtos),
	gen_erlang_pack_file(GameProtos),
	gen_erlang_unpack_file(GameProtos),
	NewPtVersion = gen_pt_code_file(GameProtos),
	{ok, NewPtVersion}.


get_msg_code(MsgName) ->
	list_to_integer(string:slice(MsgName, length(MsgName) - 4), 16).

get_msg_name(MsgName) ->
	string:slice(MsgName, 0, length(MsgName) - 5).

gen_pt_code_file(Protos) ->
	Fun = fun({D1, _}, {D2, _}) -> 
		get_msg_code(D1) =< get_msg_code(D2)
	end,
	Protos2 = lists:sort(Fun, Protos),
	{ok, Fd} = file:open(?PROTO_CODE, [write]),
	Head = proto_code_head(),
	NewPtVersion = get_new_pt_version(),
	io:format(Fd, unicode:characters_to_binary(Head, utf8), [NewPtVersion]),
	

	[io:format(Fd, "pack_code(~s) -> ~p;\n", [get_msg_name(M), get_msg_code(M)]) || {M, _} <- Protos2],
	file:write(Fd, "pack_code(_T) -> undefined.\n\n\n"),

	[io:format(Fd, "unpack_fun(~p) -> {~s, ~s};\n", [get_msg_code(M), M, get_msg_name(M)]) || {M, _} <- Protos2],
	file:write(Fd, "unpack_fun(_C) -> {undefined, undefined}.\n\n"),
	
	file:close(Fd),
	io:format("gen ~s succ.~n", [?PROTO_CODE]),
	NewPtVersion.


get_new_pt_version() ->
	try
		pt_code_id:version() + 1
	catch
		_E:_R ->
			1
	end.

proto_code_head() ->
"%% @doc 协议号，这个文件自动生成的，请不要修改
-module (pt_code_id).
-compile([export_all]).

version() -> ~p.

".


gen_route_key(Fd, Protos, Terms) ->
	Fun = fun({RouteKey, ProtoNameList}) ->
		[gen_route_key_help(Fd, RouteKey, Name, Terms) || {Name, _} <- ProtoNameList]
	end,
	[Fun(M) || M <- Protos],
	file:write(Fd, "get_route_key(_C) -> undefined.\n\n\n").

gen_route_key_help(Fd, RouteKey, ProtoName, Terms) ->
	case hd(ProtoName) == $m andalso lists:last(ProtoName) == $s of 
		true -> %% 发给服务端的协议
			ProtoName2 = string:slice(ProtoName, 2, length(ProtoName) - 5),
			case lists:keyfind(ProtoName2, 2, Terms) of
				false ->
					io:format("error:forgot to add protocol code for:~s?~n~n", [ProtoName]),
					halt(1);
				Term -> 
					ProtoCode = element(1, Term),
					file:write(Fd, lists:concat(["get_route_key(", ProtoCode, ") -> ", RouteKey, ";\n"]))
			end;
		_ -> ok
	end.


%% 将所有的协议定义头文件include到一个头文件
gen_erlang_proto_hrl(Protos) ->
	% {MsgName, Fields}
	{ok, Fd} = file:open(?ONE_PT_HRL_FILE, [write]),
	file:write(Fd, unicode:characters_to_binary("%% @doc 这个文件自动生成的，请不要修改\n\n", utf8)),
	Fun = fun(MsgName, Fields) -> 
		case string:prefix(MsgName, "pt_public_") of
			nomatch -> 
				MsgName2 = string:slice(MsgName, 0, length(MsgName) - 5);
			_ -> 
				MsgName2 = MsgName
		end,
		io:format(Fd, "-record(~s, {~s}).\n", [MsgName2, make_record_fields_str(Fields)])
	end,
	[Fun(MsgName, Fields) || {MsgName, Fields} <- Protos],
	file:close(Fd),
	io:format("gen ~s succ.~n", [?ONE_PT_HRL_FILE]).


make_record_fields_str(Fields) ->
	Fun = fun({_Type, Name, DefaultVal}) -> 
		Name ++ " = " ++ field_defalt_val(DefaultVal)
	end,
	List = [Fun(E) || E <- Fields],
	string:join(List, ", ").

field_defalt_val("null") -> "undefined";
field_defalt_val("") -> "<<>>";
field_defalt_val("\"\"") -> "<<>>";
field_defalt_val(Val) -> Val.


gen_erlang_common_pt_file(Protos) ->
	{ok, Fd} = file:open(?PROTO_READ_COMMON_FILE, [write, {encoding, utf8}]),
	io:format(Fd, header_read_common(), []),
	[gen_one_msg_unpack(Fd, P) || P <- Protos],
	file:close(Fd),
	io:format("gen ~s succ.~n", [?PROTO_READ_COMMON_FILE]),

	{ok, Fd2} = file:open(?PROTO_WRITE_COMMON_FILE, [write, {encoding, utf8}]),
	io:format(Fd2, header_write_common(), []),
	[gen_one_msg_pack(Fd2, P) || P <- Protos],
	file:close(Fd2),
	io:format("gen ~s succ.~n", [?PROTO_WRITE_COMMON_FILE]).

%% 生成erlang的打包模块文件
gen_erlang_pack_file(Protos) -> 
	{ok, Fd} = file:open(?PROTO_PACK_FILE, [write, {encoding, utf8}]),
	io:format(Fd, header_erl_pack(), []),
	[gen_one_msg_pack(Fd, P) || P <- Protos],
	file:close(Fd),
	io:format("gen ~s succ.~n", [?PROTO_PACK_FILE]).


%% 生成erlang的解包模块
gen_erlang_unpack_file(Protos) ->
	{ok, Fd} = file:open(?PROTO_UNPACK_FILE, [write, {encoding, utf8}]),
	io:format(Fd, header_erl_unpack(), []),
	[gen_one_msg_unpack(Fd, P) || P <- Protos],
	file:close(Fd),
	io:format("gen ~s succ.~n", [?PROTO_UNPACK_FILE]).


header_read_common() ->
"%% @doc 这个文件自动生成的，请不要修改
-module(proto_read_common).
-compile(export_all).
-include(\"proto_helper.hrl\").


".

header_write_common() ->
"%% @doc 这个文件自动生成的，请不要修改
-module(proto_write_common).
-compile(export_all).
-include(\"proto_helper.hrl\").


".

header_erl_pack() -> 
"%% @doc 这个文件自动生成的，请不要修改
-module(proto_pack).
-compile(export_all).
-include(\"proto_helper.hrl\").


".

gen_one_msg_pack(Fd, {MsgName, Fields}) -> 
	case string:prefix(MsgName, "pt_public_") of
		nomatch -> 
			MsgName2 = string:slice(MsgName, 0, length(MsgName) - 5);
		_ -> 
			MsgName2 = MsgName
	end,
	Str2 = make_pack_str(MsgName2, Fields),
	file:write(Fd, Str2).

make_fields_str(0) -> 
	"";
make_fields_str(FieldNum) -> 
	List = ["V" ++ integer_to_list(N) || N <- lists:seq(1, FieldNum)],
	string:join(List, ", ").

make_pack_str(MsgName, []) ->
	util_str:format_string("~s(_) -> \n\t<<>>.\n\n", [MsgName]);
make_pack_str(MsgName, Fields) ->
	StrList = make_pack_str_help(Fields, lists:seq(1, length(Fields)), []),
	Str = "\t<<" ++ string:join(StrList, ", ") ++ ">>.\n\n",
	util_str:format_string("~s({_, ~s}) -> \n~s", [MsgName, make_fields_str(length(Fields)), Str]).


make_pack_str_help([{F, _, _} | Rest1], [N | Rest2], Acc) ->
	S = case F of
		"bool" -> util_str:format_string("?WBOOL(V~p)", [N]);
		"int8" -> util_str:format_string("?WBYTE(V~p)", [N]);
		"uint8" -> util_str:format_string("?WBYTE(V~p)", [N]);
		"byte" -> util_str:format_string("?WBYTE(V~p)", [N]);
		"int16" -> util_str:format_string("?WINT16(V~p)", [N]);
		"uint16" -> util_str:format_string("?WUINT16(V~p)", [N]);
		"int32" -> util_str:format_string("?WINT32(V~p)", [N]);
		"uint32" -> util_str:format_string("?WUINT32(V~p)", [N]);
		"int64" -> util_str:format_string("?WINT64(V~p)", [N]);
		"uint64" -> util_str:format_string("?WUINT64(V~p)", [N]);
		"float" -> util_str:format_string("?WFLOAT(V~p)", [N]);
		"string" -> util_str:format_string("?WSTRING(V~p)", [N]);
		{repeated, Type} -> util_str:format_string("?WLIST(V~p, ~s)", [N, get_real_type(Type)]);
		SelfType -> util_str:format_string("?WTUPLE(V~p, ~s)", [N, get_real_type(SelfType)])
	end,
	make_pack_str_help(Rest1, Rest2, [S | Acc]);
make_pack_str_help([], [], Acc) -> lists:reverse(Acc).


header_erl_unpack() ->
"%% @doc 这个文件自动生成的，请不要修改
-module(proto_unpack).
-compile(export_all).
-include(\"proto_helper.hrl\").

".


gen_one_msg_unpack(Fd, {MsgName, Fields}) -> 
	case string:prefix(MsgName, "pt_public_") of
		nomatch -> 
			MsgName2 = string:slice(MsgName, 0, length(MsgName) - 5);
		_ -> 
			MsgName2 = MsgName
	end,
	Str1 = util_str:format_string("~s(B0) -> \n", [MsgName2]),
	Str2 = make_unpack_str(MsgName2, Fields),
	file:write(Fd, Str1),
	file:write(Fd, Str2).


make_unpack_str(MsgName, []) -> 
	util_str:format_string("\t{{~s}, B0}.\n\n", [MsgName]);
make_unpack_str(MsgName, Fields) -> 
	{StrList, AccFields, LeftBin} = make_unpack_str_help(Fields, 0, "", ""),
	util_str:format_string("~s\n\t{{~s, ~s}, ~s}.\n\n", [string:join(StrList, "\n"), 
														 MsgName, 
														 string:join(AccFields, ", "), 
														 LeftBin]).


make_unpack_str_help([{F, _, _} | Rest], N, Acc, AccFields) ->
	S = case F of
		"bool" -> util_str:format_string("\t{V~p, B~p} = ?RBOOL(B~p),", [N+1, N+1, N]);
		"byte" -> util_str:format_string("\t{V~p, B~p} = ?RBYTE(B~p),", [N+1, N+1, N]);
		"int8" -> util_str:format_string("\t{V~p, B~p} = ?RBYTE(B~p),", [N+1, N+1, N]);
		"uint8" -> util_str:format_string("\t{V~p, B~p} = ?RBYTE(B~p),", [N+1, N+1, N]);
		"int16" -> util_str:format_string("\t{V~p, B~p} = ?RINT16(B~p),", [N+1, N+1, N]);
		"uint16" -> util_str:format_string("\t{V~p, B~p} = ?RUINT16(B~p),", [N+1, N+1, N]);
		"int32" -> util_str:format_string("\t{V~p, B~p} = ?RINT32(B~p),", [N+1, N+1, N]);
		"uint32" -> util_str:format_string("\t{V~p, B~p} = ?RUINT32(B~p),", [N+1, N+1, N]);
		"int64" -> util_str:format_string("\t{V~p, B~p} = ?RINT64(B~p),", [N+1, N+1, N]);
		"uint64" -> util_str:format_string("\t{V~p, B~p} = ?RINT64(B~p),", [N+1, N+1, N]);
		"float" -> util_str:format_string("\t{V~p, B~p} = ?RFLOAT(B~p),", [N+1, N+1, N]);
		"string" -> util_str:format_string("\t{V~p, B~p} = ?RSTRING(B~p),", [N+1, N+1, N]);
		{repeated, Type} -> util_str:format_string("\t{V~p, B~p} = ?RLIST(B~p, ~s),", [N+1, N+1, N, get_real_type(Type)]);
		SelfType -> util_str:format_string("\t{V~p, B~p} = ?RTUPLE(B~p, ~s),", [N+1, N+1, N, get_real_type(SelfType)])
	end,
	make_unpack_str_help(Rest, N + 1, [S | Acc], ["V" ++ integer_to_list(N+1) | AccFields]);
make_unpack_str_help([], N, Acc, AccFields) -> 
	{lists:reverse(Acc), lists:reverse(AccFields), "B" ++ integer_to_list(N)}.


get_real_type(Type) -> 
	Type.
	% case Type of
	% 	"bool" -> "bool";
	% 	"int8" -> "int8";
	% 	"uint8" -> "uint8";
	% 	"int16" -> "int16";
	% 	"uint16" -> "uint16";
	% 	"int32" -> "int32";
	% 	"uint32" -> "uint32";
	% 	"int64" -> "int64";
	% 	"uint64" -> "uint64";
	% 	"float" -> "float";
	% 	"string" -> "string";
	% 	_ -> "pt_public_" ++ Type
	% end.


