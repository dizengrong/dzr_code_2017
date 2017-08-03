-module(cfg_stone).
-compile(export_all).


<?py for data in all_stone: ?>
find(${data[0]}) -> [{p_stone_base_info,${data[0]},<<"${data[1]}">>,${data[2]},${data[3]},${data[4]},${data[17]},${data[5]},${data[10]},${data[11]},${data[12]},${data[17]},${data[15]},[${data[16]}]}];
<?py #endfor ?>
find(_) -> [].

