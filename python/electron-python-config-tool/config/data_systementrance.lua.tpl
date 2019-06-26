<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>
<?py type_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	if data['typeid'] not in type_dict: ?>
<?py 		type_dict[data['typeid']] = [] ?>
<?py 	#endif ?>
<?py 	type_dict[data['typeid']].append((data['tagid'], data['labelname'])) ?>
<?py #endfor ?>
local sysType_dict = {
<?py for key in type_dict: ?> 
 	[${key}] = 
  	{
<?py 	for data in type_dict[key]: ?>
		{
			tagid = ${data[0]},
			labelname = "${data[1]}",
	 	},
<?py 	#endfor ?>
	},
	<?py #endfor ?>
}

<?py detail_dict = {} ?>
<?py for data in all_detail_data: ?> 
<?py 	if data['tagid'] not in detail_dict: ?>
<?py 		detail_dict[data['tagid']] = [] ?>
<?py 	#endif ?>
<?py 	detail_dict[data['tagid']].append((data['functionId'], data['sysname'], data['yuanhua'], data['timedes'], data['des'], data['reward'], data['jump_id'])) ?>
<?py #endfor ?>
local sysDetail_dict = {
<?py for key in detail_dict: ?> 
	[${key}] = 
	{
<?py 	for data in detail_dict[key]: ?>
		{
	 		functionId = ${data[0]},
	 		sysname = "${data[1]}",
			yuanhua =${as_escaped("{\"" + "\",\"".join(data[2].split("|")) + "\"}")},
			timedes = "${data[3]}",
			des = "${data[4]}",
			reward = ${split_items(data[5])},
			jump_id = ${data[6]},
		},
<?py 	#endfor ?>
	},
<?py #endfor ?>
}

-- 查找某个系统功能的大类
local function find_systementrance(_bigType)
	local id = hero_id * 100 + star
	return data_item[id]
end

-- 获取某个系统中大类对应的具体功能数据
local function get_systementrancefunc(_smallType)
	return synthesisIdList[race]
end

return {FindSystemEntrance = find_systementrance, GetSystemEntranceFunc = get_systementrancefunc}