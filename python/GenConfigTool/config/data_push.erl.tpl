-module(data_push).
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[" + ", ".join(item_str.split("|")) + "]" ?>
<?py #enddef ?>

<?py length = len(all_data) ?>
all() -> [
<?py for i in xrange(0, length): ?>
<?py 	if i == length - 1: ?>
	{${split_items(all_data[i][2])}, {${all_data[i][1]}, "${all_data[i][3]}"}}
<?py 	else: ?>
	{${split_items(all_data[i][2])}, {${all_data[i][1]}, "${all_data[i][3]}"}},
<?py 	#endif ?>
<?py #endfor ?>
].

