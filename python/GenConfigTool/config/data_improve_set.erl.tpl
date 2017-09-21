-module(data_improve_set).
-include("common.hrl").
-compile(export_all).

<?py all_break_lv = [] ?>
<?py for data in all_data: ?>
get_improve_set(${data[1]}) -> #improve_set{item_improve_lev=${data[1]},multy=${data[2]},add_attr=${data[3]},need_item_id=${data[4]},need_item_num=${data[5]},breakItemNum=${data[6]},breakItemId=${data[7]}};
<?py 	if data[6] > 0: ?>
<?py 		all_break_lv.append(data[1]) ?>
<?py #endif ?>
<?py #endfor ?>
get_improve_set(_) -> {}.

get_break_lev() -> ${all_break_lv}.
