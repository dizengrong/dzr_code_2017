-module(data_equipment_synthwsis).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['equipment_synthesis']}) -> [{${data['equipment_consume']}, ${data['consumption_num']}}, {1, ${data['gold']}}];
<?py #endfor ?>
get_data(_Type) -> [].