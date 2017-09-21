-module(data_buyGold_config).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]})-> #st_buyGold_config{id=${data[0]},diamondCost=${data[1]},minutes=${data[2]}};
<?py #endfor ?>
get_data(_) -> {}.

