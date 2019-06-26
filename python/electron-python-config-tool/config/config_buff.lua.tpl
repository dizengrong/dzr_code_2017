local data_item = {
<?py for data in all_data: ?> 
	[${data['type']}] = 
	{
		icon = "${data['icon']}",
	},
<?py #endfor ?>
}
return data_item