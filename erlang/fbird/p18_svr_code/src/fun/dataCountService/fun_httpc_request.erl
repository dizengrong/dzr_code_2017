-module(fun_httpc_request).
-include("common.hrl").
-export([send_to_background/2,send_to_background/5,data_call_back/2,default_call_back/2]).

-define(GAME_ID, db:get_all_config(gameid)).



send_to_background(Req,Args,Mod,Fun,CallArgs)->
	case db:get_config(addrbc) of
		"0.0.0.0" -> skip;
		_ ->
			Url=make_url(Req, Args),
			?debug("URL_CALLBACK:~p",[Url]),
			fun_http_client:async_http_request(get, {Url,[]}, {Mod, Fun, CallArgs})
	end.
send_to_background(Req,Args)->
%% 	?log_trace("send_to_background,{Req,Args} = ~p",[{Req,Args}]),
	case db:get_config(addrbc) of
		"0.0.0.0" -> skip;
		_ ->
			Url=make_url(Req, Args),
			?debug("URL_CALLBACK:~p",[Url]),
			% ?log_trace("send_to_background,Url = ~p",[Url]),
			httpc:request(get, {Url,[]}, [], [{sync, false}, {receiver,self()}])
	end.


make_url(get_versions, _)-> 
	Addr=db:get_all_config(sdk),
	ServerId = db:get_all_config(serverid),
	Addr ++ "/GetGMInfo?Get=SvrVersion&" ++ "SvrNo=" ++ integer_to_list(ServerId); 



make_url(update_cdkey_use,{_Uid,_Aid,_SvrId,Key})->
	Addr=db:get_all_config(sdk),
	Str = "CDKey="++util:to_list(Key),
	List = sign_list(Str),
	Sign = cdk_sign(List),
	Http = Addr++"/cdk/cancel?"++Str++"&Sign="++util:to_list(Sign),
	?debug("-------------update_cdkey_use=~p",[Http]),
	Http;

%%cdk访问用户中心地址
make_url(get_cdkey_info,{_Uid,_Aid,_SvrId,Key})->
	Addr=db:get_all_config(sdk),
	Str = "CDKey="++util:to_list(Key),
	List = sign_list(Str),
	Sign = cdk_sign(List),
	Http = Addr++"/cdk/use?"++Str++"&Sign="++util:to_list(Sign),
	?debug("-------------get_cdkey_info=~p",[Http]),
	Http;

%%---------------------------------------------------------------------------------
%%聊天上报 
make_url(chat_content,{ChatChannel,Acc,Uid,SvrId,Content})->
%% GmUserId	string	游戏用户id	必选
%% SvrNo	Int	服务器ID	必选
%% RoleId	String	角色ID	必选
%% FrequencyChannel	String	聊天频道	必选
%% Note	String	聊天内容	必选
%% http://ryzj-report.lynlzqy.com:8080/rpc/report/chat?
%% RoleId=2540000000000172&GmUserId=&Note=2211213&SvrNo=254000&FrequencyChannel=%E4%B8%96%E7%95%8C&GameID=7&Sign=C7257E3671DF283039F7593127232217
	Addr=db:get_config(addrbc),
	Str = "RoleId="++util:to_list(Uid)++
			  "&GmUserId="++util:escape_uri(util:to_list(Acc))++
			  "&Note="++util:escape_uri(util:to_list(Content))++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&FrequencyChannel="++util:escape_uri(util:to_list(ChatChannel))++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "RoleId="++util:to_list(Uid)++
			  "&GmUserId="++util:escape_uri(util:to_list(Acc))++
			  "&Note="++util:to_list(Content)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&FrequencyChannel="++util:to_list(ChatChannel)++
			  "&GameID="++util:to_list(?GAME_ID),
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/chat?"++Str++"&Sign="++util:to_list(Sign);
%%任务
make_url(taskCount,{_Task,Step,Status,SvrId,Uid})->
%% 地址	http://ryzj-report.lynlzqy.com:8080/rpc/report/taskNode?UID=2540000000000172&Status=1&TaskStep=154&SvrNo=254000&RoleName=%E5%AE%89%E9%A3%9E%E7%BD%97%E4%BC%AF%E7%89%B9&GameID=7&Sign=7854DEE62D8008E7B9A3891003D2B6C9
%% Status	String	状态：  (0接受任务 1完成任务)	必选
%% TaskStep	string	任务步骤	必选
%% UID	String	角色ID	必选
%% SvrID	Int	服务器ID	必选
%% RoleName	String	角色名	必选

	
	Name = util:get_name_by_uid(Uid),
	Addr=db:get_config(addrbc),
	Str = "UID="++util:to_list(Uid)++
			  "&Status="++util:to_list(Status)++
			  "&TaskStep="++util:to_list(Step)++
			  "&SvrID="++util:to_list(SvrId)++
			  "&RoleName="++util:escape_uri(util:to_list(Name))++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "UID="++util:to_list(Uid)++
			  "&Status="++util:to_list(Status)++
			  "&TaskStep="++util:to_list(Step)++
			  "&SvrID="++util:to_list(SvrId)++
			  "&RoleName="++util:to_list(Name)++
			  "&GameID="++util:to_list(?GAME_ID),
	
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/taskNode?"++Str++"&Sign="++util:to_list(Sign);

