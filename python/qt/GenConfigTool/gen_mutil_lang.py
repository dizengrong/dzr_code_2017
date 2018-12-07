# -*- coding: utf-8 -*-
# 多语言配置生成
import os
import re
import time
import traceback
import xlrd
from xml.dom import minidom
from common import *
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QTableWidgetItem, QAction, QMenu, QFileDialog, QMessageBox


def init_lang(self):
    self.all_src_lang_text = None
    self.lang_src_dict = {}
    self.lang_export_tpl_dict = {}
    self.lang_export_files = {}
    max_zh_col_size = load_lang_xml_cnf(self.lang_src_dict, self.lang_export_tpl_dict, self.lang_export_files)
    self.m_lang_cnf_tab.setRowCount(1 + len(self.lang_src_dict))
    self.m_lang_cnf_tab.setColumnCount(2 + max_zh_col_size)
    self.m_lang_cnf_tab.verticalHeader().setFixedWidth(30)
    self.m_lang_cnf_tab.verticalHeader().setDefaultAlignment(Qt.AlignCenter)
    self.m_lang_cnf_tab.horizontalHeader().setStretchLastSection(True)
    self.m_lang_cnf_tab.horizontalHeader().setFixedHeight(30)
    header_labels = [u'Excel文件名(双击打开)  ', u'  sheet分页  '] + [u'  中文列  ' for n in range(0, max_zh_col_size)]
    self.m_lang_cnf_tab.setHorizontalHeaderLabels(header_labels)

    row = 0
    for key in self.lang_src_dict:
        d = self.lang_src_dict[key]
        for d in self.lang_src_dict[key]:
            print(d)
            item1 = QTableWidgetItem(key)
            item1.setTextAlignment(Qt.AlignCenter)
            self.m_lang_cnf_tab.setItem(row, 0, item1)

            item2 = QTableWidgetItem(d['sheet'])
            item2.setTextAlignment(Qt.AlignCenter)
            self.m_lang_cnf_tab.setItem(row, 1, item2)
            col = 2
            for col_name in d['cols']:
                item = QTableWidgetItem(col_name)
                item.setTextAlignment(Qt.AlignCenter)
                self.m_lang_cnf_tab.setItem(row, col, item)
                col += 1
            row += 1
    self.m_lang_cnf_tab.resizeColumnsToContents()


    self.m_lang_tab.setRowCount(1 + len(self.lang_export_tpl_dict))
    self.m_lang_tab.setColumnCount(2)
    self.m_lang_tab.verticalHeader().setFixedWidth(30)
    self.m_lang_tab.verticalHeader().setDefaultAlignment(Qt.AlignCenter)
    self.m_lang_tab.horizontalHeader().setStretchLastSection(True)
    self.m_lang_tab.horizontalHeader().setFixedHeight(30)
    header_labels = [u'Excel文件名(双击打开)', u'翻译配置(双击导出)']
    self.m_lang_tab.setHorizontalHeaderLabels(header_labels)

    row = 0
    for excle_file in self.lang_export_files.keys():
        self.m_lang_tab.setItem(row, 0, QTableWidgetItem(excle_file))
        col = 1
        for cfg in self.lang_export_files[excle_file]:
            cfg_dict = self.lang_export_tpl_dict[cfg]
            tpl = cfg_dict['tpl']
            name, ext = os.path.splitext(tpl)
            if cfg_dict['tpl_type'] == 1:
                tpl_name = u'S:' + name
            else:
                tpl_name = u'C:' + name
            self.m_lang_tab.setItem(row, col, QTableWidgetItem(tpl_name))
            col += 1
        row += 1
    self.m_lang_tab.resizeColumnsToContents()


def check_contain_chinese(check_str):
    # print(check_str)
    if isinstance(check_str, str) or isinstance(check_str, unicode):
        try:
            print(check_str.encode('ascii'))
            return False
        except UnicodeDecodeError:
            return True
        except UnicodeEncodeError:
            return True
        else:
            return False
    else:
        return False


def excel_col_2_int(col):
    if len(col) == 1:
        return ord(col) - ord('A')
    else:
        a = ord(col[0])
        b = ord(col[1])
        return (a - ord('A') + 1) * 26 + b - ord('A')


