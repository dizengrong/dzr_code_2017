-module(data_ride_equ_info).
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
get_data(${data[0]}) -> #st_ride_equ_info{type=${data[0]},pos=${data[3]},quality=${data[4]},next_type=${data[5]},item=${data[6]},num=${data[7]},props=${split_items(data[17])},gs=${data[18]}};
<?py #endfor ?>
get_data(_) -> {}.

