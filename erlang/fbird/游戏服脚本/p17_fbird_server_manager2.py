# -*- coding: utf-8 -*-
#!/usr/bin/python
'''
项目运维脚本
'''

import os
import sys
import urllib2
import json
from datetime import datetime
import my_util
import time
import subprocess
import zipfile


# ==================== 常量定义（不同的项目就只修改这些常量）===================
GAME_NAME = "p17"
AGENT = "fbird"
CODES_DIR = "/data/codes/"
RELOAD_CODES_DIR = "/data/codes/reload/"

GAME_BASE_DIR = os.path.join("/data/", AGENT, GAME_NAME)

# 基础ansible的hosts配置文件路径
ANSIBLE_HOSTS_PATH = "./p17_fbird_hosts"

# gm运营后台获取游戏服列表的地址(获取的游戏服配置，只是外服的，传过来就过滤掉内网服了)
GM_URL = "https://p17-uc.lynlzqy.com/GetGMInfo?Get=svr-no-name-ip"
# ==================== 常量定义（不同的项目就只修改这些常量）===================



# 获取当前时间的字符串，用来作为文件名用的
def filename_time_str(ext):
    time_tuple = datetime.now()
    return time_tuple.strftime('%Y_%m_%d_%H_%M_%S') + ext


def parse_ansible_hosts():
    '''return {ip:host_config}'''
    fd = open(ANSIBLE_HOSTS_PATH, 'r')
    base_hosts = fd.read()
    hosts = {}
    for line in base_hosts.split('\n'):
        if 'ansible_host' not in line:
            continue
        host = line.split(' ')[1]
        if 'ansible_host' not in host:
            continue
        ip = host.split('=')[1]
        hosts[ip] = line
    fd.close()
    return hosts


def fetch_servers_from_gm():
    data = urllib2.urlopen(GM_URL).read()
    json_datas = json.loads(data)
    return json_datas['data']
    # return [
    #     {
    #         'ip': '120.92.229.76',
    #         'inner_ip': '120.92.229.76',
    #         'svr_no': '101',
    #         'net_port': '9903',
    #         'web_port': '50103',
    #         'gm_port': '5103'
    #     }
    # ]


# 获取云服务器列表:[ip]
def get_server_list():
    game_servers = fetch_servers_from_gm()
    length = len(game_servers)
    ret_list = []
    for i in range(0, length):
        ip = game_servers[i].get('ip')
        if ip not in ret_list:
            ret_list.append(ip)
    
    return ret_list


# 获取云服务器列表，并写入到文件
def dump_server_list():
    server_list = get_server_list()
    hosts = parse_ansible_hosts()
    save_file = 'server_ip_' + filename_time_str('')
    fd = open(save_file, 'w')
    for ip in server_list:
        if ip not in hosts:
            print("警告：%s中没有找到ip为：%s的配置！" % (ANSIBLE_HOSTS_PATH, str(ip)))
        else:
            fd.write(hosts[ip] + '\n')
    fd.close()
    print('save server list to:%s' % save_file)


# 获取游戏服列表，按外网ip组织，一个ip下面有多个游戏服
def get_game_server_list():
    game_servers = fetch_servers_from_gm()
    length = len(game_servers)
    game_dict = {}
    for i in range(0, length):
        ip = game_servers[i].get('ip')
        if ip not in game_dict:
            game_dict[ip] = []

        game_info = {
            'serverid': str(game_servers[i].get('svr_no')),
            'server_host': game_servers[i].get('inner_ip'),
            'net_port': str(game_servers[i].get('net_port')),
            'web_port': str(game_servers[i].get('web_port')),
            'http_listen_port': str(game_servers[i].get('gm_port'))
        }
        game_dict[ip].append(game_info)

    return game_dict


# 获取游戏服列表，并写入到文件
def dump_game_server_list():
    game_list = get_game_server_list()
    save_file = 'game_servers_' + filename_time_str('')
    fd = open(save_file, 'w')
    data = json.dumps(game_list, indent=4, sort_keys=True)
    fd.write(data)
    fd.close()
    print(data)
    print('\nsave game server list to:%s' % save_file)



