-module(fun_dataCount_update).
-include("common.hrl").
-export([get_cdkey_info/5,update_cdkey_use/5,role_update/6,svr_on_off/2,max_online/2,check_recharge_back/2,get_recharge_back/3]).

-export([coin_change/5,camp_kill/4,recharge/7,usr_register/5,lev_change/2,lev_change/4,task_count/3,diamo_change/7,shop_count/5,item_change/4]).
-export([chat_upload/4,war_activity/3,group_reported/4]).
-export([handle/1]).
-export([barrier_win/2,task_step/3,gm_activity/3,gm_activity_rank/3]).
-export([get_versions/0, report_usr_login/12,report_usr_logout/12]).

handle({report, ReportFun}) -> 
	% ?debug("report in process:~p", [self()]),
	ReportFun().


send_httpclient(Msg)->gen_server:cast({global,http_client}, Msg).

%%聊天上报 
chat_upload(ChatChannel,AccName,Uid,Content) ->	
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_CHAT, {AccName, Uid, ChatChannel, Content}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%%任务节点上报
task_count(_Task,_Step,_Status)-> ok.

%%击杀上报
camp_kill(_Killer,_KillName, _BeKiller,_BeKillName)->
	ok.

%% 虚拟货币上报 
diamo_change(Way,Uid,Name,CoinNum, BindingCoinNum,TotalCoin,TotalBindingCoin)->
	Lv = util:get_lev_by_uid(Uid),
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_DIAMOND_CHANGE, {Uid,Name,Lv,CoinNum,TotalCoin,BindingCoinNum,TotalBindingCoin,Way}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%%兑换货币上报
coin_change(Uid,Name,Desc,Num,SurplusNum)->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_CASH_CHANGE, {Uid,Name,Num,SurplusNum,Desc}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%%商城操作日志上报
shop_count(Uid, Item,Num,D1,D2)->
	Name = util:get_name_by_uid(Uid),
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_SHOP_BUY, {Uid,Name,Item,Num,D2,D1}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%%返利验证
check_recharge_back(Acc,Hid)->
	CbInfo = {fun_plat_interface_gms, data_call_back, {check_recharge_back,Hid}},
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_REQ_REBATE_INFO, {CbInfo, Acc}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).
%%返利上报
get_recharge_back(Acc,Name,Channel)->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_REBATE_DONE, {Acc,Name,Channel}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%%物品上报 
item_change(Uid,Item,Num,Way) when Item /= ?RESOUCE_EXP_NUM ->
	Name = util:get_name_by_uid(Uid),
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_ITEM_CHANGE, {Uid,Name,Item,Num,Way}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun});
item_change(_Uid,_Item,_Num,_Action) ->
	ok.	

%% 主关卡通关上报
barrier_win(Uid, Barrier) ->
	Name = util:get_name_by_uid(Uid),
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_BARRIER, {Uid, Name, Barrier}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%% 主关卡通关上报
task_step(Uid, Sort, TaskStep) ->
	Name = util:get_name_by_uid(Uid),
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_TASK2, {Uid, Name, Sort, TaskStep}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).	

%%军团上报
group_reported(Uid,Action,GroupId,GroupName)->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_GUILD, {GroupId,GroupName,Uid,Action}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

gm_activity(Uid,ActType,ID) ->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_ACTIVITY, {Uid,ActType,ID}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

gm_activity_rank(Uid,ActType,Rank) ->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_ACTIVITY_RANK, {Uid,ActType,Rank}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

recharge(_Uid,_Aid,_Lev,_First,_Num,_Channel,_OrderId)->
	ok.

usr_register(AccName,Uid,UserName,ServerId,ClientIp)->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_USR_REGISTER, {AccName,Uid,UserName,ServerId,ClientIp,util_time:unixtime()}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).


report_usr_login(Uid, UsrName, Ip, UsrLv, Prof, GuildID, VipLev, Fighting, Camp, Copper, Coin, CoinBind) ->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_LOGIN_LOGOUT, {"login", Uid, UsrName, Ip, UsrLv, Prof, GuildID, VipLev, Fighting, Camp, Copper, Coin, CoinBind,util_time:unixtime()}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

report_usr_logout(Uid, UsrName, Ip, UsrLv, Prof, GuildID, VipLev, Fighting, Camp, Copper, Coin, CoinBind) ->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_LOGIN_LOGOUT, {"logout", Uid, UsrName, Ip, UsrLv, Prof, GuildID, VipLev, Fighting, Camp, Copper, Coin, CoinBind,util_time:unixtime()}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).


lev_change(_Lev,_UpLev,_Aid,_Uid)->
	ok.
lev_change(_Lev,_UpLev)-> 
	ok.

role_update(_Aid,_Uid,_Prof,_Camp,_Status,_Name)-> ok.
	% send_httpclient({role,{Aid,util:unixtime(),db:get_all_config(serverid),Uid,Prof,Camp,Status,Name}}).
svr_on_off(_ServerId,_Status)->
	ok.

update_cdkey_use(Uid,Aid,SvrId,Key,Hid)->
	send_httpclient({update_cdkey_use,{Uid,Aid,SvrId,Key,Hid}}).
get_cdkey_info(Uid,Aid,SvrId,Key,Hid)->
	send_httpclient({get_cdkey_info,{Uid,Aid,SvrId,Key,Hid}}).

get_versions() ->
	send_httpclient({get_versions}).


max_online(CurNum,MaxNum)->
	Fun = fun() -> fun_plat_interface_gms:report(?GMS_EVT_ONLINE, {CurNum, MaxNum}) end,
	mod_msg:handle_to_http_client(?MODULE, {report, Fun}).

%%多人活动数据采集
war_activity(_Uid,_WarId,_Time)-> ok.


% get_chat_desc(?CHANLE_WORLD)->"世界";
% get_chat_desc(?CHANLE_TEAM)->"队伍";
% get_chat_desc(?CHANLE_CAMP)->"阵营";
% get_chat_desc(?CHANLE_GUILD)->"公会";
% get_chat_desc(?CHANLE_PRIVITE)->"私人";
% get_chat_desc(?CHANLE_SPEAKER)->"喇叭";
% get_chat_desc(?CHANLE_SYSTEM)->"系统";
% get_chat_desc(?CHANLE_GUILD_SYSTEM)->"公会系统";
% get_chat_desc(?CHANLE_CURR)->"当前场景";
% get_chat_desc(?CHANLE_GM_SYSTEM)->"GM频道";
% get_chat_desc(_)->"未知频道".

