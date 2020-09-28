%% @doc 游戏时长给奖励，下线也算时间
-module(fun_offline_reward).
-include("common.hrl").
-export([init_data/1]).
-export([req_offline_reward/3, req_offline_info/3]).

%% ===================== 数据操作 =====================
init_data(Uid) ->
	Rec = #t_offline_reward{
		uid      = Uid,
		step     = 1,
		end_time = agent:agent_now() + get_time(1)
	},
	set_data(Rec).

get_data(Uid) -> 
	case mod_role_tab:lookup(Uid, t_offline_reward) of
		[] -> [];
		[Rec] -> Rec
	end.

set_data(Rec) -> 
	mod_role_tab:insert(Rec#t_offline_reward.uid, Rec).

del_data(Rec) ->
	mod_role_tab:delete(Rec#t_offline_reward.uid, Rec).

%% ===================== 数据操作 =====================
req_offline_reward(Uid, Sid, Seq) ->
	case get_data(Uid) of
		[] -> skip;
		Rec ->
			Now = agent:agent_now(),
			case Now >= Rec#t_offline_reward.end_time of
				true ->
					Succ = fun() ->
						NewStep = Rec#t_offline_reward.step + 1,
						case data_offline_reward:get_data(NewStep) of
							{Time, _} ->
								NewRec = Rec#t_offline_reward{step = NewStep, end_time = Now + Time},
								set_data(NewRec),
								send_info_to_client(Uid, Sid, Seq);
							_ ->
								del_data(Rec),
								Pt = #pt_offline_reward{},
								?send(Sid, proto:pack(Pt, Seq))
						end
					end,
					Args = #api_item_args{
						way      = ?ITEM_WAY_OFFLINE_REWARD,
						add      = get_reward(Rec#t_offline_reward.step),
						succ_fun = Succ
					},
					fun_item_api:add_items(Uid, Sid, Seq, Args);
				_ -> ?error_report(Sid, "end_of_countdown", Seq)
			end
	end.

req_offline_info(Uid, Sid, Seq) ->
	send_info_to_client(Uid, Sid, Seq).

send_info_to_client(Uid, Sid, Seq) ->
	case get_data(Uid) of
		[] -> skip;
		Rec ->
			Pt = #pt_offline_reward{
				end_time = Rec#t_offline_reward.end_time,
				rewards  = fun_item_api:make_item_pt_list(get_reward(Rec#t_offline_reward.step))
			},
			?send(Sid, proto:pack(Pt, Seq))
	end.

get_time(Id) ->
	{Time, _} = data_offline_reward:get_data(Id),
	Time.

get_reward(Id) ->
	{_, Reward} = data_offline_reward:get_data(Id),
	Reward.