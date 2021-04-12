# -*- coding: utf-8 -*-
import sys
import os
import traceback
import xlrd
from PyQt5 import QtCore, QtGui, QtWidgets
from tab_conf_ui import Ui_TabConfig
from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *

from tenjin.helpers import *
from tenjin.escaped import *
from xml.dom import minidom
from common import *
import settings
import time
import importlib
import codecs


sys.path.append('.')
# import helper
helper = importlib.import_module("helper")


def excel_cell_value_format(value):
    if isinstance(value, float):
        if int(value) == value:
            return int(value)
        else:
            return round(value, 4)
    elif isinstance(value, str):
        try:
            return int(value)
        except Exception:
            try:
                return round(value, 4)
            except Exception:
                return as_escaped(value)
    else:
        try:
            return int(value)
        except Exception:
            return as_escaped(value)

ExportTypeDict = {
    's':'server',
    'c':'client',
}


def make_button(parent, label):
    btn = QPushButton(parent)
    btn.setText(label)
    btn.setFlat(True)
    btn.setStyleSheet("color: rgb(51, 153, 255);")
    btn.setCursor(QCursor(Qt.PointingHandCursor))
    return btn


class ExportItem(object):
    """
        一个excel文件的导出数据：
            {
                'sheet1':{'server':'data_xxx.erl', 'client':'data_xxx.lua'},
                'sheet2':{'server':'data_xxx.erl', 'client':'data_xxx.lua'}
            }
    """
    def __init__(self, excel_filename):
        super(ExportItem, self).__init__()
        self.excel_filename = excel_filename
        self.sheets = {}

    def add_sheet(self, sheet, export_type, tpl):
        if sheet not in self.sheets:
            self.sheets[sheet] = {'server':'', 'client':''}
        self.sheets[sheet][export_type] = tpl[:-4]

    def get_sheet_size(self):
        return len(self.sheets)
    
    def get_sheets(self):
        return self.sheets

    def excle_filename(self):
        return self.excel_filename

    def is_matched(self, query_str):
        if query_str in self.excel_filename:
            return True
        for sheet in self.sheets:
            if query_str in sheet or query_str in self.sheets[sheet]['server'] or query_str in self.sheets[sheet]['client']:
                return True
        return False
        

