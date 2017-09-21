-module(data_entourage_update).
-include("common.hrl").
-compile(export_all).

<?py max_lv = 0 ?>
<?py for data in all_data: ?>
<?py 	if data[1] != '': ?>
get_data(${data[0]})->#st_entourage_update{level=${data[0]},exp=${data[1]}};
<?py 		max_lv = max(max_lv, data[0]) ?>
<?py #endif ?>
<?py #endfor ?>
get_data(_) -> {}.

get_max_() -> ${max_lv}.
