-module(data_dropcontentconfig).
-include("common.hrl").
-compile(export_all).

<?py def cmp_func(item1, item2):?>
<?py 	return item1[0] + item1[4] < item2[0] + item2[4] ?>
<?py #enddef ?>
<?py all_data2 = sorted(all_data, key=lambda item: item[0]*10 + item[4]) ?>

<?py pre1 = 0 ?>
<?py pre2 = 0 ?>
<?py drop_item = '' ?>
<?py for data in all_data2: ?>
<?py	if pre1 == data[0] and pre2 == data[4]: ?>
<?py 		drop_item = drop_item + '{{' + str(data[2]) + ',' + str(data[3]) + ',' + str(data[5]) + '},' + str(data[1]) + '},' ?>
<?py 	else: ?>
get_data(${pre1}, ${pre2}) -> [${drop_item[:-1]}];
<?py 		drop_item = '{{' + str(data[2]) + ',' + str(data[3]) + ',' + str(data[5]) + '},' + str(data[1]) + '},' ?>
<?py 		pre1 = data[0] ?>
<?py 		pre2 = data[4] ?>
<?py #endif ?>
<?py #endfor ?>
get_data(${pre1}, ${pre2}) -> [${drop_item[:-1]}];
get_data(_, _) -> {}.
