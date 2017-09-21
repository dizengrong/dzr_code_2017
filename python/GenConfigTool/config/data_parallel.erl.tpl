-module(data_parallel).
-compile(export_all).

<?py for data in all_data: ?>
get_from_scene(${data[0]}) -> ${data[1]};
<?py #endfor ?>
get_from_scene(_) -> 0.
