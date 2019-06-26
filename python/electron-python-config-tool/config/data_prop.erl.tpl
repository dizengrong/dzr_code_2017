-module(data_prop).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['ID']}) -> ${data['GS']};
<?py #endfor ?>
get_data(_Type) -> 0.