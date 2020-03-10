-- 生产者协程，负责产生数据（由控制台输入），然后挂起协程，把值传递给过滤器协程
produceFunc = function()
    while true do
        local value = io.read()						-- 等待输入，即生产数据
        print("produce: ", value)
        coroutine.yield(value)   					-- 挂起本生产者协程，返回生产的值
    end
end

-- 过滤器协程，唤醒生产者协程，等待其产生数据，得到数据后，负责把数据放大100倍，然后挂起协程，把值传递给消费者函数
filteFunc = function(p)
    while true do
        local status, value = coroutine.resume(p); 	-- 唤醒生产者协程，直到其返回数据
        value = value *100        					-- 把数据放大100倍
		print("filte: 	", value)
        coroutine.yield(value)						-- 挂起本过滤器协程，返回处理后的值
    end
end

-- 消费者，只是个函数，并非协程，while一直调用，即一直唤醒过滤器协程
consumer = function(f, p)
    while true do
        local status, value = coroutine.resume(f, p);--唤醒过滤器协程，参数是生产者协程
        print("consume: ", value)					-- 打印出得到的值，即消费
    end
end

--备注：
-- 1. 消费者驱动的设计，也就是消费者需要产品时找生产者请求，生产者完成生产后提供给消费者
-- 2. 这里做了中间的过滤器协程，即消费者函数找过滤器协程，过滤器协程找生产者协程，等待其返回数据，再原路返回，传递给消费者函数，while一直循环

-- 生产者协程
producer = coroutine.create(produceFunc)

--过滤器协程
filter = coroutine.create(filteFunc)

-- 消费者函数，传入过滤器协程和生产者协程
consumer(filter, producer)