%%击杀上报
make_url(camp_kill,{Killer,KillName,SvrId,BeKiller,BeKillName})->
%%http://ryzj-report.lynlzqy.com:8080/rpc/report/kill?
%%SrcRoleId=2540000000000172&SrcRoleName=%E5%AE%89%E9%A3%9E%E7%BD%97%E4%BC%AF%E7%89%B9&
%%TargetRoleName=%E6%81%B6%E7%81%AB%E8%8E%8E%E7%A2%A7%E5%A8%9C&TargetRoleId=220000000165&SvrNo=254000&GameID=7&Sign=1C96088D58E0697632F4371D9F1BA538
%% 地址	/rpc/report/kill
%% SrcRoleId	String	击杀者角色ID	必选
%% SrcRoleName	String	击杀者角色名	必选
%% TargetRoleName	String	被击杀者名	必选
%% TargetRoleId	String	被击杀者ID	必选
%% SvrNo	Int	服务器编号	必选
%% Num	Int	击杀次数	必选
%% "&name="++util:escape_uri(util:to_list(Name))++
	
	Addr=db:get_config(addrbc),
	Str = "SrcRoleId="++util:to_list(Killer)++
			  "&SrcRoleName="++util:escape_uri(util:to_list(KillName))++
			  "&TargetRoleName="++util:escape_uri(util:to_list(BeKillName))++
			  "&TargetRoleId="++util:to_list(BeKiller)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&Num="++util:to_list(1)++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "SrcRoleId="++util:to_list(Killer)++
			  "&SrcRoleName="++util:to_list(KillName)++
			  "&TargetRoleName="++util:to_list(BeKillName)++
			  "&TargetRoleId="++util:to_list(BeKiller)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&Num="++util:to_list(1)++
			  "&GameID="++util:to_list(?GAME_ID),
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/kill?"++Str++"&Sign="++util:to_list(Sign);
%% 虚拟货币上报
make_url(diamo,{Uid,Name,SvrId,Desc,CoinNum,BindingCoinNum,TotalCoin,TotalBindingCoin})->
%% http:// 120.92.234.181:8080/game_gm/rpc/starReport
%% RoleId	String	角色ID	必选
%% RoleName	String	角色名	必选
%% SvrNo	Int	服务器ID	必选
%% RechargeVirtualCurrency	Int	充值虚拟币消耗	必选
%% GiveVirtualCurrency	Int	赠送虚拟币消耗	必选
%% RechargeBalance	Int	充值虚拟币余额	必选
%% GiveBalance	Int	赠送虚拟币余额	必选
%% Remark	String	获取描述	必选

	Addr=db:get_config(addrbc),
	Str = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:escape_uri(util:to_list(Name))++
			  "&Remark="++util:escape_uri(util:to_list(Desc))++
			  "&RechargeVirtualCurrency="++util:to_list(CoinNum)++
			  "&GiveVirtualCurrency="++util:to_list(BindingCoinNum)++
			  "&RechargeBalance="++util:to_list(TotalCoin)++
			  "&GiveBalance="++util:to_list(TotalBindingCoin)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:to_list(Name)++
			  "&Remark="++util:to_list(Desc)++
			  "&RechargeVirtualCurrency="++util:to_list(CoinNum)++
			  "&GiveVirtualCurrency="++util:to_list(BindingCoinNum)++
			  "&RechargeBalance="++util:to_list(TotalCoin)++
			  "&GiveBalance="++util:to_list(TotalBindingCoin)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GameID="++util:to_list(?GAME_ID),

	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/virtualCurrency?"++Str++"&Sign="++util:to_list(Sign);
