%% -*- coding: latin-1 -*-
-module(data_skillmain).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_skillmain(${data['skillId']}) -> #st_skillmain_config{skillId=${data['skillId']},skillMode="${data['skillMode']}",ai_skill_cast_condition={${data['ai_skill_cast_condition']}},ai_skill_cast_param=[${data['ai_skill_cast_param']}]}; 
<?py #endfor ?>
get_skillmain(_) -> {}.