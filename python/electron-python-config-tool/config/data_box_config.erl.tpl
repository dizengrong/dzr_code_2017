%% -*- coding: latin-1 -*-
-module(data_box_config).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['boxId']})-> #st_box_config{boxid=${data['boxId']},next=${data['next']},droplistid=${data['dropListId']},droprate=${data['dropRate']},group=${data['group']}};
<?py #endfor ?>
get_data(_) -> {}.
