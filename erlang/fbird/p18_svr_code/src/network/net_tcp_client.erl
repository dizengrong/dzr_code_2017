%% @doc 网络tcp客户端消息收发模块

-module(net_tcp_client).
-behaviour(gen_server).
-include("common.hrl"). 

-export([start_link/1, send_packet/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([do_normal_login/7, do_terminate/2]).


-define(LOOP_TICKET, 10000).


start_link(ClientSocket) ->
    gen_server:start_link(?MODULE, [ClientSocket], [{spawn_opt, [{min_heap_size, 10*1024},{min_bin_vheap_size, 10*1024}]}]).

init([ClientSocket]) ->
    erlang:process_flag(trap_exit, true),
    erlang:put(is_tcp_client, true),
    erlang:send_after(?LOOP_TICKET, self(), loop),
    put(last_heartbeat_time, util_time:unixtime()),
    case inet:peername(ClientSocket) of
        {ok, {IP, _}} ->
            erlang:put(socket, ClientSocket),
            {ok, #client_state{socket=ClientSocket, ip=IP, last_packet_time=util_time:unixtime()}};
        {error, Reason} ->
            {stop, inet:format_error(Reason)}
    end.


parse_net_packet(RecvBin, State, Socket) -> 
    case RecvBin of
        <<Len:?u32, Remain/binary>> ->
            BodyLen1 = Len bxor ?PSW_CODE,
            % ?DEBUG("Len:~p, BodyLen1:~p", [Len, BodyLen1]),
            BodyLen = BodyLen1 - ?HEADER_LENGTH,      
            case BodyLen < ?MINI_BODY orelse BodyLen > ?MAX_BODY of
                true -> 
                    do_terminate(msg_body_error, State),
                    {stop, normal, State};
                _ ->
                    case Remain of
                        <<Data:BodyLen/binary, Remain2/binary >> -> 
                            case handle_recv_packet(Data, State, Socket) of
                                {noreply, State2} ->
                                    parse_net_packet(Remain2, State2, Socket);
                                Ret -> 
                                    Ret
                            end;
                        _ ->
                            prim_inet:async_recv(Socket, 0, -1),
                            {noreply, State#client_state{left_bin = RecvBin}}
                    end
            end;
        _ ->
            prim_inet:async_recv(Socket, 0, -1),
            {noreply, State#client_state{left_bin = RecvBin}}
    end. 


handle_recv_packet(Data, State, Socket) ->
    case proto:unpack(Data) of
        {Seq,PtMod,Pt} ->
            ?DEBUG_PRINT_RECV_PACKET(PtMod, Pt),
            mod_trace_role:do_trace_recv_pt(State#client_state.uid, Pt),
            Ret = do_handle_pt(State, Seq, PtMod, Pt, State#client_state.status),
            %% 一定要处理完上一个协议后，再接收新的协议数据
            prim_inet:async_recv(Socket, 0, -1),
            Ret;
        Result -> 
            ?log_error("recv fill_pt error Result:~p",[Result]),
            {stop, normal, State}
    end.

handle_call(login_again, _From, State) ->
    do_terminate(login_again, State),
    {stop, normal, ok, State};

handle_call(Request, From, State) ->
    ?ERROR("unknown call: ~w from ~w", [Request, From]),
    {reply, gate_way, State}.

handle_cast({send, PtBin}, #client_state{socket = Socket} = State) -> 
    send_packet(Socket, PtBin),
    % ?DEBUG("send PtBin:~w", [PtBin]),
    {noreply, State};

handle_cast({discon, Reason}, State) -> 
    ?INFO("server shutdwon client connection for reason: ~p", [Reason]),
    {stop, normal, State};

handle_cast(Msg, State) ->
    ?ERROR("unknown cast: ~w", [Msg]),
    {noreply, State}.

%% 开启网关，接收数据
handle_info(start, #client_state{socket = Socket} = State) ->
    prim_inet:async_recv(Socket, 0, -1),
    %% psw_code不动态生成了，直接写死
    % send_len_code(Socket),
    ?DEBUG("begin recv data from socket..."),
    {noreply, State};

%% 处理网络数据
handle_info({inet_async, Socket, _Ref, {ok, Data}}, State) -> 
    LeftBin = State#client_state.left_bin,
    Data2 = case LeftBin of
        <<>> -> Data;
        _ -> <<LeftBin/binary, Data/binary>>
    end,
    parse_net_packet(Data2, State, Socket);


handle_info({inet_reply, _Sock, ok}, State) ->
    % ?DEBUG("send data ok"),
    {noreply, State};

handle_info({inet_async, _Sock, _Ref, {error, closed}}, State) ->
    do_terminate(tcp_closed, State),
    {stop, normal, State};


%% 处理role process down
handle_info({'DOWN', _, process, _, _}, State) -> 
    do_terminate(role_process_down, State),
    {stop, normal, State};

handle_info({'EXIT', _Pid, Reason}, State) ->
    #client_state{uid=Uid} = State,
    ?ERROR("kick role ~w for reason:~p", [Uid, Reason]),
    {stop, normal, State};

handle_info(loop, State) ->
    erlang:send_after(?LOOP_TICKET, self(), loop),
    case check_heart_beat(State) of
        lost -> 
            do_terminate(no_heartbeat, State),
            {stop, normal, State};
        _ -> 
            {noreply, State}
    end;

handle_info(Info, State) ->
    ?ERROR("receive unknown msg:~w", [Info]),
    {noreply, State}.

terminate(Reason, State) -> 
    do_terminate(Reason, State),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


send_packet(Socket, PtBin) -> 
    % <<Len:?u32,Pt:?u16, Remain/binary>> = PtBin,
    % NewLen = Len bxor ?PSW_CODE,
    % PtBin2 = <<NewLen:?u32,Pt:?u16, Remain/binary>>,
    erlang:port_command(Socket, PtBin, [force]),
    ?DEBUG_PRINT_SEND_PACKET(PtBin),
    mod_trace_role:do_trace_send_pt(get(id), PtBin),
    ok.


%% pt_pass_audit_login_a111
do_handle_pt(State, Seq, pt_login_a001, Pt, connected) ->
    case ?DEBUG_IS_ACC_ALLOW(Pt#pt_login.account) of
        true -> do_unity_login(State, Pt, Seq, 0, 0, "");
        _ -> 
            ?DEBUG("Server is busy doing things, you are not allowed to login"),
            {stop, normal, State}
    end;

do_handle_pt(State, Seq, pt_sdk_login_a10f, Pt, connected) ->
    do_sdk_login(State, Pt, Seq);

do_handle_pt(State, Seq, pt_req_create_usr_a006, Pt, logined) -> 
    do_create_usr(State, Pt, Seq),
    {noreply, State};

do_handle_pt(State, Seq, pt_usr_enter_b001, Pt, logined) -> 
    do_enter_game(State, Pt, Seq);

do_handle_pt(State, Seq, pt_ping_a10a, Pt, _) -> 
    put(last_heartbeat_time, util_time:unixtime()),
    send_packet(State#client_state.socket, proto:pack(Pt, Seq)),
    % ?debug("send ping to cleint"),
    {noreply, State};

do_handle_pt(State, Seq, PtMode, Pt, entered) ->
     case erlang:get(role_pid) of
        undefined ->
            ?ERROR("role_process_not_found,PtMode=~w", [PtMode]),
            do_terminate(role_process_not_found, State),
            {stop, normal, State};
        PID ->
            gen_server:cast(PID, {recv_pt, self(), PtMode, Seq, Pt}),
            {noreply, State}
    end;

do_handle_pt(State, _Seq, _PtCode, Pt, Status) ->
    %% 对于在登陆状态还没进入游戏收到的协议，我们都认为前端发的协议有问题或是发的缓存的网络数据
    %% 所以这里做一个容错处理
    case get(wrong_pt_count) of
        undefined -> 
            ?WARNING("receive pt:~p when status is:~p, wrong count:~p", [Pt, Status, 1]),
            put(wrong_pt_count, 1),
            {noreply, State};
        Count when Count >= 5 -> 
            ?WARNING("receive wrong pt count >= 5, close connection"),
            {stop, normal, State};
        Count ->
            ?WARNING("receive pt:~p when status is:~p, wrong count:~p", [Pt, Status, Count]),
            put(wrong_pt_count, Count + 1),
            {noreply, State}
    end.


check_heart_beat(#client_state{status = Status}) -> 
    Now = util_time:unixtime(),
    S = case Status of
        connected -> 20;
        logined -> 30;
        _ -> 180
    end,
    case Now - util_misc:get_process_dict(last_heartbeat_time, Now) >= S of
        true -> lost;
        _ -> ok
    end.


get_client_register_name(Aid) ->
    util:list_to_atom2(lists:concat(["client_aid_", Aid])).


do_unity_login(State, Pt, Seq, PlatformID, Channel, DeviceToken) -> 
    Account = Pt#pt_login.account,
    Password = Pt#pt_login.password,
    PtVersion = Pt#pt_login.pt_version,
    case PtVersion == pt_code_id:version() of
        true -> 
            do_normal_login(State, Account, Password, Seq, PlatformID, Channel, DeviceToken);
        _ -> 
            ?error_report(State#client_state.socket, "error_pt_version_wrong", Seq), 
            {stop, normal, State}
    end.


do_sdk_login(#client_state{socket = Socket} = State, Pt, Seq) ->
    Account       = Pt#pt_sdk_login.acc,
    Password      = Pt#pt_sdk_login.pwd,
    Line          = Pt#pt_sdk_login.line,
    Type          = Pt#pt_sdk_login.type,
    % Code          = Pt#pt_sdk_login.statusCode,
    Pack          = Pt#pt_sdk_login.logPack,
    % ClientVersion = Pt#pt_sdk_login.client_version,
    if
        Account == "" ->  
            ?error_report(Socket,"account_field_error",Seq);
        Password == "" -> 
            ?error_report(Socket,"password_field_error",Seq);
        true -> 
            mod_sdk_lyn:lyn_auth(State, Account, Type, Line, Pack, Seq)
    end.


do_normal_login(#client_state{socket = Socket} = State, Account, Password, Seq, PlatformID, Channel, DeviceToken) ->
    case check_login(Account, Password, Channel, DeviceToken) of
        {error, ErrCode} ->
            ?error_report(Socket, ErrCode, Seq),
            {noreply, State};
        Aid ->
            case fun_gm_operation:check_sethonor(Aid, Seq) of
                {false, LeftTime} -> 
                    ?INFO("account:~s is ban", [Account]),
                    ?error_report(Socket, "login_forbidden", Seq, [LeftTime]),
                    do_terminate(account_is_ban, State),
                    {stop, normal, State};
                _ ->
                    case catch check_account_relogin(Aid) of 
                        {ok, IsReLogin} -> 
                            do_normal_login_help(State, Account, Aid, Seq, PlatformID, IsReLogin);
                        {error, ErrCode} ->
                            do_terminate(ErrCode, State),
                            {stop, normal, State}
                    end
            end
    end.


do_normal_login_help(#client_state{socket = _Socket, ip = Ip} = State, Account, Aid, Seq, PlatformID, _IsReLogin) ->
    request_usr_list(Aid,Seq,Ip,PlatformID),
    RegName = get_client_register_name(Aid),
    {noreply, State#client_state{account = Account, account_id = Aid, reg_name = RegName, status = logined}}.


check_login(Account, Password, Channel, DeviceToken) ->
    Account2  = util:to_binary(Account),
    Password2 = util:to_binary(Password),
    case util_misc:is_valid_account(Account) of
        true -> 
            case db_api:dirty_index_read(account, Account2, #account.name) of
                [] -> 
                    case mod_account_service:check_account_name_exists(Account2) of
                        false -> 
                            Rec = #account{
                                id           = 0, 
                                name         = Account2, 
                                password     = Password2,
                                channel      = Channel,
                                device_token = DeviceToken,
                                create_time  = util:unixtime()
                            },
                            [#account{id = Aid}] = db:insert(Rec),
                            Aid;
                        _ -> 
                            {error, "acc_error"}
                    end;
                [#account{id = Aid, password = ThisPassword}] ->
                    case ThisPassword == Password2 of
                        true -> Aid;
                        _ -> 
                            {error, "password_error"}
                    end
            end;
        _ -> 
            {error, "acc_error"}
    end.


check_account_relogin(Aid) ->
    RegName = get_client_register_name(Aid),
    Res = case erlang:whereis(RegName) of
        undefined ->
            {ok, false};
        Pid ->
            erlang:monitor(process, Pid),
            case catch gen_server:call(Pid, login_again) of
                ok ->
                    next;
                _ ->
                    erlang:exit(Pid, kill)
            end,
            receive
                {'DOWN', _, process, _, _} -> 
                    timer:sleep(500),
                    {ok, true};
                Info ->
                    ?ERROR("relogin recieved other msg:~p", [Info]),
                    {error, login_again_error}
                after 5000 ->
                    {error, login_again_timeout}
            end
    end,
    case Res of
        {ok, IsLoginAgain} ->
             case erlang:whereis(RegName)  of
                undefined ->
                    erlang:register(RegName, self()),
                    put(reg_name, RegName),
                    {ok, IsLoginAgain};
                _ ->
                    throw({error, register_error})
            end;
        {error, Err} ->
            throw({error, Err})
    end.


load_usr_list(Aid) ->
    UsrList=db:dirty_get(usr, Aid, #usr.acc_id),
    lists:filter(fun(#usr{state = Status}) -> Status == 0 end, UsrList).

request_usr_list(Aid,Seq,_Ip,PlatformID) ->
    GetUsrList = load_usr_list(Aid),
     
    FunSet = fun(UsrRec) ->
        #usr{
            camp=Camp,id = ID,name = Name,prof = Prof,
            lev = Lev,last_login_time=LastLoginTime,
            paragon_level=ParagonLevel,vip_lev=VipLev
        } = UsrRec,
        ModelClothesDress = fun_item_model_clothes:get_model_clothes_dress(ID),
        #pt_public_create_usr_info{
            id              = ID,  
            name            = util:to_list(Name),
            level           = Lev,
            prof            = Prof,
            camp            = Camp,
            last_login_time = LastLoginTime,
            model_clothes   = ModelClothesDress,
            paragon_level   = ParagonLevel,
            create_time     = util:unixtime(),
            vip_lev         = VipLev
        }
    end,
    GetUsrList1 = lists:map(FunSet, GetUsrList),
    Pt2 = #pt_usr_list{
        default_camp = ?CAMP_ROLE_DEFAULT,
        platform_id = PlatformID,
        usr_list = GetUsrList1,
        is_version_matched = 1
    },
    ?send(self(),proto:pack(Pt2,Seq)).


do_create_usr(#client_state{socket = Socket, account_id = Aid, account = Account, ip = Ip}, Pt, Seq) ->
    Name = Pt#pt_req_create_usr.name,
    if
        Name == "" -> ?error_report(Socket,"usr_name_error",Seq);
        true -> 
            case check_name_exists(list_to_binary(Name)) of
                false -> 
                    case create_usr(Aid,Name,0,?CAMP_ROLE_DEFAULT,Socket,Seq) of
                        {ok, Uid} -> 
                            ServerId = server_config:get_conf(serverid),
                            fun_dataCount_update:usr_register(Account,Uid,Name,ServerId,Ip);
                        _ -> skip
                    end;
                _ -> ?error_report(Socket,"name_creation2",Seq)
            end
    end.


check_name_exists(Name) ->
    mod_account_service:check_role_name_exists(Name).

create_usr(Aid,Name,Prof,Camp,Socket,Seq) ->
    % ?log_trace("login create Prof=~p",[Prof]),
    HasUsr = erlang:length(load_usr_list(Aid)),
    if  
        HasUsr >= ?MAX_USR -> ?error_report(Socket,"create_usr_max_usr",Seq);
        true ->
            Now = util:unixtime(),
            Usr = #usr{
                acc_id = Aid, name = list_to_binary(Name), prof = Prof,
                camp=Camp,lev = 1, hp = 100, mp = 100, create_time = Now,
                last_login_time = Now, is_first_register = true
            },
            [#usr{id = Pid} = NUsr] = db:insert(Usr),
            create_user_new_data(Pid),
            Ptc1 = #pt_public_create_usr_info{
                id              = NUsr#usr.id,
                name            = util:to_binary(NUsr#usr.name),
                level           = NUsr#usr.lev,
                prof            = NUsr#usr.prof,
                camp            = Camp,
                equip_id_list   = [],
                last_login_time = Now,
                create_time     = Now,
                model_clothes   = 0,
                paragon_level=0,vip_lev=0,sum_star=0
            },
            Sid = self(),
            Pt2 = #pt_create_usr_list{usr_list = [Ptc1]},
            ?send(Sid,proto:pack(Pt2,Seq)),
            {ok, Pid}
    end.


do_enter_game(#client_state{ip = Ip, account_id = Aid} = State, Pt, Seq) ->
    Uid = Pt#pt_usr_enter.uid,
    PhoneType = Pt#pt_usr_enter.phone_type,
    {ok, RolePID} = agent_ctr:start_role_process(self(), Ip, Seq, Aid, Uid, PhoneType),
    erlang:put(id, Uid),
    erlang:put(role_pid, RolePID),
    erlang:monitor(process, RolePID),
    {noreply, State#client_state{uid = Uid, status = entered}}.


do_terminate(Reason, State) -> 
    case get(already_terminate) of
        undefined ->
            put(already_terminate, true),
            do_terminate_help(Reason, State);
        _ ->
            ok
    end.
    
do_terminate_help(Reason, _State = #client_state{uid = Uid, reg_name = RegName, socket = Socket, status = Status}) -> 
    ?ERROR("tcp client down, Uid:~p, Reason:~p, status:~p", [Uid, Reason, Status]),
    ?_IF(RegName /= undefined, erlang:unregister(RegName), skip),
    ?_IF(Reason == login_again, timer:sleep(1500), skip),
    erlang:port_close(Socket),
    ok.
 

 create_user_new_data(_Uid) ->
    %% 如果确实需要，创建角色后玩家的数据可以在这里初始化，
    %% 不然都应该放到:agent:init_create_usr_datas/1去初始化
    %% 注意新表使用db_api:dirty_write 新表如确实需要在建号时插入数据的就在这里处理

    %% 注意老表使用db:insert
    ok.