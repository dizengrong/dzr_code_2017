-define (INFO(Format),  
	io:format("~p:~p:" ++ Format ++ "~n", [?MODULE,?LINE])
).
-define (INFO(Format, Args), 
	io:format("~p:~p:" ++ Format ++ "~n", [?MODULE,?LINE] ++ Args)
). 