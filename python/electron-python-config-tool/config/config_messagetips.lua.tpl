local data_item = {
<?py for data in all_data: ?> 
	[${data['ID']}] = 
		{
			sort = ${data['sort']},
			string = "${data['string']}",
		},
<?py #endfor ?>
}

return data_item