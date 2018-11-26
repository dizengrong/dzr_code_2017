# -*- coding: utf-8 -*-
# 根据unity导出的地图navmesh文件导出对应的服务端erlang地图数据文件
import math
import os

def erl_file_head(mod):
    return '''
-module({}).
-include(\"common.hrl\").
-export([get_point/1,get_line/1,get_face/1,get_divide_info/0,get_divide/1]).

'''.format(mod)


class Face(object):
    """docstring for Face"""
    def __init__(self, p1, p2, p3):
        super(Face, self).__init__()
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        self.mini_point = None
        self.max_point = None


class Line(object):
    """docstring for Line"""
    def __init__(self, p1, p2, face_index):
        super(Line, self).__init__()
        self.p1 = p1
        self.p2 = p2
        self.connect_face1 = face_index
        self.connect_face2 = None


def start(map_obj, erl_file):
    point_dict, line_dict, face_dict = read_obj_file(map_obj)
    remove_no_connect_line(line_dict)
    divide_data = (20, 1, 20)
    (from_point, to_point, per_point, divide_dict) = divide_face(point_dict, face_dict, divide_data)
    write_erl_file(erl_file, point_dict, line_dict, face_dict, from_point, to_point, per_point, divide_dict)


def format_map_point(point):
    return '#map_point{x = %s,y = %s,z = %s}' % (point[0], point[1], point[2])


def format_connect_face(face):
    if face:
        p1, p2, p3 = face
        return '{%s,%s,%s}' % (p1, p2, p3)
    else:
        return 'no'


def write_erl_file(erl_file, point_dict, line_dict, face_dict, from_point, to_point, per_point, divide_dict):
    fd = open(erl_file, 'w')
    mod, _ = os.path.splitext(os.path.basename(erl_file))
    fd.write(erl_file_head(mod))

    # write point
    for point_index in point_dict:
        point = point_dict[point_index]
        point_fun = 'get_point(%s) -> %s;\n' % (point_index, format_map_point(point))
        fd.write(point_fun)
    fd.write('get_point(_)->no.\n\n')

    # write line
    for line_index in line_dict:
        p1, p2 = line_index
        line = line_dict[line_index]
        format_datas = (p1, p2, line.p1, line.p2, format_map_point(line.centre_point), format_connect_face(line.connect_face1), format_connect_face(line.connect_face2))
        line_fun = 'get_line({%s,%s}) -> #map_line{point1 = %s,point2 = %s,centre_point = %s,connect_face1 = %s,connect_face2 = %s};\n' % format_datas
        fd.write(line_fun)
    fd.write('get_line(_)->no.\n\n')

    # write face
    for face_index in face_dict:
        p1, p2, p3 = face_index
        face = face_dict[face_index]
        format_datas = (p1, p2, p3, face.p1, face.p2, face.p3, format_map_point(face.mini_point), format_map_point(face.max_point))
        face_fun = 'get_face({%s,%s,%s}) -> #map_face{point1 = %s,point2 = %s,point3 = %s,mini_point = %s,max_point = %s};\n' % format_datas
        fd.write(face_fun)
    fd.write('get_face(_)->no.\n\n')

    # write divide
    fd.write('get_divide_info()->{%s, %s, %s}.\n\n' % (format_map_point(from_point), format_map_point(to_point), format_map_point(per_point)))
    for divide_index in divide_dict:
        p1, p2, p3 = divide_index
        face_list = divide_dict[divide_index]
        # print(face_list)
        face_list2 = []
        for face_p1, face_p2, face_p3 in face_list:
            face_list2.append('{%s,%s,%s}' % (face_p1, face_p2, face_p3))
        format_datas = (p1, p2, p3, ','.join(face_list2))
        face_fun = 'get_divide({%s,%s,%s}) -> [%s];\n' % format_datas
        fd.write(face_fun)
    fd.write('get_divide(_)->no.\n\n')
    fd.close()



def read_obj_file(map_obj):
    point_index = 1
    point_dict = {}
    line_dict = {}
    face_dict = {}
    fd = open(map_obj, 'r')
    for line in fd.readlines():
        tokens = line.split(' ')
        if tokens[0] == 'v':
            [_, x, y, z] = tokens
            point_dict[point_index] = (-float(x), float(y), float(z))
            point_index += 1
        elif tokens[0] == 'f':
            [_, p1, p2, p3] = tokens
            p1 = int(p1)
            p2 = int(p2)
            p3 = int(p3)
            face = Face(p1, p2, p3)
            face.mini_point = get_min_point(point_dict[face.p3], get_min_point(point_dict[face.p1], point_dict[face.p2]))
            face.max_point  = get_max_point(point_dict[face.p3], get_max_point(point_dict[face.p1], point_dict[face.p2]))
            face_index = tuple(sorted([p1, p2, p3]))
            face_dict[face_index] = face

    for face_index in face_dict:
        face = face_dict[face_index]
        line1 = Line(face.p1, face.p2, face_index)
        line1.centre_point = get_centre_point(point_dict[line1.p1], point_dict[line1.p2])
        line2 = Line(face.p2, face.p3, face_index)
        line2.centre_point = get_centre_point(point_dict[line2.p1], point_dict[line2.p2])
        line3 = Line(face.p1, face.p3, face_index)
        line3.centre_point = get_centre_point(point_dict[line3.p1], point_dict[line3.p2])

        make_line_connect(line1, line_dict)
        make_line_connect(line2, line_dict)
        make_line_connect(line3, line_dict)

    return (point_dict, line_dict, face_dict)


def remove_no_connect_line(line_dict):
    for key in line_dict.keys():
        if not line_dict[key].connect_face1:
            del line_dict[key]


