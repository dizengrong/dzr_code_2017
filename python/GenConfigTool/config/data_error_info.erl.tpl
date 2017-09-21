-module(data_error_info).
-include("common.hrl").
-compile(export_all).


<?py for data in all_data: ?>
<?py s = data[4].replace("\"", "") ?>
get_data("${data[1]}") -> #st_error_info{id=${data[0]},name="${data[1]}"}; 	%% ${s}
<?py #endfor ?>
get_data(_) -> {}.
