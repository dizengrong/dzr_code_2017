%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2015-10-9
%% Company : fbird.Co.Ltd
%% Desc : fun_resoure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_resoure).
-include("common.hrl").
-export([add_resoure/3,add_resoure/4,add_exp/3,is_prof/2,get_resoure/2,check_resouce_num/3,check_resouce/1,del_resoure/3,del_resoure/4]).
-export([check_coin/2, send_resource_to_client/2]).

proc_add_resource(Uid,Sid,Type,Num,Way) ->
	NewNum = case Type of
		?RESOUCE_VIP_EXP_NUM->
			fun_vip:add_vip_exp(Uid, Sid, Num);
		?RESOUCE_EXP_NUM->
			add_exp(Uid, Num, 0);
		_->
			mod_role_tab:add_resource(Uid, Type, Num)
	end,
	fun_count:can_trigger_diamond_event(Way) andalso fun_count:process_count_event(resource_change,{Way,Type,Num},Uid,Sid),
	if
		Type == ?RESOUCE_COIN_NUM orelse Type == ?RESOUCE_BINDING_COIN_NUM ->
			% Level=util:get_lev_by_uid(Uid),
			TotalCoin = mod_role_tab:get_resoure(Uid, ?RESOUCE_COIN_NUM),
			TotalBindingCoin = mod_role_tab:get_resoure(Uid, ?RESOUCE_BINDING_COIN_NUM),
			if
				Type == ?RESOUCE_COIN_NUM->
					TotalCoin = NewNum,
					TotalBindingCoin = mod_role_tab:get_resoure(Uid, ?RESOUCE_BINDING_COIN_NUM),
					fun_dataCount_update:diamo_change(Way,Uid,util:get_name_by_uid(Uid), Num,0,TotalCoin,TotalBindingCoin);
				Type == ?RESOUCE_BINDING_COIN_NUM->
					TotalCoin = mod_role_tab:get_resoure(Uid, ?RESOUCE_COIN_NUM),
					TotalBindingCoin = NewNum,
					fun_dataCount_update:diamo_change(Way,Uid,util:get_name_by_uid(Uid),0, Num,TotalCoin,TotalBindingCoin);
				true -> skip
			end;
		abs(Num) > 5000 andalso Type == ?RESOUCE_COPPER_NUM->
			SurplusNum = mod_role_tab:get_resoure(Uid, ?RESOUCE_COPPER_NUM),
			fun_dataCount_update:coin_change(Uid, util:get_name_by_uid(Uid), Way, Num, SurplusNum);
		true -> skip
	end,
	%% send client
	case check_resouce(Type) of
		true -> send_resource_to_client(Sid,[{Type,NewNum}]);
		_ -> skip
	end.

send_resource_to_client(Sid, ResourceList) ->
	Fun = fun({Type,Num}) ->
		#pt_public_resource_list{resource_type=Type,resource_num=Num}
	end,		
	ResourceList1=lists:map(Fun, ResourceList),
	Pt = #pt_update_resource{resource_list=ResourceList1},
	?send(Sid,proto:pack(Pt)).

%%增加资源
add_resoure(Uid,Type,N) when N > 0->
	add_resoure(Uid,Type,N,0).
add_resoure(Uid,Type,N,Way) when N > 0->
	NewN = util:ceil(N),
	Sid = util:get_sid_by_uid(Uid),
	proc_add_resource(Uid,Sid,Type,NewN,Way);
add_resoure(_Uid,_Type,_N,_Way)->skip.

%%增加资源
del_resoure(Uid,Type,N) when N > 0->
	del_resoure(Uid,Type,N,0).
del_resoure(Uid,Type,N,Way) when N > 0->
	NewN = util:ceil(N),
	Sid = util:get_sid_by_uid(Uid),
	case Type of
	   ?RESOUCE_BINDING_COIN_NUM -> 
		    HasNum1 = mod_role_tab:get_resoure(Uid,?RESOUCE_BINDING_COIN_NUM),
		    HasNum2 = mod_role_tab:get_resoure(Uid,?RESOUCE_COIN_NUM),
		    if
			    HasNum1 >= NewN -> 
			    	proc_add_resource(Uid, Sid, ?RESOUCE_BINDING_COIN_NUM, -1 * NewN, Way);
			    HasNum1 + HasNum2 >= NewN -> 
			    	proc_add_resource(Uid, Sid, ?RESOUCE_BINDING_COIN_NUM, -1 * HasNum1, Way),
			    	proc_add_resource(Uid, Sid, ?RESOUCE_COIN_NUM, -1 * (NewN - HasNum1), Way);
			    true -> false
		    end;
	    _ -> 
		    HasNum = mod_role_tab:get_resoure(Uid,Type),
		    if
			   	HasNum >= NewN -> 
			   		proc_add_resource(Uid, Sid, Type, -1 * NewN, Way);
			   	true -> false
		    end
    end;
