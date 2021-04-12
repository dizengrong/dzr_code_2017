# -*- coding: utf-8 -*-

import sys
import os
import traceback
import xlrd
from base_main_gui import Ui_BaseMainFrame
from tab_module_conf import TabModuleConfig
from tab_lang import TabLang
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


VERSION = u"配置导出工具-v6.4    设计者：dzR    更新日期：2020-02-03    "
'''
2020-04-10:
    生成配置文件前，添加可选的先写入common_xxx.ext文件内的内容，如果存在该文件的话
    并可以带入文件名参数
2020-05-27:
    支持excel中可以配置空行，空行的数据将会被跳过
2020-09-28:
    导出浮点数据时，由之前的保留2位小数改为保留4位小数
2020-12-05:
    增加多语言导出功能
2020-12-14:
    修复当导出的后端文件名与前端文件名一样时，全部导出功能无法导出的bug
2021-02-03:
    修复多语言提取中文时，固定从源文件的第三行还是读的bug
2021-04-12:
    增加导出多个同样内容文件的功能
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
        # self.excel_src_path = u'F:/work/slg/slg_design/5_配置表'
        # self.config_path = u'F:/work/slg/slg_design/5_配置表/config_gen_tool/config'

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

        self.m_tab_lang = TabLang(self.tab_container, self)
        icon1 = QtGui.QIcon()
        icon1.addPixmap(QtGui.QPixmap(":/image/tab_conf.png"), QtGui.QIcon.Normal, QtGui.QIcon.On)
        self.tab_container.addTab(self.m_tab_lang, icon1, u"多语言配置")

        self.tab_container.setCurrentIndex(0)


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    # QtWidgets.QApplication.setStyle('Fusion')
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())

