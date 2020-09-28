-module(fun_plat_interface_gms).

-include("common.hrl").


-export([report/2]).
-export([report_cb/2, http_request_cb/2]).
-export([handle/1]).
-export([data_call_back/3]).

-define(GAME_ID, server_config:get_conf(gameid)).
-define(GAME_KEY, server_config:get_conf(gamekey)).

%% GM后台数据上报接口

http_request(_Url, _) ->
	ok.
% http_request(Url, {Module, Cb_func, Cb_args}) ->
% 	case lists:member({Cb_func, 2}, Module:module_info(exports)) of
% 		false ->
% 			erlang:error(invalid_callback);
% 		_ ->
% 			fun_http_client:async_http_request(get, {Url, []}, {?MODULE, http_request_cb, {Module, Cb_func, Cb_args}})
% 			% mod_msg:handle_to_http_client(?MODULE, {do_request, Url, {Module, Cb_func, Cb_args}})
% 	end.

%% http_request(Url, JsStr, {Module, Cb_func, Cb_args}) ->
%% 	case lists:member({Cb_func, 2}, Module:module_info(exports)) of
%% 		false ->
%% 			erlang:error(invalid_callback);
%% 		_ ->
%% 			%fun_http:async_http_request(get, {Url, []}, {?MODULE, http_request_cb, {Module, Cb_func, Cb_args}})
%% 			fun_http:async_http_request(post, {Url, [], "application/json", JsStr}, {?MODULE, http_request_cb, {Module, Cb_func, Cb_args}})
%% 	end.

handle({do_request, Url, CallbackInfo}) ->
	fun_http_client:async_http_request(get, {Url, []}, {?MODULE, http_request_cb, CallbackInfo}).


http_request_cb({{_HttpVersion, StatusCode, Desc}, Body}, CallbackInfo = {Module, Cb_func, Cb_args}) ->
	% ?debug("http response,code=~p,desc=~p,data=~s", [StatusCode, Desc, Body]),
	case StatusCode of
		200 ->
			case rfc4627:decode(Body) of
				{ok, JsonObj, _Reminder} ->	
					%?log("~p", [JsonObj]),
					Module:Cb_func({true, JsonObj}, Cb_args);
				{error, Reason} ->
					Module:Cb_func(false, Cb_args),
					?log_warning("parse json error,reason=~p", [Reason]);
				_ ->
					skip
			end;
		_ -> ?log_warning("http response error,code=~p,desc=~p,CallbackInfo=~w", [StatusCode,Desc,CallbackInfo])
	end;
http_request_cb({error, Reason}, _CbInfo) ->
	?log_warning("http response error,reason=~p",[Reason]).



get_gms_hostname() ->
	db:get_config(addrbc).


get_server_id() ->
	db:get_all_config(serverid).

get_item_way_str(Way) -> 
	case Way of
		{Way2, AdditionStr} ->
			item_log:get(Way2) ++ ":" ++ AdditionStr;
		_ -> 
			item_log:get(Way)
	end.

report(?GMS_EVT_DIAMOND_CHANGE, {Uid,Name,Lev,AddAmount,RestAmount,AddBindAmount,RestBindAmount,Way0}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/virtualCurrency",[get_gms_hostname()])),
	Way = get_item_way_str(Way0),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"RoleId",Uid},
			  {"RoleName",Name},
			  {"Remark",Way},
			  {"RechargeVirtualCurrency", AddAmount},
			  {"GiveVirtualCurrency", AddBindAmount},
			  {"RechargeBalance", RestAmount},
			  {"GiveBalance", RestBindAmount},
			  {"Level", Lev}
			  ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_DIAMOND_CHANGE, FullUrl}});

report(?GMS_EVT_CASH_CHANGE, {Uid,Name,AddAmount,RestAmount,Way0}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/convertCurrency",[get_gms_hostname()])),
	Way = get_item_way_str(Way0),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"RoleId",Uid},
			  {"RoleName",Name},
			  {"Remark",util:to_list(Way)},
			  {"GameCurrency", AddAmount},
			  {"AllCurrency", RestAmount},
			  {"State", if AddAmount > 0 -> 1; true -> -1 end}
			  ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_CASH_CHANGE, FullUrl}});

