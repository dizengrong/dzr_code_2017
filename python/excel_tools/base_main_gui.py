# -*- coding: utf-8 -*- 

###########################################################################
## Python code generated with wxFormBuilder (version Jun 17 2015)
## http://www.wxformbuilder.org/
##
## PLEASE DO "NOT" EDIT THIS FILE!
###########################################################################

import wx
import wx.xrc
import wx.dataview

###########################################################################
## Class BaseMainFrame
###########################################################################

class BaseMainFrame ( wx.Frame ):
	
	def __init__( self, parent ):
		wx.Frame.__init__ ( self, parent, id = wx.ID_ANY, title = u"翻译导入导出工具", pos = wx.DefaultPosition, size = wx.Size( 1158,300 ), style = wx.DEFAULT_FRAME_STYLE|wx.TAB_TRAVERSAL )
		
		self.SetBackgroundColour( wx.SystemSettings.GetColour( wx.SYS_COLOUR_BTNFACE ) )
		
		bSizer1 = wx.BoxSizer( wx.VERTICAL )
		
		fgSizer2 = wx.FlexGridSizer( 0, 2, 0, 0 )
		fgSizer2.SetFlexibleDirection( wx.HORIZONTAL )
		fgSizer2.SetNonFlexibleGrowMode( wx.FLEX_GROWMODE_SPECIFIED )
		
		bSizer2 = wx.BoxSizer( wx.HORIZONTAL )
		
		self.m_dir_src_import = wx.DirPickerCtrl( self, wx.ID_ANY, wx.EmptyString, u"Select a folder", wx.DefaultPosition, wx.DefaultSize, wx.DIRP_DEFAULT_STYLE )
		self.m_dir_src_import.SetMinSize( wx.Size( 400,-1 ) )
		
		bSizer2.Add( self.m_dir_src_import, 1, wx.ALL, 5 )
		
		self.m_button1 = wx.Button( self, wx.ID_ANY, u"导入原始文件列表", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer2.Add( self.m_button1, 0, wx.ALL, 5 )
		
		
		fgSizer2.Add( bSizer2, 0, wx.EXPAND, 5 )
		
		bSizer21 = wx.BoxSizer( wx.HORIZONTAL )
		
		self.m_dir_src_export = wx.DirPickerCtrl( self, wx.ID_ANY, wx.EmptyString, u"Select a folder", wx.DefaultPosition, wx.DefaultSize, wx.DIRP_DEFAULT_STYLE )
		self.m_dir_src_export.SetMinSize( wx.Size( 400,-1 ) )
		
		bSizer21.Add( self.m_dir_src_export, 1, wx.ALL, 5 )
		
		self.m_button11 = wx.Button( self, wx.ID_ANY, u"导出原始文件列表", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer21.Add( self.m_button11, 0, wx.ALL, 5 )
		
		self.m_button9 = wx.Button( self, wx.ID_ANY, u"导出增量列表", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer21.Add( self.m_button9, 0, wx.ALL, 5 )
		
		
		fgSizer2.Add( bSizer21, 1, wx.EXPAND, 5 )
		
		bSizer211 = wx.BoxSizer( wx.HORIZONTAL )
		
		self.m_dir_translate_import = wx.DirPickerCtrl( self, wx.ID_ANY, wx.EmptyString, u"Select a folder", wx.DefaultPosition, wx.DefaultSize, wx.DIRP_DEFAULT_STYLE )
		bSizer211.Add( self.m_dir_translate_import, 1, wx.ALL, 5 )
		
		self.m_button111 = wx.Button( self, wx.ID_ANY, u"导入翻译文件列表", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer211.Add( self.m_button111, 0, wx.ALL, 5 )
		
		
		fgSizer2.Add( bSizer211, 1, wx.EXPAND, 5 )
		
		bSizer13 = wx.BoxSizer( wx.HORIZONTAL )
		
		self.m_button8 = wx.Button( self, wx.ID_ANY, u"写入到原始文件", wx.DefaultPosition, wx.DefaultSize, 0 )
		bSizer13.Add( self.m_button8, 0, wx.ALL, 5 )
		
		self.m_staticText1 = wx.StaticText( self, wx.ID_ANY, u"导入翻译不区分是否是增量的，都会正确的写入的", wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_staticText1.Wrap( -1 )
		self.m_staticText1.SetForegroundColour( wx.Colour( 128, 0, 0 ) )
		
		bSizer13.Add( self.m_staticText1, 0, wx.ALL|wx.ALIGN_CENTER_VERTICAL, 5 )
		
		
		fgSizer2.Add( bSizer13, 1, wx.EXPAND, 5 )
		
		
		bSizer1.Add( fgSizer2, 0, wx.ALL|wx.EXPAND, 0 )
		
		self.m_data_result = wx.dataview.DataViewListCtrl( self, wx.ID_ANY, wx.DefaultPosition, wx.DefaultSize, wx.dataview.DV_HORIZ_RULES|wx.dataview.DV_ROW_LINES|wx.dataview.DV_SINGLE|wx.dataview.DV_VERT_RULES )
		bSizer1.Add( self.m_data_result, 1, wx.ALL|wx.EXPAND, 0 )
		
		
		self.SetSizer( bSizer1 )
		self.Layout()
		
		self.Centre( wx.BOTH )
		
		# Connect Events
		self.m_button1.Bind( wx.EVT_BUTTON, self.on_import_src )
		self.m_button11.Bind( wx.EVT_BUTTON, self.on_export_src )
		self.m_button9.Bind( wx.EVT_BUTTON, self.on_export_src_increase )
		self.m_button111.Bind( wx.EVT_BUTTON, self.on_import_translate )
		self.m_button8.Bind( wx.EVT_BUTTON, self.on_write_translate_to_src )
	
	def __del__( self ):
		pass
	
	
	# Virtual event handlers, overide them in your derived class
	def on_import_src( self, event ):
		event.Skip()
	
	def on_export_src( self, event ):
		event.Skip()
	
	def on_export_src_increase( self, event ):
		event.Skip()
	
	def on_import_translate( self, event ):
		event.Skip()
	
	def on_write_translate_to_src( self, event ):
		event.Skip()
	

