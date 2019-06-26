<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		godWeaponId = ${data['godWeaponId']},
		starLv = ${data['starLv']},
		need_level = ${data['need_level']},
		show_skill = ${split_items(data['show_skill'])},
		need_items = ${split_items(data['need_item'])},
		god_weapon_need = ${split_items(data['god_weapon_need'])},
	},
<?py #endfor ?>
}
return data_item