-module (proto).
-include("common.hrl").
-export([pack/1, pack/2, unpack/1]).


unpack(<<PtCode:16/unsigned-integer, Seq:32/unsigned-integer, Bin/binary>>) ->
    {PtMod, Fun} = pt_code_id:unpack_fun(PtCode),
    {Tos, _} = proto_unpack:Fun(Bin),
    {Seq, PtMod, Tos}.


pack(R) ->
    pack(R, 0).
pack(R, Seq) ->
    Class = element(1, R),
    PtCode = pt_code_id:pack_code(Class),
    Bin = proto_pack:Class(R),

    Len = byte_size(Bin) + 10,
    NewLen = Len bxor ?PSW_CODE,
    <<NewLen:32/unsigned-integer, PtCode:16/unsigned-integer, Seq:32/unsigned-integer, Bin/binary>>.

