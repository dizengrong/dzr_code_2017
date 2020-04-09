# -*- coding: utf-8 -*-

import sys
import os
import traceback
import xlrd
from base_main_gui import Ui_BaseMainFrame
from tab_module_conf import TabModuleConfig
from PyQt5 import QtWidgets, QtCore, QtGui
from PyQt5.QtWidgets import QTableWidgetItem, QAction, QMenu, QFileDialog, QMessageBox
from PyQt5.QtCore import Qt, QTimer, QFile, QTextStream
from PyQt5.QtCore import QSize
from PyQt5.QtGui import QIcon, QCursor
from xml.dom import minidom
# from tenjin.helpers import *
# from tenjin.escaped import *
import time
import json
import settings


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

VERSION = u"配置导出工具-v6.0    设计者：dzR    更新日期：2020-03-23    "


class MainWindow(QtWidgets.QMainWindow, Ui_BaseMainFrame):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent=parent)
        self.load_stylesheet()
        self.setupUi(self)
        self.setWindowTitle(VERSION)

        self.excel_src_path = os.path.abspath('..')
        self.config_path = os.path.join(os.getcwd(), 'config')
        # for local test
        # self.excel_src_path = u'F:/work/yz_project/cehua_doc/数值表格'
        # self.config_path = u'F:/work/yz_project/cehua_doc/数值表格/config_gen_tool/config'

        self.add_tab_widgets()


    def get_excel_src_path(self):
        return self.excel_src_path

    def get_config_path(self):
        return self.config_path

    def load_stylesheet(self):
        qss_file = QFile(":/qss/my_style_sheet.qss")
        qss_file.open(QFile.ReadOnly | QFile.Text)
        text_stream = QTextStream(qss_file)
        self.setStyleSheet(text_stream.readAll())


    def add_tab_widgets(self):
        self.m_tab_mod_conf = TabModuleConfig(self.tab_container, self)
        icon1 = QtGui.QIcon()
        icon1.addPixmap(QtGui.QPixmap(":/image/tab_conf.png"), QtGui.QIcon.Normal, QtGui.QIcon.On)
        self.tab_container.addTab(self.m_tab_mod_conf, icon1, u"功能配置")

        self.tab_container.setCurrentIndex(0)

  

    def on_export_one_line(self):
        if self.current_tab_type == TAB_TYPE_ERL:
            current_tab = self.m_table
            if self.sell_tab_clicked_row is not None:
                row = self.sell_tab_clicked_row
                val = current_tab.item(row, 0).text()
                tpls = [self.export_list[x] for x in self.export_files[val]]
                self.OnExport(tpls)
        elif self.current_tab_type == TAB_TYPE_LUA:
            current_tab = self.m_tab_lua
            if self.sell_tab_clicked_row is not None:
                row = self.sell_tab_clicked_row
                val = current_tab.item(row, 0).text()
                tpls = [self.lua_export_list[x] for x in self.lua_export_files[val]]
                tab_lua.OnExport(self, tpls)
        elif self.current_tab_type == TAB_TYPE_CS:
            current_tab = self.m_tab_cs
            if self.sell_tab_clicked_row is not None:
                row = self.sell_tab_clicked_row
                val = current_tab.item(row, 0).text()
                tpls = [self.cs_export_list[x] for x in self.cs_export_files[val]]
                tab_cs.OnExport(self, tpls)

    def init_last_dir(self):
        self.last_dir_file = os.path.join(os.path.expanduser('~'), ".gen_conf_export_dir.json")
        if os.path.exists(self.last_dir_file):
            with open(self.last_dir_file, "r", encoding="UTF-8") as fd:
                try:
                    self.last_dir = json.load(fd)
                except Exception:
                    self.last_dir = {}
                    self.last_dir[str(TAB_TYPE_ERL)] = self.cwd
                    self.last_dir[str(TAB_TYPE_LUA)] = self.cwd
                    self.last_dir[str(TAB_TYPE_CS)] = self.cwd
        else:
            self.last_dir = {}
            self.last_dir[str(TAB_TYPE_ERL)] = self.cwd
            self.last_dir[str(TAB_TYPE_LUA)] = self.cwd
            self.last_dir[str(TAB_TYPE_CS)] = self.cwd

    def get_last_dir(self, tab_type):
        return self.last_dir[str(tab_type)]

    def set_last_dir(self, tab_type, new_dir):
        if self.last_dir[str(tab_type)] != new_dir:
            self.last_dir[str(tab_type)] = new_dir
            with open(self.last_dir_file, "w", encoding="UTF-8") as fd:
                fd.write(json.dumps(self.last_dir, indent=4))

    def OnExport(self, tpl_dicts):
        path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir(TAB_TYPE_ERL))
        print(path)
        if os.path.exists(path):
            self.set_last_dir(TAB_TYPE_ERL, path)
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

    def DoExport(self, tpl_dict, dest_dir):
        dict = {}
        tpl = tpl_dict['tpl']
        cfg, ext = os.path.splitext(tpl)
        excle_file = tpl_dict['excle_file']
        for data in tpl_dict['datas']:
            print("excle_file: %s" % (excle_file))
            excle_filename = os.path.join(
                self.excel_src_path, excle_file)
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
                data_dict = {}
                for j in range(col_start - 1, col_end):
                    data_dict[table.cell(0, j).value.strip()] = format(table.cell(i, j).value)
                dict[key].append(data_dict)

            sort_col = data['sort_col']
            if sort_col is '':
                pass
            else:
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
    # QtWidgets.QApplication.setStyle('Fusion')
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())
