%% -*- coding: latin-1 -*-
-module(data_buy_time_price).
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
get_data(${data['sort']},${data['count']}) -> #st_buy_time_price{id=${data['id']},sort=${data['sort']},cost=${split_items(data['cost'])},count=${data['count']}};
<?py #endfor ?>
get_data(_,_) -> {}.

<?py max_dict = {} ?>
<?py for data in all_data: ?>
<?py 	if data['sort'] in max_dict: ?>
<?py 		max_dict[data['sort']] = max(data['count'], max_dict[data['sort']]) ?>
<?py 	else: ?>
<?py 		max_dict[data['sort']] = data['count'] ?>
<?py 	#endif ?>
<?py #endfor ?>

<?py for key in max_dict.keys(): ?>
get_max_times(${key}) -> ${max_dict[key]};
<?py #endfor ?>
get_max_times(_) -> 0.