# -*- coding: utf-8 -*-
"""
基础遗传算法实现
    Inputs:
        gene_factors:类型为数组，其长度表示遗传基因个数，每个基因的取值范围为：[1, gene_factors[i]].
        init_population_num:初始种群数量
        max_generation:最大迭代次数（即多少代后停止）
        stop_search_num:种群中的最优解不变化多少代后停止
        cross_exchange_num:交叉互换位置个数
        elitism:精英保留概率（%），如果为0表示采用精英机制
        selection_method:选择机制，对应不同的选择算法
        Algorithm: 0 for the brute-force algorithm, or 1 for genetic algorithm，暂时未实现.
        Reset: True to reset the travelling salesman algorithm.
        Run: True to run, or False to pause the travelling salesman algorithm.
        timer_interval: 循环的时间间隔（毫秒，必须大于0）
    Output:
        out_best_result:最优结果
        out_current_population:当前种群数组，传递给适应度计算模块的
"""


__author__ = "xxx"

gh_env = ghenv

gh_env.Component.Name = "基础遗传算法实现"
gh_env.Component.NickName = "GeneticAlgorithm"

gene_factor_list = [int(val) for val in gene_factors]
max_gen_num = max_generation
in_stop_search_num = stop_search_num
in_cross_exchange_num = cross_exchange_num
in_elitism = elitism
use_algorithm = Algorithm
keep_run = Run
is_reset = Reset
loop_interval = max(1, int(timer_interval))
selection_algorithm = int(selection_method)


import Rhino.Geometry as rg
from scriptcontext import sticky
import random
import math
import time
from datetime import datetime
import codecs
import copy


# 获取现在的时间
def now_datetime():
    return datetime.now()


# 普通格式化的时间字符串
def normal_dt_str(time_tuple=None, only_date = False):
    # return time.strftime("%Y-%m-%d %H:%M:%S", t)
    if time_tuple is None:
        time_tuple = now_datetime()
    if only_date:
        return time_tuple.strftime('%Y-%m-%d')
    else:
        return time_tuple.strftime('%Y-%m-%d %H:%M:%S')


def add_log(log):
    with codecs.open("d:/gs_debug_log.log", "a", "utf-8") as fd:
        fd.write(u"%s %s\n\n" % (normal_dt_str(), log))
        fd.flush()


class AsyncExchangeSignal(object):
    """异步数据交换"""
    def __init__(self, wait = True):
        super(AsyncExchangeSignal, self).__init__()
        self.wait     = wait
        self.in_data  = []
        self.out_data = []
        self.current_population = None
        self.signal_num = 0

    def is_wait(self):
        return self.wait

    def set_wait(self, wait):
        self.wait = wait

    def put_in_data(self, data):
        self.in_data.append(data)

    def pop_in_data(self):
        return self.in_data.pop()

    def in_data_empty(self):
        return len(self.in_data) == 0

    def put_out_data(self, data):
        self.out_data.append(data)

    def pop_out_data(self):
        data = self.out_data.pop()
        return data

    def out_data_empty(self):
        return len(self.out_data) == 0


# 将一个列表中的元素顺序打乱
# random.shuffle(arrary)
# 从序列中获取一个随机元素
# random.choice(arrary)


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
    s = sum(weightings)
    w = [float(x)/s for x in weightings]

    t = 0
    for i, v in enumerate(w):
        t += v
        w[i] = t

    c = __in_which_part(random.random(), w)
    try:
        return data[c]
    except IndexError:
        return data[-1]


