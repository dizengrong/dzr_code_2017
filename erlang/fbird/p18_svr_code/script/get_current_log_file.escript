#!/usr/bin/env escript


main([]) -> 
	code:add_path("./ebin/"),
	try
		Dir = util_server:get_log_filename(),
  		io:format("~s", [Dir])
	catch
		_E:_R ->
			io:format("log_file_not_exists")
	end.



