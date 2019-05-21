"""
适应度计算结果收集模块
    Inputs:
        val: 输入的一个适应度值，对应于一个个体的适应度
    Output:
        out_fitness_results: 当前得到的适应度数组
"""

__author__ = "xxx"

gh_env = ghenv

gh_env.Component.Name = "适应度计算结果收集模块"
gh_env.Component.NickName = "适应度计算结果收集模块"

one_fitness_val = val

from scriptcontext import sticky
from datetime import datetime
import codecs


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
    with codecs.open("d:/gs_log.log", "a", "utf-8") as fd:
        fd.write(u"%s %s\n\n" % (normal_dt_str(), log))
        fd.flush()


# ==============================================================================
# ============================= 运行开始 ========================================

if "fitness_signal" in sticky.keys() and one_fitness_val is not None:
    signal = sticky["fitness_signal"]
    signal.out_data.append(one_fitness_val)
    out_fitness_results = signal.out_data
    if len(signal.out_data) >= signal.signal_num:
        signal.out_data.reverse()
        signal.set_wait(False)
        # add_log("collect fitness finished, return:%s" % out_fitness_results)
    sticky["fitness_signal"] = signal
else:
    add_log("error:signal is not ready")
