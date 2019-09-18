# -*- coding: utf-8 -*-
import re
import operator

# 贪婪模糊匹配


def get_match_weight(regex, items):
    w1 = 0
    w2 = 0
    for item in items:
        match = regex.search(item)
        if match:
            w1 += len(match.group())
            w2 += -match.start()
    return (w1, w2)


# collection为一个字典，其key为要进行比较匹配的字符串，
def fuzzyfinder(user_input, collection):
    suggestions = []
    # pattern = '.*?'.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
    # 这里还是搞成精确匹配
    pattern = ''.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
    regex = re.compile(pattern, re.IGNORECASE)         # Compiles a regex.
    for item in collection:
        # Checks if the current item matches the regex.
        (w1, w2) = get_match_weight(regex, [item] + collection[item])
        if w1 > 0:
            temp = {item: collection[item]}
            suggestions.append((w1, w2, temp))
    if len(suggestions) == 0:
        return {}
    else:
        ret = {}
        for _, _, x in sorted(suggestions, key = operator.itemgetter(0, 1)):
            ret.update(x)
        # 因为这里返回的是字典，所以顺序不太重要了
        return ret


# ==============================================================================
def get_tab_data_match_weight(regex, tab_data):
    w1 = 0
    w2 = 0
    data = [
        tab_data['excle_file'], tab_data['sheet']
    ]
    if 'export_erl' in tab_data:
        data.append(tab_data['export_erl']['tpl'])
    if 'export_lua' in tab_data:
        data.append(tab_data['export_lua']['tpl'])
    if 'export_cs' in tab_data:
        data.append(tab_data['export_cs']['tpl'])
    for item in data:
        match = regex.search(item)
        if match:
            w1 += len(match.group())
            w2 += -match.start()
    return (w1, w2)


# tab_datas为一个字典的数组，其key为要进行比较匹配的字符串，
def fuzzyfinder2(user_input, tab_datas):
    suggestions = []
    # pattern = '.*?'.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
    # 这里还是搞成精确匹配
    pattern = ''.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
    regex = re.compile(pattern, re.IGNORECASE)         # Compiles a regex.
    for item in tab_datas:
        # Checks if the current item matches the regex.
        (w1, w2) = get_tab_data_match_weight(regex, item)
        if w1 > 0:
            suggestions.append((w1, w2, item))
    if len(suggestions) == 0:
        return []
    else:
        ret = []
        for _, _, x in sorted(suggestions, key = operator.itemgetter(0, 1)):
            ret.append(x)
        return ret
