-module(data_equipMake_price).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_equipMake_price{id=${data[0]},class=${data[1]},type=${data[2]},price=${data[3]}};
<?py #endfor ?>
get_data(_) -> {}.

