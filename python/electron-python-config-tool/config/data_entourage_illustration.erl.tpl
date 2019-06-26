%% -*- coding: latin-1 -*-
-module(data_entourage_illustration).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['hero_id']}, ${data['star']}) -> ${data['id']};
<?py #endfor ?>
get_data(_, _) -> 0.