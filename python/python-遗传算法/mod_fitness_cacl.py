"""
适应度计算模块
    Inputs:
        genetic: 基因，为一个数组
    Output:
        out_fitness:得到的适应度值
"""

__author__ = "xxx"

gh_env = ghenv

gh_env.Component.Name = "适应度计算模块"
gh_env.Component.NickName = "适应度计算模块"

if genetic[0] is None:
    in_genetic = None
else:
    in_genetic = genetic


# ==============================================================================
# ============================= 运行开始 ========================================
sum_val = None
if in_genetic is not None:
    sum_val = 0
    for g in in_genetic:
        sum_val += g

out_fitness = sum_val
