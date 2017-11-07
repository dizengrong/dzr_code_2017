# -*- coding: utf-8 -*-


import wx
from background_image_panel import BackGroundImagePanel
import wx.lib.platebtn as platebtn
from wx.lib.embeddedimage import PyEmbeddedImage


def on_login_button_clicked(event):
    print("clicked")


Devil = PyEmbeddedImage(
    b"iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAABrpJ"
    b"REFUWIXtlluMlVcVx3/7u57LzLkMc5gbw2UovFRupQ1INdRkkkrIPDRpLSFREqk8oFKrPhmR"
    b"oEkfNLFJ39SQkrZGJGRMarCpVWmlLa2OCjOtpVBmgJnOfc79zHf/tg/nO5PTEQEbE1/6T/45"
    b"315n7b3+e+21sjd8iv8zRPPgtKKc9aV8UArxfT0Mf/4lcI+BocMXNME+BT4XQi6UtCqCigJz"
    b"oeQNH055cO44uKfB8BTlGwKOqvDW42G49+4FmGrx4Z9uSt98J+988JupwmzFe6mi8NjKroS6"
    b"bmOqNbcqKWKtOnpMxbMCrIrH3ERNXr9SrsxOLwatIYMrs8bAvY91Z7q3ZIyz37xU2h/KzO0E"
    b"qM2DR6QwWztzu9ZoG81W22ipFQr39XQl4jv2dJlpLKHnC4iZBeTEHCyUMGoW6bQm+j7TbspJ"
    b"J55NZ+974KEHkh2dveqNkXln+r35Hw9K+fpdZ+AFSKmKMvX5desSLYZB1XG4MH6d7dtBjYNq"
    b"gtDqs2QAoQuhDUFNMjQs2L2uj5iuU3Vdzo+OLi5K2fkEVG4nQGse3IDWFVJyZWGOvkwbw9OT"
    b"rO4FrQW0JKgxgdCbBDgQGBIUQU8nDH00zqbObq7lFyiDnIcUdxCgND4kCB3ObtycM4uexd8n"
    b"b7Kyw6NrLWgtAq1VoKVBzwqMrEDPgJ6K/ktCzxrIZFyGJm5Q8izWb8zGdDgrl2V5OZZqwIB9"
    b"3e3xL9+7tT3eVsjT2SVJrRR4cfj6JcmTb4f88SPYuUHQ2S5wEHz1lZAnL4Scm4dtGUFvAlYY"
    b"kJYh2b52pVhyEr+zg7E/wbu3zcAx0DR4ZuuWlSnn0hRIiVDr5/3sqKQ3BdcOaRy4X/Dt34fo"
    b"GcFP/hqyOiu4ckBl/3rB0ashiibq85A478+zeWNbSoNnji076mYIgB9Bf097/Mxnt3aknXeu"
    b"o2cEepZ6qrMCLQtmZNMyAi0OXgGcgsQvSrwC2HlJUASvIHELEq8Ise1dXLicL02VnEePwh+i"
    b"o44jxBmggpRPKwAm7Ovtbkn5ExVkWPdCggxBhhIR1ItOehBa4JchdCT4kT0ARYKUEtmYK8Gf"
    b"rtHTnkiZsE+CKoX4IfAEMA4EwEgjNbuzKxLCvzgTLSiRvkD6IN16uwW2RGgCGUhQIptVb8PQ"
    b"q1N61OcE9eX9gk3bPW0C2O3BTl3KUQEnpZQGoAmQGkAIuVhMZcSGMNBRanGCqXKUik+OlJak"
    b"V1cIIVeA6Tg8DpwU4FJnvTgCSGuGigxCNgwOkuzoIJHLMTo6yrZt2zBNE9M0UdV604yMjLBp"
    b"06aPBQvDkKGhIfr6+rBtm9nz57l++DCGJggg3QHXJiA7Df2dUT1A1AUqlLxFD+l56D09qKkU"
    b"ALqu33Jnmnbrom72N7q68F0Hz/ZRoQSQhyNVeHYCdn1MgAJzds1Da0niTU7eMdDdCPALBTRF"
    b"wbIDFJgD2AyFCnytDL/9EDYsCQBeX5i3ZFxXsC9fvuWCdyOg2W5duYKphCyUHAksXUjb4M0S"
    b"/KoEJ5cEOHBqYqZWzrVr5J9//n+SgfkXXySb0pgs2GUHTjX7VeFEFXa9AesVAB9eWyg5lpbQ"
    b"8D+8SnVo6BNloOFfHR7GHRtFM1UKNc/y4bVmvzJkK0ANQgXgOPg+PPXutWJ59eoEY0eO4C0s"
    b"/MdAjW64lQCvVOKfBw+yqk3lvclq2YenjoMPcBrUX8BABV4ow5sPw9jSbfg9+PVsxR0r2H6Q"
    b"M1yG9+4lnJ39rzIgy2X+0t9Pyi2Td8Nw0vKtSbj/u/CzH8Cr12CmDC+VYbYK+6DpOhYgyzBw"
    b"8UapoKQM2pVFRvbs4caJE8gwvKOAm6dO8daOHbRU5tCTGv+YqSnXocOC75Tg0Dz0z8L4NHzr"
    b"Kuw8BBNR3CUYQOwg7LhHcGZrbyqZM1V1fMZHJpKsO3CAnoEBkmvXEiYSqJZFbXycqZdfZuy5"
    b"5wjyC/SkBbO+5OJMTV6GiSpMSphwYXgO3v4bfABYgB3RbQhQgHiDD0FfP5zMpYzOzd2tMcX2"
    b"KRY9bHRc18N1HHTTwNB1YoFLulVDmiqX5hbdmZqX/yU8fbW+w0YwaxkbtlpzBmJNImJJaPkK"
    b"7F8FhzNJXV2TMuIrErowNAVdUXD9ANcLmK/58mbVtYuWL0dgcBBe9WCxaZfWLb4t6k81f/lz"
    b"SQcSgBkJMtPQ8kV4cC3saYEtCmQExCXYAZSK8P5l+PM5uGSBA3gRGxeO00QLqEW/cnkNNENE"
    b"NdEQYkTitIhqdGwiYvQKIKR+z/sR3aYdu5Ht3wLdLRoBlSY2oyGgwYaoT3Fb/At4CANJRbmY"
    b"kwAAAABJRU5ErkJggg==")