%% 同时在线峰值
% make_url(max_online,{SvrId,Curr,Time})->
% %% 地址	http://gm.lynlzqy.com:8080/game_gm/rpc/online
% %% SvrNo	Int	服务器ID	必选
% %% Online	Int	平均在线人数	必选
% %% MaxOnline	Int	最大在线人数	必选
% 	?debug("max_online_report?--------------------"),
% 	Addr=db:get_config(addrbc),
% 	Str = "&MaxOnline="++util:to_list(Curr)++
% 			  "&Online="++util:to_list(0)++
% 			  "&SvrNo="++util:to_list(SvrId)++
% 			  "&GameID="++util:to_list(?GAME_ID),
% 	List = sign_list(Str),
% 	Sign = sign(List),
% 	"http://"++Addr++"/rpc/report/onLineTop?"++Str++"&Sign="++util:to_list(Sign);
%% 兑换货币上报
make_url(coin,{Uid,SvrId,Name,Num,Desc,SurplusNum})->
%% RoleId	String	角色ID	必选
%% RoleName	String	角色名	必选
%% SvrNo	Int	服务器ID	必选
%% GameCurrency	Int	游戏币	必选
%% Remark	string	途径描述	必选
%% State	string	-1为使用，1为获得	必选
	Addr=db:get_config(addrbc),
	State = if Num > 0->1;true->-1end,
	Str = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:escape_uri(util:to_list(Name))++
			  "&Remark="++util:escape_uri(util:to_list(Desc))++
			  "&GameCurrency="++util:to_list(Num)++
			  "&Num="++util:to_list(SurplusNum)++
			  "&State="++util:to_list(State)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:to_list(Name)++
			  "&Remark="++util:to_list(Desc)++
			  "&GameCurrency="++util:to_list(Num)++
			  "&Num="++util:to_list(SurplusNum)++
			  "&State="++util:to_list(State)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GameID="++util:to_list(?GAME_ID),

	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/convertCurrency?"++Str++"&Sign="++util:to_list(Sign);
%%商店购买
make_url(shop,{Name,Uid,SvrId,Item,Num,D1,D2})->
%% http://192.168.1.250:8080/game_gm/rpc/shopReport
%% RoleId	String	角色ID	必选
%% RoleName	String	角色名	必选
%% SvrNo	Int64	服务器id	必选
%% ShopId	String	商品id	必选
%% Num	Int	数量	必选
%% DeductGiveCurrency	Int	扣除赠送币	
	%% DeductRechargeCurrency	Int	扣除充值币	
	Addr=db:get_config(addrbc),
	Str = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:escape_uri(util:to_list(Name))++
			  "&ShopId="++util:to_list(Item)++
			  "&Num="++util:to_list(Num)++
			  "&DeductGiveCurrency="++util:to_list(D2)++
			  "&DeductRechargeCurrency="++util:to_list(D1)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:to_list(Name)++
			  "&ShopId="++util:to_list(Item)++
			  "&Num="++util:to_list(Num)++
			  "&DeductGiveCurrency="++util:to_list(D2)++
			  "&DeductRechargeCurrency="++util:to_list(D1)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GameID="++util:to_list(?GAME_ID),
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/shopLog?"++Str++"&Sign="++util:to_list(Sign);
%%返利验证
make_url(check_recharge_back, {Acc})->
	
	Addr=db:get_config(addrbc),
	Str = "Acc="++util:escape_uri(util:to_list(Acc))++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "Acc="++util:to_list(Acc)++
			   "&GameID="++util:to_list(?GAME_ID),
	
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/rebate?"++Str++"&Sign="++util:to_list(Sign);
%% 返利上报
make_url(get_recharge_back, {Acc,Name,SvrId,Channel})->
%% Acc	string	唯一标识	必选
%% Name	string	玩家名称	必选
%% Channel	Int64	渠道	必选
%% SvrNo	Int64	服务器ID	必选
	Addr=db:get_config(addrbc),
	Str =  "&Acc="++util:escape_uri(util:to_list(Acc))++
			"&Name="++util:escape_uri(util:to_list(Name))++
			"&Channel="++util:to_list(Channel)++
			"&SvrNo="++util:to_list(SvrId)++
			"&GameID="++util:to_list(?GAME_ID),
	
	Str1 =  "&Acc="++util:to_list(Acc)++
			"&Name="++util:to_list(Name)++
			"&Channel="++util:to_list(Channel)++
			"&SvrNo="++util:to_list(SvrId)++
			"&GameID="++util:to_list(?GAME_ID),
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/rebateValidate?"++Str++"&Sign="++util:to_list(Sign);
%%物品上报
make_url(item_change,{SvrId,Uid,Name,Item,Num,ActionData})->
%% 	RoleId	String	角色ID	必选
%% RoleName	String	角色名	必选
%% SvrNo	Int64	服务器ID	必选
%% GoodsId	Int64	商品id	必选
%% Remark	string	途径描述	必选
%% State	string	-1为使用，1为获得	必选
	State = if Num > 0-> 1;true->-1 end,
	Addr=db:get_config(addrbc),
	Str = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:escape_uri(util:to_list(Name))++
			  "&GoodsId="++util:to_list(Item)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&State="++util:to_list(State)++
			  "&Remark="++util:escape_uri(util:to_list(ActionData))++
			  "&GameID="++util:to_list(?GAME_ID),
	
	Str1 = "RoleId="++util:to_list(Uid)++
			  "&RoleName="++util:to_list(Name)++
			  "&GoodsId="++util:to_list(Item)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&State="++util:to_list(State)++
			  "&Remark="++util:to_list(ActionData)++
			  "&GameID="++util:to_list(?GAME_ID),
	
	List = sign_list(Str1),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/res?"++Str++"&Sign="++util:to_list(Sign);

