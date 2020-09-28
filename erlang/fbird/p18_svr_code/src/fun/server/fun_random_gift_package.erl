-module(fun_random_gift_package).
-include("common.hrl").
-export([check_random/2,package_end/1,on_login/1,do_recharge/3]).
-export([req_package_info/3,req_package_reward/3]).

-define(CANNOT ,  0).
-define(CAN_BUY , 1).

get_data(Uid) -> fun_usr_misc:get_misc_data(Uid, gift_package).

set_data(Uid, Val) -> fun_usr_misc:set_misc_data(Uid, gift_package, Val).

on_login(Uid) ->
	case get_data(Uid) of
		{?CAN_BUY, Id, EndTime, _} ->
			case EndTime >= util_time:unixtime() of
				true -> erlang:start_timer((EndTime - util_time:unixtime()) * 1000, self(), {?MODULE, package_end, {Uid, Id}});
				_ -> set_data(Uid, {?CANNOT, Id, 0, 0})
			end;
		_ -> skip
	end.

req_package_info(Uid, Sid, Seq) ->
	case get_data(Uid) of
		{?CAN_BUY, _, EndTime, _} ->
			case EndTime >= util_time:unixtime() of
				true -> send_info_to_client(Uid, Sid, Seq);
				_ -> skip
			end;
		_ -> skip
	end.

req_package_reward(Uid, Sid, Seq) ->
	?debug("Data = ~p",[get_data(Uid)]),
	case get_data(Uid) of
		{?CAN_BUY, Id, EndTime, Num} ->
			?debug("Id = ~p",[Id]),
			case data_random_package:get_data(Id) of
				#st_random_package{dioamnd = NeedNum, vip = NeedVip, reward = Rewards} ->
					case EndTime >= util_time:unixtime() andalso Num >= NeedNum andalso fun_vip:get_vip_lev(Uid) >= NeedVip of
						true ->
							AddItems = [{?ITEM_WAY_RANDOM_PACKAGE, T, N} || {T, N} <- Rewards],
							Succ = fun() ->
								?error_report(Sid, "worldlevel03", Seq),
								set_data(Uid, {?CANNOT, Id, 0, 0}),
								send_info_to_client(Uid, Sid, Seq)
							end,
							fun_item_api:check_and_add_items(Uid, Sid, [], AddItems, Succ, undefined);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

do_recharge(Uid,Sid,N) ->
	case get_data(Uid) of
		{?CAN_BUY, Id, EndTime, Num} ->
			case EndTime >= util_time:unixtime() of
				true ->
					#st_random_package{dioamnd = Diamond} = data_random_package:get_data(Id),
					NewNum = case Num + N >= Diamond of
						true -> Diamond;
						_ -> Num + N
					end,
					set_data(Uid, {?CAN_BUY, Id, EndTime, NewNum}),
					send_info_to_client(Uid, Sid, 0);
				_ -> skip
			end;
		_ -> skip
	end.

check_random(Uid, Sid) ->
	case get_data(Uid) of
		{?CANNOT, Id, _, _} ->
			case data_random_package:get_data(Id + 1) of
				#st_random_package{scene_lev = SceneLev} ->
					case mod_scene_lev:get_curr_scene_lv(Uid) >= SceneLev of
						true -> check_random_help(Uid, Sid);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

check_random_help(Uid, Sid) ->
	Rate = case get(random_package_probability) of
		undefined ->
			put(random_package_probability,util:get_data_para_num(1218)),
			util:get_data_para_num(1218);
		Rate1 -> Rate1
	end,
	Rand = util:rand(0, 99),
	case Rand >= Rate of
		false ->
			put(random_package_probability,util:get_data_para_num(1218)),
			do_random_package_help(Uid, Sid);
		_ -> 
			put(random_package_probability,Rate + util:get_data_para_num(1219))
	end.

do_random_package_help(Uid, Sid) ->
	Now = util_time:unixtime(),
	{_, Id, _, _} = get_data(Uid),
	#st_random_package{time = Time} = data_random_package:get_data(Id + 1),
	set_data(Uid, {?CAN_BUY, Id + 1, Now + Time * 3600, 0}),
	erlang:start_timer(Time * 3600000, self(), {?MODULE, package_end, {Uid, Id + 1}}),
	send_info_to_client(Uid, Sid, 0).

package_end({Uid, Id}) ->
	case get_data(Uid) of
		{?CAN_BUY, Id, _, _} -> set_data(Uid, {?CANNOT, Id, 0, 0});
		_ -> skip
	end.

send_info_to_client(Uid, Sid, Seq) ->
	{HasGift, Id, EndTime, Num} = get_data(Uid),
	Pt = #pt_random_gift_package{
		has_package = HasGift,
		id 		 	= Id,
		num 	 	= Num,
		end_time 	= EndTime
	},
	?send(Sid, proto:pack(Pt, Seq)).