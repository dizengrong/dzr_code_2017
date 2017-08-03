%% @author dzr
%% @doc 
-module(util_list).
-include("common.hrl").
-export([divid_list/2, to_list/1]).

%% 将lists按DividNum的长度分割，返回分割后的列表
divid_list(List, DividNum) ->
	Len = length(List) div DividNum,
	Fun = fun(_N, {Acc, LeftList}) ->
		{L1, LeftList2} = lists:split(Len, LeftList),
		Acc2 = Acc ++ [L1],
		{Acc2, LeftList2}
	end,
	{ListOfDivid, Left} = lists:foldl(Fun, {[], List}, lists:seq(1, DividNum - 1)),
	ListOfDivid ++ [Left].

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
to_list(_) ->
    throw(other_value).

%% @doc convert float to string,  f2s(1.5678) -> 1.57
f2s(N) when is_integer(N) ->
    integer_to_list(N) ++ ".00";
f2s(F) when is_float(F) ->
    [A] = io_lib:format("~.2f", [F]),
    A.
