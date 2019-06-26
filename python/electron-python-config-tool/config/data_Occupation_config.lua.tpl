local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		name= "${data['name']}",
		energy= ${data['energy']},
		icon= ${as_escaped("{\"" + "\",\"".join(data['icon'].split("|")) + "\"}")},
		energy_icon= ${as_escaped("{\"" + "\",\"".join(data['energy_icon'].split("|")) + "\"}")},
		init_mp= ${data['init_mp']},
	},
<?py #endfor ?>
}
return data_item	