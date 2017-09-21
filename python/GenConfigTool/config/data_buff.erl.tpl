-module(data_buff).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[" + ",".join(item_str.split("|")) + "]" ?>
<?py #enddef ?>
<?py remove_list = [] ?>
<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_buff_config{id=${data[0]},sort="${data[2]}",maxmix=${data[3]},bdemage=${data[4]},data1="${data[5]}",data2=${data[6]},per_time=${data[7]},act_remove=${data[9]},delayTime =${data[14]},default_time =${data[15]},default_value=${data[16]},impactArea= "${data[18]}",areaPara=${split_items(data[19])},targetNum=${data[20]},riderEnable="${data[22]}",controlSort="${data[23]}",buffLevel=${data[24]},sceneRetain=${data[35]},dieRetain=${data[36]},dispel=${data[37]},timeRetain=${data[38]},timesgo=${data[39]},targetType="${data[25]}",skilleffectEnable=${data[31]},transmitEnable=${data[32]},script="${data[29]}"};
<?py 	if data[9] > 0: ?>
<?py 		remove_list.append(data[0]) ?>
<?py 	#endif ?>
<?py #endfor ?>
get_data(_) -> {}.

get_act_remove() -> ${remove_list}.

