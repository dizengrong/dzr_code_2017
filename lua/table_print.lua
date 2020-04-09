-- @doc 以可读的方式打印table，table的key按字母顺序排列
local table_print = {}

local msg_2_print


local function sort_keys(t)
	local index = {}
	for k in pairs(t) do
		table.insert(index, k)
	end
	table.sort(index, function(a, b) return tostring(a) < tostring(b) end)
	return index
end

local function fomrat_val(v)
	if type(v) == "number" then
		return v
	else
		return ("\"%s\""):format(v)
	end
end

local function show_kv(layer, k, v)
	if k == "__index" then
		return
	end

	local prefix = ""
	for _ = 1, layer do
		prefix = prefix .. "|   "
	end
	local str = prefix .. "|--" .. fomrat_val(k)
	if type(v) == "table" then
		str = str .. (": {%s}"):format(v)
	else
		str = str .. ": " .. fomrat_val(v)
	end
	-- print(str)
	table.insert(msg_2_print, str)
end

local function show_tree_help(layer, t)
	local keys = sort_keys(t)
	local tmp
	for _,k in ipairs(keys) do
		tmp = t[k]
		if type(tmp) == "table" and k ~= "__index" then
			show_kv(layer, k, tmp)
			show_tree_help(layer + 1, tmp)
		else
			show_kv(layer, k, tmp)
		end
	end
end

--------------------------------------------------------------------------------
function table_print:show_tree(t, msg)
	local layer = 0
	local tmp
	local keys = sort_keys(t)
	msg_2_print = {}
	table.insert(msg_2_print, "")
	for _,k in ipairs(keys) do
		tmp = t[k]
		if type(tmp) == "table" and k ~= "__index" then
			show_kv(layer, k, tmp)
			show_tree_help(layer + 1, tmp)
		else
			show_kv(layer, k, tmp)
		end
	end
	print(table.concat(msg_2_print,"\n"))
end


function table_print:show_line(t)
	local keys = sort_keys(t)
	local result = {}
	for _,k in ipairs(keys) do
		table.insert(result, string.format("%s:%s",k,tostring(t[k])))
	end
	print(table.concat(result,"\t"))
end


local t = {
	["addr"] = {
		["province"] = "湖南省",
		["city"] = "长沙",
		["detail"] = {
			["street"] = "麓谷街道",
			["company"] = "caohua",
		},
	},
	["name"] = "dzr",
	["sex"] = "man",
	[1] = {
		["score"] = 99,
		["rank"] = 1
	}
}

local t2 = {
	["role_id"] = 1000,
	["heros"] = {
		id = 8880001,
		lv = 1,
		exp = 0,
		prof_lv = 0,
		quality = 1,
		race_lv = 1,
		type_id = 110,
		attr = {
			defence = 100,
			max_hp = 123,
		},
		callback = show_kv,
	}
}

-- print(table_print:show_tree(t))
-- print(table_print:show_tree(t2))
-- print(table_print:show_line(t))

return table_print
