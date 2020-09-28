-module(fun_http_action).
-include("common.hrl").

-define(REQ_FAIL,rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("失败")}]})).
-define(REQ_ERROR,rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("错误")}]})).
-define(REQ_SUCC,rfc4627:encode({obj,[{"state",1},{"msg",util:to_binary("成功")}]})).
-define(REQ_ONE,rfc4627:encode({obj, [{"state",1}]})).
-define(REQ_DRAW_SUCCES,rfc4627:encode({obj, [{"state",1},{"msg",util:to_binary("成功")}]})).
-define(REQ_DRAW_SIGN_ERROR,rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("签名失败")}]})).
-define(REQ_DRAW_OTHER_ERROR,rfc4627:encode({obj, [{"state",3},{"msg",util:to_binary("错误")}]})).

-export([usr_kick/3,all_mail/3,all_notice/3,rescind_notice/3,usr_ban/3, 
		 usrs_mail/3,usr_muzzled/3,gm_msg/3,online_usrs/3,call_http_server/1,usr_info/3,
		 check_ip/2,gm_chat/3,activity_config/3,roles_kick/3,change_usr/3
		]).
-export([pay/3,gm_pay/3]).

call_agentmng(Msg)->gen_server:call(agent_mng, {data_count,Msg}, 2000).
send_http_server(Msg)->gen_server:cast(fun_http_server, Msg).
call_http_server(Msg)->gen_server:call(fun_http_server, Msg, 2000).
%%gm后台整理
activity_config(Sid, Env, In1)->
	?TRY_CATCH(fun() -> activity_config_help(Sid, Env, In1) end, E, R).
activity_config_help(Sid, _Env, In1) ->	
	In = http_uri:decode(In1),
	case rfc4627:decode(In)  of  
		{ok,{obj,Datas},[]}->
			%%?debug("--------------Datas=~p",[Datas]),
			{_,ActId} =lists:keyfind("act_id", 1, Datas),
			{_,State} =lists:keyfind("state", 1, Datas),
			{_,Type} =lists:keyfind("type", 1, Datas),
			gm_activity(Sid,util:to_list(ActId),util:to_integer(State), util:to_integer(Type),Datas);
		_->mod_esi:deliver(Sid,[?REQ_ERROR])
	end.

gm_activity(Sid,ActId,State,Type,Datas)->
	case State of
		1 ->
			Ret = fun_gm_activity_ex:activity_config(Datas),
			mod_esi:deliver(Sid,[Ret]);
		_ ->
			Ret = fun_gm_activity_ex:del_config(util:to_integer(ActId), Type),
			mod_esi:deliver(Sid,[Ret])
	end.


check_ip(Env,Sid)->
    {remote_addr, Ip} = lists:keyfind(remote_addr, 1, Env),
	?debug("-------Ip=~p",[Ip]),
	case db:get_config(bindips) of
		Addrs when erlang:is_list(Addrs) ->
			 case  lists:member(Ip, Addrs) of  
				  true->  true;
				  _->mod_esi:deliver(Sid,[Ip]),false
			 end;
	    _->true
	end.
%% 全服邮件
%% http://host:port/rpc/fun_http_action:all_mail?starttime=Start&endtime=End&channel=Channel&items=Items&coin=Coin&diamo=Diamo&title=Title&text=Text
%% Items=json   {items:[item...]} item={id:v,num:v,lev:v,enhancement:v}
all_mail(Sid,_Env,In)->
	?debug("-------In=~p",[In]),
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					?debug("----NewDatas=~p",[Datas]),
					{_,Start} =lists:keyfind("starttime", 1, Datas),
					{_,End} =lists:keyfind("endtime", 1, Datas),
					{_,Channel} =lists:keyfind("channel", 1, Datas),
					{_,Items} =lists:keyfind("items", 1, Datas),
					{_,Title} =lists:keyfind("title", 1, Datas),
					{_,Text} =lists:keyfind("text", 1, Datas),
					Msg={all_mail,util:to_integer(Start),util:to_integer(End),util:to_integer(Channel),get_item_list(Items),0,0,Title,Text},
					case  call_agentmng(Msg)  of  
						ok->
							?debug("--------------true"),
							mod_esi:deliver(Sid,[?REQ_SUCC]);
						_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary(util:to_list("格式错误"))}]})])
					end;
				_->skip
			end;
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:escape_uri(util:to_binary("格式错误"))}]})])
	end.

