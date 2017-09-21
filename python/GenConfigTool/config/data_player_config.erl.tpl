-module(data_player_config).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[" + ",".join(item_str.split("|")) + "]" ?>
<?py #enddef ?>

<?py max_lv = 0 ?>
<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_player_config{
	id               = ${data[0]},
	name             = "${data[1]}",
	atk              = ${data[5]},
	def              = ${data[6]},
	hpLimit          = ${data[7]},
	mpLimit          = ${data[8]},
	atkInc           = ${data[9]},
	defInc           = ${data[10]},
	hpLimitInc       = ${data[11]},
	mpLimitInc       = ${data[12]},
	height           = ${data[14]},
	sex              = ${data[15]},
	up_ID            = [${data[16]}],
	form_ID          = ${split_items(data[17])},
	born_scene       = ${data[18]},
	born_x           = ${data[19]},
	born_y           = ${data[20]},
	atk_dis          = ${data[27]},
	normalSkillList  = ${split_items(data[28])},
	basic_skill      = ${split_items(data[29])},
	roundskill       = ${data[30]},
	bufferskill      = ${data[31]},
	scene_task       = ${data[32]},
	scene_step       = ${data[33]},
	start_fuyu       = ${data[34]},
	start_kz         = ${data[35]},
	start_fz         = ${data[36]},
	start_gj         = ${data[37]},
	gS_base          = ${data[38]},
	gS_inc           = ${data[39]},
	baseMoveSpd      = ${data[42]},
	fall_time        = ${data[47]},
	stifle_time      = ${data[48]},
	showid           = ${data[52]},
	pace_speed       = ${data[53]},
	defaultskill     = ${split_items(data[54])},
	str              = ${data[55]},
	agi              = ${data[56]},
	sta              = ${data[57]},
	wis              = ${data[58]},
	spi              = ${data[59]},
	defIgnore        = ${data[60]},
	cri              = ${data[61]},
	criDmg           = ${data[62]},
	tough            = ${data[63]},
	hit              = ${data[64]},
	dod              = ${data[65]},
	dmgRate          = ${data[66]},
	dmgDownRate      = ${data[67]},
	blockRate        = ${data[68]},
	blockDmgRate     = ${data[69]},
	realDmg          = ${data[70]},
	stifle           = ${data[71]},
	long_suffering   = ${data[72]},
	moveSpd          = ${data[73]},
	passiveSkillList = [${data[76]}]
};
<?py #endfor ?>
get_data(_) -> {}.

