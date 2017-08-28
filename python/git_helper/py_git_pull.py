# -*- coding: utf-8 -*-

import msvcrt
import os
import traceback
import paramiko
import time
import subprocess
import dulwich.client
from gittle import Gittle
from ConfigParser import ConfigParser

repo_list = []
config = ConfigParser()
config.read('./git_config.ini')
for sect in config.sections():
    branch_name = config.get(sect, 'branch_name')
    path = config.get(sect, 'path')
    url = config.get(sect, 'url')
    key_file = config.get(sect, 'key_file')
    repo_list.append((branch_name, path, url, key_file))

max_len = 0
for branch_name, repo_path, repo_url, key_file in repo_list:
    max_len = max(max_len, len(repo_path))

max_len = max_len + 20


def fix_dulwich_problem(func, repo_conf):
    try:
        from dulwich.client import ParamikoSSHVendor
        # for older dulwich versions -> The class was moved
    except ImportError:
        from dulwich.contrib.paramiko_vendor import ParamikoSSHVendor
        # newer versions of dulwich

    pkey = paramiko.RSAKey.from_private_key(open(repo_conf[3]))
    ssh_vendor = ParamikoSSHVendor()
    ssh_vendor.ssh_kwargs = {
        'pkey': pkey
    }

    def _get_ssh_vendor():
        return ssh_vendor

    old_get_ssh_vendor = dulwich.client.get_ssh_vendor
    dulwich.client.get_ssh_vendor = _get_ssh_vendor

    func(repo_conf)

    dulwich.client.get_ssh_vendor = old_get_ssh_vendor


def do_pull(repo_conf):
    branch_name, repo_path, repo_url, key_file = repo_conf
    len1 = (max_len - len(repo_path)) / 2
    len2 = max_len - len(repo_path) - len1
    s1 = '-' * len1
    s2 = '-' * len2
    print("%s %s %s" % (s1, repo_path, s2))
    if not os.path.exists(os.path.join(repo_path, '.git')):
        answer = ''
        while not (answer == 'y' or answer == 'n'):
            promt = u"目录：%s不是git库，是否要执行clone？(y/n):" % (repo_path)
            answer = raw_input(promt.encode("GBK"))
        if answer == 'y':
            repo = Gittle.clone(repo_url, repo_path)
        else:
            print(u"该库操作已中止\n")
            return
    else:
        repo = Gittle(repo_path, origin_uri=repo_url)

    if not (branch_name in repo.branches):
        print("branch_name %s not exist! checkout failed!\n" % (branch_name))
        return
    elif branch_name != repo.active_branch:
        print("need switch branch")
        try:
            repo.switch_branch(branch_name)
        except Exception:
            # 因为切换时会删除老分支的文件，可能会存在重复删除文件的情况，因此这个错误可以忽略
            pass

    old_path = os.getcwd()
    os.chdir(repo_path)
    os.system("git reset --hard")
    os.chdir(old_path)

    repo.pull(branch_name=branch_name)
    ret = repo.last_commit
    print("update to: %s %s" %
          (ret.sha().hexdigest(), ret.message.decode("UTF-8").strip()))
    print("at branch %s commit time: %s" % (branch_name, time.strftime(
        "%Y-%m-%d %H:%M:%S", time.localtime(ret.commit_time))))
    print("\n")


try:
    for r in repo_list:
        fix_dulwich_problem(do_pull, r)
    print(u"更新完毕.")
except Exception, e:
    print traceback.format_exc()
    print(u"更新失败，请检查配置是否正确.")
finally:
    print("Press any key to exit.\n")
    msvcrt.getch()
