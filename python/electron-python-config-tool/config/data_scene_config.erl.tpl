%% -*- coding: latin-1 -*-
-module(data_scene_config).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str == '0': ?>
<?py 		return [] ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #endif ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_scene(${data['id']}) -> #st_scene_config{
	id                = ${data['id']},
	sort              = "${data['sort']}",
	script_scene      = ${data['script_scene']},
	name              = "${data['name']}",
	max_agent         = ${data['max_agent']},
	full_create       = ${data['full_create']},
	res               = ${data['res']},
	life_time         = ${data['life_time']},
	points            = ${split_items(to_str(data['in_Point']))},
	clipWidth         = ${data['clipWidth']},
	coordinate        = ${split_items(to_str(data['coordinate']))},
	mcoordinate       = ${split_items(to_str(data['mCoordinate']))},
	end_delay         = ${data['endTime']}
};
<?py #endfor ?>
get_scene(_) -> {}.

<?py all_ids = [d['id'] for d in all_data] ?>
get_all() -> ${all_ids}.