def init_lang_src(self):
    self.all_src_lang_text = {}
    for excle_file in self.lang_src_dict:
        excle_filename = os.path.join(self.excle_src_path, excle_file)
        xml_data = xlrd.open_workbook(excle_filename)
        for d in self.lang_src_dict[excle_file]:
            sheet = d['sheet']
            table = xml_data.sheet_by_name(sheet)
            begin_row = d['begin_row']
            no_true_count = 0
            for i in range(begin_row, table.nrows):
                for col in d['cols']:
                    text = table.cell(i, excel_col_2_int(col)).value
                    self.all_src_lang_text[text] = text
                    if not check_contain_chinese(text):
                        no_true_count += 1
                if no_true_count > 3:
                    raise Exception(u'文件：%s，分页：%s指定的列可能不是中文列，请检查配置是否正确！' % (excle_file, sheet))


def load_lang_cnf():
    lang_cnf = {}
    with open('config/lang_conf.json') as fd: 
        lang_cnf = json.load(fd)
    return lang_cnf


def load_lang_xml_cnf(lang_src_dict, export_tpl_dict, export_files):
    doc = minidom.parse('config/lang_cfg.xml')
    root = doc.documentElement
    max_zh_col_size = 0
    for node in get_xmlnode(root, 'file'):
        node_type = get_attrvalue(node, 'type')
        excle_file = get_attrvalue(node, 'excle_file')
        if node_type == 'lang_src':
            lang_src_dict[excle_file] = []
            for node2 in get_xmlnode(node, 'dict'):
                d = {
                    'sheet':get_attrvalue(node2, 'sheet'),
                    'begin_row':int(get_attrvalue(node2, 'begin_row')),
                    'cols':get_attrvalue(node2, 'cols').split(','),
                }
                max_zh_col_size = max(max_zh_col_size, len(d['cols']))
                lang_src_dict[excle_file].append(d)
        elif node_type == 'translation_src':
            export_files[excle_file] = []
            for node2 in get_xmlnode(node, 'export'):
                tpl_dict = {}
                tpl = get_attrvalue(node2, 'tpl')
                tpl_type = int(get_attrvalue(node2, 'type'))

                export_files[excle_file].append(tpl)

                tpl_dict['tpl'] = tpl
                tpl_dict['tpl_type'] = int(tpl_type)
                tpl_dict['excle_file'] = excle_file
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
                tpl_dict['datas'] = datas

                export_tpl_dict[tpl_dict['tpl']] = tpl_dict
    return max_zh_col_size


def do_export(self, tpl_dict):
    try:
        if not self.all_src_lang_text:
            begin = time.time()
            init_lang_src(self)
            print("init_lang_src cost:%s" % (time.time() - begin))
            tpl_dict['all_src_lang_text'] = self.all_src_lang_text
    except Exception:
        self.all_src_lang_text = None
        msg = u"错误信息:\n" + traceback.format_exc()
        msg_box = QMessageBox(QMessageBox.Critical, u"错误", "获取要翻译的文本失败！!\t\t\t\t\t\t\t\t", parent=self)
        msg_box.setDetailedText(msg)
        msg_box.exec_()
        return

    dest_dir = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir())
    if os.path.exists(dest_dir):
        begin = time.time()
        try:
            cfg_file, ext = os.path.splitext(tpl_dict['tpl'])
            erl_file = os.path.join(dest_dir, cfg_file)
            # print(erl_file)
            if os.path.exists(erl_file):  # 已经存在翻译文件了，则需要以增量的方式生成
                exists_key_list = read_exists_translated_file(erl_file)
            else:
                exists_key_list = []
            # print(exists_key_list)

            tpl_dict['exists_key_list'] = exists_key_list
            self.DoExport(tpl_dict, dest_dir)
        except Exception:
            msg = u"导出失败:\n    " + erl_file + "\n" \
                + u"错误信息:\n" + traceback.format_exc()
            msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()
            return
        end = time.time()
        msg = u"成功导出文件:{0} 花费：{1}秒".format(erl_file, int(end - begin))
        QMessageBox.information(self, u"导出成功", msg)


def read_exists_translated_file(erl_file):
    exists_key_list = []
    # compiled_re1 = re.compile('.*[ \\t]*\([ \\t]*\d*[ \\t]*\)[ \\t]*->[ \\t]*.*')
    compiled_re2 = re.compile(r'.*get_data[(](.*?)[)]')
    with open(erl_file, 'r', encoding='utf-8') as fd:
        for line in fd.readlines():
            match = compiled_re2.findall(line)
            print(len(match))
            if len(match) > 0:
                key = match[0]
                if key != '_':
                    exists_key_list.append(key.replace('\"', ''))
    return exists_key_list




