-module(data_box_config).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]})-> #st_box_config{boxid=${data[0]},next=${data[1]},droplistid=${data[2]},droprate=${data[3]},dropBelong="${data[4]}"};
<?py #endfor ?>
get_data(_) -> {}.
