-module(data_guildBossAward).
-include("common.hrl").
-compile(export_all).

%% get_data(伤害百分比) -> #st_guildBossAward{id=伤害百分比,awardId=物品id,awardValue=物品数量};
<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_guildBossAward{id=${data[0]},awardId=${data[1]},awardValue=${data[2]}};
<?py #endfor ?>
get_data(_) -> {}.

