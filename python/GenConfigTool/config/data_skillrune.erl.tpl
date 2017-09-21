-module(data_skillrune).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_skillrune(${data[0]}) -> #st_skillrune_config{runeId=${data[0]},skillgroup=${data[1]},unlockPlayerLvl=${data[2]},unlockSkillLvl=${data[3]},unlockItem=${data[4]},unlockPrice=${data[5]},passiveSkillId=[${data[10]}],autoType= "${data[11]}"}; 
<?py #endfor ?>
get_skillrune(_) -> {}.

