%% -*- coding: latin-1 -*-
-module(data_entourage_ex).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

%% =============================== 等级相关配置 ================================
<?py for data in all_lv_data: ?>
get_lv_up_cost(${data['lv']}) -> ${split_items(data['consume'])};
<?py #endfor ?>
get_lv_up_cost(_) -> [].

%% get_lv_attr(等级, 职业) -> 属性列表
<?py for data in all_lv_data: ?>
get_lv_attr(${data['lv']}, 1) -> ${split_items(data['occupation1'])};
get_lv_attr(${data['lv']}, 2) -> ${split_items(data['occupation2'])};
get_lv_attr(${data['lv']}, 3) -> ${split_items(data['occupation3'])};
get_lv_attr(${data['lv']}, 4) -> ${split_items(data['occupation4'])};
<?py #endfor ?>
get_lv_attr(_, _) -> [].


%% =============================== 突破相关配置 ================================
<?py for data in all_grade_data: ?>
get_lv_grade_cost(${data['grade']}) -> ${split_items(data['consume'])};
<?py #endfor ?>
get_lv_grade_cost(_) -> [].

<?py for data in all_grade_data: ?>
get_grade_attr(${data['grade']}) -> ${split_items(data['attribute'])};
<?py #endfor ?>
get_grade_attr(_) -> [].

<?py for data in all_grade_data: ?>
get_grade_lv_limit(${data['grade']}) -> ${data['lv']};
<?py #endfor ?>
get_grade_lv_limit(_) -> 0.


%% =============================== 星级相关配置 ================================
<?py for data in all_star_data: ?>
get_star_attr(${data['star']}) -> ${split_items(data['attribute'])};
<?py #endfor ?>
get_star_attr(_) -> [].

<?py for data in all_star_data: ?>
get_star_lv_limit(${data['star']}) -> ${data['max_lv']};
<?py #endfor ?>
get_star_lv_limit(_) -> 0.

<?py for data in all_star_data: ?>
get_star_up_min_lv(${data['star']}) -> ${data['min_lv']};
<?py #endfor ?>
get_star_up_min_lv(_) -> undefined. %% 这里表示无法升星

%% get_star_up_cost(英雄id, 当前星级) -> {[{英雄id,星级,数量}], [{种族,星级,数量}], 其他固定消耗材料}
<?py for data in all_compose_data: ?>
get_star_up_cost(${data['hero_id']}, ${data['star']}) -> {${split_items(data['up1'])}, ${split_items(data['up2'])}, ${split_items(data['up3'])}};
<?py #endfor ?>
get_star_up_cost(_, _) -> {[], [], []}.

