<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['lv']}] = 
	{		
		need_start = ${data['need_star']},
		god_power = ${data['god_power']},
		attribute_power1 = ${data['attribute_power1']},
		attribute_power2 = ${data['attribute_power2']},
		attribute_power3 = ${data['attribute_power3']},
		attribute_power4 = ${data['attribute_power4']},
		need_items = ${split_items(data['need_item'])},
	},
<?py #endfor ?>
}
return data_item		