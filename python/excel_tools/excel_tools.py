# -*- coding: utf-8 -*-

import sys
import wx
from main_gui import MainGui
import logging

logging.basicConfig(level=logging.DEBUG)


if __name__ == '__main__':
    app = wx.App()
    main_gui = MainGui(None)
    main_gui.Show()
    app.MainLoop()
