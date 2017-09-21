-module(data_soulLink).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_soulLink{id=${data[0]},unlockCondition=${data[1]},unlockNum=${data[2]},page=${data[3]},orderopen=${data[4]}};
<?py #endfor ?>
get_data(_) -> {}.

<?py for data in all_data: ?>
select(${data[1]}, ${data[2]}) -> [${data[0]}];
<?py #endfor ?>
select(_, _) -> [].

