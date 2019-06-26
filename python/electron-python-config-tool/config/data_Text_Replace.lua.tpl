local data_item = {
<?py for data in all_data: ?>
	[${data["id"]}] = "${data["textReplace"]}",
<?py #endfor ?>
}
return data_item