get_item_list(Items)->
	Fun = fun({obj,Item})->
				  {_,ID} = lists:keyfind("id", 1, Item),
				  {_,Num} = lists:keyfind("num", 1, Item),  
				  {ID,Num}  
		  end,
	lists:map(Fun, Items).
get_objs_usr(Usrs)->
	lists:foldl(fun(Usr,Acc)->[util:to_integer(Usr)]++Acc end,[] , Usrs).
%% 玩家邮件
%% http://host:port/rpc/fun_http_action:usrs_mail?usrs=Usrs&items=Items&coin=Coin&diamo=Diamo&title=Title&text=Text
%% items=json   {items:[item...]} item={id:v,num:v,lev:v,enhancement:v}
%% usrs=json   {usrs:[id...]} id={id:v}
usrs_mail(Sid,_Env,In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					{_,Usrs} =lists:keyfind("users", 1, Datas),
					{_,Items} =lists:keyfind("items", 1, Datas),
					{_,Title} =lists:keyfind("title", 1, Datas),
					{_,Text} =lists:keyfind("text", 1, Datas),
					{_,CanDel} = case lists:keyfind("canDel", 1, Datas) of
						false -> {0,0};
						_ -> lists:keyfind("canDel", 1, Datas)
					end,
					Msg={usrs_mail,get_objs_usr(Usrs),get_item_list(Items),0,0,Title,Text,CanDel},
					case  call_agentmng(Msg)  of  
						ok->
							mod_esi:deliver(Sid,[?REQ_SUCC]);
						_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary(util:to_list("格式错误"))}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary(util:to_list("格式错误"))}]})])
			end;
		_R->
			mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary(util:to_list("格式错误"))}]})])
	end.
%% 全服公告
%% http://host:port/rpc/fun_http_action:all_notice?starttime=Start&endtime=End&frequency=Frequency&text=Text
all_notice(Sid,_Env,In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					{_,Start} =lists:keyfind("starttime", 1, Datas),
					{_,End} =lists:keyfind("endtime", 1, Datas),
					{_,Frequency} =lists:keyfind("interval", 1, Datas),
					{_,Text} =lists:keyfind("text", 1, Datas),
					Msg={all_notice,util:to_integer(Start),util:to_integer(End),util:to_integer(Frequency),Text},
					case  call_http_server(Msg)  of  
						Id when erlang:is_integer(Id)->
							mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",1},{"msg",util:to_binary("成功")},
																	   {"data",{obj,[{"id",Id}]}}]})]);
						_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_R->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.
%% 撤销全服公告
%% http://host:port/rpc/fun_http_action:rescind_notice?id=Id
rescind_notice(Sid,_Env,In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					?debug("Datas=~p",[Datas]),
					{_,Id} =lists:keyfind("id", 1, Datas),
					?debug("--------------=~p",[Id]),
					Msg={rescind_notice,util:to_integer(Id)},
					send_http_server(Msg),
					?debug("--------------true"),
					mod_esi:deliver(Sid,[?REQ_SUCC]);
				_R->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.


%% gm喊话
%% http://host:port/rpc/fun_http_action:gm_msg?text=Text
gm_msg(Sid,_Env,In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					?debug("Datas=~p",[Datas]),
					{_,Text} =lists:keyfind("text", 1, Datas),
					?debug("--------------=~p",[Text]),
					Msg={gm_msg,util:to_list(Text)},
					case  call_agentmng(Msg)  of  
						ok->
							?debug("--------------true"),
							mod_esi:deliver(Sid,[?REQ_SUCC]);
						_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->skip
	end.

%%http://host:port/rpc/fun_http_action:gm_chat?uid=Uid&text=Text
gm_chat(Sid,_Env,In) ->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					?debug("Datas=~p",[Datas]),
					{_,Uid} =lists:keyfind("uid", 1, Datas),
					?debug("--------------=~p",[Uid]),
					{_,Text} =lists:keyfind("text", 1, Datas),
					?debug("--------------=~p",[Text]),
					Msg={gm_send_chat_to_ply,util:to_integer(Uid),util:to_list(Text)},
					case call_agentmng(Msg) of  
						ok->
							?debug("--------------true"),
							mod_esi:deliver(Sid,[?REQ_SUCC]);
						_-> mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.

%% 在线玩家数
%% http://host:port/rpc/fun_http_action:online_usrs
online_usrs(Sid,_Env,_In)->
	Msg={online_usrs},
	
	case  call_agentmng(Msg)  of  
		{ok,Num}->
			?debug("--------------Num=~p",[Num]),
			mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",1}, {"msg",util:to_binary("成功")},
													   {"data",{obj,[{"num",Num}]}}]})]);