report(?GMS_EVT_COIN_CHANGE, {Uid,Name,AddAmount,RestAmount,Way}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/convertCurrency",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"RoleId",Uid},
			  {"RoleName",Name},
			  {"Remark",util:to_list(Way)},
			  {"GameCurrency", abs(AddAmount)},
			  {"AllCurrency", RestAmount},
			  {"State", if AddAmount > 0 -> 1; true -> -1 end}
			  ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_COIN_CHANGE, FullUrl}});

report(?GMS_EVT_ITEM_CHANGE, {Uid,Name,ItemType,AddAmount,Way}) ->
	Way2 = get_item_way_str(Way),
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/res",[get_gms_hostname()])),
	KvList = [
			  {"RoleId",Uid},
			  {"RoleName",util:to_binary(Name)},
			  {"SvrNo", get_server_id()},
			  {"GoodsId", ItemType},
			  {"Remark",Way2},
			  {"State", if AddAmount > 0 -> 1; true -> -1 end},
			  {"Num", abs(AddAmount)}
			  ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_ITEM_CHANGE, FullUrl}});

report(?GMS_EVT_KILL, {KillerUid, KillerName, BeKillerUid, BeKillerName}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/kill",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"SrcRoleId", KillerUid},
			  {"SrcRoleName", KillerName},
			  {"TargetRoleId", BeKillerUid},
			  {"TargetRoleName", BeKillerName},
			  {"Num", 1}
			  ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_KILL, FullUrl}});


%% report(?GMS_EVT_RECHARGE, {Aid, Uid, Channel, Level, Num, IsFirstRecharge}) ->
%% 	Url = lists:flatten(io_lib:format("http://~s/rpc/report/pay",[get_gms_hostname()])),
%% 	KvList = [
%% 			  {"SvrID", get_server_id()},
%% 			  {"AID", Aid},
%% 			  {"UID", Uid},
%% 			  {"Channel", Channel},
%% 			  {"Level", Level},
%% 			  {"Num", Num},
%% 			  {"IsFirst", if IsFirstRecharge == true -> 1; true -> 0 end}
%% 			  ],
%% 	FullUrl = make_url(Url, KvList),
%% 	http_request(FullUrl,
%% 				  {?MODULE, report_cb, {?GMS_EVT_RECHARGE, FullUrl}});

%% report(?GMS_EVT_ACC_REG, {Aid, _CreateTime, Channel}) ->
%% 	Url = lists:flatten(io_lib:format("http://~s/rpc/report/reg",[get_gms_hostname()])),
%% 	KvList = [
%% 			  {"SvrID", get_server_id()},
%% 			  {"AID", Aid},
%% 			  {"Channel", Channel}
%% 			 ],
%% 	FullUrl = make_url(Url, KvList),
%% 	http_request(FullUrl,
%% 				  {?MODULE, report_cb, {?GMS_EVT_ACC_REG, FullUrl}});

report(?GMS_EVT_LOGIN, {AccName, Uid, Name, SourceId, IP}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/line",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"UserId", util:to_binary(AccName)},
			  {"RoleId", Uid},
			  {"RoleName", util:to_binary(Name)},
			  {"Channo", SourceId},
			  {"Ip", util:ip2str(IP)},
			  {"Action", "in"},
			  {"ActionTime",util:unixtime()}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_LOGIN, FullUrl}});

report(?GMS_EVT_LOGOUT, {AccName, Uid, Name, SourceId, IP, LastLoginTime}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/line",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"UserId", util:to_binary(AccName)},
			  {"RoleId", Uid},
			  {"RoleName", util:to_binary(Name)},
			  {"Channo", SourceId},
			  {"Ip", util:ip2str(IP)},
			  {"Action", "out"},
			  {"ActionTime", LastLoginTime}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_LOGOUT, FullUrl}});

%% report(?GMS_EVT_LEVEL_UP, {Aid, Uid, OldLev, NewLev}) ->
%% 	Url = lists:flatten(io_lib:format("http://~s/rpc/report/level",[get_gms_hostname()])),
%% 	KvList = [
%% 			  {"SvrID", get_server_id()},
%% 			  {"AID", Aid},
%% 			  {"UID", Uid},
%% 			  {"Lev", OldLev},
%% 			  {"UpLev", NewLev}
%% 			 ],
%% 	FullUrl = make_url(Url, KvList),
%% 	http_request(FullUrl,
%% 				  {?MODULE, report_cb, {?GMS_EVT_LEVEL_UP, FullUrl}});

