%% @doc 没有具体分类的一些杂项方法
-module (util_misc).
-include("common.hrl").
-export ([get_process_dict/2, safe_exe_fun/1, ip_to_str/1]).
-export ([raw_log/4]).
-export ([is_valid_account/1, list_2_atom/1, msg_handle_cast/3]).
-export ([recv_pt/2, send_pt/1, debug_is_acc_allow/1]).

%% 获取当前进程的进程字典数据，如果不存在则返回第二个参数默认值
get_process_dict(Key, Default) ->
    case erlang:get(Key) of
        undefined -> Default;
        Val -> Val
    end.


%% 带时间、文件、行号的io:format
raw_log(Format, Args, File, Line) ->
    io:format("~w.erl:~w " ++ Format ++ "~n", [File, Line | Args]).


is_valid_account(Account) ->
    case length(Account) > 0 of
        true ->
            case re:run(Account, "[^a-zA-Z0-9_\-]") of
                nomatch -> true;
                _ -> false
            end;
        _ -> false
    end.


list_2_atom(List) when is_list(List) -> 
	%% 使用list_to_existing_atom是为了避免使用list_to_atom造成大量的atom资源消耗
	%% 然后如果有多次转为atom调用时，使用list_to_existing_atom性能也快一些。
    case catch(list_to_existing_atom(List)) of
        {'EXIT', _} -> erlang:list_to_atom(List);
        Atom when is_atom(Atom) -> Atom
    end.


msg_handle_cast(Pid, Mod, Msg) ->
	gen_server:cast(Pid, {handle_msg,Mod,Msg}).


recv_pt(Name, Pt) -> 
    case code:which(test_print_pt) of
        non_existing -> skip;
        _ -> test_print_pt:recv_pt(Name, Pt)
    end.


send_pt(Data) -> 
    case code:which(test_print_pt) of
        non_existing -> skip;
        _ -> test_print_pt:send_pt(Data)
    end.


debug_is_acc_allow(Acc) ->
    case code:which(test_print_pt) of
        non_existing -> true;
        _ ->
            case erlang:function_exported(test_print_pt, is_acc_allow, 1) of
                true -> test_print_pt:is_acc_allow(Acc);
                _ -> true
            end
    end.

safe_exe_fun(Fun) -> 
    ?TRY_CATCH(Fun, Error, Reason).


ip_to_str(Ip) -> 
    case Ip of
        {P1, P2, P3, P4} -> 
            lists:concat([P1, ".", P2, ".", P3, ".", P4]);
        _ -> 
            Ip
    end.
