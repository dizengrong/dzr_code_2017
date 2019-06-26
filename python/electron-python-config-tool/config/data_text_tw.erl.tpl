%% -*- coding: latin-1 -*-
-module(data_text_tw).
-include("common.hrl").
-compile(export_all).

<?py translate_dict = {} ?> 
<?py for data in all_data: ?> 
<?py 	translate_dict[data['text']] = data['text_to'] ?>
<?py #endfor ?>

<?py exists_key_dict = {} ?> 
<?py for data in exists_key_list: ?> 
<?py 	exists_key_dict[data] = True ?>
<?py #endfor ?>

<?py for data in exists_key_list: ?> 
<?py 	if data not in all_src_lang_text or data.strip() == '': ?> 
<?py 		continue ?> 
<?py 	#endif ?>
get_data(<<"${data}">>) -> "${translate_dict[data]}";
<?py #endfor ?>

<?py for data in all_src_lang_text: ?> 
<?py 	if data in exists_key_dict: ?> 
<?py 		continue ?> 
<?py 	#endif ?>
<?py 	if data in translate_dict: ?> 
get_data(<<"${data}">>) -> "${translate_dict[data]}";
<?py 	#endif ?>
<?py #endfor ?>
get_data(Str) -> 
	case ?DEBUG_MODE of
		true -> 
			{error_not_find_tw_translation, Str};
		_ -> 
			Str
	end.