report(?GMS_EVT_TASK, {Uid, Name, TaskId, TaskStep, Status}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/taskNode",[get_gms_hostname()])),
	KvList = [
			  {"SvrID", get_server_id()},
			  {"UID", Uid},
			  {"RoleName", util:to_binary(Name)},
			  {"TaskID", TaskId},
			  {"TaskStep", TaskStep},
			  {"Status", Status}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_TASK, FullUrl}});

report(?GMS_EVT_TASK2, {Uid, Name, Sort, TaskStep}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/taskStep",[get_gms_hostname()])),
	KvList = [
			  {"SvrID", get_server_id()},
			  {"UID", Uid},
			  {"RoleName", util:to_binary(Name)},
			  {"Sort", Sort},
			  {"TaskStep", TaskStep}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_TASK2, FullUrl}});

report(?GMS_EVT_BARRIER, {Uid, Name, Barrier}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/barrier",[get_gms_hostname()])),
	KvList = [
			  {"SvrID", get_server_id()},
			  {"UID", Uid},
			  {"RoleName", util:to_binary(Name)},
			  {"Barrier", Barrier}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_BARRIER, FullUrl}});

%% report(?GMS_EVT_CREATE_ROLE, {Aid, Uid, _Channel, Prof, Name}) ->
%% 	Url = lists:flatten(io_lib:format("http://~s/rpc/report/role",[get_gms_hostname()])),
%% 	KvList = [
%% 			  {"SvrID", get_server_id()},
%% 			  {"AID", Aid},
%% 			  {"UID", Uid},
%% 			  {"Prof", Prof},
%% 			  {"Name", Name},
%% 			  {"Status", "add"},
%% 			  {"Camp", 0}
%% 			 ],
%% 	FullUrl = make_url(Url, KvList),
%% 	http_request(FullUrl,
%% 				  {?MODULE, report_cb, {?GMS_EVT_CREATE_ROLE, FullUrl}});

report(?GMS_EVT_CHAT, {AccName, Uid, Channel, Content}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/chat",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"GmUserId", util:to_binary(AccName)},
			  {"RoleId", Uid},
			  {"FrequencyChannel", Channel},
			  {"Note", Content}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_CHAT, FullUrl}});

report(?GMS_EVT_ONLINE, {CurNum, _MaxNum}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/onLineTop",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"Online", 0},
			  {"MaxOnline", CurNum}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_ONLINE, FullUrl}});


report(?GMS_EVT_REQ_REBATE_INFO, {CbInfo, AccName}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/rebate",[get_gms_hostname()])),
	KvList = [
			  {"Acc",util:to_binary(AccName)}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_REQ_REBATE_INFO, FullUrl, CbInfo}});

report(?GMS_EVT_REBATE_DONE, {AccName,Name,Channel}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/rebateValidate",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"Acc", AccName},
			  {"Name", Name},
			  {"Channel", Channel}
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_REBATE_DONE, FullUrl}});

report(?GMS_EVT_SHOP_BUY, {Uid,Name,ItemType,Amount,BindingSycee,Sycee}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/shopLog",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"RoleId", Uid},
			  {"RoleName", Name},
			  {"ShopId", ItemType},
			  {"Num", Amount},
			  {"DeductGiveCurrency",BindingSycee},
			  {"DeductRechargeCurrency",Sycee}

			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_SHOP_BUY, FullUrl}});

report(?GMS_EVT_GUILD, {GuildId,GuildName,LeaderID,Action}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/group",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"Action", Action},
			  {"GroupId", GuildId},
			  {"GroupName", GuildName},
			  {"CreateUser", LeaderID}
			
			 ],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_GUILD, FullUrl}});

report(?GMS_EVT_ACTIVITY, {Uid,ActType,ID}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/activity",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"RoleId", Uid},
			  {"ActiveType", ActType},
			  {"Grade", ID}
			],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_ACTIVITY, FullUrl}});

report(?GMS_EVT_ACTIVITY_RANK, {Uid,ActType,Rank}) ->
	Url = lists:flatten(io_lib:format("http://~s/rpc/report/activityRank",[get_gms_hostname()])),
	KvList = [
			  {"SvrNo", get_server_id()},
			  {"RoleId", Uid},
			  {"ActiveType", ActType},
			  {"Remark", Rank}
			],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl,
				  {?MODULE, report_cb, {?GMS_EVT_ACTIVITY_RANK, FullUrl}});

