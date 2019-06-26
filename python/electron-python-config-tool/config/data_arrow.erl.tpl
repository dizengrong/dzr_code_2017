%% -*- coding: latin-1 -*-
-module(data_arrow).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[" + ", ".join(item_str.split("|")) + "]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data['arrowId']}) -> #st_arrow_config{id=${data['arrowId']},speed=${data['speed']},add_speed=${data['add_speed']},impactArea="${data['impactArea']}",areaPara=${split_items(data['areaPara'])},targetnum=${data['targetnum']},max_effect=${data['max_effect']},one_max_effect=${data['one_max_effect']},per_time=${data['per_time']},max_dis=${data['max_dis']},min_dis=${data['min_dis']},arrowWidth=${data['arrowWidth']},arrowUpHigh=${data['arrowUpHigh']},arrowDownHigh=${data['arrowDownHigh']}}; 
<?py #endfor ?>
get_data(_) -> {}.
