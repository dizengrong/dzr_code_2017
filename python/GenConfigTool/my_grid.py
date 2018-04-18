# -*- coding: utf-8 -*-
"""
wx.grid.Grid派生类，列背景是可以设置颜色的
"""

import wx
import wx.grid as grid
import wx.lib.mixins.gridlabelrenderer as glr


class MyGrid(grid.Grid, glr.GridWithLabelRenderersMixin):
    def __init__(self, *args, **kw):
        grid.Grid.__init__(self, *args, **kw)
        glr.GridWithLabelRenderersMixin.__init__(self)

    def SetAllColBackgroudColour(self, color):
        for col in xrange(0, self.GetNumberCols()):
            self.SetColLabelRenderer(col, MyColLabelRenderer(color))


class MyColLabelRenderer(glr.GridLabelRenderer):
    def __init__(self, bgcolor):
        self._bgcolor = bgcolor

    def Draw(self, grid, dc, rect, col):
        rect.SetX(max(rect.GetX() - 1, 0))
        # rect.SetWidth(rect.GetWidth() - 1)
        dc.SetBrush(wx.Brush(self._bgcolor))
        dc.SetPen(wx.TRANSPARENT_PEN)
        dc.DrawRectangle(rect)
        hAlign, vAlign = grid.GetColLabelAlignment()
        text = grid.GetColLabelValue(col)
        self.DrawBorder(grid, dc, rect)
        self.DrawText(grid, dc, rect, text, hAlign, vAlign)


