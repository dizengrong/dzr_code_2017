-module(data_item).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
<?py 	if data[43] == 'YES': ?>
<?py 		can_recycle = 1 ?>
<?py 	else: ?>
<?py 		can_recycle = 1 ?>
<?py #endif ?>
get_data(${data[0]}) -> #st_item_type{id=${data[0]},sort=${data[2]},name="${data[59]}",max=${data[4]},req_lev=${data[6]},req_prof=${data[7]},att1=${data[8]},val1=${data[9]},att2=${data[10]},val2=${data[11]},bind=${data[13]},business=${data[14]},discard=${data[15]},color=${data[16]},price=${data[21]},action=${data[19]},action_arg=${data[20]},suitId=${data[37]},gs=${data[23]},multi_open=${data[24]},quick_buy=${data[25]},maxPowerLv=${data[27]},autoInBag=${data[46]},useLimitGroup=${data[48]},meltingValue=${data[64]},makeValue=${data[65]},useTimeCount=${data[49]},recycleType=${can_recycle},propLv=${data[29]},profType=[${data[36]}],passiveSkillId=[${data[42]}]};
<?py #endfor ?>
get_data(_) -> {}.

<?py all_ids = [d[0] for d in all_data] ?>
get_all() -> ${all_ids}.
