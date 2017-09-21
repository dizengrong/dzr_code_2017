-module(data_equipMake_list).
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> ${data[1]};
<?py #endfor ?>
get_data(_) -> 0.

