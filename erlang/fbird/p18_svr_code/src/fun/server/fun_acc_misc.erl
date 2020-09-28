%% @doc 玩家账号的杂项数据处理，主要处理一些只有一两字段的但是又不想加新表的情况
%% 这里的acc_misc通过加字段的方法来横向扩展
%% todo:还可以增加对某些字段的每天重置功能或者是字段的格式转化
-module (fun_acc_misc).
-include("common.hrl").
-export([get_misc_data/2, set_misc_data/3]).

init_misc(Aid) ->
	#acc_misc{
		aid = Aid,
		download_reward = 0
	}.

get_misc_data(Aid) ->
	case db:dirty_get(acc_misc, Aid, #acc_misc.aid) of
		[] -> init_misc(Aid);
		[Rec] -> Rec
	end.
set_misc_data(Rec) ->
	case Rec#acc_misc.id of
		0 -> db:insert(Rec);
		_ -> db:dirty_put(Rec)
	end.

%% ============================== get 方法 ==============================
get_misc_data(Aid, download_reward) ->
	Rec = get_misc_data(Aid),
	Rec#acc_misc.download_reward.
%% ============================== get 方法 ==============================

%% ============================== set 方法 ==============================
set_misc_data(Aid, download_reward, Val) ->
	Rec = get_misc_data(Aid),
	Rec2 = Rec#acc_misc{download_reward = Val},
	set_misc_data(Rec2).
%% ============================== set 方法 ==============================