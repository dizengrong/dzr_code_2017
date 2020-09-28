%% @doc 玩家的杂项数据处理，主要处理一些只有一两字段的但是又不想加新表的情况
%% 这里的t_usr_misc通过加字段的方法来横向扩展
%% todo:还可以增加对某些字段的每天重置功能或者是字段的格式转化
-module (fun_usr_misc).
-include("common.hrl").
-export([get_misc_data/2, set_misc_data/3, set_misc_data/1]).
-export([get_data_ex/3, set_data_ex/3]).

init_misc(Uid) ->
	#t_usr_misc{
		uid        = Uid
	}.

get_misc_data(Uid) ->
	case mod_role_tab:lookup(Uid, t_usr_misc) of
		[] -> init_misc(Uid);
		[Rec] -> Rec
	end.

set_misc_data(Rec) ->
	mod_role_tab:insert(Rec#t_usr_misc.uid, Rec).

%% ============================== get 方法 ==============================
get_misc_data(Uid, task_step_n) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.task_step_n;
get_misc_data(Uid, task_step_h) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.task_step_h;
get_misc_data(Uid, fast_artifact) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.fast_artifact;
get_misc_data(Uid, last_called_hero) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.last_called_hero;
get_misc_data(Uid, fast_time) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.fast_time;
get_misc_data(Uid, relife_time) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.relife_time;
get_misc_data(Uid, task_step) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.task_step;
get_misc_data(Uid, meeting_times) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.meeting_times;
get_misc_data(Uid, buy_farm_times) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.buy_farm_times;
get_misc_data(Uid, story_step) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.story_step;
get_misc_data(Uid, medicine) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.medicine;
get_misc_data(Uid, story_reward) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.story_reward;
get_misc_data(Uid, fetched_cdkey) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.fetched_cdkey;
get_misc_data(Uid, relife_task) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.relife_task;
get_misc_data(Uid, sign) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.sign;
get_misc_data(Uid, time_reward) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.time_reward;
get_misc_data(Uid, grow_fund) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.grow_fund;
get_misc_data(Uid, first_recharge) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.first_recharge;
get_misc_data(Uid, revive) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.revive;
get_misc_data(Uid, world_level_reward) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.world_level_reward;
get_misc_data(Uid, guild_blessing) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.guild_blessing;
get_misc_data(Uid, vip_daily_reward) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.vip_daily_reward;
get_misc_data(Uid, random_task) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.random_task;
get_misc_data(Uid, compensation_award) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.compensation_award;
get_misc_data(Uid, guard_entourage) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.guard_entourage;
get_misc_data(Uid, barrier_reward1) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.barrier_reward1;
get_misc_data(Uid, barrier_reward2) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.barrier_reward2;
get_misc_data(Uid, praise_reward) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.praise_reward;
get_misc_data(Uid, gift_package) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.gift_package;
get_misc_data(Uid, hero_illustration) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.hero_illustration;
get_misc_data(Uid, pass_copy) ->
	Rec = get_misc_data(Uid),
	Rec#t_usr_misc.pass_copy.
%% ============================== get 方法 ==============================



%% ============================== set 方法 ==============================
set_misc_data(Uid, task_step_n, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{task_step_n = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, task_step_h, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{task_step_h = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, fast_artifact, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{fast_artifact = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, last_called_hero, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{last_called_hero = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, relife_time, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{relife_time = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, meeting_times, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{meeting_times = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, buy_farm_times, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{buy_farm_times = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, task_step, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{task_step = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, story_step, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{story_step = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, fast_time, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{fast_time = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, story_reward, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{story_reward = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, fetched_cdkey, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{fetched_cdkey = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, medicine, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{medicine = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, relife_task, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{relife_task = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, sign, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{sign = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, time_reward, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{time_reward = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, grow_fund, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{grow_fund = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, first_recharge, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{first_recharge = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, revive, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{revive = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, world_level_reward, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{world_level_reward = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, guild_blessing, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{guild_blessing = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, vip_daily_reward, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{vip_daily_reward = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, random_task, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{random_task = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, compensation_award, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{compensation_award = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, guard_entourage, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{guard_entourage = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, barrier_reward1, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{barrier_reward1 = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, barrier_reward2, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{barrier_reward2 = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, praise_reward, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{praise_reward = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, gift_package, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{gift_package = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, hero_illustration, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{hero_illustration = Val},
	set_misc_data(Rec2);
set_misc_data(Uid, pass_copy, Val) ->
	Rec = get_misc_data(Uid),
	Rec2 = Rec#t_usr_misc{pass_copy = Val},
	set_misc_data(Rec2).
%% ============================== set 方法 ==============================


%% =============================================================================
%% =============================================================================
%% 使用maps来保存各种数据的扩展接口
get_data_ex(Uid, Key, Default) ->
	Rec = get_misc_data(Uid),
	maps:get(Key, Rec#t_usr_misc.datas, Default).

set_data_ex(Uid, Key, Val) ->
	Rec = get_misc_data(Uid),
	Maps = Rec#t_usr_misc.datas,
	Maps2 = Maps#{Key => Val},
	Rec2 = Rec#t_usr_misc{datas = Maps2},
	set_misc_data(Rec2).

