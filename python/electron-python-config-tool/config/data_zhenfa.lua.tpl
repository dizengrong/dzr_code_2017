<?py import helper ?>
<?py all_type_set = set() ?>
<?py all_type_dict = {} ?>
<?py for data in all_data: ?>
<?py 	all_type_set.add(data['type']) ?>
<?py 	if data['type'] not in all_type_dict: ?>
<?py 		all_type_dict[data['type']] = [] ?>
<?py 	#endif ?>
<?py 	all_type_dict[data['type']].append((data['id'], helper.lua_split_items(data['activation']))) ?>
<?py #endfor ?>

local active_cond = {
<?py for key in all_type_dict: ?>
	[${key}] = {${','.join(['{' + str(d[0]) + ', ' + d[1] + '}' for d in all_type_dict[key]])}},
<?py #endfor ?>
}

local zhenfa_describe = {
<?py for data in all_data: ?>
	[${data['id']}] = {
		name      = "${data['name']}",
		explain   = "${data['explain']}",
		icon= ${as_escaped("{\"" + "\",\"".join(data['icon'].split("|")) + "\"}")},
		attribute = ${helper.lua_split_items(data['attribute'])},
	},
<?py #endfor ?>
}

return {active_cond, zhenfa_describe}
