#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
from PyQt5.QtWidgets import QWidget, QLabel, QApplication


class Example1(QWidget):

    def __init__(self):
        super().__init__()
        self.initUI()
        pass

    def initUI(self):
        label1 = QLabel('第一个', self)
        label1.move(15, 10)

        label2 = QLabel('第2个', self)
        label2.move(35, 40)

        label3 = QLabel('第3个', self)
        label3.move(55, 70)

        self.setGeometry(300, 300, 450, 450)
        self.setWindowTitle('绝对定位示例')
        self.show()


def main1():
    app = QApplication(sys.argv)
    example1 = Example1()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main1()
