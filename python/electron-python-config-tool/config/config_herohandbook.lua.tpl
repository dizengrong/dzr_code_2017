local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
		{
			hero_id = ${data['hero_id']},
			star = ${data['star']},
		},
<?py #endfor ?>
}

<?py race_dict = {} ?>
<?py for data in hero_base_data: ?> 
<?py 	race_dict[data['id']] = data['type'] ?>
<?py #endfor ?>

<?py id_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	if race_dict[data['hero_id']] not in id_dict: ?>
<?py 		id_dict[race_dict[data['hero_id']]] = [] ?>
<?py 	#endif ?>
<?py 	id_dict[race_dict[data['hero_id']]].append(data['id']) ?>
<?py #endfor ?>


local raceIdList = {
<?py for race in id_dict: ?> 
	[${race}] = ${str(id_dict[race]).replace('[', '{').replace(']', '}')},
<?py #endfor ?>
}

-- 查找图鉴数据
local function find_data(id)
	return data_item[id]
end

-- 获取某个种族的图鉴列表
local function get_race_datalist( race )
	return raceIdList[race]
end

return {FindData = find_data, GetRaceDataList = get_race_datalist}
