-module (fun_medicine).
-include("common.hrl").
-export([add_buff/7,send_info_to_client/3,is_buff/2]).

get_data(Uid) ->
	List = fun_usr_misc:get_misc_data(Uid, medicine),
	List.

set_data(Uid, Val) ->
	fun_usr_misc:set_misc_data(Uid, medicine, Val).

add_buff(Uid, Sid, Type, ItemID, Num, Time, Multi) -> 
	List = get_data(Uid),
	Now = util_time:unixtime(),
	case Num > 0 of
		true -> TIME = Num * Time;
		_ -> TIME = Time
	end,
	case lists:keyfind(Type, 1, List) of
		false -> 
			NewList = lists:keystore(Type, 1, List, {Type, ItemID, Multi, Now+TIME}),
			set_data(Uid, NewList),
			send_info_to_client(Uid, Sid, 0);
		{Type, _, Multi1, Time1} ->
			case Multi == Multi1 of
				true ->
					case Time1 >= Now of
						true ->
							NewList = lists:keystore(Type, 1, List, {Type, ItemID, Multi1, Time1+TIME}),
							set_data(Uid, NewList),
							send_info_to_client(Uid, Sid, 0);
						_ ->
							NewList = lists:keystore(Type, 1, List, {Type, ItemID, Multi1, Now+TIME}),
							set_data(Uid, NewList),
							send_info_to_client(Uid, Sid, 0)
					end;
				_ -> 
					NewList = lists:keystore(Type, 1, List, {Type, ItemID, Multi1, Now+TIME}),
					set_data(Uid, NewList),
					send_info_to_client(Uid, Sid, 0)
			end
	end.

send_info_to_client(Uid, Sid, Seq) ->
	List = get_data(Uid),
	Now = util_time:unixtime(),
	Fun = fun({_, ItemID, _, EndTime}) ->
		#pt_public_buff_list{id=ItemID,end_time=EndTime-Now}
	end,
	List1 = lists:map(Fun, List),
	Fun1 = fun(#pt_public_buff_list{end_time=Time}) ->
		if Time >= 0 -> true;
			true -> false
		end
	end,
	Data = lists:filter(Fun1, List1),
	Pt = #pt_medicine{
		buff = Data
	},
	?send(Sid, proto:pack(Pt, Seq)).

is_buff(Uid, Type) ->
	List = get_data(Uid),
	case lists:keyfind(Type, 1, List) of
		false -> {false ,0};
		{Type, _, Multi, EndTime} -> {true, Multi/100, EndTime}
	end.