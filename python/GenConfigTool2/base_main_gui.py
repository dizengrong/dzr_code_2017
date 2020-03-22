# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'base_main_gui.ui'
#
# Created by: PyQt5 UI code generator 5.13.0
#
# WARNING! All changes made in this file will be lost!


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_BaseMainFrame(object):
    def setupUi(self, BaseMainFrame):
        BaseMainFrame.setObjectName("BaseMainFrame")
        BaseMainFrame.resize(1100, 723)
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap(":/image/ico.ico"), QtGui.QIcon.Normal, QtGui.QIcon.On)
        BaseMainFrame.setWindowIcon(icon)
        self.centralwidget = QtWidgets.QWidget(BaseMainFrame)
        self.centralwidget.setObjectName("centralwidget")
        self.horizontalLayout = QtWidgets.QHBoxLayout(self.centralwidget)
        self.horizontalLayout.setContentsMargins(0, 0, 0, 0)
        self.horizontalLayout.setSpacing(0)
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.tab_container = QtWidgets.QTabWidget(self.centralwidget)
        self.tab_container.setIconSize(QtCore.QSize(20, 23))
        self.tab_container.setElideMode(QtCore.Qt.ElideNone)
        self.tab_container.setObjectName("tab_container")
        self.horizontalLayout.addWidget(self.tab_container)
        BaseMainFrame.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(BaseMainFrame)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1100, 26))
        self.menubar.setObjectName("menubar")
        self.menu = QtWidgets.QMenu(self.menubar)
        self.menu.setObjectName("menu")
        BaseMainFrame.setMenuBar(self.menubar)
        self.action = QtWidgets.QAction(BaseMainFrame)
        self.action.setObjectName("action")
        self.menu.addAction(self.action)
        self.menubar.addAction(self.menu.menuAction())

        self.retranslateUi(BaseMainFrame)
        self.tab_container.setCurrentIndex(-1)
        QtCore.QMetaObject.connectSlotsByName(BaseMainFrame)

    def retranslateUi(self, BaseMainFrame):
        _translate = QtCore.QCoreApplication.translate
        BaseMainFrame.setWindowTitle(_translate("BaseMainFrame", "配置导出工具"))
        self.menu.setTitle(_translate("BaseMainFrame", "帮助"))
        self.action.setText(_translate("BaseMainFrame", "关于"))
import resource_rc
