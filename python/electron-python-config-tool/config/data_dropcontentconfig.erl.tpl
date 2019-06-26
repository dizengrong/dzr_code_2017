%% -*- coding: latin-1 -*-
-module(data_dropcontentconfig).
-include("common.hrl").
-compile(export_all).

<?py pre = 0 ?>
<?py drop_item = '' ?>
<?py for data in all_data: ?>
<?py	if data['rewardItemId'] == data['toRewardItemId']: ?>
<?py		item = str(data['rewardItemId']) ?>
<?py 	else: ?>
<?py		item = "[" + str(data['rewardItemId']) + "," + str(data['toRewardItemId']) + "]" ?>
<?py 	#endif ?>
<?py	if data['rewardNum'] == data['toRewardNum']: ?>
<?py		num = str(data['rewardNum']) ?>
<?py 	else: ?>
<?py		num = "[" + str(data['rewardNum']) + "," + str(data['toRewardNum']) + "]" ?>
<?py 	#endif ?>
<?py	if pre == data['dropContentId']: ?>
<?py 		drop_item = drop_item + '{{' + item + ',' + num + ',' + str(data['itemPara']) + '},' + str(data['rate']) + '},' ?>
<?py 	else: ?>
get_data(${pre}) -> [${drop_item[:-1]}];
<?py 		drop_item = '{{' + item + ',' + num + ',' + str(data['itemPara']) + '},' + str(data['rate']) + '},' ?>
<?py 		pre = data['dropContentId'] ?>
<?py 	#endif ?>
<?py #endfor ?>
get_data(${pre}) -> [${drop_item[:-1]}];
get_data(_) -> [].