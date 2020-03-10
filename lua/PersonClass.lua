------------------------------------ Person ------------------------------------
Person={}

function Person:new(p)
    local obj = p
    if (obj == nil) then
        obj = {name="ChenHao", age=37, handsome=true}
    end
    self.__index = self
    return setmetatable(obj, self)

end

function Person:toString()
    return self.name .." : ".. self.age .." : ".. (self.handsome and "handsome" or "ugly")
end


------------------------------------ Student -----------------------------------
Student = Person:new()

function Student:new()
    newObj = {year = 2013}
    self.__index = self
    return setmetatable(newObj, self)
end

function Student:toString()
    return "Student : ".. self.year.." : " .. self.name
end

------------------------------------- test -------------------------------------
me = Person:new()
print(me:toString())
kf = Person:new{name="King's fucking", age=70, handsome=false}
print(kf:toString())


me = Student:new()
print(me:toString())
