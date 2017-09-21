-module(data_skillperformance).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[" + ",".join(item_str.split("|")) + "]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
<?py 	if data[9] == "": ?>
<?py 		continue ?>
<?py 	#endif ?>
<?py 	if data[15] == "NONE": ?>
<?py 		targetType = "NO" ?>
<?py 	else: ?>
<?py 		targetType = data[15] ?>
<?py 	#endif ?>
get_skillperformance(${data[0]}) -> #st_skillperformance_config{skillId=${data[0]},castRange=${data[14]},targetType="${targetType}",skillGroup="${data[16]}",skillType="${data[17]}",castType="${data[18]}",castPoint="${data[19]}",targetnumType="${data[20]}",targetnum=${data[21]},impactArea="${data[22]}",areaPara=${split_items(data[23])},areaCenterRange=${data[24]},selfShiftType="${data[25]}",selfShiftRange=${data[26]},targetShiftRange=${data[27]},aoeEffect=${data[28]},arrowEffect=${data[29]},time_yz_start=${data[30]},time_yz=${data[31]},time_bt_start=${data[32]},time_bt=${data[33]},time_wd_start=${data[34]},time_wd=${data[35]},kick_type="${data[36]}",kickdistance=${data[37]},shiftDirection=${data[38]},kickSpeed=${data[45]},kickStartTime=${data[46]},kickTimes=${data[48]},delayTimes=${data[52]},aleretTimes=${data[54]},buffReleaseType="${data[71]}"}; 
<?py #endfor ?>
get_skillperformance(_) -> {}.

