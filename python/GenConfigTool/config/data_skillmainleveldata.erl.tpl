-module(data_skillmainleveldata).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_skillmainleveldata(${data[1]}) -> #st_skillmainleveldata_config{skillId=${data[1]},skillLevel=${data[2]},learnLevel=${data[3]},coinType=${data[4]},learnCoin=${data[5]},learnCoin_add=${data[6]},spType=${data[7]},learnSp=${data[8]},gs=${data[9]},gs_add=${data[10]}}; 
<?py #endfor ?>
get_skillmainleveldata(_) -> {}.

