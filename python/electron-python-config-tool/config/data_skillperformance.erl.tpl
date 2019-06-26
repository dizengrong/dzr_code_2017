%% -*- coding: latin-1 -*-
-module(data_skillperformance).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py for data in all_data: ?>
<?py 	if data['processTime'] == "": ?>
<?py 		continue ?>
<?py 	#endif ?>
<?py 	if data['targetType'] == "NONE": ?>
<?py 		targetType = "NO" ?>
<?py 	else: ?>
<?py 		targetType = data['targetType'] ?>
<?py 	#endif ?>
<?py 	if int(data['time_yz']) - 100 >= 0: ?>
<?py 		YZ = int(data['time_yz']) - 100 ?>
<?py 	else: ?>
<?py 		YZ = 0 ?>
<?py 	#endif ?>
get_skillperformance(${data['skillId']}) -> #st_skillperformance_config{skillId=${data['skillId']},castRange=${data['castRange']},targetType="${targetType}",skillGroup="${data['skillGroup']}",skillType="${data['skillType']}",castType="${data['castType']}",castPoint="${data['castPoint']}",targetnumType="${data['targetnumType']}",targetnum=${data['targetnum']},impactArea="${data['impactArea']}",areaPara=[${data['areaPara'].replace('|', ',')}],areaCenterRange=${data['areaCenterRange']},selfShiftType="${data['selfShiftType']}",selfShiftRange=${data['selfShiftRange']},targetShiftRange=${data['targetShiftRange']},aoeEffect=${data['aoeEffect']},arrowEffect=${data['arrowEffect']},time_yz_start=${data['time_yz_start']},time_yz=${YZ},time_bt_start=${data['time_bt_start']},time_bt=${data['time_bt']},time_wd_start=${data['time_wd_start']},time_wd=${data['time_wd']},kick_type="${data['kick_type']}",kickdistance=${data['kickdistance']},shiftDirection=${data['shiftDirection']},kickSpeed=${data['kickShowTimes']},kickStartTime=${data['kickStartTime']},kickTimes=${data['kickTimes']},delayTimes=${data['delayTimes']},aleretTimes=${data['alertTimes']},buffReleaseType="${data['buffReleaseType']}",skill_ai = {${data['entourageAI']}}}; 
<?py #endfor ?>
get_skillperformance(_) -> {}.

