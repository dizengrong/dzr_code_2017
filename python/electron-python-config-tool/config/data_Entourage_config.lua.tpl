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
		name= "${data['name']}",
		sex= ${data['sex']},
		type= ${data['type']},
		profession= ${data['occupation']},
		intro ="${data['intro']}",
		skin = ${data['skin']},
		bone_name ="${data['bone_name']}",
		res_name ="${data['res_name']}",
		initial_attribute= ${split_items(data['initial_attribute'])},
		pace_speed= ${data['pace_speed']},
		base_move_spd= ${data['base_move_spd']},
		preview_scale= ${data['preview_scale']},
		preview_postion = {${data['preview_postion']}},
		preview_rotation = {${data['preview_rotation']}},
		name_heigiht= ${data['name_heigiht']},
		model_scale= ${data['model_scale']},
		deathLag_time= ${data['deathLag_time']},
		attack_range= ${data['attack_range']},
		quility= ${data['quility']},
		max_star= ${data['max_star']},
		max_grade= ${data['max_grade']},
	},
<?py #endfor ?>
}
return data_item	