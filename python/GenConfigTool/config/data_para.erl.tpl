-module(data_para).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_para_config{id=${data[0]},val=${data[3]}}; 	%% ${data[4]}
<?py #endfor ?>
get_data(_) -> {}.

