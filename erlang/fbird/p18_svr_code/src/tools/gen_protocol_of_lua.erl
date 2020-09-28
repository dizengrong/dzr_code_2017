-module (gen_protocol_of_lua).
-compile([export_all]).

-define (PROTO_MAP_FILE, "pb_map.lua").
-define (PROTO_PACK_FILE, "pb_pack.lua").
-define (PROTO_UNPACK_FILE, "pb_unpack.lua").


do(GameProtos, CommonProtos, NewPtVersion) ->
	put({?MODULE, common_protos}, CommonProtos),
	put(user_type, []),
	gen_pack_file(GameProtos),
	put(user_type, []),
	gen_unpack_file(GameProtos),
	gen_map_file(NewPtVersion, GameProtos),
	ok.


gen_unpack_file(Protos) -> 
	File = filename:join(server_config:get_conf(client_pt_lua_dir), ?PROTO_UNPACK_FILE),
	{ok, Fd} = file:open(File, [write]),
	file:write(Fd, header_unpack()),
	[gen_one_msg_unpack(Fd, P) || P <- Protos],
	file:close(Fd),
	io:format("gen ~s succ.~n", [File]).


gen_pack_file(Protos) ->
	File = filename:join(server_config:get_conf(client_pt_lua_dir), ?PROTO_PACK_FILE),
	{ok, Fd} = file:open(File, [write]),
	file:write(Fd, header_pack()),
	[gen_one_msg_pack(Fd, P) || P <- Protos],
	file:close(Fd),
	io:format("gen ~s succ.~n", [File]).


get_public_self_type_fields(SelfType) ->
	CommonProtos = get({?MODULE, common_protos}),
	{_, Fields} = lists:keyfind(SelfType, 1, CommonProtos),
	Fields.


header_unpack() ->
"module(\"pb_unpack\", package.seeall)

local BOOL = pb.rbool
local BYTE = pb.rbyte
local UI16 = pb.ruint16
local I16 = pb.rint16
local UI32 = pb.ruint32
local I32 = pb.rint32
local I64 = pb.rint64
local FLOAT = pb.rfloat
local STR = pb.rstring
local TUPLE = pb.rtuple
local LIST = pb.rlist
	
".


header_pack() -> 
"module(\"pb_pack\", package.seeall)

local BOOL = pb.wbool
local BYTE = pb.wbyte
local UI16 = pb.wuint16
local I16 = pb.wint16
local UI32 = pb.wuint32
local I32 = pb.wint32
local I64 = pb.wint64
local FLOAT = pb.wfloat
local STR = pb.wstring
local TUPLE = pb.wtuple
local LIST = pb.wlist

".


unpack_lua_function() -> 
"
-- ~s
function ~s(m)
~s
end
".


pack_lua_function() -> 
"
-- ~s
function ~s(t)
~s
end
".


%% ================================ gen unpack ================================= 
gen_one_msg_unpack(Fd, {MsgName, Fields}) ->
	MsgId = string:slice(MsgName, length(MsgName) - 4),
	Str = make_unpack_function_body(Fields),
	Str2 = util_str:format_string(unpack_lua_function(), [MsgId, gen_protocol_of_erl:get_msg_name(MsgName), Str]),
	file:write(Fd, Str2),
	gen_user_define_type_msg_unpack2(Fd, Fields).


make_unpack_function_body([]) ->
	"\t";
make_unpack_function_body(Fields) ->
	StrList = make_unpack_function_body2(Fields, []),
	"\t" ++ string:join(StrList, "\n\t").


