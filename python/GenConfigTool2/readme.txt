将.ui文件转为python代码文件：
pyuic5 base_main_gui.ui -o base_main_gui.py
pyuic5 tab_conf.ui -o tab_conf_ui.py
pyuic5 tab_lang.ui -o tab_lang_ui.py

将.qrc文件转为python代码文件：
pyrcc5 resource.qrc -o resource_rc.py

打包：
pyinstaller main_window.spec

