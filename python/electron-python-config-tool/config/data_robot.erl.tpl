%% -*- coding: latin-1 -*-
-module(data_robot).
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
get_data(${data['ID']}) -> #st_robot{id=${data['ID']},name="${data['name']}",level=${data['level']},headid=${data['headid']},entourageList=${split_items(data['entourageId'])},artifact={${data['artifact']}}};
<?py #endfor ?>
get_data(_) -> {}.

<?py all_ids = [d['ID'] for d in all_data] ?>
get_all() -> ${all_ids}.