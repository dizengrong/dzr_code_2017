
local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		sysName = "${data['sysName']}",
		sysId = ${data['sysId']},
		openTask = ${data['openTask']},
		openLv = ${data['openLv']},
		text = "${data['text']}",
		des = "${data['des']}",
	},
<?py #endfor ?>
}
return data_item