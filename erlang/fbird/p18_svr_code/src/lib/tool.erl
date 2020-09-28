-module(tool).
-include("common.hrl").
-export([send_packet/2, send_packets/2, for/5
		,escape_uri/1,unescape_other/1,unescape_string/1,range/1
		,range/2,range/3,check_str/1]).

send_packet(Sid, Data) ->
	case is_pid(Sid) of
		true ->
			gen_server:cast(Sid, {send, Data});
		false ->
			ok
	end.

send_packets(Sid, Datas) ->
    case is_pid(Sid) of
        true ->
            gen_server:cast(Sid, {sends, Datas});
        false ->
            ok
    end.

for(Max,Max,R,_C,L)->[R(L)];
for(I,Max,R,C,L)->[R(L)|for(I+1,Max,R,C,C(L))].


escape_uri(S) when is_list(S) ->
%%     escape_uri(unicode:characters_to_binary(S));
	escape_uri(list_to_binary(S));
escape_uri(<<C:8, Cs/binary>>) when C >= $a, C =< $z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $A, C =< $Z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $0, C =< $9 ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $. ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $- ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $_ ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) ->
    escape_byte(C) ++ escape_uri(Cs);
escape_uri(<<>>) ->
    "".
escape_byte(C) ->
    "%" ++ hex_octet(C).

hex_octet(N) when N =< 9 ->
    [$0 + N];
hex_octet(N) when N > 15 ->
    hex_octet(N bsr 4) ++ hex_octet(N band 15);
hex_octet(N) ->
    [N - 10 + $A].

unescape_other(Str) ->
	unescape_other(Str, []).
unescape_other([], Acc) ->   
   	lists:reverse(Acc);
unescape_other([$%, H1, H2 |T], Acc) ->
    I1 =util:hex2int(H1),
    I2 =util:hex2int(H2),
    I = I1 * 16 + I2,
	unescape_other(T, [I, $\ |Acc]);
unescape_other([H|T], Acc) ->
    unescape_other(T, [H|Acc]).

unescape_string(Str) ->
	unescape_string(Str, []).
unescape_string([], Acc) ->   
   	lists:reverse(Acc);
unescape_string([$%, H1, H2 |T], Acc) ->
    I1 = util:hex2int(H1),
    I2 = util:hex2int(H2),
    I = I1 * 16 + I2,
	unescape_string(T, [I, []|Acc]);
unescape_string([H|T], Acc) ->
    unescape_string(T, [H|Acc]).

range(Max) when Max >= 1->
	range(1, Max).
range(Min, Max) when Min>=1,Max>=Min->
	range(Min, Max, []).
range(Min, Min, L)->
	[Min|L];
range(_, 0, L)->
	L;
range(Min, Max, L)->
	range(Min, Max-1, [Max|L]).

check_str(Content) when is_binary(Content) ->
	check_str(binary_to_list(Content));
check_str(Content)->
	if
		length(Content)==0 -> false;
		true ->
			String = util_lang:cant_words(),
			UnicodeStr = xmerl_ucs:from_utf8(Content),
			lists:all(fun(Char) -> string:chr(UnicodeStr, Char) == 0 end, String)
	end.