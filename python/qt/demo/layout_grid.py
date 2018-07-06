#!/usr/bin/python3
# -*- coding: utf-8 -*-


import sys
from PyQt5.QtWidgets import QWidget, QApplication, QPushButton, QGridLayout


class Example3(QWidget):

    def __init__(self):
        super().__init__()
        self.initUI()
        pass

    def initUI(self):

        grid = QGridLayout()
        self.setLayout(grid)
        names = ['cls', 'bck', '', 'close',
                 '7', '8', '9', '/',
                 '4', '5', '6', '*',
                 '1', '2', '3', '-',
                 '0', '.', '=', '+']
        poses = [(i, j) for i in range(5) for j in range(4)]

        for (x, y), name in zip(poses, names):
            if name == '':
                continue
            btn = QPushButton(name)
            grid.addWidget(btn, x, y)

        self.setGeometry(300, 300, 450, 450)
        self.setWindowTitle('网格布局--计算器')
        self.show()
        pass


def main3():
    app = QApplication(sys.argv)
    example3 = Example3()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main3()
