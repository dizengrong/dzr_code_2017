% -include("/media/sf_E_DRIVE/cq_svr_project/cq_res/include/config.hrl").
-include("../../temp/config.hrl").
-include("../../temp/property.hrl").
-define (INFO(Format),  
	io:format("~p:~p:" ++ Format ++ "~n", [?MODULE,?LINE])
).
-define (INFO(Format, Args), 
	io:format("~p:~p:" ++ Format ++ "~n", [?MODULE,?LINE] ++ Args)
). 