%%军团上报
make_url(group_reported,{SvrId,Uid,Action,GroupId,GroupName})->
%% 	SvrNo	Int	服务器ID	必选
%% Action	String	操作动作0：增加1：删除2：修改	必选
%% GroupId	String	军团id	必选
%% GroupName	String	军团名称	N
%% CreateUser	String	创建者	N
	Addr=db:get_config(addrbc),
	Str = "CreateUser="++util:to_list(Uid)++
			  "&Action="++util:to_list(Action)++
			  "&SvrNo="++util:to_list(SvrId)++
			  "&GroupId="++util:to_list(GroupId)++
			  "&GroupName="++util:escape_uri(util:to_list(GroupName))++
			  "&GameID="++util:to_list(?GAME_ID),
	List = sign_list(Str),
	Sign = sign(List),
	"http://"++Addr++"/rpc/report/group?"++Str++"&Sign="++util:to_list(Sign);


make_url(recharge,{Uid,Aid,SvrId,Level,Time,First,Num,Channel,OrderId})->
	

%% 	RoleId	String	角色ID	必选
%% RoleName	String	角色名	必选
%% SvrNo	Int	服务器ID	必选
%% RechargeVirtualCurrency	Int	充值虚拟币	必选
%% GiveVirtualCurrency	Int	赠送虚拟币	必选
%% RechargeBalance	Int	充值虚拟币余额	必选
%% GiveBalance	Int	赠送虚拟币余额	必选
%% Remark	String	获取描述	必选

	Addr=db:get_config(addrbc),
  "http://"++Addr++"/game_gm/rpc/rechargeReport"++
        "?uid="++util:to_list(Uid)++
		"&aid="++util:to_list(Aid)++
		"&svrId="++util:to_list(SvrId)++
		"&level="++util:to_list(Level)++
		"&time="++util:to_list(Time)++
		"&isFirst="++util:to_list(First)++
        "&num="++util:to_list(Num)++
		"&channel="++util:to_list(Channel)++
		"&orderId="++util:to_list(OrderId)++
		"&level="++util:to_list(Level);

make_url(camp_join,{Uid,SvrId,Camp,Time})->
	Addr=db:get_config(addrbc),
  "http://"++Addr++"/mytemplate/gameAcc/camp_join"++
		"?Uid="++util:to_list(Uid)++
		"&SvrId="++util:to_list(SvrId)++
		"&Camp="++util:to_list(Camp)++
		"&Time="++util:to_list(Time);









make_url(lev,{Aid,Uid,SvrId,Lev,UpLev,Time})->
%% 	地址	http://192.168.1.250:8080/game_gm/rpc/levelReport
%% 参数	aid：账号ID  
%% uid：角色ID  
%% serverId：服务器id 
%% lev：等级 
%% upLev：提升等级 
%% time：时间 
	Addr=db:get_config(addrbc),
  "http://"++Addr++"/game_gm/rpc/levelReport"++
        "?aid="++util:to_list(Aid)++
		"&uid="++util:to_list(Uid)++
		"&serverId="++util:to_list(SvrId)++
		"&lev="++util:to_list(Lev)++
        "&upLev="++util:to_list(UpLev)++
		"&time="++util:to_list(Time);








make_url(svr_on_off,{SvrId,Status})->
	Addr=db:get_config(addrbc),
   "http://"++Addr++"/mytemplate/gameAcc/svr_on_off"++
         "?SvrId="++util:to_list(SvrId)++
		 "&Status="++util:to_list(Status);




