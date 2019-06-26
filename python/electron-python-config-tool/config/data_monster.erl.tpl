%% -*- coding: latin-1 -*-
-module(data_monster).
-include("common.hrl").
-compile(export_all).

<?py def array_2_str(array_datas, n, sep_str1, sep_str2):?>
<?py ret = "" ?>
<?py count = 1 ?>
<?py end_data = array_datas[-1] ?>
<?py for data in array_datas: ?>
<?py 	if end_data == data:?>
<?py 		ret += data ?>
<?py 	elif count < n:?>
<?py 		ret += data + sep_str1 ?>
<?py 		count += 1 ?>
<?py 	else:?>
<?py 		ret += data + sep_str2 ?>
<?py 		count = 1 ?>
<?py 	#endif ?>
<?py #endfor ?>
<?py return ret ?>
<?py #enddef ?>

<?py for data in all_data: ?>
<?py skill = ", ".join(to_str(data['skill']).split("|")) ?>
<?py passive_skill = ", ".join(to_str(data['passive_skill']).split("|")) ?>
get_monster(${data['id']}) -> #st_monster_config{id=${data['id']},name="${data['name']}",level=${data['lv']},rank_level=${data['rank_level']},ai=${data['ai']},feel=${data['feel']},normal_skill=${data['skill_public']},skill=[${skill}],monster_r=${data['model_r']},corpse_remain_time=${data['corpse_remain_time']},passive_skill=[${passive_skill}],baseMoveSpd=${data['baseMoveSpd']},bornTime=${data['bornTime']},star=${data['star']},sex=${data['sex']},race=${data['type']},profession=${data['profession']}};
<?py #endfor ?>
get_monster(_) -> {}.

<?py for data in all_data: ?>
get_monster_prop(${data['id']}) -> #st_monster_battle{atk = ${data['atk']}, hplimit = ${data['hplimit']}, mplimit = ${data['mplimit']}, realdmg = ${data['realdmg']}, dmgdown = ${data['dmgdown']}, defignore = ${data['defignore']}, def = ${data['def']}, cri = ${data['cri']}, cridown = ${data['cridown']}, hit = ${data['hit']}, dod = ${data['dod']}, cridmg = ${data['cridmg']}, toughness = ${data['toughness']}, blockrate = ${data['blockrate']}, breakdef = ${data['breakdef']}, breakdefrate = ${data['breakdefrate']}, blockdmgrate = ${data['blockdmgrate']}, dmgrate = ${data['dmgrate']}, dmgdownrate = ${data['dmgdownrate']}, contorlrate = ${data['contorlrate']}, contorldefrate = ${data['contorldefrate']}, movespd = ${data['movespd']}, limitdmg = ${data['limitdmg']}};
<?py #endfor ?>
get_monster_prop(_) -> {}.

get_all() -> [${"\n\t" + array_2_str([str(d['id']) for d in all_data], 20, ", ", ",\n\t")}].