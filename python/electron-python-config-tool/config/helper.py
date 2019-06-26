# -*- coding: utf-8 -*-

def tuple_list_2_dict(tuple_list):
    '''tuple_list:[(k, v)], return:{k:v}'''
    dic = {}
    for t in tuple_list:
       dic[t[0]] = t[1]
    return dic


def dict_2_tuple_list(dic):
    '''dic:{k:v}, return:[(k, v)]'''
    t = []
    for k in dic:
        t.append((k, dic[k]))
    return t


def attr_add(attr1, attr2):
    '''将attr1和attr2相加，key相同则相加 attr:[(k, v)], return:[(k, v)]'''
    dict1 = tuple_list_2_dict(attr1)
    for t in attr2: 
        if t[0] in dict1:
            dict1[t[0]] = dict1[t[0]] + t[1]
        else: 
            dict1[t[0]] = t[1]
    return dict_2_tuple_list(dict1)


def erl_split_items(item_str):
    # 分割字符串，字符串格式为"1,a|2,b|3,c"，分割后格式为：[{1,a},{2,b},{3,c}]
    if item_str.strip() == "":
        return "[]"
    else:
        return "[{" + "}, {".join(item_str.split("|")) + "}]"


def lua_split_items(item_str):
    # 分割字符串，字符串格式为"1,a|2,b|3,c"，分割后格式为：{{1,a},{2,b},{3,c}}
    if item_str.strip() == "":
        return "[]"
    else:
        return "{{" + "}, {".join(item_str.split("|")) + "}}"


