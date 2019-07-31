# -*- coding: utf-8 -*-
"""
基础遗传算法实现
    Inputs:
        best_val_type:最优值类型，1：表示最大值为最优，2：表示最小值为最优
        gene_factors:类型为数组，其长度表示遗传基因个数，每个基因的取值范围为：[1, gene_factors[i]].
        init_population_num:初始种群数量
        max_generation:最大迭代次数（即多少代后停止）
        stop_search_num:种群中的最优解不变化多少代后停止
        cross_rate:交叉概率(%)
        cross_exchange_num:交叉互换位置个数
        elitism:精英保留比例（%），如果为0表示不采用精英机制
        selection_method:选择机制，对应不同的选择算法
        mutation_genetic_num: 个体中变异的基因个数
        mutation_rate: 变异的千分比概率
        log_file_path: 日志文件路径
        fitness_scale：适应度动态标定伊布西龙值
        Algorithm: 0 for the brute-force algorithm, or 1 for genetic algorithm.
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

in_best_val_type = best_val_type
gene_factor_list = [int(val) for val in gene_factors]
max_gen_num = max_generation
in_stop_search_num = stop_search_num
in_cross_rate = cross_rate
in_cross_exchange_num = cross_exchange_num
in_elitism = elitism
in_mutation_genetic_num = mutation_genetic_num
in_mutation_rate = mutation_rate
in_log_file_path = log_file_path
in_fitness_scale = fitness_scale
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
    with codecs.open(in_log_file_path, "a", "utf-8") as fd:
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


def weighting_choice(data, weightings, reverse=False):
    '''
        data:输入的数组
        weightings:同等长度的权重数组
        reverse:为True表示权重大的反而被选中的概率低
    '''
    if reverse:
        arrary = zip(data, weightings)
        arrary.sort(key = lambda tuple: tuple[1])
        new_weightings = [t[1] for t in arrary]
        new_weightings.reverse()
        s = sum(new_weightings)
        w = [float(x)/s for x in new_weightings]
    else:
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
        self.init_num = 2*init_num
        self.max_generation = generation
        self.first_population = []
        self.current_population = []
        self.current_fitness = []
        self.current_best_result = None  # 当前最优解
        self.best_no_change_count = 0  # 当前最优解已经有多少代没有变化了
        self.elitism_list = []
        self.saved_cacl_fitness = {}  # 保存上一次计算获得的每个个体的适应度：{个体:适应度}

        self.best_result = None
        self.count = 1
        self.finished = False
        self.last_fitness_scale = 1

    def init_population(self):
        '''初始化种群'''
        for i in xrange(0, self.init_num):
            self.current_population.append([])
            for j in xrange(0, len(self.factors)):
                self.current_population[i].append(random.randint(1, self.factors[j]))
            self.first_population = copy.deepcopy(self.current_population)

    def setup(self):
        """第一次开始时，生成初始种群，和生成一些初始化数据"""
        self.init_population()
        self.population_size = len(self.current_population)

    def split_population_by_fitness_status(self):
        self.cacled_list = []
        self.no_cacled_list = []
        for i in xrange(0, len(self.current_population)):
            key = tuple(self.current_population[i])
            if key in self.saved_cacl_fitness:
                self.cacled_list.append((i, self.current_population[i]))
            else:
                self.no_cacled_list.append((i, self.current_population[i]))

    def cacl_fitness(self):
        """计算当前种群self.current_population中每个个体的适应度"""
        fitness_signal = sticky["fitness_signal"]
        # add_log("fitness_signal.signal_num:%s" % fitness_signal.signal_num)
        if fitness_signal.is_wait():
            if fitness_signal.current_population is None:
                self.split_population_by_fitness_status()
                add_log(u"不需要计算的个体为：%s" % self.cacled_list)
                if len(self.no_cacled_list) == 0:
                    out_data = []
                    for i, individual in self.cacled_list:
                        key = tuple(individual)
                        out_data.append(self.saved_cacl_fitness[key])
                    return False, out_data
                fitness_signal.current_population = [copy.deepcopy(ind[1]) for ind in self.no_cacled_list]
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
            got_out_data = fitness_signal.out_data
            out_data = range(0, len(self.current_population))
            for i in xrange(0, len(got_out_data)):
                out_data[self.no_cacled_list[i][0]] = got_out_data[i]
            for j in xrange(0, len(self.cacled_list)):
                key = tuple(self.cacled_list[j][1])
                out_data[self.cacled_list[j][0]] = self.saved_cacl_fitness[key]
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
        reserve_num = int(size * in_elitism / 100)
        arrary = zip(self.current_population, self.current_fitness)
        if in_best_val_type == 1:
            new_arrary = sorted(arrary, key = lambda t: t[1], reverse=True)
        else:
            new_arrary = sorted(arrary, key = lambda t: t[1], reverse=False)
        self.update_current_best_result(new_arrary[0])
        if reserve_num > 0:
            # 精英保留处理
            reservr_tuple_list = new_arrary[0:reserve_num]
            self.elitism_list = copy.deepcopy(reservr_tuple_list)
            add_log("current elitism_list:%s" % self.elitism_list)
        else:
            self.elitism_list = []

        # 采用权重扩大法
        if in_best_val_type == 1:
            min_w = min(self.current_fitness)
            weightings = [w - min_w for w in self.current_fitness]
        else:
            max_w = max(self.current_fitness)
            weightings = [max_w - w for w in self.current_fitness]
        # 计算动态标定值
        if in_fitness_scale > 0:
            self.last_fitness_scale = self.last_fitness_scale * in_fitness_scale
            for i in xrange(0, len(weightings)):
                # if weightings[i] < 0.000001:
                weightings[i] += self.last_fitness_scale
        add_log("轮盘赌使用的适应度数组：%s" % weightings)
        for x in xrange(0, size):
            if in_best_val_type == 1:
                val = weighting_choice(self.current_population, weightings)
            else:
                val = weighting_choice(self.current_population, weightings, True)
            new_populations.append(copy.deepcopy(val))
        return new_populations

    def get_change_points(self, change_num):
        points = range(0, self.factor_len)
        ret = []
        while len(ret) < change_num:
            cross_index = random.choice(points)
            ret.append(cross_index)
            points.remove(cross_index)

        return ret

    def cross(self, population):
        '''交叉'''
        children = []
        random.shuffle(population)
        left = len(population)
        log = u"\n============================== 交叉开始 ==============================\n"
        while left > 0:
            # 每个个体都是数组，因此这里的个体修改回直接修改其他引用个体的地方的
            father = population.pop()
            mother = population.pop()
            father0 = copy.deepcopy(father)
            mother0 = copy.deepcopy(mother)
            if random.randint(1, 100) <= in_cross_rate:
                points = self.get_change_points(in_cross_exchange_num)
                for cross_index in points:
                    temp = father[cross_index]
                    father[cross_index] = mother[cross_index]
                    mother[cross_index] = temp
                log += u"%s 与 %s 交叉，交叉点：%s，后代：%s %s\n" % (father0, mother0, points, father, mother)
            children.append(father)
            children.append(mother)

            left = left - 2
        log += u"============================== 交叉完成 =============================="
        add_log(log)
        return children

    def mutation(self, population):
        '''变异'''
        for individual in population:
            if random.randint(1, 1000) > in_mutation_rate:
                continue
            points = self.get_change_points(in_mutation_genetic_num)
            for pos in points:
                new_gene = random.randint(1, self.factors[pos])
                add_log(u"产生变异，个体：%s, 位置：%s, 变异为:%s" % (individual, pos + 1, new_gene))
                individual[pos] = new_gene

    def handle_elitism(self):
        if len(self.elitism_list) == 0:
            return
        if in_best_val_type == 1:
            best_elitism_fitness = max([t[1] for t in self.elitism_list])
            new_best_fitness = max(self.current_fitness)
            add_log("best_elitism_fitness:%s, new_best_fitness:%s" % (best_elitism_fitness, new_best_fitness))
            if new_best_fitness + 0.000001 >= best_elitism_fitness:
                return
        else:
            best_elitism_fitness = min([t[1] for t in self.elitism_list])
            new_best_fitness = min(self.current_fitness)
            add_log("best_elitism_fitness:%s, new_best_fitness:%s" % (best_elitism_fitness, new_best_fitness))
            if new_best_fitness - 0.000001 < best_elitism_fitness:
                return

        # 新一代的精英不如上一代的精英，则上一代的精英需要保留下来，并替换掉当前最差的个体
        arrary = zip(range(0, len(self.current_fitness)), self.current_fitness)
        for elitism in self.elitism_list:
            if in_best_val_type == 1:
                min_val = min(arrary, key=lambda x: x[1])
            else:
                min_val = max(arrary, key=lambda x: x[1])
            add_log(u"精英替换，差个体:%s is replace by elitism:%s" % (self.current_population[min_val[0]], elitism[0]))
            self.current_population[min_val[0]] = elitism[0]
            self.current_fitness[min_val[0]] = elitism[1]
            arrary.remove(min_val)

    def save_last_fitness(self, population, fitness):
        dic = {}
        for i in xrange(0, len(population)):
            key = tuple(population[i])
            dic[key] = fitness[i]
        self.saved_cacl_fitness = dic
        add_log(u"保存本次计算所得的适应度:%s" % self.saved_cacl_fitness)

    def update(self):
        """进行一次遗传算法的迭代繁衍"""
        global out_current_population
        wait, result = self.cacl_fitness()
        # add_log("wait:%s, result:%s" % (wait, result))
        if wait:
            out_current_population = result
            print("wait for fitness signal %s, current elitism:%s" % (self.count, self.elitism_list))
            return
        else:
            out_current_population = None
            add_log("got fitness:%s" % result)
            self.current_fitness = result
            self.save_last_fitness(self.current_population, self.current_fitness)
        add_log(u"============================== 第%s代 ==============================" % self.count)
        add_log(u"当前种群:%s" % self.current_population)
        # 处理上一代的精英去留问题
        self.handle_elitism()

        # ================================== 停止处理 ==================================
        if self.count >= self.max_generation:
            self.finished = True
            self.best_result = self.current_population
            add_log(u"已达最大迭代次数，停止计算，得到种群：%s" % self.best_result)
            add_log(u"最优解为：%s，适应度值为：%s" % (self.current_best_result[0], self.current_best_result[1]))
            return

        if self.best_no_change_count >= in_stop_search_num:
            self.finished = True
            self.best_result = self.current_population
            add_log(u"最优解已不再变化，停止计算，得到种群：%s" % self.best_result)
            add_log(u"最优解为：%s，适应度值为：%s" % (self.current_best_result[0], self.current_best_result[1]))
            return
        # ================================== 停止处理 ==================================

        # 淘汰个体，得到剩余的个体参与繁衍
        new_populations = self.select_by_fitness()
        add_log(u"选择后得到种群:%s" % (new_populations))
        # 交叉
        children = self.cross(new_populations)
        add_log("after cross children:%s" % children)
        # 变异
        self.mutation(children)
        add_log("after mutation children:%s" % children)
        self.current_population = children
        self.count += 1

    def IsFinished(self):
        return self.finished

    def get_best_result(self):
        return self.current_best_result


class GABruteForce:
    """蛮力算法"""
    def __init__(self, factors):
        self.factors = factors
        self.current_population = []
        self.best_result = []
        self.finished = False
        self.count = 1

    def setup(self):
        self.permutations = 1
        for f in self.factors:
            self.permutations = self.permutations * f
        add_log("total times:%s" % (self.permutations))
        size = len(self.factors)
        if size == 2:
            self.iter = ([i1, i2] for i1 in range(1, self.factors[0] + 1)
                                  for i2 in range(1, self.factors[1] + 1)
                        )
        elif size == 3:
            self.iter = ([i1, i2, i3] for i1 in range(1, self.factors[0] + 1)
                                      for i2 in range(1, self.factors[1] + 1)
                                      for i3 in range(1, self.factors[2] + 1)
                        )
        elif size == 4:
            self.iter = ([i1, i2, i3, i4] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                        )
        elif size == 5:
            self.iter = ([i1, i2, i3, i4, i5] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                                          for i5 in range(1, self.factors[4] + 1)
                        )
        elif size == 6:
            self.iter = ([i1, i2, i3, i4, i5, i6] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                                          for i5 in range(1, self.factors[4] + 1)
                                          for i6 in range(1, self.factors[5] + 1)
                        )
        elif size == 7:
            self.iter = ([i1, i2, i3, i4, i5, i6, i7] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                                          for i5 in range(1, self.factors[4] + 1)
                                          for i6 in range(1, self.factors[5] + 1)
                                          for i7 in range(1, self.factors[6] + 1)
                        )
        elif size == 8:
            self.iter = ([i1, i2, i3, i4, i5, i6, i7, i8] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                                          for i5 in range(1, self.factors[4] + 1)
                                          for i6 in range(1, self.factors[5] + 1)
                                          for i7 in range(1, self.factors[6] + 1)
                                          for i8 in range(1, self.factors[7] + 1)
                        )
        elif size == 9:
            self.iter = ([i1, i2, i3, i4, i5, i6, i7, i8, i9] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                                          for i5 in range(1, self.factors[4] + 1)
                                          for i6 in range(1, self.factors[5] + 1)
                                          for i7 in range(1, self.factors[6] + 1)
                                          for i8 in range(1, self.factors[7] + 1)
                                          for i9 in range(1, self.factors[8] + 1)
                        )
        elif size == 19:
            self.iter = ([i1, i2, i3, i4, i5, i6, i7, i8, i9, i10] for i1 in range(1, self.factors[0] + 1)
                                          for i2 in range(1, self.factors[1] + 1)
                                          for i3 in range(1, self.factors[2] + 1)
                                          for i4 in range(1, self.factors[3] + 1)
                                          for i5 in range(1, self.factors[4] + 1)
                                          for i6 in range(1, self.factors[5] + 1)
                                          for i7 in range(1, self.factors[6] + 1)
                                          for i8 in range(1, self.factors[7] + 1)
                                          for i9 in range(1, self.factors[8] + 1)
                                          for i10 in range(1, self.factors[9] + 1)
                        )
        self.current_population = [next(self.iter)]

    def update(self):
        global out_current_population
        wait, result = self.cacl_fitness()

        if wait:
            out_current_population = result
            print("wait for fitness signal %s" % (self.count))
            # add_log("wait for fitness signal %s" % self.count)
            return
        else:
            out_current_population = None
            add_log("count:%s got fitness:%s" % (self.count, result))
            # add_log("current_population:%s, result:%s" % (self.current_population, result))
            if len(self.best_result) == 0:
                self.best_result = [(self.current_population[0], result[0])]
            else:
                if in_best_val_type == 1:
                    min_val = min(self.best_result, key=lambda x: x[1])
                    if result[0] + 0.000001 > min_val[1]:  # 比最好的结果里的最差个体要好，则替换它
                        self.best_result.remove(min_val)
                        self.best_result.append((self.current_population[0], result[0]))
                else:
                    min_val = max(self.best_result, key=lambda x: x[1])
                    if result[0] < min_val[1] - 0.000001:  # 比最好的结果里的最差个体要好，则替换它
                        self.best_result.remove(min_val)
                        self.best_result.append((self.current_population[0], result[0]))

            self.count += 1
        # ======================================================================
        # ======================================================================
        if self.count > self.permutations:
            self.count = self.permutations
            self.finished = True
            return
        self.current_population = [next(self.iter)]

    def cacl_fitness(self):
        fitness_signal = sticky["fitness_signal"]
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

    def IsFinished(self):
        return self.finished

    def get_best_result(self):
        return self.best_result[0]


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
        elif use_algorithm == 1:
            ts = GABruteForce(gene_factor_list)
        ts.setup()
        sticky["my_ga"] = ts
        update_component()
    else:
        ts = sticky["my_ga"]
        if not ts.IsFinished():
            ts.update()
            update_component()
            if use_algorithm == 0:
                gh_env.Component.Message = "Running... count:%s" % (ts.count)
            else:
                gh_env.Component.Message = "Running... count:%.1f%%" % (ts.count / ts.permutations * 100)
        else:
            out_best_result = ts.get_best_result()
            add_log("count:%s out_best_result:%s" % (ts.count, out_best_result))
            if use_algorithm == 0:
                print("generation:%s\nCompleted, first_population:%s\nbest result:%s %s" % (ts.count, ts.first_population, out_best_result[0], out_best_result[1]))
            else:
                print("generation:%s\nCompleted, best result:%s %s" % (ts.count, out_best_result[0], out_best_result[1]))
            gh_env.Component.Message = "Completed, best result:%s %s" % (out_best_result[0], out_best_result[1])
        sticky["my_ga"] = ts


else:
    # Pause the travelling salesman algorithm
    if "my_ga" in sticky.keys():
        ts = sticky["my_ga"]
        ts.update()
        sticky["my_ga"] = ts
        gh_env.Component.Message = "Paused"

