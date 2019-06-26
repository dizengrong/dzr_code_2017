<?py index = 0 ?>
local data_item = {
<?py for data in all_data: ?>
	<?py index = index + 1 ?>
	[${index}] = 
		{
			name = "${data['name']}",
			surname = "${data['surname']}",
		},
<?py #endfor ?>
}

return data_item