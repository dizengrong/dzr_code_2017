-module(fun_cdkey).

-include("common.hrl").
-export([check_use/1,use_cdkey/3]).
-export([handle/1]).
-export([req_fetch_recharge_return/3, req_recharge_back_info/1]).


-define(RMB_TO_COIN(RMB), RMB*15).

handle({check_recharge_back, AccountName, RechargeRMB}) ->
	?debug("verify_reback,data = ~p",[{ok,AccountName,RechargeRMB}]),
	case db:getOrKeyFindData(account, get(aid)) of  
		[#account{channel=Channel}|_]->
            case get(recharge_back) of
            	0 -> 
            		send_recharge_back_to_client(RechargeRMB);
            	1 -> 
					[#usr{name=Name}|_] = db:dirty_get(usr, get(uid)),
					fun_item_api:check_and_add_items(get(uid), get(sid), [], [{?ITEM_WAY_CHARGE_REBACK, ?RESOUCE_COIN_NUM, ?RMB_TO_COIN(RechargeRMB)}]),
		            fun_vip:add_vip_exp(get(uid), get(sid), ?RMB_TO_COIN(RechargeRMB)),
		            ?error_report(get(sid),"recharge_return_success"),
            		fun_dataCount_update:get_recharge_back(AccountName, util:to_list(Name), Channel),
            		%% 下面的告诉前端领取完了
            		send_recharge_back_to_client(0)
            end;
		_->skip
	end.

send_recharge_back_to_client(RechargeRMB) ->
	Pt = #pt_recharge_return{
		recharge_money = ?RMB_TO_COIN(RechargeRMB),  %% 该字段作为返利的vip经验用
		return_coin    = ?RMB_TO_COIN(RechargeRMB)
	},
	?send(get(sid), proto:pack(Pt)).


%% 请求获取充值返利信息
req_recharge_back_info(_Uid) ->
	erlang:put(recharge_back, 0),
	get_recharge_return_info().


%% 请求领取充值返利
req_fetch_recharge_return(_Uid, _Sid, _Seq) ->
	erlang:put(recharge_back, 1),
	get_recharge_return_info().

get_recharge_return_info() ->
	Aid = get(aid),
	case db:getOrKeyFindData(account, Aid) of  
		[#account{name=AccountName}|_]->
			% ?log("get_charge_reback = ~p",[{AccountName}]),
			fun_dataCount_update:check_recharge_back(AccountName, self());
		_->skip
	end.



use_cdkey(Uid,Aid,Key)->
	?debug("Key ~p:",[Key]),
	put(cdkey_info,Key),
	fun_dataCount_update:get_cdkey_info(Uid, Aid, db:get_all_config(serverid), Key, self()).


check_use({ok,ItemList,Key,Type})->
	Uid = get(uid),
	?debug("use_cd_key ~p:",[Key]),
	case  get(cdkey_info) of  
		Key->
			FetchedList = fun_usr_misc:get_misc_data(Uid, fetched_cdkey),
			case lists:member(Type, FetchedList) of
				true -> 
					?debug("---------cdkey error"),
					fun_dataCount_update:update_cdkey_use(Uid, get(aid), db:get_all_config(serverid), Key, self()),
					?error_report(get(sid),"be_used_cdkey");
				false ->
					FetchedList2 = [Type | FetchedList],
					fun_usr_misc:set_misc_data(Uid, fetched_cdkey, FetchedList2),
					get_cdkey_price(Uid, ItemList)
			end;
		_R-> %%?debug("key ~p:",[_R]),
			skip
	end,
	erase(cdkey_info);
check_use(_)->
	erase(cdkey_info),
	?error_report(get(sid),"nokey").

get_cdkey_price(Uid, ItemList)->
	?debug("ItemList ~p:",[ItemList]),
	#mail_content{mailName = Title, text = Content} = data_mail:data_mail(cdkey_reward),
	mod_mail_new:sys_send_personal_mail(Uid, Title, Content, ItemList, ?MAIL_TIME_LEN),
	?error_report(get(sid),"receive_successful").



