-module(fun_error_report).
-include("common.hrl").

-export([send_error_report/2,send_error_report/3,send_error_report/4]).
send_error_report(Sid,Error)-> send_error_report(Sid,Error,0).
send_error_report(Sid,Error,Seq)-> send_error_report(Sid,Error,Seq,[]).
send_error_report(Sid,Error,Seq,Data) when erlang:is_list(Data)->
	case data_error_info:get_data(Error) of
		#st_error_info{id = Id} -> 
			FunFilter = fun(Arg) ->
								if
									erlang:is_integer(Arg) == true -> true;
									erlang:is_float(Arg) == true -> true;
									erlang:is_list(Arg) == true -> true;
									true -> false
								end
						end,
			Data1 = lists:filter(FunFilter, Data),
			FunMake = fun(Arg) ->
							  if
									erlang:is_integer(Arg) == true -> {1,erlang:integer_to_list(Arg)};
									erlang:is_float(Arg) == true -> {2,erlang:float_to_list(Arg)};
									erlang:is_list(Arg) == true -> {3,Arg}
								end
						end,
			Data2 = lists:map(FunMake, Data1),
			FunSet = fun({Type,DataList}) ->
				#pt_public_normal_info{type=Type,data=DataList}
			end,
			Data22 = lists:map(FunSet, Data2),
			Pt1 = #pt_error_info{error=Id,msg=Data22},
			Pt = proto:pack(Pt1,Seq),
			case get(is_tcp_client) of
				true -> net_tcp_client:send_packet(Sid, Pt);
				_    -> ?send(Sid, Pt)
			end;
		_ -> ?ERROR("error tips:~s not finded", [Error])
	end.



