-module(data_achievelLevel).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py max_lv = 0 ?>
<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_achieveLevel{level=${data[0]},achievePoint=${data[1]},achieveProp=${split_items(data[3])},achieveGs=${data[5]}};
<?py max_lv = max(max_lv, data[0]) ?>
<?py #endfor ?>
get_data(_) -> {}.


get_max_()-> ${max_lv}.

