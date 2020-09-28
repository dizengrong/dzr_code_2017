#!/usr/bin/env escript


main([]) -> 
	code:add_path("./ebin/"),
	makesure_config_compiled(),
	Dir = util_server:make_mnesia_dir(),
  	io:format("\"~s\"", [Dir]);
main([_NoQuat]) -> 
	code:add_path("./ebin/"),
	makesure_config_compiled(),
	Dir = util_server:make_mnesia_dir(),
  	io:format("~s", [Dir]).


makesure_config_compiled() ->
	case code:which(server_config_gen) of
		non_existing ->
			server_config:init();
		_ -> 
			ignore
	end.

