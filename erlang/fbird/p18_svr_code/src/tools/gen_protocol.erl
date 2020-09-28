%% @doc 生成协议工具
-module (gen_protocol).
-compile([export_all]).

proto_temp() -> 
"message pt_~p_~s {
~s}

".

proto_temp2() -> 
"message pt_public_~p {
~s}

".

parse_from_old_ptc() ->
	List = all_ptc:get_list() ++ all_ptc:get_new_list(),
	{ok, Fd} = file:open("./src/proto_def/game.proto", [write, {encoding, utf8}]),
	[write_ptc_2_proto(Fd, Ptc) || Ptc <- List, Ptc /= ptc_public_class],
	
	{ok, Fd2} = file:open("./src/proto_def/common.proto", [write, {encoding, utf8}]),
	[write_common_ptc_2_proto(Fd2, Ptc) || Ptc <- ptc_public_class:get_all(), ptc_public_class:get_des(Ptc) /= no],
	ok.

write_ptc_2_proto(Fd, Ptc) ->
	Fun = fun({FieldName, Type, DefaultVal}, Acc) ->
		case Type of
			{list, Type2} -> Decorate = "repeated";
			_ -> Type2 = Type, Decorate = "required"
		end,
		Acc ++ util_str:format_string("\t~s ~s ~p = ~p;\n", [Decorate, get_real_type(Type2), FieldName, DefaultVal])
	end,
	Str = lists:foldl(Fun, "", Ptc:get_des()),
	io:format(Fd, proto_temp(), [Ptc:get_name(), string:to_lower(integer_to_list(Ptc:get_id(), 16)), Str]),
	ok.

write_common_ptc_2_proto(Fd, Ptc) ->
	Fun = fun({FieldName, Type, DefaultVal}, Acc) ->
		case Type of
			{list, Type2} -> Decorate = "repeated";
			_ -> Type2 = Type, Decorate = "required"
		end,
		Acc ++ util_str:format_string("\t~s ~s ~p = ~p;\n", [Decorate, get_real_type(Type2), FieldName, DefaultVal])
	end,
	Str = lists:foldl(Fun, "", ptc_public_class:get_des(Ptc)),
	io:format(Fd, proto_temp2(), [Ptc, Str]),
	ok.

gen_all(_Args) -> 
	io:format("~n==================== begin gen protocol ====================~n"),
	server_config:init(),
	Dir = server_config:get_conf(temp_erl_pt_dir),
	true = is_list(Dir),
	filelib:ensure_dir(Dir),
	compile_ptc_files(),
	all_ptc:write(),
	io:format("===================== end gen protocol =====================~n~n"),
	halt(0).


compile_ptc_files() -> 
	Dir = server_config:get_conf(temp_erl_pt_dir),
	{ok, List} = file:list_dir("./src/proto_def/"),
	Opts = [{outdir, Dir}],
	[c:c(filename:join("./src/proto_def/", File), Opts) || File <- List],
	ok.

get_real_type(Type) -> 
	case Type of
		bool -> "bool";
		int8 -> "int8";
		uint8 -> "uint8";
		int16 -> "int16";
		uint16 -> "uint16";
		int32 -> "int32";
		uint32 -> "uint32";
		int64 -> "int64";
		uint64 -> "uint64";
		float -> "float";
		string -> "string";
		_ -> "pt_public_" ++ atom_to_list(Type)
	end.