make_url(role,{Aid,Time,SvrId,Uid,Prof,Camp,Status,Name})-> 
%% 	地址	http://gm.lynlzqy.com:8080/game_gm/rpc/roleReport
%% 参数	registerTime:创建时间
%% channel：渠道
%% serverId：服务器ID
%% uid：角色ID
%% aid:账号ID
%% prof：职业
%% status：新增|删除（"add"| "del"）
%% name：角色名称
%% 返回值	json:
%% status: succ成功 fail 失败
	Addr=db:get_config(addrbc),
 "http://"++Addr++"/game_gm/rpc/roleReport"
       "?aid="++ util:to_list(Aid)++
	   "&registerTime="++util:to_list(Time)++
	   "&serverId="++util:to_list(SvrId)++
		"&uid="++util:to_list(Uid)++
		"&prof="++util:to_list(Prof)++
		"&camp="++util:to_list(Camp)++
		"&name="++util:escape_uri(util:to_list(Name))++
		"&status="++util:to_list(Status);
make_url(register,{Aid,Time,SvrId,Channel})->
%% 	地址	http://192.168.1.250:8080/game_gm/rpc/register
%% 参数	registerTime：注册时间（秒）
%% serverId：服务器ID
%% aid:aid:账号ID（long型）
%% channelId:渠道名称（String型）
%% 返回值	succ:成功
%% Fail：失败

  Addr=db:get_config(addrbc),
  "http://"++Addr++"/game_gm/rpc/register"
        "?aid="++ util:to_list(Aid)++
	    "&registerTime="++util:to_list(Time)++
	    "&serverId="++util:to_list(SvrId)++
	    "&channelId="++util:to_list(Channel);








make_url(activeData,{Uid,SvrId,WarId,Time})->
%% 地址	http://192.168.1.249:8080/game_gm/rpc/activeData
%% uid：角色ID
%% svrId：服务器ID
%% actId：多人活动ID
%% activeDate：活动时间
%% 返回值	result:0 成功
%% result：-1失败

  Addr=db:get_config(addrbc),
  "http://"++Addr++"/game_gm/rpc/activeData"
        "?serverId="++ util:to_list(SvrId)++
	    "&time="++util:to_list(Time)++
	    "&uid="++util:to_list(Uid)++
	    "&activityId="++util:to_list(WarId);


make_url(_Req,_Args)->  
  Addr=db:get_config(addrbc),
  "http://"++Addr++"/mytemplate/nomatch".


cdk_sign(List)->
	Str= string:join(lists:sort(List), "&")++":"++db:get_all_config(gamekey),
	string:to_upper(util:md5(Str)). 

sign(List)->
	Str= string:join(lists:sort(List), "&")++":4RFMD15AS49U6JPATT3H9FKC4ZRXEQPW",
	string:to_upper(util:md5(Str)). 
sign_list(Str)->
	string:tokens(Str, "&").
	
default_call_back(_,_)->ok.		
	


data_call_back({StatusLine, Body}, {get_cdkey_info,Hid})->
 	?debug("get_cdkey_info,~p",[{StatusLine, Body}]),
	case  rfc4627:decode(Body)  of  
		{ok, {obj, Datas}, []} when  erlang:is_list(Datas) ->
			case lists:keyfind("Status", 1, Datas)  of  
				{_,true}->
					{_,Type}=lists:keyfind("Type", 1, Datas),
					{_,Key}=lists:keyfind("Key", 1, Datas),
					{_,Data} = lists:keyfind("Data", 1, Datas),
					NewData = case rfc4627:decode(Data) of
								  {ok,DataJosn,_}->DataJosn;
								  _->[]
							  end,
					DataList = cdkey_item_josn_info(NewData, []),
					?debug("cdkey item:~p",[DataList]),
					gen_server:cast(Hid, {get_cdkey_info,{ok,DataList,util:to_list(Key),Type}});
				_->gen_server:cast(Hid, {get_cdkey_info,{nokey}})
			end;
		_R-> 
			gen_server:cast(Hid, {get_cdkey_info,{nokey}})
	end;


data_call_back(_, _)->ok.

cdkey_item_josn_info([ItemList|OldItem],OldList)->
	FunItem = fun({obj,ItemInfo})->
					  {_,Num}=lists:keyfind("num", 1, ItemInfo),
					  {_,ItemType}=lists:keyfind("item", 1, ItemInfo),
					  {ItemType,Num}
			  end,		
	cdkey_item_josn_info(OldItem, OldList ++  lists:map(FunItem, [ItemList]));
cdkey_item_josn_info([],OldList)->OldList.