%% 			Ret="{\"status\":\"succ\""++
%% 					",\"Num\":"++util:to_list(Num)++
%% 					"}",
%% 			mod_esi:deliver(Sid,[Ret]);
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.

%% 玩家信息
%% http://host:port/rpc/fun_http_action:usr_info?uid=Uid
usr_info(Sid,_Env,In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					?debug("Datas=~p",[Datas]),
					{_,Uid} =lists:keyfind("uid", 1, Datas),
					?debug("--------------=~p",[Uid]),
					Msg={usr_info,util:to_integer(Uid)},
					case call_agentmng(Msg) of 
						{ok,SvrId,Acc,Aid,Name,NewUid,Channel,Create,LastLogOut,Lev,Vip,Fighting,BDiamo,Diamo,Coin,DelUsr,Equs,Heros,Stones}->
							UsrData=make_usr_data(SvrId,Acc,Aid,Name,NewUid,Channel,Create,LastLogOut,Lev,Vip,Fighting,BDiamo,Diamo,Coin,DelUsr,Equs,Heros,Stones),
							mod_esi:deliver(Sid,[UsrData]);
						_R->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->skip
	end.

%% 玩家禁言|解除
%% http://host:port/rpc/fun_http_action:usr_muzzled?uid=Uid&time=Time&action=Action
usr_muzzled(Sid, _Env, In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					?debug("Datas=~p",[Datas]),
					{_,Uid} =lists:keyfind("roleId", 1, Datas),
					?debug("--------------=~p",[Uid]),
					{_,Time} =lists:keyfind("time", 1, Datas),
					?debug("--------------=~p",[Time]),
					{_,Action} =lists:keyfind("action", 1, Datas),
					?debug("--------------=~p",[Action]),
					Msg={usr_muzzled,util:to_integer(Uid),util:to_list(Action),util:to_integer(Time)},
					case  call_agentmng(Msg)  of  
						ok->
							?debug("-------------------true"),
							mod_esi:deliver(Sid,[?REQ_SUCC]);
						_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("玩家没有被禁言")}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.
%%  玩家封号|解除
%% http://host:port/rpc/fun_http_action:usr_ban?uid=Uid&time=Time&action=Action
usr_ban(Sid,_Env,In)->
	case rfc4627:decode(In)  of  
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas)  of  
				{ok,{obj,Datas},[]}->
					{_,Uid} =lists:keyfind("roleId", 1, Datas),
					{_,Time} =lists:keyfind("time", 1, Datas),
					{_,Action} =lists:keyfind("action", 1, Datas),
					Msg={usr_ban,util:to_integer(Uid),util:to_list(Action),util:to_integer(Time)},
					
					case  call_agentmng(Msg)  of  
						ok->
							mod_esi:deliver(Sid,[?REQ_SUCC]);
						_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("玩家没有封号")}]})])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->skip
	end.
%%  踢玩家下线
%% http://host:port/rpc/fun_http_action:usr_kick?uid=Uid
usr_kick(Sid,_Env,In)->
	case rfc4627:decode(In) of
		{ok,{obj,Data},[]}->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas) of
				{ok,{obj,Datas},[]}->
					?debug("Datas=~p",[Datas]),
					{_,Uid} =lists:keyfind("uid", 1, Datas),
					Msg={usr_kick,util:to_integer(Uid)},
					case call_agentmng(Msg)  of   
						skip->
							mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("角色不在线")}]})]);
						_R->
							?debug("-------true"),
							mod_esi:deliver(Sid,[?REQ_SUCC])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.

