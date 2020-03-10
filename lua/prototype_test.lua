require("prototype")

-- Point类定义
Point = Class:new()
function Point:init(x, y)
    self.x = x
    self.y = y
end

function Point:magnitude()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

-- 对象定义
point = Point:new(3, 4)
print(point:magnitude())

-- 继承: Point3D定义
Point3D = Point:clone()
function Point3D:init(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function Point3D:magnitude()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

p3 = Point3D:new(1, 2, 3)
print(p3:magnitude())

-- 创建p3副本
ap3 = p3:clone()
print(ap3.x, ap3.y, ap3.z)
