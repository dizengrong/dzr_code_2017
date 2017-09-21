-module(data_filiationLevel).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}, ${data[1]}) -> #st_filiationLevel{filiationId=${data[0]},level=${data[1]},propType=${data[2]},propVal=${data[3]},requireTargetLevel=${data[4]},requireTargetStarNum=${data[5]},upgradeItemType=${data[6]},itemNum=${data[7]},gs=${data[8]}};
<?py #endfor ?>
get_data(_, _) -> {}.

