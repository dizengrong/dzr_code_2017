-module(data_liveness).
-compile(export_all).


%% get_data(类型) -> {次数, 活跃度, Id}
<?py for data in all_data: ?>
get_data(${data[10]}) -> {${data[3]}, ${data[2]}, ${data[0]}};
<?py #endfor ?>
get_data(_) -> [].

