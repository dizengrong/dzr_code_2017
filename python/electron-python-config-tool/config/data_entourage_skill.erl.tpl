%% -*- coding: latin-1 -*-
-module(data_entourage_skill).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py pre_id = 0 ?>
<?py for data in all_data: ?>
<?py 	if pre_id != data['entourage_id']:?>
<?py 		additon_str = '\n' ?>
<?py 	else: ?>
<?py 		additon_str = '' ?>
<?py 	#endif ?>
<?py 	pre_id = data['entourage_id'] ?>
${additon_str}get_data(${data['entourage_id']}, Break, Star) when Break >= ${data['grade']} andalso Star >= ${data['star']} -> #st_entourage_skill{id = ${data['id']}, skill = ${split_items(data['skill_group'])}, prop = ${split_items(data['attribute'])}};
<?py #endfor ?>
get_data(_, _, _) -> {}.