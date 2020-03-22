# -*- coding: utf-8 -*-
# 处理程序配置
from PyQt5.QtCore import *
import os


home_path = QDir.homePath()
save_file = os.path.join(home_path, "caohua_gen_config.setting")

settings = QSettings(save_file, QSettings.IniFormat)


def get_server_export_dir():
	return settings.value("/dir/server_export_dir")


def set_server_export_dir(export_dir):
	settings.setValue("/dir/server_export_dir", export_dir)
	settings.sync()


def get_client_export_dir():
	return settings.value("/dir/client_export_dir")


def set_client_export_dir(export_dir):
	settings.setValue("/dir/client_export_dir", export_dir)
	settings.sync()
