local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		val = ${data['val']},
		des = "${data['des']}",
	},
<?py #endfor ?>
}
return data_item