make_unpack_function_body2([{Type, Field, _Default} | Rest], Acc) ->
	S = case Type of
		"bool" -> 
			util_str:format_string("m.~s = BOOL()", [Field]);
		"int8" -> 
			util_str:format_string("m.~s = BYTE()", [Field]);
		"uint8" -> 
			util_str:format_string("m.~s = BYTE()", [Field]);
		"int16" -> 
			util_str:format_string("m.~s = I16()", [Field]);
		"uint16" -> 
			util_str:format_string("m.~s = UI16()", [Field]);
		"int32" -> 
			util_str:format_string("m.~s = I32()", [Field]);
		"uint32" -> 
			util_str:format_string("m.~s = UI32()", [Field]);
		"uint64" -> 
			util_str:format_string("m.~s = I64()", [Field]);
		"float" -> 
			util_str:format_string("m.~s = FLOAT()", [Field]);
		"string" -> 
			util_str:format_string("m.~s = STR()", [Field]);
		{repeated, Type2} -> 
			util_str:format_string("m.~s = LIST(\"~s\")", [Field, Type2])
	end,
	make_unpack_function_body2(Rest, [S | Acc]);
make_unpack_function_body2([], Acc) -> 
	lists:reverse(Acc).


gen_user_define_type_msg_unpack2(Fd, [{{repeated, UserDefineType}, _Field, _Default} | Rest]) 
	when UserDefineType /= "uint8" andalso 
		 UserDefineType /= "int8" andalso
		 UserDefineType /= "uint16" andalso
		 UserDefineType /= "int16" andalso
		 UserDefineType /= "int32" andalso
		 UserDefineType /= "uint32" andalso
		 UserDefineType /= "uint64" andalso
		 UserDefineType /= "int64" andalso
		 UserDefineType /= "float" andalso
		 UserDefineType /= "string" -> 
	AllUserTypes = get(user_type),
	case lists:member(UserDefineType, AllUserTypes) of
		false -> 
			case get_public_self_type_fields(UserDefineType) of
				UserDefineTypeFields when is_list(UserDefineTypeFields) -> 
					put(user_type, [UserDefineType | AllUserTypes]), %% 标记这个已经生成过了
					Str = make_unpack_function_body(UserDefineTypeFields),
					Str2 = util_str:format_string(unpack_lua_function(), ["public_pt", UserDefineType, Str]),
					file:write(Fd, Str2),
					gen_user_define_type_msg_unpack2(Fd, UserDefineTypeFields);
				_ -> 
					util_misc:raw_log("user type:~p not defined!", [UserDefineType], ?MODULE, ?LINE)
			end;
		_ -> skip
	end,
	gen_user_define_type_msg_unpack2(Fd, Rest);
gen_user_define_type_msg_unpack2(Fd, [_ | Rest]) -> 
	gen_user_define_type_msg_unpack2(Fd, Rest);
gen_user_define_type_msg_unpack2(_Fd, []) -> 
	ok. 

%% ================================ gen pack ================================= 
gen_one_msg_pack(Fd, {MsgName, Fields}) ->
	MsgId = string:slice(MsgName, length(MsgName) - 4),
	Str = make_pack_function_body(Fields),
	Str2 = util_str:format_string(pack_lua_function(), [MsgId, gen_protocol_of_erl:get_msg_name(MsgName), Str]),
	file:write(Fd, Str2),
	gen_user_define_type_msg_pack2(Fd, Fields).


make_pack_function_body([]) ->
	"\treturn \"\"";
make_pack_function_body(Fields) ->
	StrList = make_pack_function_body2(Fields, []),
	"\tlocal s = \"\"\n\t" ++ string:join(StrList, "\n\t") ++ "\n\treturn s".


make_pack_function_body2([{Type, Field, _Default} | Rest], Acc) ->
	S = case Type of
		"bool" -> 
			util_str:format_string("s = s..BOOL(t.~s)", [Field]);
		"int8" -> 
			util_str:format_string("s = s..BYTE(t.~s)", [Field]);
		"uint8" -> 
			util_str:format_string("s = s..BYTE(t.~s)", [Field]);
		"int16" -> 
			util_str:format_string("s = s..I16(t.~s)", [Field]);
		"uint16" -> 
			util_str:format_string("s = s..UI16(t.~s)", [Field]);
		"int32" -> 
			util_str:format_string("s = s..I32(t.~s)", [Field]);
		"uint32" -> 
			util_str:format_string("s = s..UI32(t.~s)", [Field]);
		"uint64" -> 
			util_str:format_string("s = s..I64(t.~s)", [Field]);
		"float" -> 
			util_str:format_string("s = s..FLOAT(t.~s)", [Field]);
		"string" -> 
			util_str:format_string("s = s..STR(t.~s)", [Field]);
		{repeated, Type2} -> 
			util_str:format_string("s = s..LIST(t.~s, \"~s\")", [Field, Type2])
	end,
	make_pack_function_body2(Rest, [S | Acc]);
