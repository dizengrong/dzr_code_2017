# fact.py
import tornado.ioloop
import tornado.web

class FactorialService(object):  # 定义一个阶乘服务对象

    def __init__(self):
        self.cache = {}   # 用字典记录已经计算过的阶乘

    def calc(self, n):
        if n in self.cache:  # 如果有直接返回
            return self.cache[n]
        s = 1
        for i in range(1, n):
            s *= i
        self.cache[n] = s  # 缓存起来
        return s

class FactorialHandler(tornado.web.RequestHandler):

    service = FactorialService()  # new出阶乘服务对象

    def get(self):
        print("recv get request")
        n = int(self.get_argument("n"))  # 获取url的参数值
        self.write(str(self.service.calc(n)))  # 使用阶乘服务

def make_app():
    return tornado.web.Application([
        (r"/fact", FactorialHandler),  # 注册路由
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
