<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py for data in all_data: ?> 
	[${data['id']}] = 
	{
		entourage_id = ${data['entourage_id']},
		grade = ${data['grade']},
		star = ${data['star']},
		show_skill= ${split_items(data['show_skill'])},
		skill_group= ${split_items(data['skill_group'])},
		attribute= ${split_items(data['attribute'])},
	},
<?py #endfor ?>
}

<?py index_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	if data['entourage_id'] not in index_dict:?>
<?py 		index_dict[data['entourage_id']] = {} ?>
<?py 	#endif ?>
<?py 	if data['star'] not in index_dict[data['entourage_id']]:?>
<?py 		index_dict[data['entourage_id']][data['star']] = {} ?>
<?py 	#endif ?>
<?py 	index_dict[data['entourage_id']][data['star']][data['grade']] = data['id'] ?>
<?py #endfor ?>

local index_tab = {
<?py for eid in index_dict: ?> 
	[${eid}] = {
	<?py for star in index_dict[eid]: ?> 
		[${star}] = {
		<?py for grade in index_dict[eid][star]: ?> 
			[${grade}] = ${index_dict[eid][star][grade]},
		<?py #endfor ?>
		},
	<?py #endfor ?>
	},
<?py #endfor ?>
}

-- 查找英雄几星几品的技能配置
local function find_data(eid, star, grade)
	local star = index_tab[eid][star]
	if star == nil then return nil end
	local id = star[grade]
	if id ~= nil then
		return data_item[id]
	else
		return nil
	end
end

-- 查找英雄几星几品的技能配置(品质向下查找到0, 找到有技能的则停止)
local function find_data_topdown(eid, star, grade)
	local star = index_tab[eid][star]
	if star == nil then return nil end
	while grade >= 0 do
		local id = star[grade]
		if id ~= nil then
			return data_item[id]
		else
			grade = grade - 1
		end
	end
	return nil
end

return {data = data_item, find_data = find_data, find_data_topdown = find_data_topdown}