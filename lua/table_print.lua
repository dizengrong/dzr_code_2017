-- @doc 以可读的方式打印table，table的key按字母顺序排列
local table_print = {}

local function sort_keys(t)
	local index = {}
	for k in pairs(t) do
		table.insert(index, k)
	end
	table.sort(index, function(a, b) return tostring(a) < tostring(b) end)
	return index
end

local function show_kv(layer, k, v)
	prefix = ""
	for _ = 1, layer do
		prefix = prefix .. "|  "
	end
	if v ~= nil then
		str = prefix .. "|--" .. k .. ": " .. tostring(v)
	else
		str = prefix .. "|--" .. k
	end
	print(str)
end

local function show_tree_help(layer, t)
	keys = sort_keys(t)
	local tmp
	for _,k in ipairs(keys) do
		tmp = t[k]
		if type(tmp) == "table" then
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
	keys = sort_keys(t)
	for _,k in ipairs(keys) do
		tmp = t[k]
		if type(tmp) == "table" then
			show_kv(layer, k, nil)
			show_tree_help(layer + 1, tmp)
		else
			show_kv(layer, k, tmp)
		end
	end
end

function table_print:show_line(t)
	keys = sort_keys(t)
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

print(table_print:show_tree(t))
print(table_print:show_line(t))

return table_print
