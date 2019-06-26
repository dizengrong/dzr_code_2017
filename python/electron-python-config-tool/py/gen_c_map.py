# -*- coding: utf-8 -*-
# 根据unity导出的地图navmesh文件导出对应的服务端c代码地图数据文件
import math
import os
import codecs
import gen_erlang_map
from gen_erlang_map import Face, Line
from common import engine
from tenjin.helpers import *
from tenjin.escaped import *


def start(config_path, map_obj, c_file):
    basename = os.path.basename(c_file)
    name, _ = os.path.splitext(basename)
    [_, _, map_id] = name.split('_')
    point_dict, line_dict, face_dict, from_point, to_point, per_point, divide_dict = gen_erlang_map.parse_obj_file(map_obj)
    if len(point_dict) >= 10000:
        raise IndexError(u'point number >= 10000')
    if len(divide_dict) >= 1000:
        raise IndexError(u'divide number >= 1000')

    line_index_dict, line_arrary = make_line_arrary(line_dict)
    face_index_dict, face_arrary = make_face_arrary(face_dict)
    divide_index_dict, divide_arrary = make_divide_arrary(divide_dict, face_index_dict)
    map_dict = {
        'map_id': map_id,
        'point_dict': point_dict,
        'line_index_dict': line_index_dict,
        'line_arrary': line_arrary,
        'face_arrary': face_arrary,
        'face_index_dict': face_index_dict,
        'from_point': from_point,
        'to_point': to_point,
        'per_point': per_point,
        'divide_arrary': divide_arrary,
        'divide_index_dict': divide_index_dict,
    }
    content = engine.render(os.path.join(config_path, 'data_map_xxx.c.tpl'), map_dict)
    dest = codecs.open(c_file, "w", 'utf-8')
    content = content.replace("\r\n", "\n")
    dest.write(content)
    dest.close()


def make_line_arrary(line_dict):
    line_index_dict = {}
    line_arrary = []
    arrary_index = 0
    for line_index in line_dict:
        p1, p2 = line_index
        index = p1 * 10000 + p2
        line_index_dict[index] = arrary_index
        line_arrary.append(line_dict[line_index])
        arrary_index += 1

    return (line_index_dict, line_arrary)


def make_face_arrary(face_dict):
    face_index_dict = {}
    face_arrary = []
    arrary_index = 0
    for face_index in face_dict:
        index = calc_face_index(face_index)
        face_index_dict[index] = arrary_index
        face_arrary.append(face_dict[face_index])
        arrary_index += 1

    return (face_index_dict, face_arrary)


def make_divide_arrary(divide_dict, face_index_dict):
    divide_index_dict = {}
    divide_arrary = []
    arrary_index = 0
    for divide_index in divide_dict:
        p1, _p2, p3 = divide_index
        index = p1 * 1000 + p3
        divide_index_dict[index] = arrary_index
        face_index_list = []
        for face_index in divide_dict[divide_index]:
            index = calc_face_index(face_index)
            face_index_list.append(str(face_index_dict[index]))
        divide_arrary.append(face_index_list)
        arrary_index += 1

    return (divide_index_dict, divide_arrary)


def calc_face_index(face_index):
    p1, p2, p3 = face_index
    return p1 * 100000 + p2 * 100 + p3

