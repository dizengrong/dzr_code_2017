-module(data_onlineReward_config).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_onlineReward_config{id=${data[0]},time=${data[1]},boxId=${data[2]}};
<?py #endfor ?>
get_data(_) -> {}.
