-module(data_outLineReward).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py length = len(all_data) ?>
all_items() -> [
<?py for i in xrange(0, length): ?>
<?py 	if i == length - 1: ?>
	{${all_data[i][0]}, ${split_items(all_data[i][1])}, ${all_data[i][2]}}
<?py 	else: ?>
	{${all_data[i][0]}, ${split_items(all_data[i][1])}, ${all_data[i][2]}},
<?py 	#endif ?>
<?py #endfor ?>
].

<?py for data in all_time: ?>
get_time(${data[0]})-> ${data[1]};
<?py #endfor ?>
get_time(_) -> 0.
