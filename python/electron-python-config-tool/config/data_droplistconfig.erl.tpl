%% -*- coding: latin-1 -*-
-module(data_droplistconfig).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data['dropListId']})-> #st_droplist_config{next=${data['next']},dropcontentid=${data['dropContentId']},droprate=${data['dropRate']},group=${data['group']},droptimes=${data['dropTimes']},droptype=${data['dropType']},calculationtype=${data['calculationtype']}};
<?py #endfor ?>
get_data(_) -> {}.
