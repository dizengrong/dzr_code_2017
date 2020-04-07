local reader = {}


local table_print = require("table_print")

local function unpack_t_hero_heros(m)
    return {1,2,3}
end


local function reader_t_hero(m)
    m.heros = unpack_t_hero_heros(m.heros)
    m.name = "ddddd"
end


local all_user_define_reader = {
	t_hero = reader_t_hero
}


function reader.read(tab_name, data)
	local func = all_user_define_reader[tab_name]
	if func ~= nil then
		func(data)
	end
end


local data = {
	id = 1000,
	heros = {1,1,1}
}

table_print:show_tree(data)
print(table.unpack(data))

G_reader = {}
setmetatable(G_reader, {__index = reader})

table_print:show_tree(data)
G_reader.read("t_hero", data)
table_print:show_tree(data)
