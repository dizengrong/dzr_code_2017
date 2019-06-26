<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
	<?py for data in all_data: ?>
		[${data["ID"]}] = {
			challengeFree = ${data["challengeFree"]},
			consumption = ${split_items(data["consumption"])}
			victoryReward = ${data["victoryReward"]},
			failureReward = ${data["failureReward"]},
		}
	<?py #endfor ?>
}
return data_item