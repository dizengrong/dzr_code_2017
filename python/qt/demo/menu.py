#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
from PyQt5.QtWidgets import QMainWindow, QAction, qApp, QApplication
from PyQt5.QtGui import QIcon


class Example(QMainWindow):

    def __init__(self):
        super().__init__()

        self.initUI()

    def initUI(self):

        exit = QAction(QIcon('test.png'), 'Exit', self)
        # QAction是菜单栏、工具栏或者快捷键的动作的组合
        # 创建了一个图标、一个exit的标签
        exit.setShortcut('Ctrl+Q')
        # 创建快捷键
        exit.setStatusTip('Exit application')
        exit.triggered.connect(qApp.quit)

        self.statusBar()  # 创建状态栏

        menubar = self.menuBar()  # 创建菜单栏
        fileMenu = menubar.addMenu('File')
        # 为菜单栏添加file信息
        fileMenu.addAction(exit)
        # 并关联了点击退出应用的事件
        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Menubar')
        self.show()


if __name__ == '__main__':

    app = QApplication(sys.argv)
    ex = Example()
    sys.exit(app.exec_())
