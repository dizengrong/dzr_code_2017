#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QWidget, QLabel, QApplication, QGridLayout, QLineEdit, QTextEdit


class Example4(QWidget):

    def __init__(self):
        super().__init__()
        self.initUI()
        pass

    def initUI(self):

        title = QLabel('Title')
        author = QLabel('Author')
        review = QLabel('Review')

        titleEdit = QLineEdit()
        authorEdit = QLineEdit()
        reviewEdit = QTextEdit()

        grid = QGridLayout()
        grid.setSpacing(10)

        grid.addWidget(title, 0, 0)
        grid.addWidget(titleEdit, 0, 1)

        grid.addWidget(author, 1, 0)
        grid.addWidget(authorEdit, 1, 1)

        grid.addWidget(review, 2, 0, 1, 1, Qt.AlignTop)
        grid.addWidget(reviewEdit, 2, 1, 5, 1)

        self.setLayout(grid)
        self.setGeometry(300, 300, 450, 450)
        self.setWindowTitle('网格布局--文本审阅窗口')
        self.show()
        pass


def main4():
    app = QApplication(sys.argv)
    example4 = Example4()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main4()
