
<?py max_lv = 0?>
local data_item = {
<?py for data in all_data: ?>
	[${data["lv"]}]=${data["exp"]},
	<?py max_lv = max(max_lv ,data["lv"]) ?>
<?py #endfor ?>
    ["max_lv"] = ${max_lv},
}
return data_item	