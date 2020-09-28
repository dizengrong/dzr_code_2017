%-define(log(F, D), syslog_svr:logs("[~p] " ++ F, [?MODULE|D])).
%-define(log(F), syslog_svr:logs("[~p] " ++ F, [?MODULE])).
%-define(mark(), syslog_svr:logs("MARK ~p : ~p ", [ ?MODULE, ?LINE ])). 

-define(mark(), syslog_svr:logs("[~10.10s] : ~p ", [ atom_to_list(?MODULE), ?LINE ])). 

-ifdef(robot).
-define(IFROBOT,true).
-else.
-define(IFROBOT,false).
-endif.

-ifdef(check_time).
-define(mark_time(Data),?log("mark_time now = ~p Data=~p",[util:unixtime(),Data])).
-define(mark(Data),?log("mark Data=~p",[Data])).
-else.
-define(mark_time(Data),ok).
-define(mark(Data),ok).
-endif.

-ifdef(secure).
-define(SECURE,true).
-else.
-define(SECURE,false).
-endif.

-ifdef(gm_cord).
-define(proc_gm_cmd(Uid,Sid,String),gm).
-else.
-define(proc_gm_cmd(Uid,Sid,String),ok).
-endif.

-ifdef(gm_cord).
-define(START_HELPER, true).
-else.
-define(START_HELPER, false).
-endif.

-ifdef(resort).
-define(RESORT,true).
-else.
-define(RESORT,false).
-endif.

-define(error_report(Sid,Error), fun_error_report:send_error_report(Sid, Error)).
-define(error_report(Sid,Error,Seq), fun_error_report:send_error_report(Sid, Error,Seq)).
-define(error_report(Sid,Error,Seq,Data), fun_error_report:send_error_report(Sid, Error, Seq, Data)).

-define(send(Sid, Data), tool:send_packet(Sid, Data)).
-define(sends(Sid, Data), tool:send_packets(Sid, Data)).
-define(send_world(Type,Msg), tool:send_to_world(Type, Msg)).
-define(discon(Sid,Reson,Time), timer:apply_after(Time, gen_server, cast, [Sid, {discon, Reson}])).

%%挂机机器人专用
-define(client_send(Data), gen_server:cast(self(), {send, Data}) ).

-define(str(A), (byte_size(util:to_binary(A))):16/integer, (util:to_binary(A))/binary).
-define(u8,     8/unsigned-integer).
-define(u16,    16/unsigned-integer).
-define(u32,    32/unsigned-integer).
-define(i8,     8/signed-integer).
-define(i16,    16/signed-integer).
-define(i32,    32/signed-integer).
-define(f,      32/float).


-define(rtype_int, read_int).
-define(rtype_short, read_short).
-define(rtype_byte, read_byte).
-define(rtype_str, read_string).
-define(rtype_tuple, read_tuple).

-define(_IF(IF, Expr1), case IF of true -> Expr1; false -> skip end).
-define(_IF(IF, Expr1, Expr2), case IF of true -> Expr1; false -> Expr2 end).


-ifdef(debug_pt).
-define(DEBUG_PRINT_RECV_PACKET(Name, Pt), util_misc:recv_pt(Name, Pt)).
-else.
-define(DEBUG_PRINT_RECV_PACKET(Name, Pt), ok).
-endif.

-ifdef(debug_pt).
-define(DEBUG_PRINT_SEND_PACKET(Data), util_misc:send_pt(Data)).
-else.
-define(DEBUG_PRINT_SEND_PACKET(Data), ok).
-endif.

-ifdef(debug_mode).
-define(DEBUG_IS_ACC_ALLOW(Acc), util_misc:debug_is_acc_allow(Acc)).
-else.
-define(DEBUG_IS_ACC_ALLOW(Acc), true).
-endif.


-define(TRY_CATCH(Fun, Error, Reason), 
	try 
		Fun()
	catch 
		Error:Reason -> ?EXCEPTION_LOG(Error, Reason, Fun, {})
	end
).