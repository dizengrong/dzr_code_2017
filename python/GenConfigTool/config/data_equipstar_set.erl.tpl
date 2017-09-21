-module(data_equipstar_set).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_equipstar_set(${data[0]}) -> #equipstar_set{starNum=${data[0]},propRate=${data[1]},weaponNeedItem=${data[2]},otherNeedItem=${data[3]},needItemNum=${data[4]},needCoin=${data[5]}};
<?py #endfor ?>
get_equipstar_set(_) -> {}.

