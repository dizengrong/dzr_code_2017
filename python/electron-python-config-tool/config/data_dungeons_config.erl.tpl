%% -*- coding: latin-1 -*-
-module(data_dungeons_config).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	if item_str == 0:?>
<?py 		return "[]" ?>
<?py 	elif item_str.strip() == "":?>
<?py 		return "[]" ?>
<?py 	else: ?>
<?py 		return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_dungeons(${data['id']}) -> #st_dungeons_config{id = ${data['id']}, dungenScene = ${data['dungenScene']}, monsterId = [${data['monsterGroupId']}], bossId = [${data['bossId']}], nextStage = ${data['nextStage']}, client_refresh_boss = ${data['autoBoss']}, lvRestriction=${data['rankRestriction']}, forceLimitation=${data['forceLimitation']}, common_reward=${split_items(data['stageAward'])}, time_reward=${split_items(data['timeAward'])}, time_box=${data['timeAwardBox']}};
<?py #endfor ?>
get_dungeons(_) -> {}.

<?py all_ids = [d['id'] for d in all_data] ?>
get_all() -> ${all_ids}.

<?py for data in all_data: ?>
get_difficulty(${data['id']}) -> #st_dungeon_dificulty{levPower = ${data['lev']}, atkPower = ${data['atk']}, hpPower = ${data['hplimit']}, mpPower = ${data['mplimit']}, realdmgPower = ${data['realdmg']}, dmgdownPower = ${data['dmgdown']}, defignorePower = ${data['defignore']}, defPower = ${data['def']}, criPower = ${data['cri']}, cridownPower = ${data['cridown']}, hitPower = ${data['hit']}, dodPower = ${data['dod']}, cridmgPower = ${data['cridmg']}, toughnessPower = ${data['toughness']}, blockratePower = ${data['blockrate']}, breakdefPower = ${data['breakdef']}, breakdefratePower = ${data['breakdefrate']}, blockdmgratePower = ${data['blockdmgrate']}, dmgratePower = ${data['dmgrate']}, dmgdownratePower = ${data['dmgdownrate']}, contorlratePower = ${data['contorlrate']}, contorldefratePower = ${data['contorldefrate']}, movespdPower = ${data['movespd']}, limitdmgPower = ${data['limitdmg']}};
<?py #endfor ?>
get_difficulty(_) -> {}.