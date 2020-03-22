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
        if export_type == 's':
            self.sheets[sheet]['server'] = tpl[:-4]
        elif export_type == 'c':
            self.sheets[sheet]['client'] = tpl[:-4]

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
            if query_str in sheet or query_str in self.sheets[sheet]['server'] or query_str in self.sheets[sheet]['server']:
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

    def on_export_all_server(self):
        pass

    def on_export_all_client(self):
        pass

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
            'tpl':'data_xxx.lua.tpl',
            'excle_file':对应的excel文件名称
            'datas':[{'data_key':data_key, 'sheet':sheet, 'begin_row':begin_row, 'sort_col':sort_col}]
        }
        """
        doc = minidom.parse('config/cfg_module.xml')
        root = doc.documentElement
        self.export_files = {}  # {'data_xxx.lua.tpl':tpl_dict}
        self.export_items = []  # [ExportItem]
        for node in get_xmlnode(root, 'file'):
            excle_file = get_attrvalue(node, 'excle_file')
            export_item = ExportItem(excle_file)
            for node2 in get_xmlnode(node, 'export'):
                tpl_dict = {}
                tpl_dict['tpl'] = get_attrvalue(node2, 'tpl')
                tpl_dict['excle_file'] = excle_file
                datas = []
                for node3 in get_xmlnode(node2, 'dict'):
                    d = {}
                    d['data_key'] = get_attrvalue(node3, 'data_key')
                    d['sheet'] = get_attrvalue(node3, 'sheet')
                    d['begin_row'] = int(get_attrvalue(node3, 'begin_row'))
                    d['sort_col'] = get_attrvalue(node3, 'sort_col')
                    datas.append(d)
                    export_item.add_sheet(d['sheet'], get_attrvalue(node2, 'type'), tpl_dict['tpl'])
                tpl_dict['datas'] = datas
                self.export_files[tpl_dict['tpl']] = tpl_dict
            self.export_items.append(export_item)

    def init_table(self):
        self.m_table
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

    def on_cell_double_click(self, row, col):
        if self.m_table.item(row, col) is None:
            return
        try:
            begin = time.time()
            tpl_file = self.m_table.item(row, col).text()
            tpl_file = tpl_file + ".tpl"
            export_dict = self.export_files[tpl_file]
            ret = self.export_one_file_help(save_dir, export_dict)
            end = time.time()
            return "|".join(["1", ret + u"\n消耗时间：{0}秒".format(int(end - begin))])
        except Exception:
            exception_log = traceback.format_exc()
            add_log(exception_log)
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

    def on_open_excelfile(self):
        sender = self.sender()
        excel = sender.property("excle")
        fileName = os.path.join(self.main_window.get_excel_src_path(), excel)
        if(os.path.exists(fileName)):
            # QDesktopServices.openUrl(QUrl.fromLocalFile(fileName))
            os.startfile(fileName)
        else:
            QMessageBox.critical(self, "error", "文件不存在：" + fileName)


