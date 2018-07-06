# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'main.ui'
#
# Created by: PyQt5 UI code generator 5.11.2
#
# WARNING! All changes made in this file will be lost!

from PyQt5 import QtCore, QtGui, QtWidgets

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(800, 600)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.verticalLayout_2 = QtWidgets.QVBoxLayout(self.centralwidget)
        self.verticalLayout_2.setContentsMargins(0, 0, 0, 0)
        self.verticalLayout_2.setSpacing(0)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.verticalLayout = QtWidgets.QVBoxLayout()
        self.verticalLayout.setObjectName("verticalLayout")
        self.horizontalLayout = QtWidgets.QHBoxLayout()
        self.horizontalLayout.setContentsMargins(5, 0, -1, 0)
        self.horizontalLayout.setSpacing(5)
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.label = QtWidgets.QLabel(self.centralwidget)
        self.label.setObjectName("label")
        self.horizontalLayout.addWidget(self.label)
        self.m_search_edit = QtWidgets.QLineEdit(self.centralwidget)
        self.m_search_edit.setObjectName("m_search_edit")
        self.horizontalLayout.addWidget(self.m_search_edit)
        self.verticalLayout.addLayout(self.horizontalLayout)
        self.m_table = QtWidgets.QTableWidget(self.centralwidget)
        self.m_table.setEditTriggers(QtWidgets.QAbstractItemView.NoEditTriggers)
        self.m_table.setSelectionMode(QtWidgets.QAbstractItemView.SingleSelection)
        self.m_table.setObjectName("m_table")
        self.m_table.setColumnCount(0)
        self.m_table.setRowCount(0)
        self.verticalLayout.addWidget(self.m_table)
        self.verticalLayout_2.addLayout(self.verticalLayout)
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 800, 23))
        self.menubar.setObjectName("menubar")
        self.menu = QtWidgets.QMenu(self.menubar)
        self.menu.setObjectName("menu")
        MainWindow.setMenuBar(self.menubar)
        self.m_statusbar = QtWidgets.QStatusBar(MainWindow)
        self.m_statusbar.setSizeGripEnabled(True)
        self.m_statusbar.setObjectName("m_statusbar")
        MainWindow.setStatusBar(self.m_statusbar)
        self.menu_export_all = QtWidgets.QAction(MainWindow)
        self.menu_export_all.setObjectName("menu_export_all")
        self.menu.addAction(self.menu_export_all)
        self.menubar.addAction(self.menu.menuAction())

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "配置导出工具"))
        self.label.setText(_translate("MainWindow", "搜索："))
        self.menu.setTitle(_translate("MainWindow", "工具"))
        self.menu_export_all.setText(_translate("MainWindow", "一键导出所有配置"))

