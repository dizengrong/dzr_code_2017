<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = {
		name = ${data['name']},
		suit = {${data['suit']}},
<?py 	data['attribute'] = data['attribute'].replace('[', '{') ?>
<?py 	data['attribute'] = data['attribute'].replace(']', '}') ?>
		attribute = ${split_items(data['attribute'])},		
	},
<?py #endfor ?>
}
return data_item
		