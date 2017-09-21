-module(data_update_lev).
-include("common.hrl").
-compile(export_all).

<?py max_lv = 0 ?>
<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_lev_exp{max_exp =${data[1]},dailyReward=${data[2]},dailyExp=${data[3]},dailyCoin=${data[4]},resetDailyCost=${data[5]},offlineExpMinute= ${data[6]}};
<?py 	max_lv = max(max_lv, data[0]) ?>
<?py #endfor ?>
get_data(_) -> {}.

max_lev()-> ${max_lv}.
