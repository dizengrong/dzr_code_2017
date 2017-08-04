#-*- coding: utf8 -*-

# Requires wxPython. &nbsp;This sample demonstrates:
#
# - single file exe using wxPython as GUI.

from distutils.core import setup
import py2exe
import sys

# If run without args, build executables, in quiet mode.

if len(sys.argv) == 1:
	sys.argv.append("py2exe")
	sys.argv.append("-q")


excludes = ["pywin", "pywin.debugger", "pywin.debugger.dbgcon",
            "pywin.dialogs", "pywin.dialogs.list", "win32com.client"]
includes=["encodings","encodings.*"]
setup(
options = {"py2exe": {"compressed": 1,
					  "optimize": 2,
					  "ascii": 0,
					  "includes":includes,
					  "excludes": excludes, # COM stuff we don't want
					  "dll_excludes": ["MSVCP90.dll"],
					  "bundle_files": 1 #所有文件打包成一个exe文件
					  }
		  },
name = "GenConfigTool",  
zipfile = None,
windows = [{"script":"main.py"}],
data_files = [
			("config", ["config/cfg.xml", "config/cfg_stone.erl.tpl"]),
			(".", ["wxpdemo.ico"]),
			(".", ["ReadMe.txt"])
    	     ]
)

############################################################