class ColoredPanel(wx.Window):
    def __init__(self, parent, color):
        wx.Window.__init__(self, parent, -1, style = wx.SIMPLE_BORDER)
        self.SetBackgroundColour(color)
        if wx.Platform == '__WXGTK__':
            self.SetBackgroundStyle(wx.BG_STYLE_CUSTOM)

def makeColorPanel(parent, color):
    p = wx.Panel(parent, -1)
    win = ColoredPanel(p, color)
    p.win = win

    def OnCPSize(evt, win=win):
        win.SetPosition((0, 0))
        win.SetSize(evt.GetSize())
    p.Bind(wx.EVT_SIZE, OnCPSize)
    return p


app = wx.App()
frame = wx.Frame(None, size=(400, 300))
box = wx.BoxSizer(wx.VERTICAL)
# panel = wx.Panel(frame)
# btn = platebtn.PlateButton(
#     panel, wx.ID_ANY, "PlateButton", devil, style=platebtn.PB_STYLE_GRADIENT | platebtn.PB_STYLE_NOBG)
# btn.Bind(wx.EVT_BUTTON, on_login_button_clicked)

listbook = wx.Listbook(frame, wx.ID_ANY, style=wx.BK_DEFAULT)
listbook.AddPage(makeColorPanel(listbook, "blue"), "qqqqqqqqqqqqqqqqqq", imageId=0)
listbook.AddPage(makeColorPanel(listbook, "blue"), "11111111", imageId=0)
listbook.AddPage(makeColorPanel(listbook, "blue"), "33333333333333", imageId=0)
box.Add(listbook, 1, wx.ALL | wx.GROW, 1)

frame.SetSizer(box)
frame.SetAutoLayout(True)
frame.Show()
app.MainLoop()
