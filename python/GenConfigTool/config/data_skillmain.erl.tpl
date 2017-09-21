-module(data_skillmain).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_skillmain(${data[0]}) -> #st_skillmain_config{skillId=${data[0]},skillMode="${data[4]}",prof=${data[5]},levelLimit=${data[6]},unlockLvl=${data[7]},baseRune=${data[9]},proRune= [${data[10]}]}; 
<?py #endfor ?>
get_skillmain(_) -> {}.


<?py prof3 = [] ?>
<?py prof6 = [] ?>
<?py prof9 = [] ?>
<?py for data in all_data: ?>
<?py 	if data[5] == 3: ?>
<?py 		prof3.append(data[0]) ?>
<?py 	elif data[5] == 6: ?>
<?py 		prof6.append(data[0]) ?>
<?py 	elif data[5] == 9: ?>
<?py 		prof9.append(data[0]) ?>
<?py 	#endif ?>
<?py #endfor ?>

get_prof_skill(3) -> ${prof3};
get_prof_skill(6) -> ${prof6};
get_prof_skill(9) -> ${prof9};
get_prof_skill(_)->[].
