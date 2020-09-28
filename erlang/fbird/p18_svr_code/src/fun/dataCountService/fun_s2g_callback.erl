-module(fun_s2g_callback).
-include("common.hrl").
-export([do_call/1,do_msg/1]).

do_msg({all_notice,Text})->
	mod_msg:handle_to_chat_server({send_system_msg, ["264",Text], gm});
do_msg(_R)->ok.

do_call({usr_muzzled,Uid,Action,Time})->
	case  Action of  
		"impl"->fun_gm_operation:start_shutup(Uid,Time);
		"relieve"->fun_gm_operation:remove_shutup(Uid);
		_->skip
	end;
do_call({usr_ban,Uid,Action,Time})->
	fun_agent_mng:on_usr_ban(Uid),
	case  Action of  
		"impl"->fun_gm_operation:start_sethonor(Uid,Time);
		"relieve"->fun_gm_operation:remove_sethonor(Uid);
		_->skip
	end;
do_call({usr_kick,Uid})->
	fun_gm_operation:kick_usr(Uid);

do_call({kick_all_usr})->
	fun_gm_operation:kick_all_usr(); 

do_call({usrs_mail,Usrs,Items,Coin,Diamo,Title,Text})->
	?debug("--------Usrs=~p",[Usrs]),
	mod_mail_new:gm_usrs_mail(Usrs, Title, Text,Items++[{?RESOUCE_COPPER_NUM,Coin},{?RESOUCE_COIN_NUM,Diamo}], 14),
	ok;
do_call({usrs_mail,Usrs,Items,Coin,Diamo,Title,Text,CanDel})->
	?debug("--------Usrs=~p",[Usrs]),
	mod_mail_new:gm_usrs_mail(Usrs, Title, Text,Items++[{?RESOUCE_COPPER_NUM,Coin},{?RESOUCE_COIN_NUM,Diamo}], 14, CanDel),
	ok;
do_call({all_mail,Start,End,Channel,Items,Coin,Diamo,Title,Text})->
	mod_mail_new:gm_all_mail(Title, Text, Items++[{?RESOUCE_COPPER_NUM,Coin},{?RESOUCE_COIN_NUM,Diamo}], 14, Channel, Start, End),
	ok;

do_call({draw_action_state,State})->
	case db:dirty_get(opening_server_time, 1) of
		[OpeningServerTime = #opening_server_time{draw_astrict=DrawState}|_]->
			if DrawState == State->error;
			   true->
				   db:dirty_put(OpeningServerTime#opening_server_time{draw_astrict=State}),{ok,State}
			end;
		_->error
	end;
do_call({gm_msg,Text})->
	mod_msg:handle_to_chat_server({send_system_msg, [Text], gm});

do_call({gm_send_chat_to_ply,Uid,Text})->
	mod_msg:handle_to_chat_server({send_system_msg, [Text], {gm_chat,Uid}});

do_call({online_usrs}) ->   
	{ok,length(fun_agent_mng:get_usrs())};

do_call({usr_info,Uid})->gm_get_usr_info(Uid);

do_call({change_usr,Uid1,Uid2}) ->
	case db:dirty_get(usr, Uid1) of
		[Usr = #usr{acc_id = AccId1}] ->
			case db:dirty_get(usr, Uid2) of
				[#usr{acc_id = AccId2}] ->
					case AccId1 == AccId2 of
						true -> skip;
						_ ->
							NewUsr = Usr#usr{acc_id = AccId2},
							db:dirty_put(NewUsr),
							ok
					end;
				_ -> skip
			end;
		_ -> skip
	end;

do_call(_Msg)->nomatch.

gm_get_usr_info(Uid)->
	case db:getOrKeyFindData(usr, Uid) of  
		[#usr{name=Name,acc_id=Aid,create_time=Create,last_logout_time=LastLogOut,lev=Lev,vip_lev=Vip,fighting=Fighting,state=DelUsr}]->
			case db:getOrKeyFindData(account,Aid) of   
				[#account{name=Acc,channel=Channel}]->
					Diamo = mod_role_tab:get_resoure(Uid, ?RESOUCE_COIN_NUM),
					BDiamo = mod_role_tab:get_resoure(Uid, ?RESOUCE_BINDING_COIN_NUM),
					Coin = mod_role_tab:get_resoure(Uid, ?RESOUCE_COPPER_NUM),
					Equs=[],
					Heros=[],
					Stones=get_stones(Uid),
					{ok,db:get_all_config(serverid),Acc,Aid,Name,util:to_integer(Uid),Channel,Create,LastLogOut,Lev,Vip,Fighting,BDiamo,Diamo,Coin,DelUsr,Equs,Heros,Stones};
				_->skip
			end;
		_->skip
	end.

get_stones(Uid)-> 
	case db:getOrFindData(t_gem, Uid, #t_gem.uid, uid)  of  
		Gems when  erlang:is_list(Gems)->
			[{obj, [{"Type", Type},{"Lev",Lev},{"Status",Status}]}|| {Type,Lev,Status}<-Gems];
		_->[]
	end.