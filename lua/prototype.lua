-- Object为所有对象的上级
Object = {}

-- 创建现有对象副本
function Object:clone()
    local object = {}

    -- 复制表元素
    for k, v in pairs(self) do
        object[k] = v
    end

    -- 设定元表: 指定向自身`转发`
    setmetatable(object, { __index = self })

    return object
end

-- 基于类的编程
function Object:new(...)
    local object = {}

    -- 设定元表: 指定向自身`转发`
    setmetatable(object, { __index = self })

    -- 初始化
    object:init(...)

    return object
end

-- 初始化实例
function Object:init(...)
    -- 默认不进行任何操作
end

Class = Object:new()
