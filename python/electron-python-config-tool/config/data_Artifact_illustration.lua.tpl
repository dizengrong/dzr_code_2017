local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
		{
			artifact_id = ${data['artifact_id']},
			star = ${data['star']},
			lv = ${data['lv']},
		},
<?py #endfor ?>
}

<?py type_dict = {} ?>
<?py for data in artifact_base_data: ?> 
<?py 	type_dict[data['itemId']] = data['type'] ?>
<?py #endfor ?>

<?py id_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	if type_dict[data['artifact_id']] not in id_dict: ?>
<?py 		id_dict[type_dict[data['artifact_id']]] = [] ?>
<?py 	#endif ?>
<?py 	id_dict[type_dict[data['artifact_id']]].append(data['id']) ?>
<?py #endfor ?>


local typeIdList = {
<?py for race in id_dict: ?> 
	[${race}] = ${str(id_dict[race]).replace('[', '{').replace(']', '}')},
<?py #endfor ?>
}

-- 查找图鉴数据
local function find_data(id)
	return data_item[id]
end

-- 获取某个种族的图鉴列表
local function get_type_datalist( _type )
	return typeIdList[_type]
end

return {FindData = find_data, GetTypeDataList = get_type_datalist}