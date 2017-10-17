# -*- coding: utf-8 -*-

import wx
import wx.lib.agw.labelbook as LB
from wx.lib.agw.fmresources import *
import images


class SamplePane(wx.Panel):
    """
    Just a simple test window to put into the LabelBook.
    """
    def __init__(self, parent, colour, label):

        wx.Panel.__init__(self, parent, style=0)#wx.BORDER_SUNKEN)
        self.SetBackgroundColour(wx.Colour(255,255,255))

        label = label + "\nEnjoy the LabelBook && FlatImageBook demo!"
        static = wx.StaticText(self, -1, label, pos=(10, 10))
        # self.SetMinSize(wx.Size(-1, 200))


class HospitalStatePanel (wx.Panel):
    def __init__(self, parent):
        wx.Panel.__init__(self, parent, id=wx.ID_ANY, pos=wx.DefaultPosition, size=wx.Size(
            500, 300), style=wx.TAB_TRAVERSAL)

        bSizer6 = wx.BoxSizer(wx.VERTICAL)

        self.m_scrolledWindow1 = wx.ScrolledWindow(
            self, wx.ID_ANY, wx.DefaultPosition, wx.DefaultSize, wx.HSCROLL | wx.VSCROLL)
        self.m_scrolledWindow1.SetScrollRate(5, 5)
        bSizer7 = wx.BoxSizer(wx.VERTICAL)

        bSizer7.Add(self.init_hospital_book(self.m_scrolledWindow1), 1, wx.EXPAND | wx.ALL, 0)
        # bSizer7.Add(SamplePane(self.m_scrolledWindow1, wx.WHITE, u"中心医院"), 0, wx.EXPAND | wx.ALL, 0)

        self.m_scrolledWindow1.SetSizer(bSizer7)
        self.m_scrolledWindow1.Layout()
        bSizer7.Fit(self.m_scrolledWindow1)
        bSizer6.Add(self.m_scrolledWindow1, 1, wx.EXPAND | wx.ALL, 0)

        self.SetSizer(bSizer6)
        self.Layout()
        print self.book.GetSize()
        print self.GetSize()

    def init_hospital_book(self, parent):
        style = INB_FIT_BUTTON | INB_SHOW_ONLY_IMAGES | INB_WEB_HILITE | INB_BOLD_TAB_SELECTION | INB_LEFT | INB_NO_RESIZE | INB_FIT_LABELTEXT
        self.book = LB.LabelBook(parent, -1, agwStyle=style)
        self.imagelist = wx.ImageList(32, 32)
        self.imagelist.Add(images.Devil.GetBitmap())
        self.book.AssignImageList(self.imagelist)

        self.book.SetColour(INB_TAB_AREA_BACKGROUND_COLOUR, wx.Colour(132, 164, 213))
        self.book.SetColour(INB_ACTIVE_TAB_COLOUR, wx.Colour(255, 255, 255))
        self.book.SetColour(INB_TABS_BORDER_COLOUR, wx.Colour(0, 0, 204))
        self.book.SetColour(INB_TEXT_COLOUR, wx.BLACK)
        self.book.SetColour(INB_ACTIVE_TEXT_COLOUR, wx.BLACK)
        self.book.SetColour(INB_HILITE_TAB_COLOUR, wx.Colour(191, 216, 216))
        # self.book.SetFontSizeMultiple(1.0)

        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"中心医院"), u"中心医院", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.AddPage(SamplePane(self.book, wx.WHITE, u"妇幼保健院 "), u"妇幼保健院 ", True, 0)
        self.book.SetSelection(0)
        self.book.SetMinSize(wx.Size(-1, 500))
        return self.book


# for test
if __name__ == '__main__':
    app = wx.App()
    frame = wx.Frame(None, size=(500, 200))
    panel = HospitalStatePanel(frame)
    frame.Show()
    app.MainLoop()
