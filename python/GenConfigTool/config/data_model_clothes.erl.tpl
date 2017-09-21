-module(data_model_clothes).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_model_clothes{id=${data[0]},dressitem=${data[1]},active_num=${data[7]},attribute=${split_items(data[2])},power=${data[3]}};
<?py #endfor ?>
get_data(_) -> {}.
