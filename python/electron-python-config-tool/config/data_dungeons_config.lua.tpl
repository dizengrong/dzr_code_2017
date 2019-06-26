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
		dungenName = "${data['dungenName']}",
		dungenDes = "${data['dungenDes']}",
		dungenScene = ${data['dungenScene']},
		dugnengroup = ${data['dugnengroup']},
		autoBoss = ${data['autoBoss']},
		rankRestriction = ${data['rankRestriction']},
		forceLimitation = ${data['forceLimitation']},
		stageAward = ${split_items(data['stageAward'])},
		timeAward = ${split_items(data['timeAward'])},
	},
<?py #endfor ?>
}
return data_item