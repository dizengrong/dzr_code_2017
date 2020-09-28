%% @doc 游戏app推送通知
-module (fun_push_notify).
-include("common.hrl").
-export ([do_minute_loop/1]).
-export ([handle/1]).
-export ([push_result/2]).
-export ([send_notify_worker/1]).
-export ([test_send_notify/2]).

-define(SEND_WORKER_INTERVAL, 200).

%% 每分钟的循环来检测是否此刻有通知需要推送
do_minute_loop(_Now) ->
	% case db:get_config(push_addr) of
	% 	[] -> skip;
	% 	_ ->
	% 		{_, {Hour, Min, _}} = util_time:seconds_to_datetime(Now),
	% 		[check_push_time(PushData, Hour, Min) || PushData <- data_push:all()]
	% end,
	ok.

% check_push_time({TimeList, Notify}, Hour, Min) ->
% 	check_push_time_help(TimeList, Hour, Min, Notify).

% check_push_time_help([], _H2, _M2, _Notify) -> ok;
% check_push_time_help([{H1, M1} | _Rest], H2, M2, Notify) when H1 == H2 andalso M1 == M2 ->
% 	mod_msg:handle_to_http_client(?MODULE, {notify, Notify});
% check_push_time_help([{_H1, _M1} | Rest], H2, M2, Notify) ->
% 	check_push_time_help(Rest, H2, M2, Notify).


handle({notify, Notify}) ->
	do_notify(Notify).

%% 将通知发送到技术中心
do_notify({bag, NotifyContent}) ->
	OfflineList = get_offline_usrs(),
	OfflineList2 = filter_bag_is_full(OfflineList),
	send_request(OfflineList2, NotifyContent),
	ok;
do_notify({time, NotifyContent}) ->
	send_request(all, NotifyContent),
	ok.

get_offline_usrs() ->
	List        = db:dirty_all_keys(usr),
	OnlineList  = db:dirty_all_keys(ply),
	List -- OnlineList.

filter_bag_is_full(OfflineList) ->
	Fun = fun(Uid) ->
		[#usr{last_logout_time = LastLogoutTime}] = db:dirty_get(usr, Uid),
		OfflineMinutes = (util_time:unixtime() - LastLogoutTime) div 60,
		CanGetItemNum = util:floor(OfflineMinutes / util:get_data_para_num(1010)),
		CanGetItemNum >= fun_item_api:get_free_pos_num(Uid)
	end,
	lists:filter(Fun, OfflineList).

get_account_name(Uid) ->
	[UsrRec] = db:dirty_get(usr, Uid),
	[#account{name = Name}] = db:dirty_get(account, UsrRec#usr.acc_id),
	%% 使用sdk登陆时，服务端的账号是加了一个前缀的:lynid_
	case util:to_list(Name) of
		[$l, $y, $n, $i, $d, $_ | Rest] -> Rest;
		Name2 -> Name2
	end. 

send_request(all, NotifyContent) ->
	send_request(get_offline_usrs(), NotifyContent);
send_request(UsrIdList, NotifyContent) ->
	UsrIdList2 = [get_account_name(Uid) || Uid <- UsrIdList],
	ListOfList = util_list:divid_list(UsrIdList2, 100),
	erlang:start_timer(?SEND_WORKER_INTERVAL, self(), {?MODULE, send_notify_worker, {NotifyContent, ListOfList}}),
	ok.

send_notify_worker({_NotifyContent, []}) -> ok;
send_notify_worker({NotifyContent, [List | Rest]}) ->
	[send_request_help(UsrId, NotifyContent) || UsrId <- List],
	erlang:start_timer(?SEND_WORKER_INTERVAL, self(), {?MODULE, send_notify_worker, {NotifyContent, Rest}}).

send_request_help(UsrId, NotifyContent) ->	
	PushAdder      = db:get_config(push_addr),
	PushAppId      = db:get_config(push_app_id),
	PushAppKey      = db:get_config(push_app_key),
	Serverid   = db:get_all_config(serverid),
	Args = lists:concat([
		"appId=", PushAppId,
		"&content=", util:escape_uri(util:to_binary(NotifyContent)),
		"&groupId=", Serverid,
		"&platfrom=ANDROID", 
		"&userId=", UsrId
	]),
	Str     = lists:concat([Args, ":", PushAppKey]),
	Sign    = string:to_upper(util:md5(Str)),
	Url     = PushAdder ++ "?" ++ Args ++ "&sign=" ++ Sign,
	?debug("Url:~p", [Url]),
	% Request = {Url, [], "application/x-www-form-urlencoded", ""},
	% fun_http_client:async_http_request(post, Request, {?MODULE, push_result, NotifyContent}).
	Request = {Url, []},
	fun_http_client:async_http_request(get, Request, {?MODULE, push_result, NotifyContent}),
	Url.

push_result({_StatusLine, Body}, NotifyContent) ->
	case rfc4627:decode(Body) of
		{ok, {obj, Datas}, _} ->	
			{_, State} = lists:keyfind("state", 1, Datas),
			{_, Msg}   = lists:keyfind("msg", 1, Datas),
			case State /= 1 of
				true -> 
					?log_error("push notify:~s failed, state:~p, reason:~s", [NotifyContent, State, Msg]);
				_ -> skip
			end;
		Ret ->
			?log_error("push notify:~w failed, body:~p", [NotifyContent, Ret])
	end.

%% ========================= test ==============================================
% fun_push_notify:test_send_notify(10050000000421, "notify").
% fun_push_notify:test_send_notify(10000000538, "notify").
test_send_notify(Uid, NotifyContent) ->
	Fun = fun() ->
		AccName = get_account_name(Uid),
		send_request_help(AccName, NotifyContent)
	end,
	world_svr:debug_call(http_client, Fun).
