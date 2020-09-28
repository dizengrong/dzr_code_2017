%% @doc 与字符串相关的一些方法

-module (util_str).
-export([term_to_str/1, str_to_term/1, bin_str_to_term/1, bin_str_to_atom/1]).
-export([bin_str_to_integer/1]).
-export([format_string/2]).


-spec term_to_str(tuple()) -> string().
%% @doc term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_str(Term) ->
	lists:flatten(io_lib:format("~w", [Term])).


-spec str_to_term(string()) -> tuple().
%% @doc term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
%% 由调用者处理错误
str_to_term(String) ->
    {ok, Tokens, _} = erl_scan:string(String ++ "."),
    {ok, Term} = erl_parse:parse_term(Tokens),
	Term.


%% 将形如<<"12">>的数据转为整型
bin_str_to_integer(BinStr) -> 
    list_to_integer(binary_to_list(BinStr)).


bin_str_to_term(BinString) ->
	String = binary_to_list(BinString), 
	str_to_term(String).


%% 将形如<<"atom">>的数据转为原子
bin_str_to_atom(BinStr) -> 
    util:list_to_atom2(binary_to_list(BinStr)).


%% 格式化字符串
format_string(Format, Args) ->
	lists:flatten(io_lib:format(Format, Args)).