class TabModuleConfig(QtWidgets.QWidget, Ui_TabConfig):
    def __init__(self, parent, main_window):
        super(TabModuleConfig, self).__init__(parent=parent)
        self.main_window = main_window
        self.setupUi(self)
        self.load_export_conf()
        self.init_table()
        self.init_event()
        self.create_context_menu()

        self.m_edit_s_dir.setText(settings.get_server_export_dir())
        self.m_edit_c_dir.setText(settings.get_client_export_dir())
        self.last_search_str = None

    def init_event(self):
        self.m_search.textChanged['QString'].connect(self.on_search)
        self.m_btn_s_dir.clicked.connect(self.on_set_server_export_dir)
        self.m_btn_all_s.clicked.connect(self.on_export_all_server)
        self.m_btn_c_dir.clicked.connect(self.on_set_client_export_dir)
        self.m_btn_all_c.clicked.connect(self.on_export_all_client)
        self.m_table.cellDoubleClicked['int','int'].connect(self.on_cell_double_click)

        self.m_table.setContextMenuPolicy(Qt.CustomContextMenu)
        self.m_table.customContextMenuRequested['QPoint'].connect(self.on_context_menu)

    def on_set_server_export_dir(self):
        path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录")
        if os.path.exists(path):
            self.m_edit_s_dir.setText(path)
            settings.set_server_export_dir(path)

    def on_set_client_export_dir(self):
        path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录")
        if os.path.exists(path):
            self.m_edit_c_dir.setText(path)
            settings.set_client_export_dir(path)

    def on_search(self, query_str):
        print ("on search %s" % (query_str))
        timer = QTimer(self)
        timer.timeout.connect(self.show_search)
        timer.setSingleShot(True)
        timer.start(200)

    def show_search(self):
        searchstr = self.m_search.text()
        if self.last_search_str == searchstr:
            return
        self.last_search_str = searchstr

        matched_datas = []
        for item in self.export_items:
            if item.is_matched(searchstr):
                matched_datas.append(item)

        # self.m_table.clearContents()
        row = self.m_table.rowCount()
        while row >= 0:
            self.m_table.removeRow(row)
            row -= 1
        self.show_datas(matched_datas)

    def load_export_conf(self):
        """
        tpl_dict:{
            'export_type':'client' or 'server'
            'tpl':'data_xxx.lua.tpl',
            'excle_file':对应的excel文件名称
            'datas':[{'data_key':data_key, 'sheet':sheet, 'begin_row':begin_row, 'sort_col':sort_col}]
        }
        """
        doc = minidom.parse(os.path.join(self.main_window.get_config_path(), 'cfg_module.xml'))
        root = doc.documentElement
        self.export_files = {}  # {'data_xxx.lua.tpl':tpl_dict}
        self.export_items = []  # [ExportItem]
        for key in ExportTypeDict.values():
            setattr(self, 'export_files_' + key, {})

        for node in get_xmlnode(root, 'file'):
            excle_file    = get_attrvalue(node, 'excle_file')
            export_series = get_attrvalue(node, 'series')
            export_series = int(export_series) if export_series != '' else 0
            export_item   = ExportItem(excle_file)
            for node2 in get_xmlnode(node, 'export'):
                export_type = ExportTypeDict[get_attrvalue(node2, 'type')]
                tpl_dict = {}
                tpl_dict['tpl'] = get_attrvalue(node2, 'tpl')
                tpl_dict['export_type'] = export_type
                tpl_dict['excle_file'] = excle_file
                tpl_dict['export_series'] = export_series
                datas = []
                for node3 in get_xmlnode(node2, 'dict'):
                    d = {}
                    d['data_key'] = get_attrvalue(node3, 'data_key')
                    d['sheet'] = get_attrvalue(node3, 'sheet')
                    d['begin_row'] = int(get_attrvalue(node3, 'begin_row'))
                    d['sort_col'] = get_attrvalue(node3, 'sort_col')
                    datas.append(d)
                    export_item.add_sheet(d['sheet'], export_type, tpl_dict['tpl'])
                tpl_dict['datas'] = datas
                self.export_files[tpl_dict['tpl']] = tpl_dict

                tmp = getattr(self, 'export_files_' + export_type)
                tmp[tpl_dict['tpl']] = tpl_dict
            self.export_items.append(export_item)

    def init_table(self):
        header = []
        header.append("Excel文件(点击打开)")
        header.append("Sheet名称")
        header.append("后端配置(双击导出)")
        header.append("前端配置(双击导出)")
        self.m_table.setColumnCount(len(header))

        self.m_table.setHorizontalHeaderLabels(header)
        self.m_table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)

        self.m_table.setEditTriggers(QAbstractItemView.NoEditTriggers)
        self.m_table.setSortingEnabled(False)

        self.show_datas(self.export_items)

    def show_datas(self, export_items):
        total_num = 0
        for item in export_items:
            total_num += item.get_sheet_size()
        self.m_table.setRowCount(total_num + 1)

        count = 0
        for item in export_items:
            addSize = item.get_sheet_size()
            row = count
            sheet_dict = item.get_sheets()
            for sheet in sheet_dict:
                if row == count:
                    btn = make_button(self.m_table, item.excle_filename())
                    btn.setProperty("excle", item.excle_filename())
                    self.m_table.setCellWidget(row, 0, btn)
                    btn.clicked.connect(self.on_open_excelfile)
                self.m_table.setItem(row, 1, QTableWidgetItem(sheet));
                self.m_table.setItem(row, 2, QTableWidgetItem(sheet_dict[sheet]['server']))
                self.m_table.setItem(row, 3, QTableWidgetItem(sheet_dict[sheet]['client']))
                row += 1
            if addSize > 1:
                self.m_table.setSpan(count, 0, addSize, 1)
            count += addSize

    def on_context_menu(self, point):
        # print("point:", point)
        # item = self.m_table.itemAt(self.m_table.viewport().mapFrom(self, point))
        # todo:这里应该要优化成，那些文件可以打开，直接显示在菜单里
        item = self.m_table.itemAt(point)
        if item and item.column() != 1 :
            self.sell_tab_clicked_row = item.row()
            self.sell_tab_clicked_col = item.column()
            val = self.m_table.item(self.sell_tab_clicked_row, self.sell_tab_clicked_col).text()
            if val != '':
                self.table_right_menu.exec_(QCursor.pos())

   
    def create_context_menu(self):
        self.table_right_menu = QMenu(self)
        menus = [
            (u'打开文件所在目录', self.on_show_tpl_in_explore),
        ]
        for text, slot in menus:
            action = self.table_right_menu.addAction(text)
            action.triggered.connect(slot)

    def get_export_dir(self, col):
        if col == 2:
            return settings.get_server_export_dir()
        else:
            return settings.get_client_export_dir()

    def on_cell_double_click(self, row, col):
        if self.m_table.item(row, col) is None:
            return
        try:
            begin = time.time()
            tpl_file = self.m_table.item(row, col).text()
            tpl_file = tpl_file + ".tpl"
            tpl_dict = self.export_files[tpl_file]
            save_dir = self.get_export_dir(col)
            if not save_dir or not os.path.exists(save_dir):
                QMessageBox.information(self, u"提示", u"请先设置导出目录")
                return
            ret = self.export_one_file_help(save_dir, tpl_dict)
            end = time.time()
            msg = "\n".join(ret) + u"\n消耗时间：{0}秒".format(int(end - begin))
            QMessageBox.information(self, u"导出成功", msg)
        except Exception:
            msg = traceback.format_exc()
            msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()

    def export_one_file_help(self, save_dir, tpl_dict, translate_cols = None, translate_words = None):
        export_series = tpl_dict['export_series']
        excle_file = tpl_dict['excle_file']
        tpl = tpl_dict['tpl']
        cfg, _ = os.path.splitext(tpl)

        file_list = []
        if export_series == 0:
            file_list.append((excle_file, cfg))
        else:
            for i in range(1, export_series + 1):
                n, ext = os.path.splitext(excle_file)
                cfg_name, cfg_ext = os.path.splitext(cfg)
                file_list.append((n + "_" + str(i) + ext, cfg_name + "_" + str(i) + cfg_ext))

        ret = []
        for e_file, t_file in file_list:
            dict = {}
            for data in tpl_dict['datas']:
                excle_filename = os.path.join(self.main_window.get_excel_src_path(), e_file)
                xml_data = xlrd.open_workbook(excle_filename)
                table = xml_data.sheet_by_name(data['sheet'])
                key = data['data_key']
                col_start = 1
                col_end = table.ncols
                begin_row = data['begin_row']
                dict[key] = []

                for i in range(begin_row, table.nrows):
                    data_dict = {}
                    # 如果第i行的第一列所在的单元格没有数据，则认为是空的，跳过该行
                    if str(table.cell(i, 0).value).strip() == '':
                        continue
                    for j in range(col_start - 1, col_end):
                        if table.cell(0, j).ctype == xlrd.XL_CELL_TEXT:
                            tran_key = e_file + "." + data['sheet'] + "." + table.cell(0, j).value
                            val = excel_cell_value_format(table.cell(i, j).value)
                            if translate_cols != None and tran_key in translate_cols:
                                if val in translate_words:
                                    data_dict[table.cell(0, j).value.strip()] = translate_words[val]
                                else:
                                    data_dict[table.cell(0, j).value.strip()] = val
                            else:
                                data_dict[table.cell(0, j).value.strip()] = val
                    dict[key].append(data_dict)

                if 'sort_col' in data and len(data['sort_col']) > 0:
                    dict[key].sort(key=lambda x: x[data['sort_col']], reverse=True)
            # render template with dict data
            content = engine.render(os.path.join(self.main_window.get_config_path(), tpl), dict)
            cfg_file = os.path.join(save_dir, t_file)
            dest = codecs.open(cfg_file, "w", 'utf-8')
            # 写入common代码
            _, ext = os.path.splitext(t_file)
            if tpl_dict['export_type'] == 'server':
                common_code_path = "common_server"
            else:
                common_code_path = "common_client"
            common_code_path = os.path.join(self.main_window.get_config_path(), common_code_path + ext)
            if os.path.exists(common_code_path):
                common_code = open(common_code_path, "r").read()
                if "%s" in common_code:
                    dest.write(common_code % t_file)
                else:
                    dest.write(common_code)

            content = content.replace(u"\r\n", u"\n")
            dest.write(content)
            dest.close()
            ret.append(cfg_file)
        return ret

    def on_export_all_server(self):
        save_dir = settings.get_server_export_dir()
        if not save_dir or not os.path.exists(save_dir):
            QMessageBox.information(self, u"提示", u"请先设置导出目录")
            return
        try:
            begin = time.time()
            export_files = []

            export_files_server = getattr(self, 'export_files_server')
            for key in export_files_server:
                tpl_dict = export_files_server[key]
                if tpl_dict['export_type'] == 'server':
                    ret = self.export_one_file_help(save_dir, tpl_dict)
                    export_files.extend(ret)
            end = time.time()
            msg = '\n'.join(export_files) + u"\n消耗时间：{0}秒".format(int(end - begin))
            msg_box = QMessageBox(QMessageBox.Information, u"导出成功", "导出成功!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()
        except Exception:
            msg = traceback.format_exc()
            msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()

    def on_export_all_client(self):
        self.on_export_all_client_help()

    def on_export_all_client_help(self, translate_cols = None, translate_words = None):
        # print("translate_cols:", translate_cols)
        # print("translate_words:", translate_words)
        save_dir = settings.get_client_export_dir()
        if not save_dir or not os.path.exists(save_dir):
            QMessageBox.information(self, u"提示", u"请先设置导出目录")
            return
        try:
            begin = time.time()
            export_files = []

            export_files_client = getattr(self, 'export_files_client')
            for key in export_files_client:
                tpl_dict = export_files_client[key]
                if tpl_dict['export_type'] == 'client':
                    ret = self.export_one_file_help(save_dir, tpl_dict, translate_cols = translate_cols, translate_words = translate_words)
                    export_files.extend(ret)
            end = time.time()
            msg = '\n'.join(export_files) + u"\n消耗时间：{0}秒".format(int(end - begin))
            msg_box = QMessageBox(QMessageBox.Information, u"导出成功", "导出成功!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()
        except Exception:
            msg = traceback.format_exc()
            msg_box = QMessageBox(QMessageBox.Critical, u"错误", "导出发生错误!\t\t\t\t\t\t\t\t", parent=self)
            msg_box.setDetailedText(msg)
            msg_box.exec_()

    def on_open_excelfile(self):
        sender = self.sender()
        excel = sender.property("excle")
        fileName = os.path.join(self.main_window.get_excel_src_path(), excel)
        if(os.path.exists(fileName)):
            # QDesktopServices.openUrl(QUrl.fromLocalFile(fileName))
            os.startfile(fileName)
        else:
            QMessageBox.critical(self, "error", "文件不存在：" + fileName)

    def on_show_tpl_in_explore(self):
        if self.sell_tab_clicked_row is not None:
            row = self.sell_tab_clicked_row
            col = self.sell_tab_clicked_col
            val = self.m_table.item(row, col).text()
            print("row:%s, col:%s, val:%s" % (row, col, val))
            if col == 0:
                excle_filename = os.path.join(self.excel_src_path, val)
                self.show_file_in_explore(excle_filename)
            else:
                tpl_filename = os.path.join(self.main_window.get_config_path(), val + '.tpl')
                self.show_file_in_explore(tpl_filename)

    def show_file_in_explore(self, path):
        print(path)
        if(os.path.exists(path)):
            os.system("explorer.exe /select,\"%s\"" % path.replace('/', '\\'))
            # os.system('start ' + path)
        else:
            QMessageBox.critical(self, "error", "文件不存在：" + path)
