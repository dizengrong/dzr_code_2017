#!/usr/bin/env escript



main(Modules) -> 
	code:add_path("./ebin/"),
    {{Year, Month, Day}, {Hour, Min, Sec}} = erlang:localtime(),
    ZipFile = util_str:format_string("reload_~w_~.2.0w_~.2.0w_~.2.0w_~.2.0w_~.2.0w.zip", [Year, Month, Day, Hour, Min, Sec]),
    Modules2 = ["ebin/" ++ M ++ ".beam" || M <- Modules],
    Modules3 = string:join(Modules2, " "),
    Cmd = util_str:format_string("zip -j ~s ~s", [ZipFile, Modules3]),
    io:format("~s~n", [Cmd]),
	os:cmd(Cmd).



