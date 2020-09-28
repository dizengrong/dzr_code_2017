%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% name   : fun_login_token
%% author : Andy lee
%% date   : 2018-8-3
%% Company: fbird.Co.Ltd
%% Desc   : 处理TOKEN失效直接跳过TOKEN验证
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_login_token).
-include("common.hrl").
-export([check/1,check_zero/1,update/1,get_data/1]).

%%判断是否需要验证token
check({SourceID,UserID,DeviceID}) ->
	ID=SourceID++"_"++UserID,
	Key={token,ID,DeviceID},
	case get(Key) of
		{Time,_PlatformID,_Data} ->
			Now=util:unixtime(),
			Diff=util:abs(Now-Time),
			if
				Diff < ?ONE_DAY_SECONDS -> false;					
				true -> true
			end;
		_ -> true
	end.

%%检测usrid=:=0
check_zero("0") ->true;
check_zero(_UserID) ->false.

%%更新token验证时间
update({ID,DeviceID,PlatformID,Data}) ->
	Key={token,ID,DeviceID},
	put(Key,{util:unixtime(),PlatformID,Data}).


%%获取平台ID
get_data({SourceID,UserID,DeviceID}) ->
	ID=SourceID++"_"++UserID,
	Key={token,ID,DeviceID},
	case get(Key) of
		{_Time,PlatformID,Data} -> {PlatformID,Data};
		_ -> {0,""}
	end.	