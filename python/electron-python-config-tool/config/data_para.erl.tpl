%% -*- coding: latin-1 -*-
-module(data_para).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['id']}) -> ${data['val']}; 	%% ${data['des']}
<?py #endfor ?>
get_data(_) -> {}.

