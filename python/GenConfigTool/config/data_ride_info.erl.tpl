-module(data_ride_info).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py	item_str2 = item_str.split("|") ?>
<?py	ret = "[" ?>
<?py	for index in range(len(item_str2)): ?>
<?py		data2 = item_str2[index].split(":") ?>
<?py		ret = ret + "{" + data2[0] + ", " + data2[1] +  "}, " ?>
<?py #endfor ?>
<?py	return ret[:-2] + "]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_ride_info{type=${data[0]},lev=${data[2]},next_type=${data[6]},explain=${data[4]},food=${data[7]},exp_add=${data[8]},double=${data[10]},four=${data[11]},speed_buff=${data[5]},props=${split_items(data[27])},gs=${data[14]}};
<?py #endfor ?>
get_data(_) -> {}.