# 将服务端代码上传到云服务器
def upload_code(hosts, code_zip_file):
    cmd = "ansible all -i %s -f 10 -m copy -a \"src=%s dest=%s force=no\"" % (hosts, code_zip_file, CODES_DIR)
    print(cmd)
    os.system(cmd)


# 上传热更新包
def upload_reload_zip(hosts, zip_file):
    cmd = "ansible all -i %s -f 10 -m copy -a \"src=%s dest=%s\"" % (hosts, zip_file, RELOAD_CODES_DIR)
    print(cmd)
    os.system(cmd)


def find_game_info(serverid):
    game_dict = get_game_server_list()
    games = []
    for ip in game_dict:
        for game_info in game_dict[ip]:
            if serverid == game_info['serverid']:
                row = [
                    ip,
                    game_info['server_host'], 
                    game_info['serverid'], 
                    game_info['net_port'], 
                    game_info['http_listen_port'], 
                    game_info['web_port']
                ]
                games.append(row)
    return games


# 获取所有配置服的信息数组
def get_game_info_list(game_dict):
    games = []
    for ip in game_dict:
        for game_info in game_dict[ip]:
            row = [
                ip,
                game_info['server_host'], 
                game_info['serverid'], 
                game_info['net_port'], 
                game_info['http_listen_port'], 
                game_info['web_port']
            ]
            games.append(row)
    return games


def print_games_info(games):
    headers = ['ip', 'inner_ip', 'serverid', 'net_port', 'gm_port', 'web_port']
    my_util.format_table(headers, games)


# 安装指定serverid的新游戏服，code_zip_filename为远程服务器目录CODES_DIR下的代码压缩包名称
def install_game(code_zip_filename, serverids):
    install_list = []
    for serverid in serverids:
        games = find_game_info(serverid)
        if len(games) == 0:
            print("没有找到serverid为：%s的游戏服配置！" % serverid)
            return
        install_list.append(games[0])
    print_games_info(install_list)
    
    answer = ''
    promt = "是否安装如上新游戏服（如果已存在，则不会执行任何操作）？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'n':
        return
    
    for game in install_list:
        code_zip_file = os.path.join(CODES_DIR, code_zip_filename)
        args = (game[0], ANSIBLE_HOSTS_PATH, code_zip_file, GAME_NAME, AGENT, game[1], game[2], game[3], game[4], game[5])
        cmd = "ansible %s -i %s -m script -a \"./install_game.sh %s %s %s %s %s %s %s %s\"" % args
        print(cmd)
        os.system(cmd)


def start_game(serverid):
    games = find_game_info(serverid)
    if len(games) == 0:
        print("没有找到serverid为：%s的游戏服配置！" % serverid)
        return

    print_games_info(games)
    answer = ''
    promt = "是否启动该游戏服？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'y':
        game_install_dir = os.path.join(GAME_BASE_DIR, serverid)
        args = (games[0][0], ANSIBLE_HOSTS_PATH, game_install_dir)
        cmd = "ansible %s -i %s -m shell -a \"chdir=%s ./server_ctrl.sh start\"" % args
        print(cmd)
        os.system(cmd)


def stop_game(serverid):
    games = find_game_info(serverid)
    if len(games) == 0:
        print("没有找到serverid为：%s的游戏服配置！" % serverid)
        return

    print_games_info(games)
    answer = ''
    promt = "是否关闭该游戏服？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'y':
        game_install_dir = os.path.join(GAME_BASE_DIR, serverid)
        args = (games[0][0], ANSIBLE_HOSTS_PATH, game_install_dir)
        cmd = "ansible %s -i %s -m shell -a \"chdir=%s ./server_ctrl.sh stop\"" % args
        print(cmd)
        os.system(cmd)


