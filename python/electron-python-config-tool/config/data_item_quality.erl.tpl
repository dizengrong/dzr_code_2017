-module(data_item_quality).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['iD']}) -> "[${data['color']}]";
<?py #endfor ?>
get_data(_Type) -> "".