del_resoure(_Uid,_Type,_N,_Way) ->skip.


%%检查是否是资源
check_resouce(Type)->
	case data_item:get_data(Type) of
		#st_item_type{sort = Sort} when Sort == ?ITEM_TYPE_RESOURCE -> true;
		_ -> false
	end.

%%获取资源		
get_resoure(Uid,Type)->
	util:floor(new_get_resoure(Uid,Type)).
new_get_resoure(Uid,Type)->
	mod_role_tab:get_resoure(Uid, Type).
	% case Type of
	% 	?RESOUCE_GUILD_CONTRIBUTION-> 
	% 		fun_guild_new:get_guild_contribution(Uid);
	% 	?RESOUCE_GUILD_INTEGRAL->
	% 		fun_guild_new:get_guild_integral(Uid);
	% 	_-> 
	% end.

check_resouce_num(Uid,Type,Num)->
	if
		Type == ?RESOUCE_BINDING_COIN_NUM -> check_coin(Uid, Num);
		true ->
			OwnNum = mod_role_tab:get_resoure(Uid,Type),
			if
				OwnNum >= Num ->true;
				true->false
			end
	end.

is_prof(P1,P2)->
	if
		P1 == 0 orelse P1 == P2 -> true;
		true->false
	end.

add_exp(Uid,Exp,_Power) -> 
	case db:dirty_get(usr, Uid) of
		[#usr{lev=Lev,exp=UExp} = Usr] ->
			MaxLev = data_update_lev:max_lev(),
			if
				Lev < MaxLev ->
					{NLev,NExp} = check_exp(Lev,MaxLev,(UExp+Exp)),
					NUsr = Usr#usr{lev = NLev, exp = NExp},
					db:dirty_put(NUsr),
					fun_agent_property:send_update_base(Uid,[{?PROPERTY_LEV,NLev}]),
					send_resource_to_client(Uid, [{?RESOUCE_EXP_NUM,NExp}]),
					NLev > Lev andalso fun_agent:send_to_scene({update_lev,Uid,Lev}),
					NExp;
				true ->
					NewExp = min(3999999999,util:ceil(UExp+Exp)),
					NUsr = Usr#usr{exp=NewExp},
					db:dirty_put(NUsr),
					send_resource_to_client(Uid, [{?RESOUCE_EXP_NUM,NewExp}]),
					NewExp
			end;
		_ -> 0
	end.

check_exp(Lev,MaxLev,Exp) ->
	case data_update_lev:get_data(Lev) of
		#st_lev_exp{need_exp = NeedExp} -> 
			if
				NeedExp == 0 -> {Lev,Exp};
				Lev >= MaxLev -> {Lev,Exp};
				true ->
					if
						NeedExp > Exp -> {Lev,Exp};
						true -> check_exp(Lev + 1, MaxLev, Exp - NeedExp)
					end
			end;
		_ -> {Lev,Exp}
	end.

% get_usr_diamo(Uid,bind)->
% 	case db:dirty_get(resource_mian, Uid, #resource_mian.pid) of  
% 		[#resource_mian{binding_coin=Coin}|_]->Coin;
% 		_->0
% 	end;
% get_usr_diamo(Uid,free)->
% 	case db:dirty_get(resource_mian, Uid, #resource_mian.pid) of  
% 		[#resource_mian{coin=Coin}|_]->Coin;
% 		_->0
% 	end;
% get_usr_diamo(Uid,all)->
% 	case db:dirty_get(resource_mian, Uid, #resource_mian.pid) of  
% 		[#resource_mian{coin=Coin,binding_coin=Coin1}|_]->Coin+Coin1;
% 		_->0
% 	end;
% get_usr_diamo(_,_)->0.

check_coin(Uid,TotalCoin) ->
	BindingCoin=fun_item:get_item_num_by_type(Uid, ?RESOUCE_BINDING_COIN_NUM),
	if
		BindingCoin >= TotalCoin -> true;
		true ->
			Coin=fun_item:get_item_num_by_type(Uid, ?RESOUCE_COIN_NUM),
			if
				BindingCoin + Coin >= TotalCoin -> true;
				true -> false
			end
	end.