%% -*- coding: latin-1 -*-
-module(data_error_info).
-include("common.hrl").
-compile(export_all).


<?py for data in all_data: ?>
<?py s = data['string'].replace("\"", "") ?>
get_data("${data['svr_id']}") -> #st_error_info{id = ${data['ID']}, name="${data['des']}"}; 	%% ${s}
<?py #endfor ?>
get_data(_) -> {}.