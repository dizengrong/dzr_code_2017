<?py id_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	id_dict[data['id']] = data['sort'] ?>
<?py #endfor ?>
<?py type_dict = {} ?>
<?py for data in all_data: ?> 
<?py 	if id_dict[data['id']] not in type_dict: ?>
<?py 		type_dict[id_dict[data['id']]] = [] ?>
<?py 	#endif ?>
<?py 	type_dict[id_dict[data['id']]].append('{'+data['cost']+'}') ?>
<?py #endfor ?>
local buyTypeIdList = 
{
<?py for sort in type_dict: ?> 
	[${sort}] = ${as_escaped(str(type_dict[sort]).replace('[', '{').replace(']', '}').replace('\'', ''))},
<?py #endfor ?>
}

-- 获取某个类型具体的购买次数数据
local function find_data( _type,_buynum)
	if _buynum>#buyTypeIdList[_type] then
		_buynum = #buyTypeIdList[_type];
	end
	local data = buyTypeIdList[_type][_buynum];
	return data;
end	

return {FindData = find_data}