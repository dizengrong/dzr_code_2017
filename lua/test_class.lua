--@param string classname 类名
--@param [mixed super] 父类或者创建对象实例的函数
function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

table_print = require("table_print")


G_PlayerHero = {
    -- data = {
    --     name = "",
    --     level = 1,
    -- }
}


local PlayerHero = class("PlayerHero", G_PlayerHero) --玩家英雄逻辑


function PlayerHero:ctor(type_id, name)
    self.type_id = type_id
    self.data = {name = name}
end

hero1 = PlayerHero.new(1, "dzr")
hero2 = PlayerHero.new(2, "nnn")

-- hero1.data.name = "dzr"
-- hero2.data.name = "mmmm"


table_print:show_tree(hero1)
table_print:show_tree(hero2)

