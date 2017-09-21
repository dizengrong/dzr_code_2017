-module(data_droplistconfig).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]})-> #st_droplist_config{droplistid=${data[0]},dropcontentid=${data[1]},droptimes=${data[2]},droptype=${data[3]},restrictionType=${data[4]}};
<?py #endfor ?>
get_data(_) -> {}.
