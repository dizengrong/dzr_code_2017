%% -*- coding: latin-1 -*-
-module(data_buff).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[" + ",".join(item_str.split("|")) + "]" ?>
<?py #enddef ?>
<?py remove_list = [] ?>
<?py for data in all_data: ?>
<?py 	if data['属性类型'].strip() != "" : ?>
<?py 		attr_type = "?" + data['属性类型'] ?>
<?py 	else: ?>
<?py 		attr_type = "undefined" ?>
<?py 	#endif ?> 
get_data(${data['type']}) -> #st_buff_config{id=${data['type']},sort="${data['sort']}",maxmix=${data['maxmix']},bdemage=${data['bdamage']},data1=${attr_type},data2=${data['data2']},per_time=${data['per_time']},act_remove=${data['act_remove']},delayTime =${data['DelayTime']},default_time =${data['defaultBuffTime']},default_value=${data['defaultBuffValue']},impactArea= "${data['impactArea']}",areaPara=${split_items(data['areaPara'])},targetNum=${data['targetnum']},riderEnable="${data['riderEnable']}",controlSort="${data['controlSort']}",buffLevel=${data['buffLevel']},sceneRetain=${data['SceneRetain']},dieRetain=${data['dieRetain']},dispel=${data['dispel']},timeRetain=${data['timeRetain']},timesgo=${data['timesgo']},targetType="${data['targetType']}",skilleffectEnable=${data['skilleffectEnable']},transmitEnable=${data['transmitEnable']},script="${data['script']}"};
<?py 	if data['act_remove'] > 0: ?>
<?py 		remove_list.append(data['type']) ?>
<?py 	#endif ?>
<?py #endfor ?>
get_data(_) -> {}.

get_act_remove() -> ${remove_list}.

