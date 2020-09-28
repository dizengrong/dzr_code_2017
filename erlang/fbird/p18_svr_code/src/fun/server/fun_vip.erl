%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% author : wangming
%% date :  2016-4-11
%% Company : fbird.Co.Ltd
%% Desc : fun_vip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-module(fun_vip).
-include("common.hrl").
-export([add_vip_exp/3,req_vip_rewards/4,req_vip_info/3,get_vip_lev/1,get_privilege_added/2]).
-export([req_fetch_daily_reward/3,refresh_daily_reward/1]).
% -export([get_prop/1,get_fighting/1]).

%%vip升级
add_vip_exp(Uid, Sid, VipExp)->
	case db:dirty_get(usr, Uid) of
		[Usr|_] -> 
			VipLev = Usr#usr.vip_lev,
			{NVipLev,NVipExp} = check_vip_exp(Uid,VipLev,Usr#usr.vip_exp + VipExp),
			DoBattle = if
				NVipLev == VipLev -> normal;
				NVipLev > Usr#usr.vip_lev -> up;
				true -> false
			end,
			case DoBattle of
				up -> 
					NUsr = Usr#usr{vip_lev = NVipLev,vip_exp = NVipExp},
					db:dirty_put(NUsr),
					fun_agent:send_to_scene({update_vip_lev,Uid,NVipLev,NVipExp}),
					req_vip_info(Uid, Sid, 0),
					fun_agent_property:send_update_base(Uid,[{?PROPERTY_VIP_LEV,NVipLev}]);
				_ -> 
					NUsr = Usr#usr{vip_exp=NVipExp},
					db:dirty_put(NUsr)
			end,
			NVipExp;
		_ -> 0
	end.

check_vip_exp(Uid,Lev,Exp) -> 
	case data_vip_config:get_data(Lev) of
		#st_vip_config{vip_exp = MaxExp} -> 
			MaxLev =  data_vip_config:get_max(), 
			if
				Lev < MaxLev ->
					if
						MaxExp > Exp -> {Lev, Exp};
						true -> check_vip_exp(Uid, Lev + 1, Exp)
					end;
				true -> {MaxLev, Exp}
			end;
		_ -> {Lev, Exp}
	end.

%%vip奖励领取
req_vip_rewards(Uid,Sid,RewardId,Seq)->
	List = fun_usr_misc:get_data_ex(Uid, vip_rewards, []),
	VipLev = get_vip_lev(Uid),
	case lists:member(RewardId) == true orelse RewardId > VipLev of
		true -> skip;
		_ ->
			#st_vip_config{vip_reward = AddItems} = data_vip_config:get_data(RewardId),
			Succ = fun() ->
				fun_usr_misc:set_data_ex(Uid, vip_rewards, [RewardId | List]),
				fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, AddItems),
				req_vip_info(Uid, Sid, Seq)
			end,
			Args = #api_item_args{
				way      = ?ITEM_WAY_VIP_REWARDS,
				add      = AddItems,
				succ_fun = Succ
			},
			fun_item_api:add_items(Uid, Sid, Seq, Args)
	end.


%%请求vip详细数据
req_vip_info(Uid, Sid, Seq)->
	VipLev = get_vip_lev(Uid),
	AllList = data_vip_config:get_all(),
	FetchList = fun_usr_misc:get_data_ex(Uid, vip_rewards, []),
	Fun = fun(Reward)->
		Status = case lists:member(Reward, FetchList) of
			true -> ?REWARD_STATE_FETCHED;
			_ ->
				if
					VipLev == 0 -> ?REWARD_STATE_NOT_REACHED;
					VipLev >= Reward -> ?REWARD_STATE_CAN_FETCH;
					true -> ?REWARD_STATE_NOT_REACHED
				end
		end,
		#pt_public_vip_rewards_list{id = Reward, status = Status}
	end,
	Pt = #pt_vip_info{
		daily_status = check_state(Uid, VipLev),
		list         = lists:map(Fun, AllList)
	},
	?send(Sid,proto:pack(Pt,Seq)).

get_vip_lev(Uid)->
	case db:dirty_get(usr, Uid)  of  
		[#usr{vip_lev=Vip}|_]->Vip;
		_->0
	end.

%% 获取vip特权加成
get_privilege_added(Type, Uid)->
	VipLev = get_vip_lev(Uid),
	Conf = data_vip_config:get_data(VipLev),
	case Type of
		hero_bags  -> Conf#st_vip_config.hero_bags;
		_ -> 0
	end.

req_fetch_daily_reward(Uid, Sid, Seq) ->
	VipLev = get_vip_lev(Uid),
	case data_vip_config:get_data(VipLev) of
		#st_vip_config{daily_reward = Rewards} ->
			case check_state(Uid, VipLev) of
				?REWARD_STATE_CAN_FETCH ->
					AddItems = [{?ITEM_WAY_VIP_DAILY_REWARDS, T, N}|| {T, N} <- Rewards],
					Succ = fun() ->
						fun_usr_misc:set_misc_data(Uid, vip_daily_reward, VipLev),
						fun_item_api:send_show_fetched_reward(Uid, Sid, ?SHOW_REWARD_COMMON, Rewards),
						req_vip_info(Uid, Sid, Seq)
					end,
					fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
				_ -> skip
			end;
		_ -> skip
	end.

check_state(Uid, VipLev) ->
	case fun_usr_misc:get_misc_data(Uid, vip_daily_reward) of
		VipLev when VipLev == 0 -> ?REWARD_STATE_NOT_REACHED;
		VipLev -> ?REWARD_STATE_FETCHED;
		_ -> ?REWARD_STATE_CAN_FETCH
	end.

refresh_daily_reward(Uid) -> fun_usr_misc:set_misc_data(Uid, vip_daily_reward, 0).

% get_prop(Uid) ->
% 	VipLev = get_vip_lev(Uid),
% 	case data_vip_config:get_data(VipLev) of
% 		#st_vip_config{prop = Prop} -> Prop;
% 		_ -> []
% 	end.

% get_fighting(Uid) ->
% 	VipLev = get_vip_lev(Uid),
% 	case data_vip_config:get_data(VipLev) of
% 		#st_vip_config{gs = Gs} -> Gs;
% 		_ -> 0
% 	end.