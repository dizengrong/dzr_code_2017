local data_item = {
<?py for data in all_data: ?> 
	[${data['type']}] = 
		{
			icon= ${as_escaped("{\"" + "\",\"".join(data['icon'].split("|")) + "\"}")},
		},
<?py #endfor ?>
}
return data_item	