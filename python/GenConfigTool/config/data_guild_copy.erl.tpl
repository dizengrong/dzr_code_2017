-module(data_guild_copy).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_data_guild_copy{id=${data[0]},boss_id=${data[3]},sceneid=${data[4]}};
<?py #endfor ?>
get_data(_) -> {}.

<?py for data in all_data: ?>
select(${data[4]}) -> [${data[0]}];
<?py #endfor ?>
select(_) -> [].

