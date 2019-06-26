local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		sourceName = "${data['sourceName']}",
		sysId = ${data['sysId']},
		sourcePath = "${data['subWndType']}",
		sourcePrefabName = "${data['GUItype']}",	
	},
<?py #endfor ?>
}
return data_item