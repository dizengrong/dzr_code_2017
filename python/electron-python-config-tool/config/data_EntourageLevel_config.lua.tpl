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
		consume = ${split_items(data['consume'])},
		occupation1 = ${split_items(data['occupation1'])},
		occupation2 = ${split_items(data['occupation2'])},
		occupation3 = ${split_items(data['occupation3'])},
		occupation4 = ${split_items(data['occupation4'])},
	},
<?py #endfor ?>
}
return data_item