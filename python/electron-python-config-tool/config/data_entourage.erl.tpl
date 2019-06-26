%% -*- coding: latin-1 -*-
-module(data_entourage).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data['id']}) -> #st_entourage_config{
	name         = "${data['name']}",
	sex          = ${data['sex']},
	race         = ${data['type']},
	profession   = ${data['occupation']},
	basePropList = ${split_items(data['initial_attribute'])},
	baseMoveSpd  = ${data['base_move_spd']},
	deatlagtime  = ${data['deathLag_time']},
	attackRange  = ${data['attack_range']},
	quility      = ${data['quility']},
	max_grade    = ${data['max_grade']},
	max_star     = ${data['max_star']}
};
<?py #endfor ?>
get_data(_) -> {}.

<?py all_ids = [d['id'] for d in all_data] ?>
get_all() -> ${all_ids}.

%% 出战孔位开放等级
<?py for data in on_battle_data: ?>
get_pos_open_lv(${data['position']}) -> ${data['lv']};
<?py #endfor ?>
get_pos_open_lv(_) -> 1000000000.

