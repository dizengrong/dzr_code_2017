%% @doc 新版协议生成工具
-module (gen_new_protocol).
-compile([export_all]).


gen_all(_Args) ->
	GameProtos = parse_proto_define(["src/proto_def/game.proto"]),
	CommonProtos = parse_proto_define(["src/proto_def/common.proto"]),
	
	{ok, NewPtVersion} = gen_protocol_of_erl:do(GameProtos, CommonProtos),
	gen_protocol_of_lua:do(GameProtos, CommonProtos, NewPtVersion),
	gen_protocol_of_cs:do(GameProtos, CommonProtos),
	io:format("gen cs pt succ\n"),
	halt(0).


parse_proto_define(FileList) ->
	parse_proto_define(FileList, []).

parse_proto_define([File | Rest], Acc) ->
	{ok, Binary} = file:read_file(File),
	Str0 = binary_to_list(Binary),
	Str = re:replace(Str0, "//[^\\r\\n]*", "", [{return, list}, global]),
	RegExp = "message[ \\t]\\w*[ \\t]{[ \\r\\n\\t]+[^}]*}",
	case re:run(Str, RegExp, [global, report_errors, {capture, all, list}]) of
		{match, MatchList} ->
			Messages = [parse_one_message(M) || M <- MatchList],
			parse_proto_define(Rest, Messages ++ Acc);
		nomatch -> 
			io:format("~s has no message defined!~n", [File]),
			erlang:halt();
		{error, ErrType} ->
			io:format("~s message defined has some error:~p!~n", [File, ErrType]),
			erlang:halt()
	end;
parse_proto_define([], Acc) -> lists:reverse(Acc).


parse_one_message(Str) ->
	RegExp = "message[ \\t]+([\\w]+)[ \\t\\n\\r]?{([ \\t\\n\\r]+[^}]*)}",
	case re:run(Str, RegExp, [global, report_errors, {capture, all, list}]) of
		{match, MatchList} -> 
			[[_, Msg, FieldsStr]] = MatchList,
			Fields = parse_fields(string:tokens(string:strip(FieldsStr), "\n"), []),
			% io:format("Msg:~s Fields:~p~n", [Msg, Fields]),
			{Msg, Fields};
		_ -> 
			io:format("parse message failed:~s!~n", [Str]),
			erlang:halt()
	end.


parse_fields([Field | Rest], Acc) -> 
	case string:trim(Field) of
		"" -> 
			parse_fields(Rest, Acc);
		_ ->
			% io:format("Field:~p~n", [Field]),
			RegExp = "[ \\t]*(required|repeated)[ \\t]+(\\w+)[ \\t]+(\\w+)[ \\t]*=[ \\t]*([^\;]+)[ \\t]*;[ \\t]*",
			case re:run(Field, RegExp, [global, report_errors, {capture, all, list}]) of
				{match, [Matched]} -> 
					[_, Decorate, Type, Name, DefaultVal] = Matched, 
					% io:format("Type:~p, Name:~p, DefaultVal:~p~n", [Type, Name, DefaultVal]),
					Type2 = case Decorate of
						"repeated" -> {repeated, Type};
						_ -> Type
					end,
					parse_fields(Rest, [{Type2, Name, DefaultVal} | Acc]);
				_ -> 
					io:format("parse field failed:~s!~n", [Field]),
					erlang:halt()
			end
	end;
parse_fields([], Acc) -> lists:reverse(Acc).


