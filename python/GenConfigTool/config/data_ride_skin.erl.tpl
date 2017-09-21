-module(data_ride_skin).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_ride_skin_info{type=${data[0]},props=${split_items(data[10])},gs=${data[11]},hechengID=${data[12]},hechengNUM=${data[13]}};
<?py #endfor ?>
get_data(_) -> {}.

