# -*- coding: utf-8 -*-
'''
注意本程序使用的第三方库版本号：
'''

from __future__ import print_function
import sys
import os
import xlrd
from common import *
import codecs
import util
import traceback
from tenjin.helpers import *
from tenjin.escaped import *
import json
import time
import gen_erlang_map
import gen_c_map
import gen_mutil_lang
import fuzzyfinder
from xml.dom import minidom
import threading
import helper


def excel_cell_value_format(value):
    if isinstance(value, float):
        if int(value) == value:
            return int(value)
        else:
            return value
    elif isinstance(value, str):
        try:
            return int(value)
        except Exception:
            try:
                return float(value)
            except Exception:
                return as_escaped(value)
    else:
        try:
            return int(value)
        except Exception:
            return as_escaped(value)


def add_log(log):
    # with codecs.open("python_log.log", "a", "utf-8") as fd:
    with open("python_log.log", "a", encoding="utf-8") as fd:
        fd.write(u"%s %s\n\n" % (util.normal_dt_str(), log))
        fd.flush()


def xml_2_json(xml_file, to_json_file):
    '''将老的xml配置文件转为json格式的文件'''
    doc = minidom.parse(xml_file)
    root = doc.documentElement
    dict_list = []
    for node in get_xmlnode(root, 'file'):
        excle_file = get_attrvalue(node, 'excle_file')
        data_dict = {"excle_file": excle_file}
        export_list = []
        for node2 in get_xmlnode(node, 'export'):
            tpl_dict = {"tpl": get_attrvalue(node2, 'tpl')}

            datas = []
            for node3 in get_xmlnode(node2, 'dict'):
                d = {}
                d['data_key'] = get_attrvalue(node3, 'data_key')
                d['sheet'] = get_attrvalue(node3, 'sheet')
                d['col_start'] = int(get_attrvalue(node3, 'col_start'))
                d['col_end'] = int(get_attrvalue(node3, 'col_end'))
                d['begin_row'] = int(get_attrvalue(node3, 'begin_row'))
                d['sort_col'] = get_attrvalue(node3, 'sort_col')
                datas.append(d)
            tpl_dict['dict'] = datas

            export_list.append(tpl_dict)
        data_dict["export"] = export_list
        dict_list.append(data_dict)
    with open(to_json_file, "w", encoding='utf8') as fd:
        fd.write(json.dumps({"files":dict_list}, indent=2, ensure_ascii=False))


