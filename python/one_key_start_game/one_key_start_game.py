#!/usr/bin/python
# -*- coding: utf-8 -*-
# @doc 一键开启服务器

import os
import re
import chardet
import codecs
import traceback
import subprocess
import msvcrt
from ConfigParser import ConfigParser


# 路径配置
install_bat    = "install.bat"
start_game_bat = "start_all.bat"
sql_cache_file = "sql_cache.txt"


def print_blankline():
    print("")


def print_head(head):
    max_len = 80
    len1 = (max_len - len(head)) / 2
    len2 = max_len - len(head) - len1
    s1 = '-' * len1
    s2 = '-' * len2
    print("%s %s %s" % (s1, head, s2))


def execute_cmd_in_subprocess(cmd):
    ps = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    while True:
        data = ps.stdout.readline()
        if data == b'':
            if ps.poll() is not None:
                break
        else:
            print data.strip("\n")
    err = ps.stderr.readline()
    print err
    return err == b'' and ps.returncode == 0


def get_sql_cnf(run_path):
    cnf = open(os.path.join(run_path, "cnf.config")).read()
    dbhost     = re.findall(r"{dbhost,(.*?)}", cnf, re.M | re.S)[0].strip().replace("\"", '')
    dbusr      = re.findall(r"{dbusr,(.*?)}", cnf, re.M | re.S)[0].strip().replace("\"", '')
    dbpsw      = re.findall(r"{dbpsw,(.*?)}", cnf, re.M | re.S)[0].strip().replace("\"", '')
    dbdatabase = re.findall(r"{dbdatabase,(.*?)}", cnf, re.M | re.S)[0].strip().replace("\"", '')
    return (dbhost, dbusr, dbpsw, dbdatabase)


def get_file_content_with_utf8(f):
    raw = open(f).read()
    raw = raw.decode(chardet.detect(raw)['encoding'])
    raw = raw.encode('utf8')
    if raw.startswith(codecs.BOM_UTF8):
        raw = raw.replace(codecs.BOM_UTF8, '', 1)
    with open("sql_temp_file", 'w') as fd:
        fd.write(raw)
    return "sql_temp_file"


def do_sql_change(sql_path, run_path):
    if not os.path.exists(sql_cache_file):
        with open(sql_cache_file, "w") as fd:
            fd.write("{}")

    def save_sql_cache(cache_dict):
        with open(sql_cache_file, "w") as fd:
            fd.write(str(cache_dict))

    def get_sql_cache():
        cache_dict = open(sql_cache_file).read()
        if cache_dict == '':
            cache_dict = "{}"
        return eval(cache_dict)

    (dbhost, dbusr, dbpsw, dbdatabase) = get_sql_cnf(run_path)
    for basename in os.listdir(sql_path):
        fullname = os.path.join(sql_path, basename)
        if os.path.isdir(fullname):
            continue

        cache_dict = get_sql_cache()
        mtime = int(os.path.getmtime(fullname))
        if (not (basename in cache_dict)) or mtime > cache_dict[basename]:
            sql = os.path.join(os.getcwd(), get_file_content_with_utf8(fullname))
            sql = sql.replace("\\", "/")
            cmd = 'mysql -u%s -p%s -D %s -e \"source %s\"' % (dbusr, dbpsw, dbdatabase, sql)
            with open(sql) as fd:
                print(u"执行sql脚本：%s\n%s" % (basename, fd.read()))
            if not execute_cmd_in_subprocess(cmd):
                answer = ''
                while not (answer == 'y' or answer == 'n'):
                    promt = u"%s脚本更新失败，是否忽略？(y/n):" % (basename)
                    answer = raw_input(promt.encode("GBK"))
                if answer == 'y':
                    cache_dict[basename] = mtime
                    save_sql_cache(cache_dict)
                else:
                    return False
            else:
                cache_dict[basename] = mtime
                save_sql_cache(cache_dict)
    return True


def parse_config():
    config = ConfigParser()
    config.read('./game_config.ini')
    project_path = config.get('config', 'project_path')
    sql_path     = config.get('config', 'sql_path')
    run_path     = config.get('config', 'run_path')
    return (project_path, sql_path, run_path)


def main():
    this_path = os.getcwd()
    # 配置
    (project_path, sql_path, run_path) = parse_config()

    # 编译
    print_head(u"编译")
    os.chdir(this_path)
    answer = ''
    while not (answer == 'y' or answer == 'n'):
        promt = u"是否需要执行clean？(y/n):"
        answer = raw_input(promt.encode("GBK"))
        if answer == 'y':
            clean_cmd = "clean.bat"
            execute_cmd_in_subprocess(clean_cmd)

    compile_cmd = "make_erl.bat"
    if not execute_cmd_in_subprocess(compile_cmd):
        print(u"编译出错啦!!!")
        return
    print_blankline()

    answer = ''
    while not (answer == 'y' or answer == 'n'):
        promt = u"是否继续开服？(y/n):"
        answer = raw_input(promt.encode("GBK"))
        if answer == 'n':
            return

    # 执行sm:install
    os.chdir(run_path)
    print_head(u"执行sm:install")
    install_cmd = "cd " + run_path + " && "
    install_cmd += open(os.path.join(run_path, install_bat)).read()
    install_cmd += " -s sm install -s init stop"
    if not execute_cmd_in_subprocess(install_cmd):
        print(u"执行sm:install发生错误!!!")
        return
    print_blankline()

    # 更新mysql
    print_head(u"更新mysql")
    os.chdir(this_path)
    if not do_sql_change(sql_path, run_path):
        print(u"更新mysql发生错误!!!")
        return
    print_blankline()

    # 启动服务器
    print_head(u"启动服务器")
    os.chdir(run_path)
    start_game_cmd = os.path.join(run_path, start_game_bat)
    print(start_game_cmd)
    os.startfile(start_game_cmd)
    print_blankline()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print traceback.format_exc()
    finally:
        print("\nPress any key to exit.\n")
        msvcrt.getch()

