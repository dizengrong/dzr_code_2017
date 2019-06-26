<?py def split_items(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{{" + "},{".join(item_str.split("|")) + "}}" ?>
<?py 	#endif ?>
<?py #enddef ?>

<?py def split_section(item_str):?>
<?py 	if item_str.strip() == "":?>
<?py 		return "{}" ?>
<?py 	else: ?>
<?py 		return "{"+item_str+"}"?>
<?py 	#endif ?>
<?py #enddef ?>

local data_item = {
<?py  for data in all_daily_data: ?>
		[${data["id"]}]= {
			sort = ${data["sort"]},
			rankLevel = ${data["rankLevel"]},
			rewardList = ${split_items(data["rewardList"])},
			section = ${split_section(data['section'])},
	    },
<?py  #endfor?>
}
local function find_reward(sort,rank)
	local max_rank
	local min_rank
	local isTrue
	for k,v in pairs(data_item) do
		 if v.sort ~= sort then
		 	break
		 end
		 if rank>=v.section[1] and rank<=v.rankLevel then
		  	return v.rewardList
		 end
	end
	return nil	 
end 

local function find_list(sort)
	local index = 1
	local itemTable={}
	for k,v in pairs(data_item) do
		 if v.sort== sort then
		 	itemTable[index]=v
		 	index=index+1
		 end	 
	end
	table.sort( itemTable, function(data1,data2 )
		return data1.rankLevel < data2.rankLevel
	end )
	return itemTable
end


return {data=data_item,find_reward=find_reward,find_list=find_list}
