#!/usr/bin/python
# -*- coding: utf-8 -*-


import os
import re
import time
import shutil

# 路径配置
conf_file     = "/home/p12_server_b/work/cnf.config"
install_path = {
    "agent_ctr" : "/home/p12_server_b/agent_ctr/lib/agent_ctr-0.0.1/ebin/",
    "dbm"       : "/home/p12_server_b/dbm/lib/dbm-0.0.1/ebin/",
    "gateway"   : "/home/p12_server_b/gateway/lib/gateway-0.0.1/ebin/",
    "mynet"     : "/home/p12_server_b/mynet/lib/mynet-0.0.1/ebin/",
    "scene_ctr" : "/home/p12_server_b/scene_ctr/lib/scene_ctr-0.0.1/ebin/",
    "world"     : "/home/p12_server_b/world/lib/world-0.0.1/ebin/",
}

project_path = "/opt/.jenkins/jobs/p12_release/workspace/"
beam_path    = os.path.join(project_path, "ebin/")
code_path    = os.path.join(project_path, "p12_svr/src/")
pt_path      = os.path.join(project_path, "p12_svr/src/pt")
cfg_path     = os.path.join(project_path, "p12_res/src/")
git_cmd1     = "git checkout master -f"
git_cmd2     = "git pull"


def print_blankline():
    print("")


def print_head(head):
    max_len = 80
    len1 = (max_len - len(head)) / 2
    len2 = max_len - len(head) - len1
    s1 = '-' * len1
    s2 = '-' * len2
    print("%s %s %s" % (s1, head, s2))


def my_print(s):
    print(s)


def copy_beam(beam_path, install_path, modules):
    for mod in modules:
        mod = mod + ".beam"
        shutil.copyfile(os.path.join(beam_path, mod),
                        os.path.join(install_path, mod))


# 更新git库
for git_path in [project_path, code_path, pt_path, cfg_path]:
    print_head(git_path)
    os.system("cd " + git_path + " && " + git_cmd1)
    os.system("cd " + git_path + " && " + git_cmd2)
    print_blankline()

# 编译
print_head("compile")
compile_result = os.popen("sh make_erl").read()
compile_result = compile_result.split("\n")
map(my_print, compile_result)
compile_modules = []
for line in compile_result:
    if line.endswith(".erl"):
        mod, _ = os.path.splitext(line.split("/")[-1:][0])
        compile_modules.append(mod)
print_blankline()

print_head("modified module")
map(my_print, compile_modules)
if compile_modules == []:
    print("no module changed, end operation!\n")
    exit()
print_blankline()

# 复制beam文件到安装目录
print_head("copy beam")
for path in install_path:
    print("to path %s" % (install_path[path]))
    copy_beam(beam_path, install_path[path], compile_modules)
print_blankline()

# 执行热更新
print_head("hot reload")
cnf = open(conf_file).read()
nodes = []
for m in re.findall(r"{name,.*?}", cnf, re.M | re.S):
    nodes.append(m.split('\'')[1])

cookie = re.findall(r"{cookie,(.*?)}", cnf, re.M | re.S)[0].strip()
for node in nodes:
    [name, ip] = node.split('@')
    ebin_path = "./ebin"  # maybe need to be change
    args = " -s sm_tool -extra " + node + " " + \
           " hot_reload " + " ".join(compile_modules)
    cmd = "erl -name sm_tool@" + ip + " -noinput -detached -setcookie " + \
          cookie + " -pa " + ebin_path + args
    print(cmd)
    os.system(cmd)
    time.sleep(1)