class ExportManager(object):
    def __init__(self, excle_src_path, config_path):
        self.excle_src_path = excle_src_path
        self.config_path = config_path
        self.last_searchstr = None
        t = threading.Thread(target=self.analysis_thread)
        t.start()
        self.wait_lang_analizer = True
        self.load_json_config()

    def load_json_config(self):
        self.cfg_game_config = {}
        with open(os.path.join(self.config_path, 'cfg_game_config.json'), 'r', encoding='utf8') as fd:
            self.cfg_game_config = json.load(fd)

        self.sheet_dict = {}
        self.export_file_dict = {}
        for data in self.cfg_game_config["files"]:
            
            add_log(data["excle_file"])
            for temp_dict in data["export"]:
                tpl_file2, _ = os.path.splitext(temp_dict["tpl"])
                _, file_type = os.path.splitext(tpl_file2)
                temp_dict["tpl"] = tpl_file2
                export_dict = {}
                export_dict['excle_file'] = data["excle_file"]
                export_dict['export_' + file_type[1:]] = temp_dict
                self.export_file_dict[tpl_file2] = export_dict
                for d in temp_dict["dict"]:
                    self.sheet_dict[data["excle_file"] + "#" + d["sheet"]] = export_dict

    def analysis_thread(self):
        try:
            self.all_src_lang_text = None
            self.lang_src_dict = {}
            self.lang_export_tpl_dict = {}
            self.lang_export_files = {}
            self.max_zh_col_size = gen_mutil_lang.load_lang_xml_cnf(self.config_path, self.lang_src_dict, self.lang_export_tpl_dict, self.lang_export_files)

            for key in self.lang_src_dict:
                d = self.lang_src_dict[key]
                book = xlrd.open_workbook(os.path.join(self.excle_src_path, key), on_demand = True)
                for d in self.lang_src_dict[key]:
                    table = book.sheet_by_name(d['sheet'])
                    d['cols_with_name'] = []
                    for col_name in d['cols']:
                        d['cols_with_name'].append(col_name + u'(%s)' % (table.cell(0, gen_mutil_lang.excel_col_2_int(col_name)).value))
                book.release_resources()
                del book
            add_log('analysis_thread finished, self.config_path:%s self.lang_src_dict:%s' % (self.config_path, self.lang_src_dict))
            add_log('self.lang_export_files:%s' % (self.lang_export_files))
            add_log('self.lang_export_tpl_dict:%s' % (self.lang_export_tpl_dict))
            self.wait_lang_analizer = False
        except Exception as e:
            exception_log = traceback.format_exc()
            add_log(exception_log)

    def query_lang_is_ready(self):
        if self.wait_lang_analizer:
            return 'wait'
        resutl_dict = {
            "lang_src_dict": self.lang_src_dict,
            "lang_export_tpl_dict": self.lang_export_tpl_dict,
            "lang_export_files": self.lang_export_files,
            "max_zh_col_size": self.max_zh_col_size,
        }
        return json.dumps(resutl_dict)


    def do_search(self, searchstr, tab_datas):
        try:
            if searchstr == self.last_searchstr:
                return 0
            self.last_searchstr = searchstr
            matched = fuzzyfinder.fuzzyfinder2(searchstr, tab_datas)
            return matched
        except Exception:
            exception_log = traceback.format_exc()
            add_log(exception_log)
            return []

    def export_erl_map(self, save_dir, obj, map_name):
        try:
            begin = time.time()
            save_file = os.path.join(save_dir, map_name)
            gen_erlang_map.start(obj, save_file)
            end = time.time()
            return "|".join(["1", save_file + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            exception_log = traceback.format_exc()
            add_log(exception_log)
            return "0|" + exception_log

    def export_c_map(self, save_dir, obj, map_name):
        try:
            begin = time.time()
            save_file = os.path.join(save_dir, map_name)
            gen_c_map.start(self.config_path, obj, save_file)
            end = time.time()
            return "|".join(["1", save_file + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            exception_log = traceback.format_exc()
            add_log(exception_log)
            return "0|" + exception_log

    def export_all(self, file_type, save_dir):
        try:
            begin = time.time()
            export_files = []

            for tpl in self.export_file_dict:
                export_dict = self.export_file_dict[tpl]
                if 'export_' + file_type in export_dict:
                    ret = self.export_one_file_help(save_dir, export_dict, file_type)
                    export_files.append(ret)
            end = time.time()
            return "|".join(["1", '\n'.join(export_files) + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            exception_log = traceback.format_exc()
            add_log(exception_log)
            return "0|" + exception_log

    def export_lang_file(self, save_dir, tpl_file):
        try:
            begin = time.time()
            export_dict = self.lang_export_tpl_dict[tpl_file]
            gen_mutil_lang.do_export(self, save_dir, export_dict)
            ret = self.export_one_file_help(save_dir, export_dict, "erl")
            end = time.time()
            return "|".join(["1", ret + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            self.all_src_lang_text = None
            exception_log = traceback.format_exc()
            add_log(exception_log)
            return "0|" + exception_log

    def export_one_file(self, save_dir, tpl_file):
        try:
            begin = time.time()
            _, file_type = os.path.splitext(tpl_file)
            file_type = file_type[1:]
            add_log("save_dir:{}, file_type:{}".format(save_dir, file_type))
            export_dict = self.export_file_dict[tpl_file]
            ret = self.export_one_file_help(save_dir, export_dict, file_type)
            end = time.time()
            return "|".join(["1", ret + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            exception_log = traceback.format_exc()
            add_log(exception_log)
            return "0|" + exception_log

    def export_by_sheet(self, dir_dict, sheet):
        try:
            begin = time.time()
            export_files = []
            export_dict = self.sheet_dict[sheet]
            for key in ['erl', 'lua', 'cs']:
                if 'export_' + key not in export_dict:
                    continue
                save_dir = dir_dict[key]
                ret = self.export_one_file_help(save_dir, export_dict, key)
                export_files.append(ret)
            end = time.time()
            return "|".join(["1", u'\n\t' + u'\n\t'.join(export_files) + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            exception_log = traceback.format_exc()
            # add_log(exception_log)
            return "0|" + exception_log

    def export_one_file_help(self, save_dir, export_dict, file_type):
        excle_file = export_dict['excle_file']
        tpl_dict = export_dict['export_' + file_type]
        add_log(export_dict)

        dict = {}
        tpl = tpl_dict['tpl'] + '.tpl'
        cfg, ext = os.path.splitext(tpl)
        for data in tpl_dict['dict']:
            excle_filename = os.path.join(self.excle_src_path, excle_file)
            xml_data = xlrd.open_workbook(excle_filename)
            table = xml_data.sheet_by_name(data['sheet'])
            key = data['data_key']
            col_start = 1
            col_end = table.ncols
            begin_row = data['begin_row']
            dict[key] = []
            # 插入多语言翻译相关的东西
            if 'all_src_lang_text' in export_dict:
                dict['all_src_lang_text'] = export_dict['all_src_lang_text']
            if 'exists_key_list' in export_dict:
                dict['exists_key_list'] = export_dict['exists_key_list']

            for i in range(begin_row, table.nrows):
                data_dict = {}
                for j in range(col_start - 1, col_end):
                    if table.cell(0, j).ctype == xlrd.XL_CELL_TEXT:
                        data_dict[table.cell(0, j).value.strip()] = excel_cell_value_format(table.cell(i, j).value)
                dict[key].append(data_dict)

            if 'sort_col' in data and len(data['sort_col']) > 0:
                dict[key].sort(key=lambda x: x[data['sort_col']], reverse=True)
        # render template with dict data
        content = engine.render(os.path.join(self.config_path, tpl), dict)
        cfg_file = os.path.join(save_dir, cfg)
        dest = codecs.open(cfg_file, "w", 'utf-8')
        content = content.replace(u"\r\n", u"\n")
        dest.write(content)
        dest.close()
        return cfg_file


def main():
    add_log("begin start python...")
    # excel_src_path = os.path.join(os.getcwd(), "..")
    # config_path = os.path.join(os.getcwd(), "config")
    
    # excel_src_path = "F:/p18/p18_cehua_doc"
    # config_path = "F:/p18/p18_cehua_tool/fbird_config_tool/resources/app/config"
    
    excel_src_path = "C:/temp"
    config_path = "C:/my_github/dzr_code_2017/c++/qt/tpl_generator"
    
    add_log(excel_src_path)
    add_log(config_path)
    manager = ExportManager(excel_src_path, config_path)
    while True:
        s = input()
        add_log(u"recv:" + s)
        parameters = s.split("|")
        cmd = parameters[0]
        if cmd == 'quit':
            add_log("exit by parent process\n")
            break
        elif cmd == 'export_one_file':
            save_dir = parameters[1]
            tpl_file = parameters[2]
            ret = manager.export_one_file(save_dir, tpl_file)
        elif cmd == 'export_by_sheet':
            dir_dict = eval(parameters[1])
            sheet = parameters[2]
            ret = manager.export_by_sheet(dir_dict, sheet)
        elif cmd == 'export_all':
            file_type = parameters[1]
            save_dir = parameters[2]
            ret = manager.export_all(file_type, save_dir)
        elif cmd == 'export_erl_map':
            save_dir = parameters[1]
            obj = parameters[2]
            filename = parameters[3]
            ret = manager.export_erl_map(save_dir, os.path.join(excel_src_path, "map", obj), filename)
        elif cmd == 'export_c_map':
            save_dir = parameters[1]
            obj = parameters[2]
            filename = parameters[3]
            ret = manager.export_c_map(save_dir, os.path.join(excel_src_path, "map", obj), filename)
        elif cmd == 'query_lang_is_ready':
            ret = manager.query_lang_is_ready()
        elif cmd == 'export_lang_file':
            save_dir = parameters[1]
            filename = parameters[2]
            ret = manager.export_lang_file(save_dir, filename)
        else:
            ret = u"0|recv unknow cmd:" + s
        add_log(ret)
        print(ret)

    add_log(u'python exit')


if __name__ == '__main__':
    main()
    exit(0)


