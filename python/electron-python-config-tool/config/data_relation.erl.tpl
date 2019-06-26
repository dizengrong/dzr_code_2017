-module(data_relation).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_relation(${data['camp1']}, ${data['camp2']}, ${data['sceneType']}) ->#st_relation_config{sceneType=${data['sceneType']},relation=${data['relation']}}; 
<?py #endfor ?>
get_relation(_,_,_) ->{}.