<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['itemId']}] = 
	{
		type = ${data['type']},
		starMax = ${data['star_max']},
		godPower = ${split_items(data['god_power'])},
		attributePower1 = ${split_items(data['attribute_power1'])},
		attributePower2 = ${split_items(data['attribute_power2'])},
		attributePower3 = ${split_items(data['attribute_power3'])},
		attributePower4 = ${split_items(data['attribute_power4'])},
		model = "${data['model']}",
	},
<?py #endfor ?>
}
return data_item		