%%  踢所有玩家下线
%% http://host:port/rpc/fun_http_action:roles_kick
roles_kick(Sid,_Env,_In)->
	Msg={kick_all_usr},
	case call_agentmng(Msg)  of   
		skip->
			mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("踢人失败")}]})]);
		_R->
			mod_esi:deliver(Sid,[?REQ_SUCC])
	end.

% 转移账号角色
% 将Uid1的角色转移到Uid2角色的账号下 
% http://host:port/rpc/fun_http_action:change_usr?uid1=Uid1&uid2=Uid2
change_usr(Sid,_Env,In) ->
	case rfc4627:decode(In) of
		{ok,{obj,Data},[]} ->
			{_,DataStr} = lists:keyfind("data", 1, Data),
			NewDatas = base64:decode_to_string(DataStr),
			case rfc4627:decode(NewDatas) of
				{ok,{obj,Datas},[]}->
					{_,Uid1} =lists:keyfind("uid1", 1, Datas),
					{_,Uid2} =lists:keyfind("uid2", 1, Datas),
					Msg={change_usr,util:to_integer(Uid1),util:to_integer(Uid2)},
					case call_agentmng(Msg)  of   
						skip ->
							mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("转移失败")}]})]);
						_ ->
							mod_esi:deliver(Sid,[?REQ_SUCC])
					end;
				_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
			end;
		_->mod_esi:deliver(Sid,[rfc4627:encode({obj, [{"state",0},{"msg",util:to_binary("格式错误")}]})])
	end.

%% {'serverId':'5001','accName':'aaa','aid':'1','uName':'abc','uid':'1','channelId':'1',
%%  'create':'2016-06-07 00:00:00','lastLoginOut':'2016-06-07 00:00:00','level':'10','vip':'1',
%%  'fighting':'10000','boundDiamond':'100','diamond':'1000','coin':'9999','idDel':'0','equipmentLog':[],'heroLog':[],'gemLog':[]}

%% 装备：强化等级 强化星级 装备名 宝石信息
%% 英雄：英雄名 英雄等级、强化星级
%% 宝石id  宝石等级  镶嵌


make_usr_data(_SvrId,_Acc,Aid,Name,Uid,_Channel,Create,LastLogOut,Lev,Vip,Fighting,BDiamo,Diamo,Coin,_DelUsr,_Equs,_Heros,_Stones)->
%% rfc4627:encode([{obj, [{"Type", 1},{"Lev",1},{"Star",1}]},{obj, [{"Type", 1},{"Lev",1},{"Star",1}]}]).
%% 	?debug("!!!!!!!!!!!!!!!!~p",[{Acc,Name}]),

%% 	{“state”:1,”msg”:”成功”,”data”:{“aid”:aid,”uid”:uid,”uName”:uName,creaet:create, 
%% lastLoginOut:lastLoginOut,”level”:level,”vip”:vip, fighting : fighting, diamond: diamond , boundDiamond : boundDiamond , coin : coin }
	Data=rfc4627:encode({obj, [{"state",1},{msg,util:to_binary("成功")},
							   {"data",{obj,[{"aid", Aid},{"uid",Uid},{"uName",util:to_binary(Name)},{"create",Create},
											 {"lastLoginOut",LastLogOut},{"level", Lev},{"vip",Vip},{"fighting",Fighting},
											 {"diamond",Diamo},{"boundDiamond", BDiamo},{"coin",Coin}]}}
						 ]}),
%% 	?debug("!!!!!!!!!!!!!!!!!!!!!!!!!!~p",[{Data}]),
	Data.

%% =============================================================================
%% ============================ 合并充值下发到一起 =============================

pay(Sid, Env, In) ->
	fun_http_rpc_lyn:pay(Sid, Env, In).

gm_pay(Sid, Env, In) ->
	fun_http_rpc_lyn:gm_pay(Sid, Env, In).