# 启动ANSIBLE_HOSTS_PATH配置指定的所有服
def start_all_game():
    game_dict = get_game_server_list()
    games = get_game_info_list(game_dict)
    
    print_games_info(games)
    print("共计：%s个服" % len(games))
    answer = ''
    promt = "是否继续批量启动操作？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer != 'y':
        return

    begin = time.time()
    log_dir = get_log_dir()
    ps_list = []
    for ip in game_dict:
        server_ids = []
        for game_info in game_dict[ip]:
            server_ids.append(game_info['serverid'])
        args = (ip, ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, ','.join(server_ids))
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh start_all_game %s %s %s\"" % args
        print(cmd)
        p = subprocess.Popen(cmd, shell = True, close_fds = True)
        ps_list.append(p)
        # os.system(cmd)
    [p.communicate() for p in ps_list]
    end = time.time()
    print("Total cost time:{0}s".format(round(end - begin)))


# 启动ANSIBLE_HOSTS_PATH配置指定的所有服
def stop_all_game():
    game_dict = get_game_server_list()
    games = get_game_info_list(game_dict)
    
    print_games_info(games)
    print("共计：%s个服" % len(games))
    answer = ''
    promt = "是否继续批量关闭操作？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer != 'y':
        return

    begin = time.time()
    log_dir = get_log_dir()
    ps_list = []
    for ip in game_dict:
        server_ids = []
        for game_info in game_dict[ip]:
            server_ids.append(game_info['serverid'])
        args = (ip, ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, ','.join(server_ids))
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh stop_all_game %s %s %s\"" % args
        print(cmd)
        p = subprocess.Popen(cmd, shell = True, close_fds = True)
        ps_list.append(p)
        # os.system(cmd)
    [p.communicate() for p in ps_list]
    end = time.time()
    print("Total cost time:{0}s".format(round(end - begin)))


def game_status(serverid):
    games = find_game_info(serverid)
    if len(games) == 0:
        print("0")
        return

    args = (games[0][0], ANSIBLE_HOSTS_PATH, GAME_NAME, AGENT, serverid)
    cmd = "ansible %s -i %s -m script -a \"./game_svr_ctr.sh game_status %s %s %s\"" % args
    os.system(cmd)
    # todo:获取cmd的输出进行解析


def all_game_status():
    game_dict = get_game_server_list()
    games = get_game_info_list(game_dict)

    print_games_info(games)
    print("共计：%s个服" % len(games))
    answer = ''
    promt = "是否继续批量获取状态操作？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer != 'y':
        return

    for ip in game_dict:
        for game_info in game_dict[ip]:
            game_install_dir = os.path.join(GAME_BASE_DIR, game_info['serverid'])
            args = (ip, ANSIBLE_HOSTS_PATH, game_install_dir)
            cmd = "ansible %s -i %s -m shell -a \"chdir=%s ./server_ctrl.sh status\"" % args
            os.system(cmd)


def get_log_dir():
    time_tuple = datetime.now()
    log_dir = './ansible_log/' + time_tuple.strftime('%Y_%m_%d_%H_%M_%S')
    os.system("mkdir -p %s" % log_dir)
    return log_dir

def update_game(serverid, code_zip_filename):
    games = find_game_info(serverid)
    if len(games) == 0:
        print("没有找到serverid为：%s的游戏服配置！" % serverid)
        return

    print_games_info(games)
    answer = ''
    promt = "是否更新该游戏服？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'y':
        begin = time.time()
        log_dir = get_log_dir()
        ip = games[0][0]
        args = (ip, ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, serverid, os.path.join(CODES_DIR, code_zip_filename))
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh update_game %s %s %s %s\"" % args
        print(cmd)
        os.system(cmd)
        end = time.time()
        print("Total cost time:{0}".format(end - begin))


def update_all_game(code_zip_filename):
    game_dict = get_game_server_list()
    games = get_game_info_list(game_dict)
    
    print_games_info(games)
    print("共计：%s个服" % len(games))
    answer = ''
    promt = "是否继续批量更新操作？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer != 'y':
        return

    begin = time.time()
    log_dir = get_log_dir()
    ps_list = []
    for ip in game_dict:
        server_ids = []
        for game_info in game_dict[ip]:
            server_ids.append(game_info['serverid'])
        args = (ip, ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, ','.join(server_ids), os.path.join(CODES_DIR, code_zip_filename))
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh update_all_game %s %s %s %s\"" % args
        print(cmd)
        p = subprocess.Popen(cmd, shell = True, close_fds = True)
        ps_list.append(p)
        # os.system(cmd)
    [p.communicate() for p in ps_list]
    end = time.time()
    print("Total cost time:{0}s".format(round(end - begin)))


