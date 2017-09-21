-module(data_achieveType).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_achieveType{id=${data[0]},totalNum=${data[2]}};
<?py #endfor ?>
get_data(_) -> {}.

