<?py page_dict = {} ?>
<?py for data in all_pageJump_data: ?> 
<?py 	page_dict[data['id']] = data ?>
<?py #endfor ?>

local data_item = {
<?py for page in all_page_data: ?> 
	[${page['type']}] = 
	{
		jump_id = {
<?py 	for id in page['jump_id'].split(','): ?> 
			{
				name = "${page_dict[int(id)]['name']}",
				icon= ${as_escaped("{\"" + "\",\"".join(page_dict[int(id)]['icon'].split("|")) + "\"}")},
				lua_script= "${page_dict[int(id)]['lua_script']}",
				parameter = "${page_dict[int(id)]['parameter']}",
				func_id = "${page_dict[int(id)]['func_id']}",
			},
<?py 	#endfor ?>
		},
	},
<?py #endfor ?>
}
return data_item