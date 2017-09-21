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
<?py 	if data[73] == '': ?>
<?py 		auto_wave = 0 ?>
<?py 	else: ?>
<?py 		auto_wave = data[73] ?>
<?py #endif ?>
get_scene(${data[0]}) -> #st_scene_config{
	id                = ${data[0]},
	sort              = "${data[2]}",
	fly_shoes         = ${data[68]},
	name              = "${data[1]}",
	max_agent         = ${data[3]},
	full_create       = ${data[4]},
	life_time         = ${data[5]},
	in_x              = ${data[6]},
	in_z              = ${data[7]},
	scene_type        = ${data[8]},
	out_scene         = ${data[9]},
	out_x             = ${data[10]},
	out_z             = ${data[11]},
	on_time_off       = ${data[12]},
	on_time           = ${data[13]},
	res               = "${data[14]}",
	cam_y             = ${data[16]},
	cam_distance      = ${data[17]},
	cam_x_min         = ${data[18]},
	cam_x_max         = ${data[19]},
	cam_z_min         = ${data[20]},
	cam_z_max         = ${data[21]},
	res_prefab        = "${data[22]}",
	map_word          = ${data[23]},
	big_map           = ${data[24]},
	need_lv           = ${data[25]},
	scene_items       = ${data[27]},
	addasset          = ${data[28]},
	jumpType          = ${data[31]},
	isAssess          = ${data[32]},
	battleEnable      = ${data[33]},
	killEnable        = ${data[35]},
	campEnable        = ${data[36]},
	bigmapEnable      = ${data[37]},
	reviveEnable      = ${data[38]},
	enterAlert        = ${data[39]},
	teamEnable        = ${data[41]},
	maxLine           = ${data[42]},
	sceneBoxId        = ${data[43]},
	hugeBoxId         = ${data[44]},
	dropRemainTimes   = ${data[50]},
	hugeBoxCycle      = ${data[45]},
	clipWidth         = ${data[53]},
	fatigueEnable     = ${data[58]},
	randomEnter       = ${data[59]},
	precreate         = ${data[60]},
	entourageEnable   = ${data[61]},
	fullReturnSceneId = ${data[62]},
	fullReturnPos     = {${", ".join(data[63].split("|"))}},
	rebornPoint1      = {${", ".join(data[46].split("|"))}},
	rebornPoint2      = {${", ".join(data[47].split("|"))}},
	rebornPoint3      = {${", ".join(data[48].split("|"))}},
	script_scene      = ${data[64]},
	mcoordinate       = ${split_items(to_str(data[70]))},
	wave              = ${data[71]},
	auto_wave         = ${auto_wave}
};
<?py #endfor ?>
get_scene(_) -> {}.

<?py all_ids = [d[0] for d in all_data] ?>
get_all() -> ${all_ids}.
