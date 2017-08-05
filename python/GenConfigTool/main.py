# -*- coding: utf-8 -*- 

import wx, os, tenjin
import wx.grid
import wx.lib.dialogs
import gettext
import fuzzyfinder
import traceback
import xdrlib, sys, xlrd, datetime
from xml.dom import minidom
from tenjin.helpers import *
from tenjin.escaped import *

## create engine object
engine    = tenjin.SafeEngine(path=[os.path.join(os.getcwd(), 'config')])

def get_attrvalue(node, attrname):
	return node.getAttribute(attrname) if node else ''

def get_nodevalue(node, index = 0):
	return node.childNodes[index].nodeValue if node else ''

def get_xmlnode(node, name):
	return node.getElementsByTagName(name) if node else []


def format(value):
	if isinstance(value, float):
		if int(value) == value: return int(value)
		else: return value
	elif isinstance(value, str):
		return as_escaped(value)
	else:
		try:
			return int(value)
		except Exception, e:
			return as_escaped(value)

VERSION = u"配置导出工具-v.03    设计者：dzR"

GRID_CONTEXT_MENU = [
	(wx.NewId(), u"导出该行的所有文件", "OnExportAll")
]

class MyFrame1 ( wx.Frame ):
	
	def __init__( self, parent ):
		wx.Frame.__init__ ( self, parent, id = wx.ID_ANY, title = u"配置导出工具", 
							pos = wx.DefaultPosition, size = wx.Size( 551,415 ), 
							style = wx.DEFAULT_FRAME_STYLE|wx.TAB_TRAVERSAL )
		
		self.init_other()
		self.init_menubar()

		self.icon = wx.Icon('wxpdemo.ico', wx.BITMAP_TYPE_ICO)
		self.SetIcon(self.icon)  
		bSizer1 = wx.BoxSizer( wx.VERTICAL )
		
		self.m_searchCtrl1 = wx.SearchCtrl( self, wx.ID_ANY, wx.EmptyString, wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_searchCtrl1.ShowSearchButton( True )
		self.m_searchCtrl1.ShowCancelButton( False )
		bSizer1.Add( self.m_searchCtrl1, 0, wx.ALIGN_CENTER|wx.EXPAND, 5 )
		
		self.init_grid()
		bSizer1.Add( self.m_grid1, 1, wx.ALIGN_CENTER|wx.EXPAND, 5 )
		
		self.m_staticText1 = wx.StaticText( self, wx.ID_ANY, VERSION, 
											wx.DefaultPosition, wx.DefaultSize, wx.ALIGN_CENTRE )
		self.m_staticText1.Wrap( -1 )
		self.m_staticText1.SetForegroundColour( wx.Colour( 204, 50, 50 ) )
		self.m_staticText1.SetBackgroundColour( wx.Colour( 255, 255, 255 ) )
		
		bSizer1.Add( self.m_staticText1, 0, wx.ALIGN_CENTER|wx.EXPAND, 5 )
		
		self.SetSizer( bSizer1 )
		self.Layout()
		self.Fit()
		
		self.Centre( wx.BOTH )

		self.m_searchCtrl1.Bind( wx.EVT_TEXT, self.OnSearch )

	def init_other(self):
		self.cwd = os.path.abspath('.')
		self.excle_src_path = os.path.abspath('..')
		self.last_search_str = None

	def init_menubar(self):
		self.menu_action = {
			101: self.OnExportAll2
		}
		menuBar = wx.MenuBar()

		menu1 = wx.Menu()
		menu1.Append(101, u"一键导出所有配置")

		menuBar.Append(menu1, u"工具")
		self.SetMenuBar(menuBar)

		self.Bind(wx.EVT_MENU, self.OnMenuEvent, id=101)

	def OnMenuEvent(self, event):
		id = event.GetId()
		print('Event id: %d\n' % (id))
		self.menu_action.get(id)()


	def init_grid(self):
		colum_size = self.LoadConfigXML()
		max_columns = 0
		for key in self.export_files.keys():
			max_columns = max(max_columns, len(self.export_files[key]))

		self.m_grid1 = wx.grid.Grid( self, wx.ID_ANY, wx.DefaultPosition, wx.DefaultSize, 0 )
		self.m_grid1.CreateGrid(1 + len(self.export_files), max_columns + 1)
		self.m_grid1.Bind( wx.grid.EVT_GRID_CELL_LEFT_DCLICK, self.OnCellDoubleClick )
		self.m_grid1.Bind( wx.grid.EVT_GRID_CELL_RIGHT_CLICK, self.OnCellRightClick )
		self.m_grid1.EnableEditing( False )
		self.m_grid1.EnableGridLines( True )
		self.m_grid1.SetMargins( 0, 0 )
		
		self.m_grid1.SetColLabelAlignment( wx.ALIGN_CENTRE, wx.ALIGN_CENTRE )
		self.m_grid1.SetRowLabelAlignment( wx.ALIGN_CENTRE, wx.ALIGN_CENTRE )
		self.m_grid1.SetDefaultCellAlignment( wx.ALIGN_LEFT, wx.ALIGN_TOP )

		self.m_grid1.SetColLabelValue(0, u'Excel文件(双击打开)')
		for row in xrange(1, max_columns + 1):
			self.m_grid1.SetColLabelValue(row, u'配置' + str(row) + u'(双击导出)')

		self.fill_grid(self.export_files, True)

	def LoadConfigXML(self):
		doc  = minidom.parse('config/cfg.xml')
		root = doc.documentElement
		self.export_files = {}
		self.export_list = {}
		colum_size = 0
		for node in get_xmlnode(root, 'file'):
			excle_file  = get_attrvalue(node, 'excle_file')
			colum_size = max(colum_size, len(excle_file))
			self.export_files[excle_file] = []
			for node2 in get_xmlnode(node, 'export'):
				tpl_dict = {}
				tpl = get_attrvalue(node2, 'tpl')
				colum_size = max(colum_size, len(tpl))
				tpl_type = int(get_attrvalue(node2, 'type'))

				
				self.export_files[excle_file].append(tpl)

				tpl_dict['tpl'] = tpl
				tpl_dict['tpl_type'] = int(tpl_type)
				tpl_dict['excle_file'] = excle_file
				datas = []
				for node3 in get_xmlnode(node2, 'dict'):
					d = {}
					d['data_key']  = get_attrvalue(node3, 'data_key')
					d['sheet']     = get_attrvalue(node3, 'sheet')
					d['col_start'] = int(get_attrvalue(node3, 'col_start'))
					d['col_end']   = int(get_attrvalue(node3, 'col_end'))
					d['begin_row'] = int(get_attrvalue(node3, 'begin_row'))
					d['sort_col']  = get_attrvalue(node3, 'sort_col')
					datas.append(d)
				tpl_dict['datas'] = datas

				self.export_list[tpl_dict['tpl']] = tpl_dict
		print self.export_files
		print self.export_list
		return colum_size

	def fill_grid(self, export_files, auto_size = False):
		row = 0
		for excle_file in export_files.keys():
			self.m_grid1.SetCellValue(row, 0, excle_file)
			col = 1
			for cfg in export_files[excle_file]:
				cfg_dict = self.export_list[cfg]
				tpl = cfg_dict['tpl']
				name, ext = os.path.splitext(tpl)
				if cfg_dict['tpl_type'] == 1:
					tpl_name = u'后端:' + name
				else :
					tpl_name = u'前端:' + name
				self.m_grid1.SetCellValue(row, col, tpl_name)
				col += 1
			row += 1
		if auto_size:
			self.m_grid1.AutoSize()

	def OnSearch( self, event ):
		print ("on search %s" % (self.m_searchCtrl1.GetValue()))
		wx.CallLater(200, self.show_search, None, None)

	def show_search(self, *args, **kwargs):
		searchstr = self.m_searchCtrl1.GetValue()
		if self.last_search_str == searchstr:
			return
		self.last_search_str = searchstr

		print searchstr
		self.m_grid1.ClearGrid()
		if searchstr != '':
			matched = fuzzyfinder.fuzzyfinder(searchstr, self.export_files)
			print self.export_files
			print matched
			self.fill_grid(matched)
		else:
			self.fill_grid(self.export_files)
		self.Layout()

	def OnCellRightClick(self, event):
		menu = wx.Menu()
		for id, title, action in GRID_CONTEXT_MENU:
			it = wx.MenuItem(menu, id, title)
			menu.Append(it)
			self.Bind(wx.EVT_MENU, getattr(self, action), it)
		self.sell_tab_clicked_row = event.GetRow()
		self.PopupMenu(menu)
		
		menu.Destroy()
		self.sell_tab_clicked_row = None

	def OnExportAll2(self):
		# print self.export_list.values() 
		self.OnExport(self.export_list.values())

	def OnExportAll(self, event):
		if self.sell_tab_clicked_row != None:
			row = self.sell_tab_clicked_row
			val = self.m_grid1.GetCellValue(row, 0)
			tpls = [self.export_list[x] for x in self.export_files[val]]
			# print tpls 
			self.OnExport(tpls)

	def OnCellDoubleClick(self, event):
		row = event.GetRow()
		col = event.GetCol()
		val = self.m_grid1.GetCellValue(row, col)
		if col == 0:
			excle_filename = os.path.join(self.excle_src_path, val.encode("GBK"))
			os.startfile(excle_filename)
			
		else:
			tpl = val[3:] + ".tpl"
			print tpl
			if self.export_list.has_key(tpl):
				self.OnExport([self.export_list[tpl]])

	def OnExport(self, tpl_dicts):
		dlg = wx.DirDialog(None, message = u"选择导出" + u"目录", style = wx.DD_DEFAULT_STYLE | wx.DD_DIR_MUST_EXIST | wx.DD_CHANGE_DIR)
		if dlg.ShowModal() == wx.ID_OK:
			path = dlg.GetPath()
			succ_files = ""
			for tpl_dict in tpl_dicts:
				cfg_file, ext = os.path.splitext(tpl_dict['tpl'])
				cfg_file = os.path.join(path, cfg_file)
				try:
					self.DoExport(tpl_dict, path)
					succ_files = succ_files + cfg_file + "\n\t"
				except Exception, e:
					msg = u"已成功导出的文件:\n" + succ_files + "\n" \
						  + u"导出失败的文件:\n\t" + cfg_file + "\n" \
						  + u"错误信息:\n" + traceback.format_exc()
					msg_dlg = wx.lib.dialogs.ScrolledMessageDialog(self, msg, u"导出失败")
					msg_dlg.ShowModal()
					return
			msg = u"成功导出的文件列表:\n" + succ_files + "\n"
			msg_dlg = wx.lib.dialogs.ScrolledMessageDialog(self, msg, u"导出成功")
			msg_dlg.ShowModal()


	def DoExport(self, tpl_dict, dest_dir):
		print tpl_dict
		dict = {}
		tpl  = tpl_dict['tpl']
		cfg, ext = os.path.splitext(tpl)
		excle_file = tpl_dict['excle_file']
		for data in tpl_dict['datas']:
			excle_filename = os.path.join(self.excle_src_path, excle_file.encode("GBK"))
			print excle_filename
			xml_data  = xlrd.open_workbook(excle_filename)
			table     = xml_data.sheet_by_name(data['sheet'])
			key       = data['data_key']
			col_start = data['col_start']
			col_end   = data['col_end']
			begin_row = data['begin_row']
			dict[key] = []
			for i in range(begin_row, table.nrows):
				tmp = []
				for j in xrange(col_start - 1, col_end):
					tmp.append(format(table.cell(i, j).value))
				dict[key].append(tmp)

			sort_col = data['sort_col']
			if sort_col is '':
				pass
			else:
				sort_col = int(sort_col) - 1
				dict[key].sort(cmp=lambda x,y: cmp(x[sort_col], y[sort_col]), reverse = True)
		## render template with dict data
		content  = engine.render(os.path.join(self.cwd, 'config'.encode("GBK"), tpl.encode("GBK")), dict)
		cfg_file = os.path.join(dest_dir, cfg)
		dest     = open(cfg_file, "w")
		content  = content.replace("\r\n", "\n")
		dest.write(content)
		dest.close()
		return cfg_file
		

	def __del__( self ):
		pass
	
class MyApp(wx.App):
	def OnInit(self):
		frame = MyFrame1(None)
		self.SetTopWindow(frame)

		print "Print statements go to this stdout window by default."

		frame.Show(True)
		return True
		
app = MyApp(redirect=False)
app.MainLoop()
