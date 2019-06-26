%% -*- coding: latin-1 -*-
-module(data_item).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py def array_2_str(array_datas, n, sep_str1, sep_str2):?>
<?py ret = "" ?>
<?py count = 1 ?>
<?py end_data = array_datas[-1] ?>
<?py for data in array_datas: ?>
<?py 	if end_data == data:?>
<?py 		ret += data ?>
<?py 	elif count < n:?>
<?py 		ret += data + sep_str1 ?>
<?py 		count += 1 ?>
<?py 	else:?>
<?py 		ret += data + sep_str2 ?>
<?py 		count = 1 ?>
<?py 	#endif ?>
<?py #endfor ?>
<?py return ret ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data['ID']}) -> #st_item_type{id=${data['ID']},sort=${data['sort']},max=${data['max']},name="${data['name']}",req_lev=${data['req_lv']},prop=${split_items(data['Attribute'])},spe_prop=${split_items(data['SpecialAttribute'])},bind=${data['bind']},business=${data['business']},color=${data['quality']},price=${data['price']},action=${data['action']},action_arg=${data['action_arg']},action_arg1=${data['action_arg2']},default_star=${data['star']}};
<?py #endfor ?>
get_data(_) -> {}.

get_all() -> [${"\n\t" + array_2_str([str(d['ID']) for d in all_data], 20, ", ", ",\n\t")}].