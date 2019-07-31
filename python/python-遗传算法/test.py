# -*- coding: utf-8 -*-
import random


# 带权重的随机
def __in_which_part(n, w):
    for i, v in enumerate(w):
        if n < v:
            return i
    return len(w) - 1


def weighting_choice(data, weightings):
    '''
        data:输入的数组
        weightings:同等长度的权重数组
    '''
    arrary = zip(data, weightings)
    arrary.sort(key = lambda tuple: tuple[1])
    new_weightings = [t[1] for t in arrary]
    new_weightings.reverse()
    s = sum(new_weightings)
    w = [float(x)/s for x in new_weightings]
    print(w)
    t = 0
    for i, v in enumerate(w):
        t += v
        w[i] = t
    print(w)
    val = random.random()
    c = __in_which_part(val, w)
    try:
        return data[c]
    except IndexError:
        return data[-1]


def my_gen(a, b, c):
    g = (i * 1000 + j * 100 + k for i in range(1, a) for j in range(1, b) for k in range(1, c))
    return g


if __name__ == '__main__':
    for v in my_gen(5000, 8, 9):
        print(v)

