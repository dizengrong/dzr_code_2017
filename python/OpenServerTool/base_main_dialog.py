# -*- coding: utf-8 -*-

###########################################################################
## Python code generated with wxFormBuilder (version Oct 26 2018)
## http://www.wxformbuilder.org/
##
## PLEASE DO *NOT* EDIT THIS FILE!
###########################################################################

import wx
import wx.xrc
import wx.dataview
# import wx.richtext
import wx.stc as stc

###########################################################################
## Class BaseOpenServerDialog
###########################################################################

class BaseOpenServerDialog ( wx.Dialog ):

	def __init__( self, parent ):
		wx.Dialog.__init__ ( self, parent, id = wx.ID_ANY, title = u"开服工具（windows下）", pos = wx.DefaultPosition, size = wx.Size( 575,604 ), style = wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER )

		self.SetSizeHints( wx.DefaultSize, wx.DefaultSize )

		bSizer1 = wx.BoxSizer( wx.VERTICAL )

		bSizer2 = wx.BoxSizer( wx.HORIZONTAL )

		self.m_staticText1 = wx.StaticText( self, wx.ID_ANY, u"游戏服路径：", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText1.Wrap( -1 )

		bSizer2.Add( self.m_staticText1, 0, wx.ALL|wx.ALIGN_CENTER_VERTICAL, 5 )

		self.m_text_dir = wx.TextCtrl( self, wx.ID_ANY, wx.EmptyString, wx.DefaultPosition, wx.DefaultSize, wx.TE_READONLY )
		bSizer2.Add( self.m_text_dir, 1, wx.ALL|wx.ALIGN_CENTER_VERTICAL, 5 )

		self.m_btn_open_dir = wx.Button( self, wx.ID_ANY, u"打开所在目录", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer2.Add( self.m_btn_open_dir, 0, wx.ALL|wx.ALIGN_CENTER_VERTICAL, 5 )


		bSizer1.Add( bSizer2, 0, wx.EXPAND, 0 )

		sbSizer1 = wx.StaticBoxSizer( wx.StaticBox( self, wx.ID_ANY, u"操作" ), wx.HORIZONTAL )

		self.m_btn_start = wx.Button( sbSizer1.GetStaticBox(), wx.ID_ANY, u"启动", wx.DefaultPosition, wx.DefaultSize, 0 )
		sbSizer1.Add( self.m_btn_start, 0, wx.ALL, 5 )

		self.m_btn_close = wx.Button( sbSizer1.GetStaticBox(), wx.ID_ANY, u"关闭", wx.DefaultPosition, wx.DefaultSize, 0 )
		sbSizer1.Add( self.m_btn_close, 0, wx.ALL, 5 )

		self.m_btn_clean_db = wx.Button( sbSizer1.GetStaticBox(), wx.ID_ANY, u"清档", wx.DefaultPosition, wx.DefaultSize, 0 )
		sbSizer1.Add( self.m_btn_clean_db, 0, wx.ALL, 5 )

		self.m_button4 = wx.Button( sbSizer1.GetStaticBox(), wx.ID_ANY, u"编译", wx.DefaultPosition, wx.DefaultSize, 0 )
		sbSizer1.Add( self.m_button4, 0, wx.ALL, 5 )

		self.m_button5 = wx.Button( sbSizer1.GetStaticBox(), wx.ID_ANY, u"清理编译", wx.DefaultPosition, wx.DefaultSize, 0 )
		sbSizer1.Add( self.m_button5, 0, wx.ALL, 5 )


		bSizer1.Add( sbSizer1, 0, wx.EXPAND, 0 )

		sbSizer2 = wx.StaticBoxSizer( wx.StaticBox( self, wx.ID_ANY, u"进程列表" ), wx.VERTICAL )

		fgSizer1 = wx.FlexGridSizer( 0, 4, 0, 0 )
		fgSizer1.AddGrowableCol( 0 )
		fgSizer1.AddGrowableCol( 1 )
		fgSizer1.AddGrowableCol( 2 )
		fgSizer1.AddGrowableCol( 3 )
		fgSizer1.SetFlexibleDirection( wx.BOTH )
		fgSizer1.SetNonFlexibleGrowMode( wx.FLEX_GROWMODE_SPECIFIED )

		self.m_staticText5 = wx.StaticText( sbSizer2.GetStaticBox(), wx.ID_ANY, u"游戏服ID", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText5.Wrap( -1 )

		self.m_staticText5.SetFont( wx.Font( wx.NORMAL_FONT.GetPointSize(), wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD, False, wx.EmptyString ) )

		fgSizer1.Add( self.m_staticText5, 0, wx.ALL|wx.ALIGN_CENTER_HORIZONTAL, 5 )

		self.m_staticText2 = wx.StaticText( sbSizer2.GetStaticBox(), wx.ID_ANY, u"进程名称", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText2.Wrap( -1 )

		self.m_staticText2.SetFont( wx.Font( wx.NORMAL_FONT.GetPointSize(), wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD, False, wx.EmptyString ) )

		fgSizer1.Add( self.m_staticText2, 0, wx.ALL|wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_CENTER_HORIZONTAL, 5 )

		self.m_staticText3 = wx.StaticText( sbSizer2.GetStaticBox(), wx.ID_ANY, u"进程PID", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText3.Wrap( -1 )

		self.m_staticText3.SetFont( wx.Font( wx.NORMAL_FONT.GetPointSize(), wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD, False, wx.EmptyString ) )

		fgSizer1.Add( self.m_staticText3, 0, wx.ALL|wx.ALIGN_CENTER_HORIZONTAL|wx.ALIGN_CENTER_VERTICAL, 5 )

		self.m_staticText4 = wx.StaticText( sbSizer2.GetStaticBox(), wx.ID_ANY, u"使用的端口", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText4.Wrap( -1 )

		self.m_staticText4.SetFont( wx.Font( wx.NORMAL_FONT.GetPointSize(), wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD, False, wx.EmptyString ) )

		fgSizer1.Add( self.m_staticText4, 0, wx.ALL|wx.ALIGN_CENTER_HORIZONTAL|wx.ALIGN_CENTER_VERTICAL, 5 )


		sbSizer2.Add( fgSizer1, 0, wx.EXPAND, 0 )

		self.m_dvc = wx.dataview.DataViewListCtrl( sbSizer2.GetStaticBox(), wx.ID_ANY, wx.DefaultPosition, wx.DefaultSize, wx.dataview.DV_HORIZ_RULES|wx.dataview.DV_NO_HEADER|wx.dataview.DV_VERT_RULES )
		self.m_dvc.SetMinSize( wx.Size( -1,60 ) )

		sbSizer2.Add( self.m_dvc, 1, wx.ALL|wx.EXPAND, 5 )


		bSizer1.Add( sbSizer2, 0, wx.EXPAND, 5 )

		# self.m_text_log = wx.richtext.RichTextCtrl( self, wx.ID_ANY, wx.EmptyString, wx.DefaultPosition, wx.DefaultSize, wx.TE_READONLY|wx.VSCROLL|wx.HSCROLL|wx.NO_BORDER|wx.WANTS_CHARS )
		self.m_text_log = stc.StyledTextCtrl( self, wx.ID_ANY)
		bSizer1.Add( self.m_text_log, 1, wx.EXPAND |wx.ALL, 5 )


		self.SetSizer( bSizer1 )
		self.Layout()

		self.Centre( wx.BOTH )

		# Connect Events
		self.Bind( wx.EVT_CLOSE, self.OnCloseDialog )
		self.m_btn_open_dir.Bind( wx.EVT_BUTTON, self.OnOpenDir )
		self.m_btn_start.Bind( wx.EVT_BUTTON, self.OnStart )
		self.m_btn_close.Bind( wx.EVT_BUTTON, self.OnClose )
		self.m_btn_clean_db.Bind( wx.EVT_BUTTON, self.OnCleanDB )
		self.m_button4.Bind( wx.EVT_BUTTON, self.OnCompile )
		self.m_button5.Bind( wx.EVT_BUTTON, self.OnCleanCompile )

	def __del__( self ):
		pass


	# Virtual event handlers, overide them in your derived class
	def OnCloseDialog( self, event ):
		event.Skip()

	def OnOpenDir( self, event ):
		event.Skip()

	def OnStart( self, event ):
		event.Skip()

	def OnClose( self, event ):
		event.Skip()

	def OnCleanDB( self, event ):
		event.Skip()

	def OnCompile( self, event ):
		event.Skip()

	def OnCleanCompile( self, event ):
		event.Skip()


