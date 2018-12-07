-module(data_text_tw).
-include("common.hrl").
-compile(export_all).

<?py translate_dict = {} ?> 
<?py for data in all_data: ?> 
<?py 	translate_dict[data[0]] = data[1] ?>
<?py #endfor ?>

<?py exists_key_dict = {} ?> 
<?py for data in exists_key_list: ?> 
<?py 	exists_key_dict[data[0]] = True ?>
<?py #endfor ?>

<?py for data in exists_key_list: ?> 
<?py    if data in translate_dict: ?> 
get_data("${data}") -> "${translate_dict[data]}";
<?py    else: ?>
get_data("${data}") -> "${data}";
<?py    #endif ?>
<?py #endfor ?>


get_data(Str) -> {error_not_find_tw_translation, Str}.

