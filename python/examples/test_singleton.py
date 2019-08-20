#-*- encoding=utf-8 -*-

'''
date = 20171127
Singleton pattern
'''
# 经典单例模式的实现


class Singleton(object):
    def __new__(cls, *args, **kwargs):
        if not hasattr(cls, '_instance'):
            org = super(Singleton, cls)
            cls._instance = org.__new__(cls)  # cls,*args,**kwargs)
        return cls._instance


#############################################################
class Singleton2(type):
    def __init__(cls, name, bases, dict):
        super(Singleton2, cls).__init__(name, bases, dict)
        cls._instance = None

    def __call__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super(Singleton2, cls).__call__(*args, **kwargs)
        return cls._instance


class Myclass(object):
    __metaclass__ = Singleton2


one = Myclass()
two = Myclass()

print(id(one))
print(id(two))

###############################################


def singleton3(cls, *args, **kw):
    instances = {}

    def _singleton():
        if cls not in instances:
            instances[cls] = cls(*args, **kw)
        return instances[cls]
    return _singleton


@singleton3
class Myclass2(object):
    a = 1

    def __init__(self, x=0):
        self.x = x


three = Myclass2()
four = Myclass2()

print(id(three))
print(id(four))

#######################################

if __name__ == '__main__':
    class SingleSpam(Singleton):
        def __init__(self, s):
            self.s = s

        def __str__(self):
            return self.s

    s1 = SingleSpam('shiter')
    print(id(s1), s1)
    s2 = SingleSpam('wynshiter')
    print(id(s2), s2)
