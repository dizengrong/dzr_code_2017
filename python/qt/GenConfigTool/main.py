# -*- coding: utf-8 -*-

import sys
import os
import fuzzyfinder
import traceback
import xlrd
from base_main_window import Ui_MainWindow
from PyQt5 import QtWidgets, QtCore
from PyQt5.QtWidgets import QTableWidgetItem, QAction, QMenu, QFileDialog, QMessageBox
from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtCore import QSize
from PyQt5.QtGui import QIcon, QCursor
from xml.dom import minidom
from tenjin.helpers import *
from tenjin.escaped import *
import time
import gen_erlang_map
import gen_c_map
import gen_mutil_lang
from common import *
import json


def format(value):
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


VERSION = u"配置导出工具-v4.0    设计者：dzR    更新日期：2018-11-28    "


class MainWindow(QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent=parent)
        self.setupUi(self)

        self.init_other()
        self.init_table()
        self.init_map_table()
        timer = QTimer(self)
        timer.timeout.connect(self.delay_init_lang)
        timer.setSingleShot(True)
        timer.start(200)
        self.create_context_menu()
        self.init_event()
        print(self.m_table.size())
        print(self.m_table.frameSize())
        print(self.m_table.sizeHint())
        # setMinimumSize
        # self.showMaximized()

    def delay_init_lang(self):
        _translate = QtCore.QCoreApplication.translate
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab3), _translate("MainWindow", "多语言翻译配置(加载中，请稍后)"))
        self.thread = gen_mutil_lang.Worker(self)
        self.thread.sinOut.connect(self.thread_event)
        self.thread.start()

    def thread_event(self, test):
        gen_mutil_lang.init_lang(self)
        _translate = QtCore.QCoreApplication.translate
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab3), _translate("MainWindow", "多语言翻译配置(加载完成)"))

    def init_other(self):
        self.setWindowIcon(QIcon('icon.png'))
        status_bar = self.statusBar()
        label = QtWidgets.QLabel(VERSION, status_bar)
        label.setStyleSheet("color:red")
        status_bar.addPermanentWidget(label)
        self.cwd = os.path.abspath('.')
        self.excle_src_path = os.path.abspath('..')
        self.map_obj_path = os.path.abspath('../map/')
        self.last_search_str = None
        self.init_last_dir()

    def init_event(self):
        self.menu_export_all.triggered.connect(self.on_export_all)
        self.menu_export_all_map.triggered.connect(self.on_export_all_map)
        self.menu_export_all_c_map.triggered.connect(self.on_export_all_c_map)
        self.m_search_edit.textChanged['QString'].connect(self.on_search)
        self.m_table.cellDoubleClicked['int','int'].connect(self.on_cell_double_click)
        self.m_table.setContextMenuPolicy(Qt.CustomContextMenu)
        self.m_table.customContextMenuRequested['QPoint'].connect(self.on_context_menu)

        self.m_map_table.cellDoubleClicked['int','int'].connect(self.on_map_cell_double_click)
        self.m_lang_tab.cellDoubleClicked['int','int'].connect(self.on_lang_cell_double_click)
        self.m_lang_cnf_tab.cellDoubleClicked['int','int'].connect(self.on_lang_cnf_cell_double_click)


    def init_map_table(self):
        self.map_conf_dict = {}
        with open('config/map_conf.json') as fd: 
            self.map_conf_dict = json.load(fd)
        self.map_obj_files = []
        for map_obj in os.listdir(self.map_obj_path):
            _, ext = os.path.splitext(map_obj)
            if ext == '.obj':
                self.map_obj_files.append(map_obj)

        self.map_obj_files.sort()
        print(self.map_obj_files)

        self.m_map_table.setRowCount(1 + len(self.map_obj_files))
        self.m_map_table.setColumnCount(3)
        self.m_map_table.verticalHeader().setFixedWidth(30)
        self.m_map_table.verticalHeader().setDefaultAlignment(Qt.AlignCenter)
        self.m_map_table.horizontalHeader().setStretchLastSection(True)
        self.m_map_table.horizontalHeader().setFixedHeight(30)
        header_labels = [u'地图源文件', u'导出Erlang文件', u'导出c文件']
        self.m_map_table.setHorizontalHeaderLabels(header_labels)

        row = 0
        for map_obj in self.map_obj_files:
            item1 = QTableWidgetItem(map_obj)
            item1.setTextAlignment(Qt.AlignCenter)
            self.m_map_table.setItem(row, 0, item1)

            rootname, _ = os.path.splitext(map_obj)
            item2 = QTableWidgetItem(rootname + '.erl')
            item2.setTextAlignment(Qt.AlignCenter)
            self.m_map_table.setItem(row, 1, item2)

            if rootname not in self.map_conf_dict:
                item3_text = u'没有正确配置，将无法导出'
            else:
                item3_text = 'data_map_' + str(self.map_conf_dict[rootname]) + '.c'
            item3 = QTableWidgetItem(item3_text)
            item3.setTextAlignment(Qt.AlignCenter)
            self.m_map_table.setItem(row, 2, item3)
            row += 1
        self.m_map_table.resizeColumnsToContents()

    def init_table(self):
        self.LoadConfigXML()
        max_columns = 0
        for key in self.export_files.keys():
            max_columns = max(max_columns, len(self.export_files[key]))

        self.m_table.setRowCount(1 + len(self.export_files))
        self.m_table.setColumnCount(max_columns + 1)

        self.m_table.verticalHeader().setFixedWidth(30)
        self.m_table.verticalHeader().setDefaultAlignment(Qt.AlignCenter)
        self.m_table.horizontalHeader().setStretchLastSection(True)
        self.m_table.horizontalHeader().setFixedHeight(30)
        # self.m_table.setStyleSheet("selection-background-color:lightblue;")
        # self.m_table.horizontalHeader().setStyleSheet("QHeaderView::section{background:skyblue;}")  # 设置表头背景色
        header_labels = [u'Excel文件(双击打开)']
        for row in range(1, max_columns + 1):
            header_labels.append(u'配置' + str(row) + u'(双击导出)')
        self.m_table.setHorizontalHeaderLabels(header_labels)

        self.fill_grid(self.export_files, True)

    def LoadConfigXML(self):
        doc = minidom.parse('config/cfg.xml')
        root = doc.documentElement
        self.export_files = {}
        self.export_list = {}
        colum_size = 0
        for node in get_xmlnode(root, 'file'):
            excle_file = get_attrvalue(node, 'excle_file')
            colum_size = max(colum_size, len(excle_file))
            self.export_files[excle_file] = []
            for node2 in get_xmlnode(node, 'export'):
                tpl_dict = {}
                tpl = get_attrvalue(node2, 'tpl')
                colum_size = max(colum_size, len(tpl))
                tpl_type = int(get_attrvalue(node2, 'type'))

                self.export_files[excle_file].append(tpl)

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

                self.export_list[tpl_dict['tpl']] = tpl_dict
        # print(self.export_files)
        # print(self.export_list)
        return colum_size

    def fill_grid(self, export_files, auto_size=False):
        row = 0
        for excle_file in export_files.keys():
            self.m_table.setItem(row, 0, QTableWidgetItem(excle_file))
            col = 1
            for cfg in export_files[excle_file]:
                cfg_dict = self.export_list[cfg]
                tpl = cfg_dict['tpl']
                name, ext = os.path.splitext(tpl)
                if cfg_dict['tpl_type'] == 1:
                    tpl_name = u'S:' + name
                else:
                    tpl_name = u'C:' + name
                self.m_table.setItem(row, col, QTableWidgetItem(tpl_name))
                col += 1
            # if row % 2 == 1:
            #     self.set_row_color(row, wx.SystemSettings.GetColour(wx.SYS_COLOUR_3DFACE))
            row += 1
        if auto_size:
            self.m_table.resizeColumnsToContents()

    def on_export_all(self):
        print("do on_export_all")
        self.OnExport(self.export_list.values())

    def on_export_all_c_map(self):
        path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir())
        if os.path.exists(path):
            succ_files = ""
            begin = time.time()
            for obj in self.map_conf_dict:
                try:
                    map_obj = os.path.join(self.map_obj_path, obj)
                    c_file = os.path.join(path, 'data_map_' + str(self.map_conf_dict[obj]) + '.c')
                    gen_c_map.start(self.cwd, map_obj + '.obj', c_file)
                    succ_files = succ_files + c_file + '.erl' + "\n    "
                except Exception:
                    msg = u"已成功导出的文件:\n    " + succ_files + "\n" \
                        + u"导出失败的文件:\n    " + c_file + "\n" \
                        + u"错误信息:\n" + traceback.format_exc()
                    msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
                    msg_box.setDetailedText(msg)
                    msg_box.exec_()
                    return
            end = time.time()
            msg = u"成功导出的文件列表:\n    {0}\n花费：{1}秒".format(succ_files, int(end - begin))
            msg_box = QMessageBox(QMessageBox.Information, u"信息", "导出成功!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()

    def on_export_all_map(self):
        path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir())
        if os.path.exists(path):
            succ_files = ""
            begin = time.time()
            for map_obj in self.map_obj_files:
                try:
                    map_name, ext = os.path.splitext(map_obj)
                    map_obj = os.path.join(self.map_obj_path, map_obj)
                    erl_file = os.path.join(path, map_name + '.erl')
                    gen_erlang_map.start(map_obj, erl_file)
                    succ_files = succ_files + map_name + '.erl' + "\n    "
                except Exception:
                    msg = u"已成功导出的文件:\n    " + succ_files + "\n" \
                        + u"导出失败的文件:\n    " + erl_file + "\n" \
                        + u"错误信息:\n" + traceback.format_exc()
                    msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
                    msg_box.setDetailedText(msg)
                    msg_box.exec_()
                    return
            end = time.time()
            msg = u"成功导出的文件列表:\n    {0}\n花费：{1}秒".format(succ_files, int(end - begin))
            msg_box = QMessageBox(QMessageBox.Information, u"信息", "导出成功!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()

    def on_search(self, query_str):
        print ("on search %s" % (query_str))
        timer = QTimer(self)
        timer.timeout.connect(self.show_search)
        timer.setSingleShot(True)
        timer.start(200)

    def show_search(self):
        searchstr = self.m_search_edit.text()
        if self.last_search_str == searchstr:
            return
        self.last_search_str = searchstr

        self.m_table.clearContents()
        if searchstr != '':
            matched = fuzzyfinder.fuzzyfinder(searchstr, self.export_files)
            # print(self.export_files)
            # print(matched)
            self.fill_grid(matched)
        else:
            self.fill_grid(self.export_files)
        # self.Layout()

    def on_lang_cnf_cell_double_click(self, row, col):
        if self.m_lang_tab.item(row, col) is None:
            return
        val = self.m_lang_tab.item(row, col).text()
        if col == 0:
            excle_filename = os.path.join(self.excle_src_path, val)
            self.OpenFile(excle_filename)

    def on_lang_cell_double_click(self, row, col):
        if self.m_lang_tab.item(row, col) is None:
            return
        val = self.m_lang_tab.item(row, col).text()
        if col == 0:
            excle_filename = os.path.join(self.excle_src_path, val)
            self.OpenFile(excle_filename)
        else:
            tpl = val[2:] + ".tpl"
            if tpl in self.lang_export_tpl_dict:
                gen_mutil_lang.do_export(self, self.lang_export_tpl_dict[tpl])


    def on_map_cell_double_click(self, row, col):
        print("on_cell_double_click row:%s, col:%s" % (row, col))
        if self.m_map_table.item(row, col) is None:
            return
        erl_file = self.m_map_table.item(row, col).text()
        if col >= 1:
            map_obj = self.m_map_table.item(row, 0).text()
            path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir())
            if os.path.exists(path):
                begin = time.time()
                try:
                    map_obj = os.path.join(self.map_obj_path, map_obj)
                    erl_file = os.path.join(path, erl_file)
                    if col == 1:
                        gen_erlang_map.start(map_obj, erl_file)
                    else:
                        gen_c_map.start(self.cwd, map_obj, erl_file)
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

    def on_cell_double_click(self, row, col):
        print("on_cell_double_click row:%s, col:%s" % (row, col))
        if self.m_table.item(row, col) is None:
            return
        val = self.m_table.item(row, col).text()
        if col == 0:
            excle_filename = os.path.join(self.excle_src_path, val)
            self.OpenFile(excle_filename)
        else:
            tpl = val[2:] + ".tpl"
            if tpl in self.export_list:
                self.OnExport([self.export_list[tpl]])

    def OpenFile(self, filename):
        if os.path.isfile(filename):
            os.startfile(filename)
        else:
            QMessageBox.critical(self, u'错误', u'找不到文件：' + filename)

    def on_context_menu(self, point):
        # row = self.m_table.currentRow()
        for item in self.m_table.selectedItems():
            self.sell_tab_clicked_row = item.row()
            self.sell_tab_clicked_col = item.column()
            # print((self.sell_tab_clicked_row, self.sell_tab_clicked_col))
        self.table_right_menu.exec_(QCursor.pos())

    def create_context_menu(self):
        self.table_right_menu = QMenu(self)
        menus = [
            (u'打开文件所在目录', self.on_open_file_in_explore),
            (u'导出该行的所有文件', self.on_export_one_line),
        ]
        for text, slot in menus:
            action = self.table_right_menu.addAction(text)
            action.triggered.connect(slot)

    def on_open_file_in_explore(self, event):
        if self.sell_tab_clicked_row is not None:
            row = self.sell_tab_clicked_row
            col = self.sell_tab_clicked_col
            val = self.m_table.item(row, col).text()
            if col == 0:
                excle_filename = os.path.join(self.excle_src_path, val)
                os.system('explorer /select,' + excle_filename)
            else:
                tpl_filename = os.path.join(self.cwd, 'config', val[2:] + '.tpl')
                os.system('explorer /select,' + tpl_filename)

    def on_export_one_line(self):
        if self.sell_tab_clicked_row is not None:
            row = self.sell_tab_clicked_row
            val = self.m_table.item(row, 0).text()
            tpls = [self.export_list[x] for x in self.export_files[val]]
            self.OnExport(tpls)

    def init_last_dir(self):
        self.last_dir_file = os.path.join(os.path.expanduser('~'), ".gen_conf_export_dir")
        if os.path.exists(self.last_dir_file):
            with open(self.last_dir_file, "r", encoding="UTF-8") as fd:
                self.last_dir = fd.read()
        else:
            self.last_dir =self.cwd

    def get_last_dir(self):
        return self.last_dir

    def set_last_dir(self, new_dir):
        if self.last_dir != new_dir:
            self.last_dir = new_dir
            with open(self.last_dir_file, "w", encoding="UTF-8") as fd:
                fd.write(new_dir)

    def OnExport(self, tpl_dicts):
        path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir())
        print(path)
        if os.path.exists(path):
            self.set_last_dir(path)
            succ_files = ""
            begin = time.time()
            for tpl_dict in tpl_dicts:
                cfg_file, ext = os.path.splitext(tpl_dict['tpl'])
                cfg_file = os.path.join(path, cfg_file)
                try:
                    self.DoExport(tpl_dict, path)
                    succ_files = succ_files + cfg_file + "\n    "
                except Exception:
                    msg = u"已成功导出的文件:\n    " + succ_files + "\n" \
                        + u"导出失败的文件:\n    " + cfg_file + "\n" \
                        + u"错误信息:\n" + traceback.format_exc()
                    # QMessageBox.critical(self, u"导出失败", msg)
                    msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
                    msg_box.setDetailedText(msg)
                    msg_box.exec_()
                    return
            end = time.time()
            msg = u"成功导出的文件列表:\n    {0}\n花费：{1}秒".format(succ_files, int(end - begin))
            msg_box = QMessageBox(QMessageBox.Information, u"信息", "导出成功!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()
            # QMessageBox.information(self, u"导出成功", msg)

    def DoExport(self, tpl_dict, dest_dir):
        dict = {}
        tpl = tpl_dict['tpl']
        cfg, ext = os.path.splitext(tpl)
        excle_file = tpl_dict['excle_file']
        for data in tpl_dict['datas']:
            print("excle_file: %s" % (excle_file))
            excle_filename = os.path.join(
                self.excle_src_path, excle_file)
            xml_data = xlrd.open_workbook(excle_filename)
            table = xml_data.sheet_by_name(data['sheet'])
            key = data['data_key']
            col_start = data['col_start']
            col_end = data['col_end']
            begin_row = data['begin_row']
            dict[key] = []
            # 插入多语言翻译相关的东西 
            if 'all_src_lang_text' in tpl_dict:
                dict['all_src_lang_text'] = tpl_dict['all_src_lang_text']
            if 'exists_key_list' in tpl_dict:
                dict['exists_key_list'] = tpl_dict['exists_key_list']

            for i in range(begin_row, table.nrows):
                tmp = []
                for j in range(col_start - 1, col_end):
                    tmp.append(format(table.cell(i, j).value))
                dict[key].append(tmp)

            sort_col = data['sort_col']
            if sort_col is '':
                pass
            else:
                sort_col = int(sort_col) - 1
                dict[key].sort(key=lambda x: x[sort_col], reverse=True)
        # render template with dict data
        content = engine.render(os.path.join(self.cwd, 'config', tpl), dict)
        cfg_file = os.path.join(dest_dir, cfg)
        dest = open(cfg_file, "w", encoding='UTF-8')
        content = content.replace("\r\n", "\n")
        dest.write(content)
        dest.close()
        return cfg_file


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    QtWidgets.QApplication.setStyle('Fusion')
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())

