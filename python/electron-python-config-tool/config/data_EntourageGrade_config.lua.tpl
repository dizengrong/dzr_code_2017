<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['grade']}] = 
	{
		lv = ${data['lv']},
		consume = ${split_items(data['consume'])},
		attribute = ${split_items(data['attribute'])},
		explain = "${data['explain']}",
	},
<?py #endfor ?>
}
return data_item