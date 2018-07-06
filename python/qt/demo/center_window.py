#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
from PyQt5.QtWidgets import QWidget, QDesktopWidget, QApplication


class Example(QWidget):

    def __init__(self):
        super().__init__()

        self.initUI()

    def initUI(self):

        self.resize(250, 150)
        self.center()

        self.setWindowTitle('Center')
        self.show()

    def center(self):

        qr = self.frameGeometry()  # 得到主窗口的大小4
        cp = QDesktopWidget().availableGeometry().center()  # 得到显示器的分辨率并得到中间点的位置
        qr.moveCenter(cp)  # 将自己的中心点放到qr的中心点
        self.move(qr.topLeft())  # 将窗口的左上角移动到qr的左上角


if __name__ == '__main__':

    app = QApplication(sys.argv)
    ex = Example()
    sys.exit(app.exec_())
