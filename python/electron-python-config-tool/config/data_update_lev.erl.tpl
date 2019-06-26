%% -*- coding: latin-1 -*-
-module(data_update_lev).
-include("common.hrl").
-compile(export_all).

<?py max_lv = 0 ?>
<?py for data in all_data: ?>
get_data(${data['lv']}) -> #st_lev_exp{need_exp = ${data['exp']}};
<?py 	max_lv = max(max_lv, data['lv']) ?>
<?py #endfor ?>
get_data(_) -> {}.

max_lev()-> ${max_lv}.