class GeneticAlgorithm:
    """基础遗传算法"""

    def __init__(self, factors, init_num, generation):
        self.factors = factors
        self.factor_len = len(factors)
        self.init_num = init_num
        self.max_generation = generation
        self.first_population = []
        self.current_population = []
        self.current_fitness = []
        self.current_best_result = None  # 当前最优解
        self.best_no_change_count = 0  # 当前最优解已经有多少代没有变化了
        self.elitism_list = []

        self.best_result = None
        self.count = 0
        self.finished = False

    def init_population(self):
        '''初始化种群'''
        for i in xrange(0, self.init_num):
            self.current_population.append([])
            for j in xrange(0, len(self.factors)):
                self.current_population[i].append(random.randint(1, self.factors[j]))
            self.first_population = self.current_population

    def setup(self):
        """第一次开始时，生成初始种群，和生成一些初始化数据"""
        self.init_population()
        self.population_size = len(self.current_population)

    def cacl_fitness(self):
        """计算当前种群self.current_population中每个个体的适应度"""
        fitness_signal = sticky["fitness_signal"]
        # add_log("fitness_signal.signal_num:%s" % fitness_signal.signal_num)
        if fitness_signal.is_wait():
            if fitness_signal.current_population is None:
                fitness_signal.current_population = self.current_population[:]
                fitness_signal.signal_num = len(fitness_signal.current_population)
                sticky["fitness_signal"] = fitness_signal
                # add_log("signal_num:%s" % fitness_signal.signal_num)
            if len(fitness_signal.current_population) > 0:
                one = fitness_signal.current_population.pop()
                sticky["fitness_signal"] = fitness_signal
                return True, one
            else:
                return True, None
        else:
            fitness_signal.set_wait(True)
            # 获取计算好的当前种群的适应度值数组，然后再清空它
            out_data = fitness_signal.out_data
            # add_log("cacl fitness mod return:%s" % out_data)
            fitness_signal.out_data = []
            fitness_signal.current_population = None
            sticky["fitness_signal"] = fitness_signal
            return False, out_data

    def update_current_best_result(self, new_best):
        '''更新当前最优解，并处理计数'''
        if self.current_best_result != new_best:
            self.current_best_result = new_best
            self.best_no_change_count = 1
        else:
            self.best_no_change_count += 1

    def select_by_fitness(self):
        # 选择机制，包含精英保留处理
        new_populations = []
        size = len(self.current_population)
        add_log("in_elitism:%s" % in_elitism)
        if in_elitism > 0:
            reserve_num = max(1, int(size * in_elitism / 100))
            # 精英保留处理
            arrary = zip(self.current_population, self.current_fitness)
            new_arrary = sorted(arrary, key = lambda tuple: tuple[1], reverse=True)
            reservr_tuple_list = new_arrary[0:reserve_num]
            self.elitism_list = copy.deepcopy(reservr_tuple_list)
            add_log("current elitism_list:%s" % self.elitism_list)
            # self.elitism_list = [t[0] for t in reservr_tuple_list]
            # left = arrary[reserve_num:]
            # current_population = [t[0] for t in left]
            # current_fitness = [t[1] for t in left]

            self.update_current_best_result(reservr_tuple_list[0][1])
        else:
            self.elitism_list = []
            # reserve_num = 0
            # current_population = self.current_population
            # current_fitness = self.current_fitness

            self.update_current_best_result(max(self.current_fitness))

        for x in xrange(0, size):
            val = weighting_choice(self.current_population, self.current_fitness)
            new_populations.append(val)
        return new_populations

    def get_cross_exchange_points(self):
        points = range(1, self.factor_len)
        ret = []
        while len(ret) < in_cross_exchange_num:
            cross_index = random.choice(points)
            ret.append(cross_index)
            points.remove(cross_index)

        return ret

    def cross(self, population):
        '''交叉'''
        children = []
        random.shuffle(population)
        left = len(population)
        while left > 0:
            # 每个个体都是数组，因此这里的个体修改回直接修改其他引用个体的地方的
            father = population.pop()
            mother = population.pop()
            points = self.get_cross_exchange_points()
            for cross_index in points:
                temp = father[cross_index - 1]
                father[cross_index - 1] = mother[cross_index - 1]
                mother[cross_index - 1] = temp

            children.append(father)
            children.append(mother)

            left = left - 2
        return children

    def handle_elitism(self):
        if len(self.elitism_list) == 0:
            return
        best_elitism_fitness = max([t[1] for t in self.elitism_list])
        new_best_fitness = max(self.current_fitness)
        add_log("best_elitism_fitness:%s, new_best_fitness:%s" % (best_elitism_fitness, new_best_fitness))
        if new_best_fitness >= best_elitism_fitness:
            return
        # 新一代的精英不如上一代的精英，则上一代的精英需要保留下来，并替换掉当前最差的个体
        arrary = zip(range(0, len(self.current_fitness)), self.current_fitness)
        for elitism in self.elitism_list:
            min_val = min(arrary, key=lambda x: x[1])
            add_log("index:%s is replace by elitism:%s" % (min_val[0], elitism[0]))
            self.current_population[min_val[0]] = elitism[0]
            self.current_fitness[min_val[0]] = elitism[1]
            arrary.remove(min_val)

    def update(self):
        """进行一次遗传算法的迭代繁衍"""
        global out_current_population
        if self.count >= self.max_generation:
            self.finished = True
            self.best_result = self.current_population
            add_log(u"已达最大迭代次数，停止计算，解：%s" % self.best_result)
            return

        if self.best_no_change_count >= in_stop_search_num:
            self.finished = True
            self.best_result = self.current_population
            add_log(u"最优解已不再变化，停止计算，解：%s" % self.best_result)
            return

        wait, result = self.cacl_fitness()
        # add_log("wait:%s, result:%s" % (wait, result))
        if wait:
            out_current_population = result
            print("wait for fitness signal %s" % self.count)
            # add_log("wait for fitness signal %s" % self.count)
            return
        else:
            out_current_population = None
            add_log("got fitness:%s" % result)
            self.current_fitness = result
        add_log("current_population:%s" % self.current_population)
        add_log("last elitism_list:%s" % self.elitism_list)
        # 处理上一代的精英去留问题
        self.handle_elitism()
        # 淘汰个体，得到剩余的个体参与繁衍
        new_populations = self.select_by_fitness()
        add_log("new_populations:%s" % (new_populations))
        add_log("new elitism_list:%s" % self.elitism_list)
        # 交叉
        children = self.cross(new_populations)
        add_log("new2 elitism_list:%s" % self.elitism_list)
        # children.extend(self.elitism_list)
        add_log("children:%s" % children)
        self.current_population = children
        self.count += 1

    def IsFinished(self):
        return self.finished

    def get_best_result(self):
        return self.best_result


