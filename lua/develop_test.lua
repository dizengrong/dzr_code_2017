-- @doc 开发时改变会热更新的脚步文件，用于测试的，
-- 把这个文件放到某个单独的目录里去，比如：develop_test
-- 每个测试文件require时会返回一个对象，对象里包含一个Test方法，用于执行测试代码的（非单元测试）
-- 另外这里可以扩展，加入lua的单元测试：lunit


DevelopTest = DevelopTest or {}


function DevelopTest:GetNeedReloadFiles(from, to)
	-- todo:获取目录里的测试代码文件，且修改时间位于区间：[from, to)
	local t = {}
	return t
end


-- 该循环每秒调用一次
function DevelopTest:OnLoop(now)
	for _,mod in ipairs(self:GetNeedReloadFiles(self.last_time, now)) do
		print(("reload module:%s and execute its test function"):format(mod))
		package.loaded[mod] = nil
		local m = require(mod)
		m:Test()
	end
	self.last_time = now
end


