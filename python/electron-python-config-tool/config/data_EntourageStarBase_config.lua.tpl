<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['star']}] = 
	{
		min_lv = ${data['min_lv']},
		max_lv = ${data['max_lv']},
		attribute = ${split_items(data['attribute'])},
		explain = "${data['explain']}",
		icon_eff = ${data['icon_eff']},
	},
<?py #endfor ?>
}

local max_star_lv = ${all_data[len(all_data) - 1]['star']}

return {data_item, max_star_lv}