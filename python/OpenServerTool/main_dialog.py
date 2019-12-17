# -*- coding: utf-8 -*-
"""
打包：
    pyinstaller -w  --distpath ./dist -F -i caohua.ico main_dialog.py -n open_server
todo:
    现在打包有一个很蛋疼的问题，打包成不带控制台的窗口文件后，执行子命令的popen方法都无法正常运行
    试了很久也没找到解决的办法，只能打包成带控制台的窗口才不会报错
    pyinstaller main_dialog.spec(记得把main_dialog.spec中的console改为true)
    
"""

import wx
import base_main_dialog
import os, sys
import subprocess, signal, time
from datetime import datetime
import images
import wx.dataview as dv


# 获取现在的时间
def now_datetime():
    return datetime.now()


# 只格式化时间部分的字符串
def time_str(dt=None):
    if dt is None:
        dt = now_datetime()
    return dt.strftime('%H:%M:%S')



def resource_path(relative_path):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_path, relative_path)



# Implementing BaseOpenServerDialog
class OpenServerDialog( base_main_dialog.BaseOpenServerDialog ):
    def __init__( self, parent ):
        base_main_dialog.BaseOpenServerDialog.__init__( self, parent )
        self.pwd = os.getcwd()
        self.game_dir = self.pwd
        print(self.game_dir)
        self.game_dir = "F:/work/yz_project/server/"
        os.chdir(self.game_dir)
        print(sys.executable)
        self.game_process = None
        server_id, port = self.GetConfig()

        # self.icon = wx.Icon('caohua.ico', wx.BITMAP_TYPE_ICO)
        self.icon = images.AppIcon.GetIcon()
        self.SetIcon(self.icon)  

        self.m_text_log.SetEditable(False)
        self.m_text_dir.SetValue(self.game_dir)

        total_width = self.m_dvc.GetRect().GetWidth() - 5
        col_width = int(total_width / 4)
        print("total_width:%s, col_width:%s" % (total_width, col_width))
        self.m_dvc.AppendTextColumn('game_id', width=col_width, align=wx.ALIGN_CENTER)
        self.m_dvc.AppendTextColumn('process_name', width=col_width, align=wx.ALIGN_CENTER)
        self.m_dvc.AppendTextColumn('process_pid', width=col_width, align=wx.ALIGN_CENTER)
        self.m_dvc.AppendTextColumn('ports', width=total_width - 3*col_width, align=wx.ALIGN_CENTER)
        self.m_dvc.AppendItem([server_id, "主进程", "", port])
        self.SetBtnState()
        self.AppendLog(u"工具启动成功，当前工作目录：%s\n" % self.game_dir)

    def GetConfig(self):
        obj = subprocess.Popen("escript script/get_server_id.escript", shell = True, cwd=self.game_dir, stdin=subprocess.PIPE, 
                               stdout=subprocess.PIPE ,stderr=subprocess.PIPE)
        info, err = obj.communicate()
        server_id = info.decode('gbk')

        obj = subprocess.Popen("escript ./script/get_server_port.escript", 
                               shell = True, cwd=self.game_dir, stdin=subprocess.PIPE, 
                               stdout=subprocess.PIPE ,stderr=subprocess.PIPE)
        info, err = obj.communicate()
        port = info.decode('gbk')

        return (server_id, port)

    # Handlers for BaseOpenServerDialog events.
    def OnOpenDir( self, event ):
        # os.system('explorer ' + self.game_dir)
        os.startfile(self.game_dir)

    def OnOpenWeb( self, event ):
        p = os.popen("escript script/get_admin_web_url.escript")
        url = p.readlines()[0]
        print(url)
        os.startfile(url)


    def OnStart( self, event ):
        self.AppendLog("游戏服启动中......\n")
        cmd = os.path.join(self.game_dir, "server_ctrl.bat start")  # 不知为何要加路径才能找到批处理文件 - - 
        # cmd = "server_ctrl.bat start"
        # cmd = "cmd /k \"erl\""
        # cmd = "erl"
        # startupinfo = subprocess.STARTUPINFO()
        # startupinfo.dwFlags |= subprocess.CREATE_NEW_CONSOLE
        # startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        # startupinfo.wShowWindow = subprocess.SW_HIDE
        # self.game_process = subprocess.Popen(cmd, shell=False, cwd=self.game_dir, startupinfo = startupinfo, creationflags=subprocess.CREATE_NEW_CONSOLE)
        self.game_process = subprocess.Popen(cmd, shell=False, cwd=self.game_dir, creationflags=subprocess.CREATE_NEW_CONSOLE)
        self.AppendLog(u"game process id:%s\n" % self.game_process.pid)
        self.SetBtnState()
        wx.CallLater(3000, self.CheckStart)

    def CheckStart(self):
        if self.game_process:
            # cmd = "cd %s && %s status" % (self.game_dir, os.path.join(self.game_dir, 'server_ctrl.bat'))
            # p = os.popen(cmd)
            cmd = "server_ctrl.bat status"
            p = subprocess.Popen(cmd, shell=False, cwd=self.game_dir, stdout=subprocess.PIPE)
            info, err = p.communicate()

            last_log = info.decode('gbk')
            print(last_log)
            if 'running' in last_log:
                self.AppendLog(u"游戏服启动成功：\n\t%s" % last_log)
                self.m_dvc.SetValue(self.game_process.pid, 0, 2)
            else:
                self.AppendLog(u"游戏服启动失败了！请查看log\n")
        else:
            self.AppendLog(u"CheckStart:no game process\n")


    def OnClose( self, event ):
        cmd = "%s stop" % (os.path.join(self.game_dir, 'server_ctrl.bat'))
        # cmd = "server_ctrl.bat stop"
        self.AppendLog(u"开始关闭游戏服......\n")
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        self.game_process = None
        self.m_dvc.SetValue("", 0, 2)
        
        self.AppendLog(u"游戏服关闭返回：\n\t%s" % p.stdout.read().decode('utf-8'))
        self.SetBtnState()

    def OnCleanDB( self, event ):
        cmd = "server_ctrl.bat clean_db"
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        print("clean_db succ")
        self.AppendLog(u"游戏服清档成功\n\t%s" % p.stdout.read().decode('utf-8'))
        self.SetBtnState()

    def OnCompile( self, event ):
        cmd = "cd %s && server_ctrl.bat make_debug" % self.game_dir
        # p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir, bufsize=-1)
        # p.wait()
        p = os.popen(cmd)
        # os.system("cd %s && %s" % (self.game_dir, cmd))
        print("compile succ")
        self.AppendLog(u"游戏服编译完毕:\n\t%s" % "\t".join(p.readlines()))
        # self.AppendLog("游戏服编译完毕:\n")
        self.SetBtnState()

    def OnCleanCompile( self, event ):
        cmd = "server_ctrl.bat clean"
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        print("clean succ")
        self.AppendLog(u"游戏服编译清理完毕\n\t%s" % p.stdout.read().decode('utf-8'))
        self.SetBtnState()

    def OnCloseDialog( self, event ):
        if self.game_process:
            self.AppendLog(u"正在退出中...\n")
            cmd = "server_ctrl.bat stop"
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
            p.wait()

            os.kill(self.game_process.pid, signal.CTRL_C_EVENT)
            self.AppendLog(u"退出成功\n")
        event.Skip()

    def AppendLog(self, log):
        # self.m_text_log.MoveEnd()
        # self.m_text_log.WriteText("%s %s" % (time_str(), log))
        self.m_text_log.SetEditable(True)
        self.m_text_log.GotoPos(self.m_text_log.GetLength())
        self.m_text_log.WriteText("%s %s" % (time_str(), log))
        self.m_text_log.SetEditable(False)

    def SetBtnState(self):
        if self.game_process:
            self.m_btn_start.Enable(False)
            self.m_btn_close.Enable(True)
            self.m_btn_clean_db.Enable(False)
        else:
            self.m_btn_start.Enable(True)
            self.m_btn_close.Enable(False)
            self.m_btn_clean_db.Enable(True)



app = wx.App()
dlg = OpenServerDialog(None)
val = dlg.ShowModal()
dlg.Destroy()
app.MainLoop()

