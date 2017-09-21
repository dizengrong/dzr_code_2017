-module(data_charge_config).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
<?py 	prize_sort, prize_num = data[6].split('|') ?>
get_data(${data[0]}) -> #st_charge_config{id=${data[0]},sort=${data[2]},charge_money=${data[3]},diamond=${data[5]},first_prize_sort=${prize_sort},first_prize_num=${prize_num}};
<?py #endfor ?>
get_data(_) -> {}.


<?py all_ids1 = [d[0] for d in all_data if d[18] == 0] ?>
<?py all_ids2 = [d[0] for d in all_data if d[18] == 1] ?>

get_all(?PHONE_TYPE_ANDRIOD) -> ${all_ids1};
get_all(?PHONE_TYPE_IOS) -> ${all_ids2}.

%% 首冲奖励
% get_first_charge_reward(第几次充值, 本次充值的人名币) -> 奖励boxid;
<?py max_times = 0 ?>
<?py for data in first_charge_data: ?>
<?py max_times = max(max_times, data[0]) ?>
get_first_charge_reward(${data[2]}, ${data[0]}, Money) when Money >= ${data[12]} -> ${data[15]};
get_first_charge_reward(${data[2]}, ${data[0]}, Money) when Money >= ${data[8]} -> ${data[11]};
get_first_charge_reward(${data[2]}, ${data[0]}, Money) when Money >= ${data[4]} -> ${data[7]};

<?py #endfor ?>
get_first_charge_reward(_, _, _Money) -> 0.

max_first_charge_times() -> ${max_times}.