###################################################################################
def update_component():
    """Updates this component, similar to using a Grasshopper timer"""
    # written by Anders Deleuran, andersholdendeleuran.com
    import Grasshopper as gh

    def call_back(e):
        """Defines a callback action"""
        gh_env.Component.ExpireSolution(False)
    # Get the Grasshopper document
    ghDoc = gh_env.Component.OnPingDocument()
    # Schedule this component to expire
    ghDoc.ScheduleSolution(loop_interval, gh.Kernel.GH_Document.GH_ScheduleDelegate(call_back))


def init_global_datas():
    if "fitness_signal" not in sticky.keys():
        sticky["fitness_signal"] = AsyncExchangeSignal()

# ==============================================================================
# ============================= 运行开始 ========================================


# 初始化与其他脚本交互的全局数据
init_global_datas()

if is_reset:
    sticky.pop("my_ga", None)
    sticky.pop("fitness_signal", None)
    gh_env.Component.Message = "Reset"

if keep_run:
    if "my_ga" not in sticky.keys():
        if use_algorithm == 0 or use_algorithm is None:
            ts = GeneticAlgorithm(gene_factor_list, int(init_population_num), int(max_gen_num))
        elif use_algorithm == 1:  # Genetic algorithm
            ts = GeneticAlgorithm(gene_factor_list, int(init_population_num), int(max_gen_num))
        ts.setup()
        sticky["my_ga"] = ts
        update_component()
    else:
        ts = sticky["my_ga"]
        if not ts.IsFinished():
            ts.update()
            update_component()
            gh_env.Component.Message = "Running... count:%s" % (ts.count)
        else:
            out_best_result = ts.get_best_result()
            print("generation:%s\nCompleted, first_population:%s\nbest result:%s" % (ts.count, ts.first_population, out_best_result))
            gh_env.Component.Message = "Completed, best result:%s" % (out_best_result)
        sticky["my_ga"] = ts


else:
    # Pause the travelling salesman algorithm
    if "my_ga" in sticky.keys():
        ts = sticky["my_ga"]
        ts.update()
        sticky["my_ga"] = ts
        gh_env.Component.Message = "Paused"

