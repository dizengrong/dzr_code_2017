# -*- coding: utf-8 -*-
'''
Lua配置生成功能的tab页
'''
from xml.dom import minidom
from common import *
from PyQt5.QtWidgets import QTableWidgetItem, QAction, QMenu, QFileDialog, QMessageBox
from PyQt5.QtCore import Qt, QTimer
import time
import traceback
import os
import xlrd
from tenjin.helpers import *
from tenjin.escaped import *


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


def init_tab(self):
    LoadLuaConfigXML(self)
    max_columns = 0
    for key in self.lua_export_files.keys():
        max_columns = max(max_columns, len(self.lua_export_files[key]))

    self.m_tab_lua.setRowCount(1 + len(self.lua_export_files))
    self.m_tab_lua.setColumnCount(max_columns + 1)

    self.m_tab_lua.verticalHeader().setFixedWidth(30)
    self.m_tab_lua.verticalHeader().setDefaultAlignment(Qt.AlignCenter)
    self.m_tab_lua.horizontalHeader().setStretchLastSection(True)
    self.m_tab_lua.horizontalHeader().setFixedHeight(30)
    header_labels = [u'Excel文件(双击打开)']
    for row in range(1, max_columns + 1):
        header_labels.append(u'配置' + str(row) + u'(双击导出)')
    self.m_tab_lua.setHorizontalHeaderLabels(header_labels)

    fill_grid(self, self.lua_export_files, True)
    init_event(self)


def LoadLuaConfigXML(self):
    doc = minidom.parse('config/cfg_lua.xml')
    root = doc.documentElement
    self.lua_export_files = {}
    self.lua_export_list = {}
    colum_size = 0
    for node in get_xmlnode(root, 'file'):
        excle_file = get_attrvalue(node, 'excle_file')
        colum_size = max(colum_size, len(excle_file))
        self.lua_export_files[excle_file] = []
        for node2 in get_xmlnode(node, 'export'):
            tpl_dict = {}
            tpl = get_attrvalue(node2, 'tpl')
            colum_size = max(colum_size, len(tpl))
            tpl_type = int(get_attrvalue(node2, 'type'))

            self.lua_export_files[excle_file].append(tpl)

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

            self.lua_export_list[tpl_dict['tpl']] = tpl_dict


def fill_grid(self, export_files, auto_size=False):
    row = 0
    for excle_file in export_files.keys():
        self.m_tab_lua.setItem(row, 0, QTableWidgetItem(excle_file))
        col = 1
        for cfg in export_files[excle_file]:
            cfg_dict = self.lua_export_list[cfg]
            tpl = cfg_dict['tpl']
            name, ext = os.path.splitext(tpl)
            if cfg_dict['tpl_type'] == 1:
                tpl_name = u'S:' + name
            else:
                tpl_name = u'C:' + name
            self.m_tab_lua.setItem(row, col, QTableWidgetItem(tpl_name))
            col += 1
        # if row % 2 == 1:
        #     self.set_row_color(row, wx.SystemSettings.GetColour(wx.SYS_COLOUR_3DFACE))
        row += 1
    if auto_size:
        self.m_tab_lua.resizeColumnsToContents()


def init_event(self):
    self.m_search_edit_lua.textChanged['QString'].connect(self.on_search_lua)
    self.m_tab_lua.cellDoubleClicked['int','int'].connect(self.on_cell_double_click_lua)
    self.m_tab_lua.setContextMenuPolicy(Qt.CustomContextMenu)
    self.m_tab_lua.customContextMenuRequested['QPoint'].connect(self.on_context_menu_lua)


def on_cell_double_click_lua(self, row, col):
    # print("on_cell_double_click row:%s, col:%s" % (row, col))
    if self.m_tab_lua.item(row, col) is None:
        return
    val = self.m_tab_lua.item(row, col).text()
    if col == 0:
        excle_filename = os.path.join(self.excle_src_path, val)
        self.OpenFile(excle_filename)
    else:
        tpl = val[2:] + ".tpl"
        if tpl in self.lua_export_list:
            OnExport(self, [self.lua_export_list[tpl]])


def OnExport(self, tpl_dicts):
    path = QFileDialog.getExistingDirectory(self, caption=u"选择导出目录", directory=self.get_last_dir(TAB_TYPE_LUA))
    # print(path)
    if os.path.exists(path):
        self.set_last_dir(TAB_TYPE_LUA, path)
        succ_files = ""
        begin = time.time()
        for tpl_dict in tpl_dicts:
            cfg_file, ext = os.path.splitext(tpl_dict['tpl'])
            cfg_file = os.path.join(path, cfg_file)
            try:
                DoExport(self, tpl_dict, path)
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
    render_dict = {}
    tpl = tpl_dict['tpl']
    cfg, ext = os.path.splitext(tpl)
    excle_file = tpl_dict['excle_file']
    for data in tpl_dict['datas']:
        print("excle_file: %s" % (excle_file))
        excle_filename = os.path.join(self.excle_src_path, excle_file)
        xml_data = xlrd.open_workbook(excle_filename)
        table = xml_data.sheet_by_name(data['sheet'])
        key = data['data_key']
        most_appear_key = key + '_most_appear'
        col_start = data['col_start']
        col_end = data['col_end']
        begin_row = data['begin_row']
        render_dict[key] = []
        render_dict[most_appear_key] = []

        for i in range(begin_row, table.nrows):
            data_dict = {}
            for j in range(col_start - 1, col_end):
                data_dict[table.cell(0, j).value.strip()] = format(table.cell(i, j).value)
            render_dict[key].append(data_dict)

        most_appear_arrary = []
        for j in range(col_start - 1, col_end):
            temp_dict = {}
            max_num = 0
            max_num_key = None
            for i in range(begin_row, table.nrows):
                val = format(table.cell(i, j).value)
                if val not in temp_dict:
                    temp_dict[val] = 1
                else:
                    temp_dict[val] += 1
                    if temp_dict[val] > max_num:
                        max_num = temp_dict[val]
                        max_num_key = val
            most_appear_arrary.append(max_num_key)

        render_dict[most_appear_key] = most_appear_arrary

        sort_col = data['sort_col']
        if sort_col is '':
            pass
        else:
            render_dict[key].sort(key=lambda x: x[sort_col], reverse=True)
    # render template with dict data
    content = engine.render(os.path.join(self.cwd, 'config_lua', tpl), render_dict)
    cfg_file = os.path.join(dest_dir, cfg)
    dest = open(cfg_file, "w", encoding='UTF-8')
    content = content.replace("\r\n", "\n")
    dest.write(content)
    dest.close()
    return cfg_file

