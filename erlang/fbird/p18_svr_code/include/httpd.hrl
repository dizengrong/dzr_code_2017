%% -define(HTTPD_LISTEN_SET, [
%% 						   %% Mandatory properties
%% 						   {port, 5000 },
%% 						   {server_name, "localhost" },
%% 						   {document_root, "."},
%% 						   {server_root, "." },
%% 						   
%% 						   %% Communication properties 
%% 						   {com_type, ssl },
%% 						   
%% 						   %% ssl properties
%% 						   {socket_type, ssl},
%% 						   {ssl_verify_client, 1},
%% 						   {ssl_ca_certificate_file, "./okjoysCA.crt"},
%% 						   {ssl_certificate_file, "./webgameserver.crt"},
%% 						   {ssl_certificate_key_file, "./webgameserver.key.nopass"},
%% 						   
%% 						   %% Administrative properties 
%% %% 						   {mime_types, "conf/mime.types" },
%% %% 						   {mime_type, "application/octet-streasm" },
%% %% 						   {server_admin, "the-ebbs-garden@googlegroups.com" },
%% %% 						   {log_format, combined }, 
%% 
%% 						   %% URL aliasing properties - requires mod_alias 
%% %% 						   {directory_index, ["index.html", "index.htm"] }, 
%% 
%% 						   %% Log properties - requires mod_log 
%% %% 						   {error_log, "logs/error.log" }, 
%% %% 						   {security_log, "logs/security.log" }, 
%% %% 						   {transfer_log, "logs/access.log" },
%% 						   
%% 						   %%modules
%% 						   {modules,[mod_esi]},						   
%% 						   {erl_script_alias, {"/rpc", [lib_http_rpc, io]}}
%% 						   ]).
%% -ifdef(inline).
%% -define(HTTPD_GM_SET, "https://gswjs.dev.okjoys.com:4439/mail/pending").
%% -define(HTTPD_GM_RE, "https://gswjs.dev.okjoys.com:4439/mail/sent").
%% -define(HTTPD_PAY_SET, "https://gswjs.dev.okjoys.com:4439/pkg/sent").
%% -define(HTTPD_GETSID, "https://gswjs.dev.okjoys.com:4439/pkg/get_sid").
%% -define(HTTPD_CARD_CHECK, "https://gswjs.dev.okjoys.com:4439/act_code/check").
%% -define(HTTPD_FCM_SET, "https://gcwjs.dev.okjoys.com:4440/real_info/save").
%% -else.
%% -define(HTTPD_GM_RE, "https://gs.wjs.okjoys.com:4439/mail/sent").
%% -define(HTTPD_GM_SET, "https://gs.wjs.okjoys.com:4439/mail/pending").
%% -define(HTTPD_GETSID, "https://gs.wjs.okjoys.com:4439/pkg/get_sid").
%% -define(HTTPD_PAY_SET, "https://gs.wjs.okjoys.com:4439/pkg/sent").
%% -define(HTTPD_CARD_CHECK, "https://gs.wjs.okjoys.com:4439/act_code/check").
%% -define(HTTPD_FCM_SET, "https://gc.wjs.okjoys.com:4440/real_info/save").
%% -endif.
-define(HTTPD_GM_SSL_SET, {ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}).
-define(HTTPD_PAY_SSL_SET, {ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}).
-define(HTTPD_CARD_SSL_SET, {ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}).
-define(HTTPD_FCM_SSL_SET, {ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}).
-define(HTTPD_PHONE_SSL_SET, {ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}).
-define(HTTPD_MAIL_SSL_SET, {ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}).

%%http://localhost:9000/rpc/fun_http_rpc:post?a=1111111
%% https://localhost:9000/rpc/fun_http_rpc:post?a=1111111  ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{ password,"123456"}]
%%httpc:request(get,{"https://localhost:9000/rpc/fun_http_rpc:post?a=1111111",[]},[?HTTPD_PAY_SSL_SET],[]),
%%httpc:request(get,{"https://localhost:9000/rpc/fun_http_rpc:post?a=1111111",[]},[{ssl,[{certfile,"wjs.crt"},{keyfile,"wjs.key"},{password,"123456"}]}],[]),
%% -define(HTTPD_PAY_SSL_SET, {}).
%% -define(HTTPD_LISTEN_SET, [
%% 			   %% Mandatory properties
%% 			   {port, 9000 },
%% 			   {server_name, "slzj"},
%% 			   {bind_address, {0,0,0,0}},
%% 			   {document_root, "."},
%% 			   {server_root, "." },
%% 			   
%% 			   %% Communication properties 
%% %		      {com_type, ssl },
%% 			   
%% 			   %% ssl properties
%% %			   {socket_type, ssl},
%% %		  	   {ssl_verify_client, 1},
%% %		       {ssl_ca_certificate_file, "./okjoysCA.crt"},
%%  %    		   {ssl_certificate_file, "./webgameserver.crt"},
%%  %    		   {ssl_certificate_key_file, "./webgameserver.key.nopass"},
%% 			   
%% 			   %% Administrative properties 
%% %% 						   {mime_types, "conf/mime.types" },
%% %% 						   {mime_type, "application/octet-streasm" },
%% %% 						   {server_admin, "the-ebbs-garden@googlegroups.com" },
%% %% 						   {log_format, combined }, 
%% 
%% 			   %% URL aliasing properties - requires mod_alias 
%% %% 						   {directory_index, ["index.html", "index.htm"] }, 
%% 
%% 			   %% Log properties - requires mod_log 
%% %% 						   {error_log, "d:\error.log" }, 
%% %% 						   {security_log, "d:\security.log" }, 
%% %% 						   {transfer_log, "d:\access.log" },
%% 			   
%% 			   %%modules
%% 			   {modules,[mod_esi]},						   
%% 			   {erl_script_alias, {"/rpc", [fun_http_rpc, io]}}
%% 			   ]).


-define(SUCC_RET_DATAS, [{"state",1},{"msg", <<"succ">>}]).
-define(FAIL_RET_DATAS(Reason), [{"state",0},{"msg", util:to_binary(Reason)}]).
-define(ENCODE_SUCC_RET_DATAS, rfc4627:encode({obj, ?SUCC_RET_DATAS})).