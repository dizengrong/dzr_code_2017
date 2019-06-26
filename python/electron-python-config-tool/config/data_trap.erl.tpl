%% -*- coding: latin-1 -*-
-module(data_trap).
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
get_data(${data['trapId']}) -> #st_trap_config{id=${data['trapId']},trap_all_time=${data['trap_all_time']},trap_effect_time=${data['trap_effect_time']},impactArea="${data['impactArea']}",areaPara=${split_items(data['areaPara'])},targetnum=${data['targetnum']},max_effect=${data['max_effect']},one_max_effect=${data['one_max_effect']},per_time=${data['per_time']}}; 
<?py #endfor ?>
get_data(_) -> {}.
