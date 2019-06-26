local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		equipment_synthesis = ${data['equipment_synthesis']},
		equipment_consume = ${data['equipment_consume']},
		consumption_num = ${data['consumption_num']},
		gold = ${data['gold']},
	},
<?py #endfor ?>
}
return data_item