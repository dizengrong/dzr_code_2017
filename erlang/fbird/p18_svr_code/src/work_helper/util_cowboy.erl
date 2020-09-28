-module (util_cowboy).
-compile(export_all).


reply_server_error(Req, Reason) ->
	{ok, Req2} = cowboy_req:reply(400, [
		{<<"content-type">>, <<"text/html">>}
	], Reason, Req),
	Req2.

