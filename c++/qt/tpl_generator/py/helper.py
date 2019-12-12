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
        return "[{" + "}, {".join([s for s in item_str.split("|") if s != '']) + "}]"


def lua_split_items(item_str):
    # 分割字符串，字符串格式为"1,a|2,b|3,c"，分割后格式为：{{1,a},{2,b},{3,c}}
    if item_str.strip() == "":
        return "{}"
    else:
        return "{{" + "}, {".join([s for s in item_str.split("|") if s != '']) + "}}"


def lua_split_attrs(attr_str):
    # 分割属性字符串，字符串格式为"1,a|2,b|3,c"，分割后格式为：{[1]=a,[2]=b,[3]=c}
    if attr_str.strip() == "":
        return "{}"
    else:
        return "{" + ", ".join(['[' + item.replace(',', '] = ') for item in attr_str.split("|")]) + "}"


# 根据一个字段获取一个其他字段的方法，可以生成形如:get_data(Id) -> [Val];
# 返回一个字典
def select_one_field(datas, index_field, index_result):
   ret_list = {}
   for data in datas:
       if data[index_field] in ret_list:
           ret_list[data[index_field]].append(data[index_result])
       else:
           ret_list[data[index_field]] = [data[index_result]]
   return ret_list

# 根据多个字段获取多个其他字段的方法，可以生成形如:get_data(Id1, Id2) -> [{Val1, Val2}];
# 返回一个字典
def select_multiple_field(datas, select_indexs, result_indexs):
   ret_list = {}
   for data in datas:
       key = tuple([data[i] for i in select_indexs])
       result = [data[i] for i in result_indexs]
       if key in ret_list:
           ret_list[key].append(result)
       else:
           ret_list[key] = [result]
   return ret_list


# 返回：[{Color, Weight}]
def erl_color_weights(weightsStr, colors = [1,2,3,4,5,6]):
  tuple_list = list(zip(colors, weightsStr.split(',')))
  color_weights = ["%s,%s" % (c,w) for (c, w) in tuple_list]
  return "[{" + "}, {".join(color_weights) + "}]"

# 返回：[{material, Weight}]
def erl_material_weights(weightsStr, material = [1,2,3,4,5]):
  tuple_list = list(zip(material, weightsStr.split(',')))
  material_weights = ["%s,%s" % (c,w) for (c, w) in tuple_list]
  return "[{" + "}, {".join(material_weights) + "}]"


# 将一个python列表转为erlang中的tuple
def list_2_erl_tuple(l):
  l = [str(d) for d in l]
  return "{" + ", ".join(l) + "}"


# 将python的tuple转为erlang中的tuple，如：(1,2,3) ---> {1,2,3}
def py_tuple_2_erl_tuple(l):
  l = [str(d) for d in l]
  return "{" + ", ".join(l) + "}"


# 将python的tuple_list转为erlang中的tuple_list，如：[(1,a),(2,b)] ---> [{1,a},{2,b}]
def py_tuple_list_2_erl(tuple_list):
  erl_list = [py_tuple_2_erl_tuple(t) for t in tuple_list]
  return "[" + ", ".join(erl_list) + "]"
