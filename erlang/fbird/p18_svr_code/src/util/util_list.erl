%% @author dzr
%% @doc 
-module(util_list).
-include("common.hrl").
-export([divid_list/2, divid_list_by_num/2, to_list/1, rand/1, rand_taken/1]).
-export([add_and_merge_list/4, random_from_tuple_weights/2]).
-export([keyfind/5]).

%% 将lists分割成DividNum个列表，返回分割后的列表
divid_list(List, DividNum) ->
	% Len = length(List) div DividNum,
    Len = util:ceil(length(List) / DividNum),
	Fun = fun(_N, {Acc, LeftList}) ->
        case length(LeftList) > Len of
            true ->
                {L1, LeftList2} = lists:split(Len, LeftList);
            false ->
                L1 = LeftList, 
                LeftList2 = []
        end,
        Acc2 = case L1 of
            [] -> Acc;
            _  -> Acc ++ [L1]
        end,
		{Acc2, LeftList2}
	end,
	{ListOfDivid, Left} = lists:foldl(Fun, {[], List}, lists:seq(1, DividNum - 1)),
    case Left of 
        [] -> ListOfDivid;
        _ -> ListOfDivid ++ [Left]
    end.


%% 将lists分割成每个子列表包含Num个元素
divid_list_by_num(List, Num) -> 
    divid_list_by_num2(List, Num, []).

divid_list_by_num2(List, Num, Acc) when length(List) >= Num ->
    {E, Left} = lists:split(Num, List),
    divid_list_by_num2(Left, Num, [E | Acc]);
divid_list_by_num2(List, _Num, Acc) -> 
    lists:reverse([List | Acc]).


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

rand(List) ->
    Len = length(List),
    case Len > 0 of
        false -> [];
        true  -> 
            N = rand:uniform(Len),
            lists:nth(N, List)
    end.

%% 从列表里随机出一个元素，并把它从列表中删除，返回:{获得的元素, 剩余的列表}
rand_taken([_ | _] = List) ->
    Len = length(List),
    N = rand:uniform(Len),
    E = lists:nth(N, List),
    {E, lists:delete(E, List)}.


%% 合并两个list，list中的元素为同样的元组
%% KeyIndex为元组的key所在的位置 ValueIndex为元组的值所在的位置
%% 相同key的元组的value将相加后合并到SumList中去
%% return：返回合并后的SumList
add_and_merge_list(SumList, [], _KeyIndex, _ValueIndex) -> SumList;
add_and_merge_list(SumList, [Tuple | Rest], KeyIndex, ValueIndex) ->
    Key = element(KeyIndex, Tuple),
    SumList2 = case lists:keyfind(Key, KeyIndex, SumList) of
        false -> 
            [Tuple | SumList];
        ExistTuple ->
            NewVal = element(ValueIndex, ExistTuple) + element(ValueIndex, Tuple),
            ExistTuple2 = setelement(ValueIndex, ExistTuple, NewVal),
            lists:keystore(Key, KeyIndex, SumList, ExistTuple2)
    end,
    add_and_merge_list(SumList2, Rest, KeyIndex, ValueIndex).


%%@doc 从静态权重列表取出选中的值
%%@param Index 表示Weight字段在Touple中的索引位置
random_from_tuple_weights(WeightList,Index) when is_list(WeightList),is_integer(Index)->
    WtList = lists:map( fun(E)-> erlang:element(Index, E) end, WeightList),
    Idx = random_from_weights(WtList,false),
    lists:nth(Idx, WeightList).

%%@doc 从静态权重列表中获取随机的索引
%%@param WeightList: [3,4,5,100] 权重列表
%%@return Index :: Integer() 
%%            Index>0
random_from_weights(WtList,true) when is_list(WtList)->
    random_from_weights_2(WtList);
random_from_weights(WtList,false) when is_list(WtList)->
    random_from_weights_2(WtList).

random_from_weights_2(WtList) when is_list(WtList)->
    {CalcWeightList,Sum} = calc_weight_list(WtList),
    Length = length(CalcWeightList),
    Random = util:rand(1, Sum),
    Idx = random_from_weights_3(CalcWeightList,1,Random),
    Length+1 - Idx.

random_from_weights_3([],Index,_Random)->
    Index;
random_from_weights_3([H1|T],Index,Random)->
    case T of
        []->
            Index;
        [H2]->
            case H1>=Random andalso Random>H2 of
                true->
                    Index;
                _ ->
                    random_from_weights_3(T,Index+1,Random)
            end;
        [H2|T2] when length(T2)>0->
            case H1>=Random andalso Random>H2 of
                true->
                    Index;
                _ ->
                    random_from_weights_3(T,Index+1,Random)
            end
    end.

calc_weight_list(WeightList)->
    lists:foldl(
      fun(E,AccIn)-> 
              {NewWtList,Sum} = AccIn,
              case E>0 of   %%负数的权重当0来处理
                  true->    Sum2 = E+Sum;
                  _ ->  Sum2 = Sum
              end,
              {[Sum2|NewWtList],Sum2}
      end, {[],0}, WeightList).


%% 同lists:keyfind/3，只不过第4个参数为value所在值的位置，第5个参数为没有找到时的默认值
keyfind(Key, KeyIndex, List, ValueIndex, DefValue) ->
    case lists:keyfind(Key, KeyIndex, List) of
        false -> DefValue;
        Tuple -> element(ValueIndex, Tuple)
    end. 
