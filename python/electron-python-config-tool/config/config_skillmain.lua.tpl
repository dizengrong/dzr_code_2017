local data_item = {
<?py for data in all_data: ?> 
	[${data['skillId']}] = 
		{
			skillName = "${data['skillName']}",
			skillDes = "${data['skillDes']}",
			skillIcon= ${as_escaped("{\"" + "\",\"".join(data['skillIcon'].split("|")) + "\"}")},
		},
<?py #endfor ?>
}

return data_item