make_pack_function_body2([], Acc) -> 
	lists:reverse(Acc).


gen_user_define_type_msg_pack2(Fd, [{{repeated, UserDefineType}, _Field, _Default} | Rest]) 
	when UserDefineType /= "uint8" andalso 
		 UserDefineType /= "int8" andalso
		 UserDefineType /= "uint16" andalso
		 UserDefineType /= "int16" andalso
		 UserDefineType /= "int32" andalso
		 UserDefineType /= "uint32" andalso
		 UserDefineType /= "uint64" andalso
		 UserDefineType /= "int64" andalso
		 UserDefineType /= "float" andalso
		 UserDefineType /= "string" -> 
	AllUserTypes = get(user_type),
	case lists:member(UserDefineType, AllUserTypes) of
		false -> 
			case get_public_self_type_fields(UserDefineType) of
				UserDefineTypeFields when is_list(UserDefineTypeFields) -> 
					put(user_type, [UserDefineType | AllUserTypes]), %% 标记这个已经生成过了
					Str = make_pack_function_body(UserDefineTypeFields),
					Str2 = util_str:format_string(pack_lua_function(), ["public_pt", UserDefineType, Str]),
					file:write(Fd, Str2),
					gen_user_define_type_msg_pack2(Fd, UserDefineTypeFields);
				_ -> 
					util_misc:raw_log("user type:~p not defined!", [UserDefineType], ?MODULE, ?LINE)
			end;
		_ -> skip
	end,
	gen_user_define_type_msg_pack2(Fd, Rest);
gen_user_define_type_msg_pack2(Fd, [_ | Rest]) -> 
	gen_user_define_type_msg_pack2(Fd, Rest);
gen_user_define_type_msg_pack2(_Fd, []) -> 
	ok. 



%% ================================ gen pt map ================================= 
gen_map_file(NewPtVersion, Protos) ->
	Fun = fun({D1, _}, {D2, _}) -> 
		gen_protocol_of_erl:get_msg_code(D1) =< gen_protocol_of_erl:get_msg_code(D2)
	end,
	Protos2 = lists:sort(Fun, Protos),
	File = filename:join(server_config:get_conf(client_pt_lua_dir), ?PROTO_MAP_FILE),
	{ok, Fd} = file:open(File, [write]),
	Str1 = gen_map_code_2_name(Protos2),
	Str2 = gen_map_name_2_code(Protos2),
	io:format(Fd, map_tpl(), [NewPtVersion, Str1, Str2]),
	file:close(Fd),
	io:format("gen ~s succ.~n", [File]).



map_tpl() ->
"
pb_map = 
{
	version = ~p,
	f2m = 
	{
		~s
	},
	m2f = 
	{
		~s
	}
}
".


gen_map_code_2_name(PtcList) ->
	List = [util_str:format_string("~s = ~p", [gen_protocol_of_erl:get_msg_name(M), gen_protocol_of_erl:get_msg_code(M)]) || {M, _} <- PtcList],
	string:join(List, ", \n\t\t").


gen_map_name_2_code(PtcList) ->
	List = [util_str:format_string("[~p] = \"~s\"", [gen_protocol_of_erl:get_msg_code(M), gen_protocol_of_erl:get_msg_name(M)]) || {M, _} <- PtcList],
	string:join(List, ", \n\t\t").


%% =============================================================================