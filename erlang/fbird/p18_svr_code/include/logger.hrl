%% 日志处理

%% 日志级别
-define(LOG_LV_CRITICAL, 1).
-define(LOG_LV_ERROR   , 2).
-define(LOG_LV_WARNING , 3).
-define(LOG_LV_INFO    , 4).
-define(LOG_LV_DEBUG   , 5).

%% 带模块tag信息的打印
-ifdef(debug_mode).
	-define(IFDEBUG,true).
	-define(m_debug(Tag,Format), srv_logger:debug_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
	-define(m_debug(Tag,Format, Args), srv_logger:debug_msg(Tag,?MODULE, ?LINE,erlang:get(id),Format, Args)).
-else.
	-define(IFDEBUG,false).
	-define(m_debug(_F, _D), ok).
	-define(m_debug(_F,), ok).
-endif.

-define(M_INFO(Tag,Format), srv_logger:info_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
-define(M_INFO(Tag,Format, Args), srv_logger:info_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).
			      
-define(M_WARNING(Tag,Format), srv_logger:warning_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
-define(M_WARNING(Tag,Format, Args), srv_logger:warning_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).
			      
-define(M_ERROR(Tag,Format), srv_logger:error_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
-define(M_ERROR(Tag,Format, Args), srv_logger:error_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(M_CRITICAL(Tag,Format), srv_logger:critical_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, [])).
-define(M_CRITICAL(Tag,Format, Args), srv_logger:critical_msg(Tag,?MODULE,?LINE,erlang:get(id),Format, Args)).


%% 不带模块tag信息的打印
-ifdef(debug_mode).
	-define(DBG(Args), ?DEBUG("~p==~p",[??Args, Args])).
	-define(DEBUG(Format), srv_logger:debug_msg("",?MODULE,?LINE,erlang:get(id),Format, [])).
	-define(DEBUG(Format, Args), srv_logger:debug_msg("",?MODULE, ?LINE,erlang:get(id),Format, Args)).
-else.
	-define(DBG(Args), ok).
	-define(DEBUG(Format, Args), srv_logger:debug_msg("",?MODULE, ?LINE,undefined,Format, Args)).
	-define(DEBUG(_F,), ok).
-endif.

-define(INFO(Format), srv_logger:info_msg("",?MODULE,?LINE,erlang:get(id),Format, [])).
-define(INFO(Format, Args), srv_logger:info_msg("",?MODULE,?LINE,erlang:get(id),Format, Args)).
                  
-define(WARNING(Format), srv_logger:warning_msg("",?MODULE,?LINE,erlang:get(id),Format, [])).
-define(WARNING(Format, Args), srv_logger:warning_msg("",?MODULE,?LINE,erlang:get(id),Format, Args)).
                  
-define(ERROR(Format), srv_logger:error_msg("",?MODULE,?LINE,erlang:get(id),Format, [])).
-define(ERROR(Format, Args), srv_logger:error_msg("",?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(CRITICAL(Format), srv_logger:critical_msg("",?MODULE,?LINE,erlang:get(id),Format, [])).
-define(CRITICAL(Format, Args), srv_logger:critical_msg("",?MODULE,?LINE,erlang:get(id),Format, Args)).

-define(EXCEPTION_LOG(Type, Reason, Fun, Args),
		?ERROR("~nexception happened when call function: ~w~n"
						"    arguments: ~p~n"
						"    type: ~w~n"
						"    reason: ~w~n"
						"    stack trace: ~p~n~n", 
			 [Fun, Args, Type, Reason, erlang:get_stacktrace()])).


-define (log(F), ?INFO(F)).
-define (log(F, D), ?INFO(F, D)).
-define (log_trace(F), ?INFO(F)).
-define (log_trace(F, D), ?INFO(F, D)).
-define (log_warning(F), ?WARNING(F)).
-define (log_warning(F, D), ?WARNING(F, D)).
-define (log_error(F), ?ERROR(F)).
-define (log_error(F, D), ?ERROR(F, D)).
-define (log_ue(F), ?CRITICAL(F)).
-define (log_ue(F, D), ?CRITICAL(F, D)).
-define (debug(F), ?DEBUG(F)).
-define (debug(F, D), ?DEBUG(F, D)).