# 移除一个已安装的游戏服
def remove_game(serverid):
    games = find_game_info(serverid)
    if len(games) == 0:
        print("没有找到serverid为：%s的游戏服配置！" % serverid)
        return

    print_games_info(games)
    answer = ''
    promt = "是否更新该游戏服？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'y':
        log_dir = get_log_dir()
        ip = games[0][0]
        args = (ip, ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, serverid)
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh remove_game %s %s %s\"" % args
        print(cmd)
        os.system(cmd)


def do_prepare(new_ip):
    game_dict = get_game_server_list()
    for ip in game_dict:
        if ip == new_ip:
            args = (new_ip, ANSIBLE_HOSTS_PATH, GAME_NAME, AGENT)
            cmd = "ansible %s -i %s -m script -a \"./prepare_server.sh %s %s\"" % args
            print(cmd)
            os.system(cmd)
            return

    print("没用找到ip地址为：%s的云服务器" % new_ip)


def get_reload_modules(reload_zip_file):
    f = zipfile.ZipFile(reload_zip_file, 'r')
    modules = [os.path.splitext(mod)[0] for mod in f.namelist()]
    modules2 = ",".join(modules)
    return modules2


def exe_code(code, serverids):
    install_list = []
    for serverid in serverids:
        games = find_game_info(serverid)
        if len(games) == 0:
            print("没有找到serverid为：%s的游戏服配置！" % serverid)
            return
        install_list.append(games[0])
    print_games_info(install_list)
    
    answer = ''
    promt = "是否对以上游戏服执行代码：%s？（y or n）" % code
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'n':
        return
    
    log_dir = get_log_dir()
    for game in install_list:
        game_install_dir = os.path.join(GAME_BASE_DIR, game[2])
        args = (game[0], ANSIBLE_HOSTS_PATH, game_install_dir, code)
        cmd = "ansible %s -i %s -m shell -a \"chdir=%s ./server_ctrl.sh exe_fun %s\"" % args
        print(cmd)
        os.system(cmd)

# 热更新
def hot_reload(reload_zip_file, serverids):
    install_list = []
    for serverid in serverids:
        games = find_game_info(serverid)
        if len(games) == 0:
            print("没有找到serverid为：%s的游戏服配置！" % serverid)
            return
        install_list.append(games[0])
    print_games_info(install_list)
    
    answer = ''
    promt = "是否对以上游戏服进行热更新？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer == 'n':
        return
    
    log_dir = get_log_dir()
    reload_zip_file2 = os.path.join(RELOAD_CODES_DIR, os.path.basename(reload_zip_file))
    modules2 = get_reload_modules(reload_zip_file)
    for game in install_list:
        args = (game[0], ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, game[2], reload_zip_file2, modules2)
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh hot_reload %s %s %s %s %s\"" % args
        print(cmd)
        os.system(cmd)


def hot_reload_all(reload_zip_file):
    game_dict = get_game_server_list()
    games = get_game_info_list(game_dict)
    
    print_games_info(games)
    print("共计：%s个服" % len(games))
    answer = ''
    promt = "是否继续批量热更新操作？（y or n）"
    while not (answer == 'y' or answer == 'n'):
        answer = raw_input(promt)
    if answer != 'y':
        return

    begin = time.time()
    log_dir = get_log_dir()
    reload_zip_file2 = os.path.join(RELOAD_CODES_DIR, os.path.basename(reload_zip_file))
    modules2 = get_reload_modules(reload_zip_file)
    ps_list = []
    for ip in game_dict:
        server_ids = []
        for game_info in game_dict[ip]:
            server_ids.append(game_info['serverid'])
        args = (ip, ANSIBLE_HOSTS_PATH, log_dir, GAME_NAME, AGENT, ','.join(server_ids), reload_zip_file2, modules2)
        cmd = "ansible %s -i %s -t %s -m script -a \"./game_svr_ctr.sh hot_reload_all %s %s %s %s %s\"" % args
        print(cmd)
        p = subprocess.Popen(cmd, shell = True, close_fds = True)
        ps_list.append(p)
    [p.communicate() for p in ps_list]
    end = time.time()
    print("Total cost time:{0}s".format(round(end - begin)))


