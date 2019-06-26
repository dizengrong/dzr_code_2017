local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		name = "${data['name']}",
		des = "${data['des']}",
		res = "${data['res']}",	
		star = ${data['star']},	
		sex = ${data['sex']},
		type = ${data['sex']},
		profession = ${data['profession']},
	},
<?py #endfor ?>
}
return data_item