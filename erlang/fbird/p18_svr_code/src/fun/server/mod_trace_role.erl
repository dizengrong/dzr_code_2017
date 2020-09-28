%% @doc 玩家跟踪处理，如打印收发协议
-module (mod_trace_role).
-include ("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).
-export([add_trace_role/1, del_trace_role/1, is_trace_role/1]).
-export([do_trace_send_pt/2, do_trace_recv_pt/2]).

-define (TRACE_LOG(Fd, Format, Args), 
	write_trace_log(Fd, ?MODULE, ?LINE, self(), erlang:get(id), Format, Args)
).

%% ================================ trace role ================================= 
%% 跟踪玩家的设置默认生效3分钟(主要怕有人调试时忘记把跟踪设置删除)
add_trace_role(RoleId) ->
	ets:insert(ets_trace_role, {RoleId, util_time:unixtime() + 180}).

del_trace_role(RoleId) -> 
	ets:delete(ets_trace_role, RoleId).

is_trace_role(RoleId) -> 
	ets:lookup(ets_trace_role, RoleId) /= [].
%% ================================ trace role ================================= 


do_trace_send_pt(RoleId, PtBin) when is_integer(RoleId) -> 
	case is_trace_role(RoleId) of
		true -> 
			case PtBin of
				<<_Len:?u32, Remain/binary >> ->
					{_Seq, _PtMod, Rec} = proto:unpack(Remain),
					RecTag = element(1, Rec),
					filter_send_pt(RecTag) orelse gen_server:cast(?MODULE, {trace_send_pt, RoleId, Rec});
				_ -> ok
			end;
		_ -> skip
	end;			
do_trace_send_pt(_RoleId, _PtBin) -> 
	ok.


do_trace_recv_pt(RoleId, Pt) when is_integer(RoleId) -> 
	case is_trace_role(RoleId) of
		true -> 
			case filter_recv_pt(element(1, Pt)) of
				false -> 
					gen_server:cast(?MODULE, {trace_recv_pt, RoleId, Pt});
				_ -> skip
			end;
		_ -> skip
	end;
do_trace_recv_pt(_RoleId, _Pt) -> 
	ok.


filter_send_pt(pt_ping) -> true;
filter_send_pt(_) -> false.


filter_recv_pt(pt_ping) -> true;
filter_recv_pt(_) -> false.


%% =============================================================================
%% =============================================================================
init() -> 
	ets:new(ets_trace_role, [named_table, set, public, {keypos, 1}]),
	ok.


handle_call(Request) ->
	?ERROR("~p recieve call:~p, but not handled!", [?MODULE, Request]),
	not_handled.

handle_msg({trace_send_pt, RoleId, Pt}) -> 
	Fd = get_log_fd(RoleId),
	?TRACE_LOG(Fd, "send pt:~w", [Pt]),
	ok;

handle_msg({trace_recv_pt, RoleId, Pt}) -> 
	Fd = get_log_fd(RoleId),
	?TRACE_LOG(Fd, "recv pt:~w", [Pt]),
	ok;

handle_msg(Msg) ->
	?ERROR("~p recieve msg:~p, but not handled!", [?MODULE, Msg]),
	ok.


terminate() -> 
	ok.


%% 一分钟一次循环
do_loop(Now) -> 
	Fun = fun(RoleId, ExpireTime) -> 
		case Now >= ExpireTime of
			true -> 
				del_trace_role(RoleId),
				Fd = get_log_fd(RoleId),
				is_port(Fd) andalso file:close(Fd),
				erase({trace_fd, RoleId});
			_ -> skip
		end
	end,
	[Fun(RoleId, ExpireTime) || {RoleId, ExpireTime} <- ets:tab2list(ets_trace_role)],
	ok.


get_log_fd(RoleId) ->
	case get({trace_fd, RoleId}) of
		undefined -> 
			Path = server_config:get_conf(log_path),
			File = filename:join(Path, "trace_role_" ++ integer_to_list(RoleId) ++ ".log"),
			{ok, Fd} = file:open(File, [append, raw]),
			put({trace_fd, RoleId}, Fd);
		Fd -> 
			ok
	end,
	Fd.

write_time({{Y,Mo,D},{H,Mi,S}}, Type) ->
    io_lib:format("~n=~s==== ~w-~.2.0w-~.2.0w ~.2.0w:~.2.0w:~.2.0w ===~n",
		  [Type, Y, Mo, D, H, Mi, S]).

write_trace_log(Fd, Mod, Line, Self, Id, Format, Args) ->
	Format2 = "T(~w:~w:~w.erl:~w id:~w): "++ Format ++"~n",
	Args2 = [Self, [], Mod, Line, Id | Args],
	T = write_time(erlang:localtime(), "TRACE REPORT"),
	case catch file:write(Fd, io_lib:format(T ++ Format2, Args2)) of
		{'EXIT', _Reason} -> 
			file:write(Fd, io_lib:format("ERROR: ~w - ~w~n", [Format2, Args2]));
		_ -> skip
	end.

