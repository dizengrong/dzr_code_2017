<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['hero_id'] * 100 + data['star']}] = 
		{
			hero_id = ${data['hero_id']},
			star = ${data['star']},
			up1 = ${split_items(data['up1'])},
			up2 = ${split_items(data['up2'])},
			up3 = ${split_items(data['up3'])},
		},
<?py #endfor ?>
}

<?py race_dict = {} ?>
<?py for data in all_base_data: ?> 
<?py 	race_dict[data['id']] = data['type'] ?>
<?py #endfor ?>

<?py star_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	if race_dict[data['hero_id']] not in star_dict: ?>
<?py 		star_dict[race_dict[data['hero_id']]] = [] ?>
<?py 	#endif ?>
<?py 	star_dict[race_dict[data['hero_id']]].append((data['hero_id'], data['star'])) ?>
<?py #endfor ?>


local synthesisIdList = {
<?py for key in star_dict: ?> 
	[${key}] = {
<?py 	for data in star_dict[key]: ?> 
<?py 		if data[1] <= 6: ?>
		{${data[0]}, ${data[1]}},
<?py 		#endif ?>
<?py 	#endfor ?>
	},
<?py #endfor ?>
}

-- 查找某个英雄对应星级的升星配置
local function find_data(hero_id, star)
	local id = hero_id * 100 + star
	return data_item[id]
end

-- 获取某个种族的英雄合成列表
local function get_race_synthesis_list(race)
	return synthesisIdList[race]
end

return {FindData = find_data, GetRaceSynthesisHeros = get_race_synthesis_list}
