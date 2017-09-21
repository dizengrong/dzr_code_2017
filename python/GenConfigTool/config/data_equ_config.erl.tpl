-module(data_equ_config).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #equ_config{id=${data[0]},ply_lev=${data[1]},att_type=${data[2]},quality=${data[7]},att_val=${data[4]},att_multy=${data[5]},gs_num=${data[6]},propJob= [${data[19]}]};
<?py #endfor ?>
get_data(_) -> {}.

<?py for data in propo_data: ?>
get_odds(${data[0]}) -> ${data[13]};
<?py #endfor ?>
get_odds(_ID) ->{}.

<?py def select_multiple_field(datas, select_indexs, result_index):?>
<?py	ret_list = {} ?>
<?py	for data in datas: ?>
<?py		key = tuple([data[i] for i in select_indexs]) ?>
<?py		result = data[result_index] ?>
<?py		if ret_list.has_key(key): ?>
<?py			ret_list[key].append(result) ?>
<?py		else: ?>
<?py			ret_list[key] = [result] ?>
<?py #endif ?>
<?py #endfor ?>
<?py	return ret_list ?>
<?py #enddef ?>

<?py prop_dict = select_multiple_field(all_data, [1,2], 0) ?>
<?py keys = sorted(prop_dict) ?>
<?py for (k1, k2) in keys: ?>
select_prop_type(${k1}, ${k2}) -> ${prop_dict[(k1, k2)]};
<?py #endfor ?>
select_prop_type(_, _) -> [].


<?py def select_prop_help(select_datas, check, k1, k2, data):?>
<?py 	if check == 1: ?>
<?py 		if not select_datas.has_key((k1, k2)): ?>
<?py			select_datas[(k1, k2)] = [] ?>
<?py 		#endif ?>
<?py 		select_datas[(k1, k2)].append(data) ?>
<?py 	#endif ?>
<?py 	return select_datas ?>
<?py #enddef ?>

<?py select_datas = {} ?>
<?py for data in propo_data: ?>
<?py profs = data[11].split(',') ?>
<?py for prof in profs: ?>
<?py 	if data[1] == 1: ?>
<?py 		select_datas = select_prop_help(select_datas, data[1], prof, 10001, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[2], prof, 10002, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[3], prof, 10003, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[4], prof, 10004, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[5], prof, 10005, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[6], prof, 10006, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[7], prof, 10007, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[8], prof, 10008, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[9], prof, 10009, data[0]) ?>
<?py 		select_datas = select_prop_help(select_datas, data[10], prof, 10010, data[0]) ?>
<?py 	#endif ?>
<?py #endfor ?>
<?py #endfor ?>

<?py for k in select_datas: ?>
select(${k[0]}, ${k[1]}) -> ${select_datas[k]};
<?py #endfor ?>
select(_,_) ->[].

<?py for data in propo_data: ?>
get_equ_type_lev(${data[0]}) -> ${data[12]};
<?py #endfor ?>
get_equ_type_lev(_) ->{}.
