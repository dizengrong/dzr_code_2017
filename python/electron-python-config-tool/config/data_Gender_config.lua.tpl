
local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		name= "${data['name']}",
		icon= ${as_escaped("{\"" + "\",\"".join(data['icon'].split("|")) + "\"}")},
	},
<?py #endfor ?>
}
return data_item	