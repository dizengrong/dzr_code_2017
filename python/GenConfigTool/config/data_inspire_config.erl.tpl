-module(data_inspire_config).
-include("common.hrl").
-compile(export_all).

<?py max_times = 0 ?>
<?py for data in all_data: ?>
<?py max_times = max(max_times, data[0]) ?>
get_data(${data[0]}) -> #st_inspire_config{iD=${data[0]},currency_type=${data[1]},currency_num=${data[2]},add_value=${data[3]}};
<?py #endfor ?>
get_data(_Id) -> {error_cfg_not_find, data_inspire_config, _Id}.

%% 鼓舞最大次数
max_times() -> ${max_times}.