report(?GMS_EVT_USR_REGISTER, {AccName,Uid,UserName,ServerId,ClientIp0,CreateTime}) ->
	Adder = server_config:get_conf(sdk), 
	Url = Adder++"/api/role_info?",
	ClientIp = util_misc:ip_to_str(ClientIp0), 
	KvList = [
			  {"Action", "create"},
			  {"CreateTime", CreateTime},
			  {"UserID", util:to_list(AccName)},
			  {"SvrRoleID", Uid},
			  {"RoleName", util:to_list(UserName)},
			  {"ServerNo", ServerId},
			  {"SourceIP", util:to_list(ClientIp)}
			],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl, {?MODULE, report_cb, {?GMS_EVT_USR_REGISTER, FullUrl}});

report(?GMS_EVT_LOGIN_LOGOUT, {Action, Uid, UserName, Ip0, UsrLv, Prof, GuildID, VipLev, Fighting, Camp, Copper, Coin, CoinBind, Time}) -> 
	Adder = server_config:get_conf(sdk), 
	Url = Adder++"/api/role_info?",
	Ip = util_misc:ip_to_str(Ip0), 
	KvList = [
			  {"Action", Action},
			  {"SvrRoleID", Uid},
			  {"RoleName", util:to_list(UserName)},
			  {"SourceIP", Ip},
			  {"Level", UsrLv},
			  {"LoginTime", Time},
			  {"Profession", Prof},
			  {"GroupID", GuildID},
			  {"VIP", VipLev},
			  {"CE", Fighting},
			  {"Camp", Camp},
			  {"Gold", Copper},
			  {"Diamond", Coin},
			  {"BindDiamond", CoinBind}
			],
	FullUrl = make_url(Url, KvList),
	http_request(FullUrl, {?MODULE, report_cb, {?GMS_EVT_USR_REGISTER, FullUrl}});

report(Evt, Args) ->
	?debug("invalid request,evt=~p,args=~p",[Evt,Args]),
	erlang:error({badarg, Evt, Args}).


report_cb(Ret, Arg) ->
	{Event,Url,CbInfo} = 
		case Arg of
			{Event1,Url1} -> {Event1,Url1,null};
			{Event1,Url1,CbInfo1} -> {Event1,Url1,CbInfo1}
		end,
	%?debug("report_cb,ret=~p,event=~p,url=~s",[Ret,Event,Url]),
	Ret1 =
	case Ret of
		{true, {obj, KvList}} ->
			parse_cb_ret_data(Event, KvList);
		_ -> false
	end,
	
	{CbRet, CbData} =
		case Ret1 of
			{true, RetData} ->
				%%额外返回的业务数据,由传入的回调函数自行处理
				{true, RetData};
			_ -> 
				?log_warning("gms report callback error,ret=~p,event=~p,url=~s",[Ret,Event,Url]),
				{false, null}
		end,
	
	case CbInfo of
		{M,F,A} -> M:F(CbRet, CbData, A);
		_ -> skip
	end.


parse_cb_ret_data(_, KvList) ->
	case lists:keyfind("ErrorCode", 1, KvList) of
		{_, 0} ->
			case lists:keyfind("Data", 1, KvList) of
				{_, {obj, KvList1}} -> {true, KvList1};
				_ -> {true, null}
			end;
		_ -> false
	end.



make_url(Url, KvList) ->
	KvList1 = [{"GameID",?GAME_ID}|KvList],
	Sign = sign(KvList1),
	fun_http:make_url(Url, [{"Sign", Sign} | KvList1]).
	
	

sign(KvList) ->
	SortedKvList = lists:sort(fun({K1,_},{K2,_})->K1<K2 end, KvList),
	RawStr = lists:flatten(string:join(lists:map(fun({K,V})->K++"="++util:to_list(V) end, SortedKvList), "&") ++ ":" ++ ?GAME_KEY),
	util:md5(RawStr).


data_call_back(true, Datas, {check_recharge_back,Hid})->
	?debug("check_recharge_back,~p",[Datas]),
	case lists:keyfind("Status", 1, Datas)  of  
		{_,false}->
			{_,Acc}=lists:keyfind("Acc", 1, Datas),
			case Acc of
				[] -> skip;
				_ ->
					{_,Num}=lists:keyfind("Num", 1, Datas),
					RechargeRMB = util:to_integer(Num),
					AccountName = util:to_list(Acc),
					mod_msg:handle_to_agent(Hid, fun_cdkey, {check_recharge_back, AccountName, RechargeRMB})
			end;
		_-> ?debug("has no recharge back:~p",[Datas])
	end;
data_call_back(_, _Datas, _)->
	skip.

