%% -*- coding: latin-1 -*-
%% @doc gm运营活动测试
-module (test_gm_act).
-compile(export_all).
-include("common.hrl").

start_gm_act(_, _) ->skip.


close_gm_act(ActType) ->
	fun_gm_activity_ex:del_config(ActType, ActType).
