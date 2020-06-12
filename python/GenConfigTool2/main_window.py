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

VERSION = u"配置导出工具-v6.1    设计者：dzR    更新日期：2020-04-10    "
'''
2020-04-10:
    生成配置文件前，添加可选的先写入common_xxx.ext文件内的内容，如果存在该文件的话
    并可以带入文件名参数
2020-05-27:
    支持excel中可以配置空行，空行的数据将会被跳过
'''


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


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    # QtWidgets.QApplication.setStyle('Fusion')
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())

