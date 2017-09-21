-module(data_signs).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_data_signs{id=${data[0]},sign_item_type=${data[1]},sign_item_num=${data[2]},vip_lev=${data[3]},times_num=${data[4]}};
<?py #endfor ?>
get_data(Id) -> throw({error_config, ?MODULE, get_data, Id}).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in acc_sign_data: ?>
get_acc_sign_reward(${data[1]}) -> ${split_items(data[2])};
<?py #endfor ?>
get_acc_sign_reward(_) -> [].
