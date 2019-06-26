local data_item = {
<?py for data in all_data: ?> 
	[${data['ID']}] = 
		{
			Stats = "${data['Stats']}",
			Explain = "${data['Explain']}",
			GS = ${data['GS']},
			association = ${data['association']},
		},
<?py #endfor ?>
}

return data_item