def write_log(log_dir, ip, log_str):
    with open(os.path.join(log_dir, ip), 'a+') as fd:
        fd.write(log_str + '\n')


def pprint_log(log_file):
    with open(log_file, 'r') as fd:
        log_dict = json.load(fd)
        print("changed:%s" % log_dict['changed'])
        print("rc:%s" % log_dict['rc'])
        print("stderr:%s" % log_dict['stderr'])
        print("stdout:%s" % log_dict['stdout'])
        # print(log_dict['stdout'])


def usage(script_name):
    Msg = '''
usage: python %s <cmd> 
    dump_server     获取云服务器列表，并写入到文件
    dump_games      获取游戏服列表，并写入到文件
    upload_code <指定的hosts文件> <代码zip文件>     将服务端代码上传到云服务器
    install_game <代码zip文件> <serverid1> <serverid2> <serverid3>   安装指定serverid的新游戏服
    start_game <serverid>     启动指定serverid的游戏服
    stop_game <serverid>     关闭指定serverid的游戏服
    start_all_game     启动所有的游戏服
    stop_all_game      关闭所有的游戏服
    update_game <serverid> <代码zip文件>      更新指定serverid的游戏服
    update_all_game <代码zip文件>     更新所有的游戏服
    all_game_status      获取所有游戏服的状态
    game_status <serverid>      获取指定游戏服的状态
    prepare ip地址     在指定的云服务器上为安装服做一些准备工作，如:创建目录
    pprint_log ansible日志文件      打印ansible日志文件
    upload_reload_zip <指定的hosts文件> <zip文件>     将热更新包上传到云服务器
    hot_reload <热更新zip文件> <serverid1> <serverid2> <serverid3>     热更新指定的游戏服(如果要更新的服很多，则会花比较长的时间)
    hot_reload_all <热更新zip文件>     热更新所有的游戏服
    exe_code code <serverid1> <serverid2> <serverid3>     到指定的服上执行erlang代码
'''
    print(Msg % script_name)
    

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == 'dump_server':
        dump_server_list()
    elif cmd == 'dump_games':
        dump_game_server_list()
    elif cmd == 'upload_code':
        upload_code(sys.argv[2], sys.argv[3])
    elif cmd == 'install_game':
        if len(sys.argv) < 4:
            print("参数错误：install_game <代码zip文件> <serverid1> <serverid2> <serverid3>")
        else:
            install_game(sys.argv[2], sys.argv[3:])
    elif cmd == 'start_game':
        start_game(sys.argv[2])
    elif cmd == 'stop_game':
        stop_game(sys.argv[2])
    elif cmd == 'start_all_game':
        start_all_game()
    elif cmd == 'stop_all_game':
        stop_all_game()
    elif cmd == 'game_status':
        game_status(sys.argv[2])
    elif cmd == 'all_game_status':
        all_game_status()
    elif cmd == 'update_game':
        update_game(sys.argv[2], sys.argv[3])
    elif cmd == 'update_all_game':
        update_all_game(sys.argv[2])
    elif cmd == 'remove_game':
        remove_game(sys.argv[2])
    elif cmd == 'prepare':
        do_prepare(sys.argv[2])
    elif cmd == 'upload_reload_zip':
        upload_reload_zip(sys.argv[2], sys.argv[3])
    elif cmd == 'hot_reload':
        hot_reload(sys.argv[2], sys.argv[3:])
    elif cmd == 'exe_code':
        exe_code(sys.argv[2], sys.argv[3:])
    elif cmd == 'hot_reload_all':
        hot_reload_all(sys.argv[2])
    elif cmd == 'pprint_log':
        pprint_log(sys.argv[2])
    elif cmd == 'ping':
        os.system('ansible -i %s all -m ping' % ANSIBLE_HOSTS_PATH)
    else:
        usage(sys.argv[0])

