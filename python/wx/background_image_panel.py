# -*- coding: utf-8 -*-

import wx


class BackGroundImagePanel(wx.Panel):
    """带一张背景图片的panel"""
    def __init__(self, parent, bg_image = None):
        super(BackGroundImagePanel, self).__init__(parent = parent)
        self.SetBackgroundStyle(wx.BG_STYLE_CUSTOM)
        self.bg_image = wx.Bitmap(bg_image)
        self._width, self._height = self.bg_image.GetSize()

        self.Bind(wx.EVT_SIZE, self.OnSize)
        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_ERASE_BACKGROUND, self.OnEraseBackground)

    def OnSize(self, size):
        self.Layout()
        self.Refresh()

    def OnEraseBackground(self, evt):
        pass

    def OnPaint(self, evt):
        dc = wx.BufferedPaintDC(self)
        self.Draw(dc)

    def Draw(self, dc):
        cliWidth, cliHeight = self.GetClientSize()
        if not cliWidth or not cliHeight:
            return
        dc.Clear()
        xPos = (cliWidth - self._width) / 2
        yPos = (cliHeight - self._height) / 2
        dc.DrawBitmap(self.bg_image, xPos, yPos)
