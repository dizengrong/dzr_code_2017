# -*- coding: utf-8 -*-
"""
打包：
    pyinstaller -w  --distpath ./dist -F -i caohua.ico main_dialog.py
    
"""

import wx
import base_main_dialog
import os
import subprocess, signal, time
from datetime import datetime
import images


# 获取现在的时间
def now_datetime():
    return datetime.now()


# 只格式化时间部分的字符串
def time_str(dt=None):
    if dt is None:
        dt = now_datetime()
    return dt.strftime('%H:%M:%S')



# class MyProcess(Process):
#     def __init__(self, name):
#         super(MyProcess,self).__init__()
#         self.name=name
# ​
#     def run(self):
#         print('%s is running' %self.name)
#         time.sleep(3)
#         print('%s has done' %self.name)


# Implementing BaseOpenServerDialog
class OpenServerDialog( base_main_dialog.BaseOpenServerDialog ):
    def __init__( self, parent ):
        base_main_dialog.BaseOpenServerDialog.__init__( self, parent )
        self.pwd = os.getcwd()
        self.game_dir = os.path.abspath(os.path.join(self.pwd, '..'))
        # self.game_dir = "F:/work/yz_project/server/"
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
        self.m_dvc.AppendTextColumn('ports', width=col_width, align=wx.ALIGN_CENTER)
        self.m_dvc.AppendItem([server_id, "主进程", "", port])
        self.SetBtnState()

    def GetConfig(self):
        obj = subprocess.Popen("escript ./script/get_server_id.escript", 
                               shell = True, cwd=self.game_dir, stdin=subprocess.PIPE, 
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
        os.system('explorer ' + self.game_dir)

    def OnStart( self, event ):
        cmd = "server_ctrl.bat start"
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.CREATE_NEW_CONSOLE
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        # startupinfo.wShowWindow = subprocess.SW_HIDE
        self.game_process = subprocess.Popen(cmd, shell=True, cwd=self.game_dir, startupinfo = startupinfo)
        print(self.game_process.pid)
        self.AppendLog("游戏服启动中......\n")
        self.SetBtnState()
        wx.CallLater(3000, self.CheckStart)

    def CheckStart(self):
        if self.game_process.poll() is None:
            self.AppendLog("游戏服启动成功\n")
            self.m_dvc.SetValue(self.game_process.pid, 0, 2)
        else:
            self.AppendLog("游戏服启动失败了！请查看log\n")


    def OnClose( self, event ):
        cmd = "server_ctrl.bat stop"
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        self.game_process = None
        self.m_dvc.SetValue("", 0, 2)
        
        self.AppendLog("游戏服关闭成功\n\t%s" % p.stdout.read().decode('utf-8'))
        self.SetBtnState()

    def OnCleanDB( self, event ):
        cmd = "server_ctrl.bat clean_db"
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        print("clean_db succ")
        self.AppendLog("游戏服清档成功\n\t%s" % p.stdout.read().decode('utf-8'))
        self.SetBtnState()

    def OnCompile( self, event ):
        cmd = "server_ctrl.bat make_debug"
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        print("compile succ")
        self.AppendLog("游戏服编译完毕:\n\t%s" % p.stdout.read().decode('utf-8').replace('\n', '\n\t')[:-1])
        self.SetBtnState()

    def OnCleanCompile( self, event ):
        cmd = "server_ctrl.bat clean"
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
        p.wait()
        print("clean succ")
        self.AppendLog("游戏服编译清理完毕\n\t%s" % p.stdout.read().decode('utf-8'))
        self.SetBtnState()

    def OnCloseDialog( self, event ):
        if self.game_process:
            self.AppendLog("正在退出中...\n")
            cmd = "server_ctrl.bat stop"
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=self.game_dir)
            p.wait()

            os.kill(self.game_process.pid, signal.CTRL_C_EVENT)
            while self.game_process.poll() is None:
                time.sleep(0.5)
            self.AppendLog("退出成功\n")
            time.sleep(0.5)
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

