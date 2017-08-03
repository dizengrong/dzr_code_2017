%% @author dzr
%% @doc 格式化输出table
-module(util_format_table).
-include("common.hrl").
-export([format_as_row/2]).

% util_format_table:format_as_row(["name", "addr", "relationship"], ["dzr", "fdafa", "1"]).
format_as_row(HeadList, ValueList) ->
	MaxHeadLen  = lists:max([length(to_list(H)) || H <- HeadList]),
	MaxValueLen = lists:max([length(to_list(V)) || V <- ValueList]),
	LineLen = 1 + MaxHeadLen + 1 + 1 + 1 + MaxValueLen,
	format_as_row_help(HeadList, ValueList, MaxHeadLen, MaxValueLen, LineLen).

format_as_row_help([], [], MaxHeadLen, MaxValueLen, _LineLen) -> 
	io:format("~s+~s~n", [lists:duplicate(MaxHeadLen+1, "-"),lists:duplicate(MaxValueLen+1, "-")]);
	% io:format("~s~n", [lists:duplicate(LineLen, "-")]);
format_as_row_help([Head | Rest1], [Value | Rest2], MaxHeadLen, MaxValueLen, _LineLen) ->
	% io:format("~s~n", [lists:duplicate(LineLen, "-")]),
	io:format("~s+~s~n", [lists:duplicate(MaxHeadLen+1, "-"),lists:duplicate(MaxValueLen+1, "-")]),
	Len1 = integer_to_list(MaxHeadLen), 
	Len2 = integer_to_list(MaxValueLen), 
	io:format("~." ++ Len1 ++ "s | ~." ++ Len2 ++ "s ~n", [Head, Value]),
	format_as_row_help(Rest1, Rest2, MaxHeadLen, MaxValueLen, _LineLen).

%% @doc convert other type to list
to_list(Msg) when is_list(Msg) -> 
    Msg;
to_list(Msg) when is_atom(Msg) -> 
    atom_to_list(Msg);
to_list(Msg) when is_binary(Msg) -> 
    binary_to_list(Msg);
to_list(Msg) when is_integer(Msg) -> 
    integer_to_list(Msg);
to_list(Msg) when is_float(Msg) -> 
    f2s(Msg);
to_list(Msg) when is_tuple(Msg) ->
	tuple_to_list(Msg);
to_list(_) ->
    throw(other_value).
    
%% @doc convert float to string,  f2s(1.5678) -> 1.57
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.6f", [F]),
	A.    