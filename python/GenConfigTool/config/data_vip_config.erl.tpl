-module(data_vip_config).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py max_vip = 0 ?>
<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_vip_config{vip_level=${data[0]},vip_exp=${data[1]},vip_reward=${split_items(data[3])},quickCombatNum=${data[4]},createequipment=${data[5]},dungeons=${data[6]},arenaNoCD=${data[7]},herostore=${data[8]},friendshipstore=${data[9]},hangyield=${data[10]},buygoldtimes=${data[11]}};
<?py max_vip = max(max_vip, data[0]) ?>
<?py #endfor ?>
get_data(_) -> {}.

get_max_() -> ${max_vip}.

