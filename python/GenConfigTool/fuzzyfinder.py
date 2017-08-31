# -*- coding: utf-8 -*-
import re

# 贪婪模糊匹配
# collection为一个字典，其key为要进行比较匹配的字符串，


def get_match_weight(regex, items):
    w1 = 0
    w2 = 0
    for item in items:
        match = regex.search(item)
        if match:
            w1 += len(match.group())
            w2 += -match.start()
    return (w1, w2)


def fuzzyfinder(user_input, collection):
    suggestions = []
    pattern = '.*?'.join(user_input)    # Converts 'djm' to 'd.*?j.*?m'
    regex = re.compile(pattern)         # Compiles a regex.
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
        for _, _, x in sorted(suggestions):
            ret.update(x)
        # 因为这里返回的是字典，所以顺序不太重要了
        return ret
