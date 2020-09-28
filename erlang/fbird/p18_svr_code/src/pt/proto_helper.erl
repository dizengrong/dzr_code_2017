%% @doc 协议解析的读写方法
-module (proto_helper).
-compile([export_all]).


%% =========================== 协议打包用的write方法 ============================
wbyte(V) ->
    B1 = V rem 256,
    <<B1>>.

wbool(V) ->
    case V =:= false orelse V =:= 0 of
        true  -> <<0>>;
        _     -> <<1>>
    end.

wuint16(V) when is_integer(V) ->
    <<V:16/unsigned>>.

wint16(V) when is_integer(V) ->
    <<V:16/integer-signed>>.

wint32(V) when is_integer(V) ->
    <<V:32/integer-signed>>.

wuint32(V) when is_integer(V) ->
    <<V:32/unsigned>>.

wint64(V) when is_integer(V) ->
    <<V:64/integer-signed>>.

wuint64(V) when is_integer(V) ->
    <<V:64/integer-unsigned>>.

wfloat(V) ->
    <<V:32/float>>.

wstring(Bin) -> 
    case is_binary(Bin) of
        true -> 
            <<(byte_size(Bin)):16,Bin/binary>>;
        _ -> %% string
            Bin2 = list_to_binary(Bin),
            <<(byte_size(Bin2)):16,Bin2/binary>>
    end.

wtuple(V, Type) ->
    <<(proto_write_common:Type(V))/binary>>.

wlist(List, Type) when is_list(List) ->
    Len = length(List),
    Bin = lists:foldl(fun(V, Acc) ->
    <<Acc/binary, (witem(V, Type))/binary>>
                    end, <<>>, List),
    <<Len:16, Bin/binary>>.

witem(V, Type) ->
    case Type of
        byte ->   wbyte(V);
        bool ->   wbool(V);
        int16 ->  wint16(V);
        uint16 ->  wuint16(V);
        int32 ->  wint32(V);
        uint32 ->  wuint32(V);
        int64 ->  wint64(V);
        uint64 ->  wuint64(V);
        float ->  wfloat(V);
        string -> wstring(V);
        _ ->
          wtuple(V, Type)
    end.


%% =========================== 协议解包用的read方法 ============================
rbyte(<<C:8/unsigned, B/binary>>) ->
    {C, B}.

rbool(<<0:8, B/binary>>) ->
    {false, B};
rbool(<<_:8, B/binary>>) ->
    {true, B}.

rint16(<<I:16/integer-signed, B/binary>>) ->
    {I, B}.

ruint16(<<I:16/unsigned, B/binary>>) ->
    {I, B}.

rint32(<<I:32/integer-signed, B/binary>>) ->
    {I, B}.

ruint32(<<I:32/unsigned, B/binary>>) ->
    {I, B}.

rint64(<<I:64/integer-signed, B/binary>>) ->
    {I, B}.

ruint64(<<I:64/integer-unsigned, B/binary>>) ->
    {I, B}.

rfloat(<<I:32/float, B/binary>>) ->
    {I, B}.

rstring(<<Len:16/unsigned-integer, S:Len/binary-unit:8, B/binary>>) ->
    {erlang:binary_to_list(S), B}.

rtuple(B, Type) ->
    proto_read_common:Type(B).


rlist(<<Len:16/unsigned-integer, B/binary>>, Type) ->
    {IsTuple, Func} = case Type of
        int8 ->   {false, fun rbyte/1};
        uint8 ->   {false, fun rbyte/1};
        byte ->   {false, fun rbyte/1};
        bool ->   {false, fun rbool/1};
        int16 ->  {false, fun rint16/1};
        uint16 ->  {false, fun ruint16/1};
        int32 ->  {false, fun rint32/1};
        uint32 ->  {false, fun ruint32/1};
        int64 ->  {false, fun rint64/1};
        uint64 ->  {false, fun ruint64/1};
        float ->  {false, fun rfloat/1};
        string -> {false, fun rstring/1};
        _ -> {true, fun rtuple/2}
    end,

    {List, LeftBin} = lists:foldl(fun(_, {Acc, Bin}) ->
    case IsTuple of
      true ->
        {V, Bin1} = Func(Bin, Type);
      false ->
        {V, Bin1} = Func(Bin)
    end,
    {[V|Acc], Bin1}
    end, {[], B}, lists:seq(1, Len)),
    {lists:reverse(List), LeftBin}.

