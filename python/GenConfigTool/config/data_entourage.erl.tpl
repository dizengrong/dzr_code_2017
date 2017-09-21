-module(data_entourage).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_entourage_config{
	id               = ${data[0]},
	star             = ${data[2]},
	petskillGroup    = [${data[4]}],
	needed_soul_id   = ${data[10]},
	needed_soul_num  = ${data[11]},
	baseFighting     = ${data[14]},
	growthFighting   = ${data[15]},
	starPropList     = ${split_items(data[16])},
	starpropFighting = ${data[17]},
	deatlagtime      = ${data[71]},
	baseMoveSpd      = ${data[19]},
	atk              = ${data[24]},
	def              = ${data[25]},
	hpLimit          = ${data[26]},
	mpLimit          = ${data[27]},
	atkInc           = ${data[28]},
	defInc           = ${data[29]},
	hpLimitInc       = ${data[30]},
	mpLimitInc       = ${data[31]},
	str              = ${data[32]},
	agi              = ${data[33]},
	sta              = ${data[34]},
	wis              = ${data[35]},
	spi              = ${data[36]},
	defIgnore        = ${data[37]},
	cri              = ${data[38]},
	criDmg           = ${data[39]},
	tough            = ${data[40]},
	hit              = ${data[41]},
	dod              = ${data[42]},
	dmgRate          = ${data[43]},
	dmgDownRate      = ${data[44]},
	blockRate        = ${data[45]},
	blockDmgRate     = ${data[46]},
	realDmg          = ${data[47]},
	stifle           = ${data[48]},
	long_suffering   = ${data[49]},
	moveSpd          = ${data[50]},
	cd               = ${data[51]},
	hpRestore        = ${data[52]},
	mpRestore        = ${data[53]},
	freeBattleTimes  = ${data[57]},
	payBattleItem    = ${data[58]},
	payBattleCost    = ${data[59]},
	payBattleCostInc = ${data[60]},
	attackRange      = ${data[72]},
	normalSkill      = ${data[20]},
	type             = ${data[13]},
	petname          = "${data[73]}"
};
<?py #endfor ?>
get_data(_) -> {}.

<?py all_ids = [d[0] for d in all_data] ?>
get_all() -> ${all_ids}.

<?py all_ids = [d[10] for d in all_data] ?>
get_all_soul_id() -> ${all_ids}.
