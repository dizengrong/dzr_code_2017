-- 出战孔位开放配置
local ret_data = {
	-- [孔位] = 开放等级
<?py for data in all_data: ?> 
	[${data['position']}] = ${data['lv']},
<?py #endfor ?>
}
return ret_data
