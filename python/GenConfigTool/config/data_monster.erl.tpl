-module(data_monster).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
<?py skill = ", ".join(to_str(data[18]).split("|")) ?>
<?py passive_skill = ", ".join(to_str(data[64]).split("|")) ?>
get_monster(${data[0]}) -> #st_monster_config{id=${data[0]},name="${data[1]}",ontime_off=${data[10]},script="${data[11]}",ai=${data[12]},level=${data[8]},camp=${data[7]},rank_level=${data[9]},view=${data[13]},view_range=${data[14]},feel=${data[15]},att_range=${data[16]},normal_skill=${data[17]},skill=[${skill}],str=${data[19]},agi=${data[20]},sta=${data[21]},wis=${data[22]},spi=${data[23]},atk=${data[24]},def=${data[25]},defIgnore=${data[26]},hp=${data[27]},hpMax=${data[28]},mp=${data[29]},mpMax=${data[30]},cri=${data[31]},criDmg=${data[32]},tough=${data[33]},hit=${data[34]},dod=${data[35]},dmgRate=${data[36]},dmgDownRate=${data[37]},blockRate=${data[38]},blockDmgDownRate=${data[39]},realDmg=${data[40]},stifle=${data[41]},long_suffering=${data[42]},moveSpd=${data[43]},fall_time=${data[44]},monster_r=${data[48]},monster_y=${data[47]},corpse_remain_time=${data[53]},stifle_time=${data[55]},rest_time=${data[52]},stifle_distance=${data[56]},passive_skill=[${passive_skill}] ,baseMoveSpd =${data[69]},returnRange=${data[70]},monsterBoxId=${data[71]},ascription=${data[82]},rewardType="${data[72]}",exp=${data[73]},bornTime=${data[76]}};
<?py #endfor ?>
get_monster(_) -> {}.