def make_line_connect(line, line_dict):
    line_index = tuple(sorted([line.p1, line.p2]))
    if line_index in line_dict:
        find_line = line_dict[line_index]
        if find_line.connect_face1 == line.connect_face1:
            pass
        elif find_line.connect_face2 == line.connect_face2:
            pass
        elif not find_line.connect_face2:
            find_line.connect_face2 = line.connect_face1
        else:
            print("error:line_has_max_connect_face")
    else:
        line_dict[line_index] = line


def divide_face(point_dict, face_dict, divide_data):
    min_point = (1000000000, 1000000000, 1000000000)
    max_point = (-1000000000, -1000000000, -1000000000)
    for point_index in point_dict:
        point = point_dict[point_index]
        min_point = get_min_point(point, min_point)
        max_point  = get_max_point(point, max_point)

    x_per = (max_point[0] - min_point[0] + 1) / divide_data[0]
    x_min = min_point[0] - 0.5
    x_max = max_point[0] + 0.5

    y_per = (max_point[1] - min_point[1] + 1) / divide_data[1]
    y_min = min_point[1] - 0.5
    y_max = max_point[1] + 0.5

    z_per = (max_point[2] - min_point[2] + 1) / divide_data[2]
    z_min = min_point[2] - 0.5
    z_max = max_point[2] + 0.5

    from_point = (x_min, y_min, z_min)
    to_point = (x_max, y_max, z_max)
    per_point = (x_per, y_per, z_per)

    divide_dict = {}
    for face_index in face_dict:
        face = face_dict[face_index]
        divide_indexs = collect_divide_index(face.mini_point, face.max_point, from_point, to_point, per_point)
        for divide_index in divide_indexs:
            if divide_index in divide_dict:
                divide_dict[divide_index].append(face_index)
            else:
                divide_dict[divide_index] = [face_index]
    return (from_point, to_point, per_point, divide_dict)


def collect_divide_index(mini_point, max_point, from_point, to_point, per_point):
    xs = collect_divide_index_help(mini_point[0], max_point[0], from_point[0], to_point[0], per_point[0])
    ys = collect_divide_index_help(mini_point[1], max_point[1], from_point[1], to_point[1], per_point[1])
    zs = collect_divide_index_help(mini_point[2], max_point[2], from_point[2], to_point[2], per_point[2])
    return [(x, y, z) for x in xs for y in ys for z in zs]


def collect_divide_index_help(MyMini, MyMax, DFrom, DTo, DPer):
    if DPer == 0:
        return [0]
    if DFrom == DTo:
        return [0]
    return collect_divide_index_help2(MyMini, MyMax, DFrom, DTo, DPer, [])


def collect_divide_index_help2(MyMini, MyMax, DFrom, DTo, DPer, ret_list):
    if MyMini + DPer > MyMax and len(ret_list) == 0:
        IndexMinCeil = get_data_index_ceil(MyMini,DFrom,DTo,DPer)
        IndexMinFloor = get_data_index_floor(MyMini,DFrom,DTo,DPer)
        IndexMaxFloor = get_data_index_floor(MyMax,DFrom,DTo,DPer)
        if IndexMinCeil == IndexMinFloor and IndexMinFloor == IndexMaxFloor:
            return [IndexMinCeil]
        elif IndexMinCeil == IndexMinFloor:
            return [IndexMinCeil,IndexMaxFloor]
        else:
            return [IndexMinCeil,IndexMinFloor,IndexMaxFloor]
    elif MyMini + DPer > MyMax:
        IndexMin = get_data_index_floor(MyMini,DFrom,DTo,DPer)
        IndexMax = get_data_index_floor(MyMax,DFrom,DTo,DPer)
        if IndexMin == IndexMax:
            if IndexMax not in ret_list:
                ret_list.append(IndexMax)
        else:
            if IndexMin not in ret_list:
                ret_list.append(IndexMin)
            if IndexMax not in ret_list:
                ret_list.append(IndexMax)
        return ret_list
    elif len(ret_list) == 0:
        IndexMinCeil = get_data_index_ceil(MyMini,DFrom,DTo,DPer)
        IndexMinFloor = get_data_index_floor(MyMini,DFrom,DTo,DPer)
        if IndexMinCeil == IndexMinFloor:
            return collect_divide_index_help2(MyMini + DPer,MyMax,DFrom,DTo,DPer,[IndexMinCeil])
        else:
            return collect_divide_index_help2(MyMini + DPer,MyMax,DFrom,DTo,DPer,[IndexMinCeil,IndexMinFloor])
    else:
        IndexMin = get_data_index_floor(MyMini,DFrom,DTo,DPer)
        if IndexMin not in ret_list:
            ret_list.append(IndexMin)
        return collect_divide_index_help2(MyMini + DPer,MyMax,DFrom,DTo,DPer,ret_list)


def get_data_index_ceil(Data,From,_To,Per):
    if Per == 0:
        return 0
    if Per <= 0.000009:
        return 0
    Value = math.ceil((Data - From) / Per) - 1
    return max(0, Value)


def get_data_index_floor(Data,From,_To,Per):
    if Per == 0:
        return 0
    if Per <= 0.000009:
        return 0
    return math.floor((Data - From) / Per)


def get_min_point(p1, p2):
    return (min(p1[0], p2[0]), min(p1[1], p2[1]), min(p1[2], p2[2]))


def get_max_point(p1, p2):
    return (max(p1[0], p2[0]), max(p1[1], p2[1]), max(p1[2], p2[2]))


def get_centre_point(p1, p2):
    return ((p1[0] + p2[0])/2, (p1[1] + p2[1])/2, (p1[2] + p2[2])/2)
