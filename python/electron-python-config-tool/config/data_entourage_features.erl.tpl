%% -*- coding: latin-1 -*-
-module(data_entourage_features).
-include("common.hrl").
-compile(export_all).

<?py for data in mp_data: ?>
get_init_mp(${data['id']}) -> ${data['init_mp']};
<?py #endfor ?>
get_init_mp(_) -> 0.
