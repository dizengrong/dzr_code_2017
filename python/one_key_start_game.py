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


# 路径配置
project_path   = "F:/guaji/server/"
sql_path       = "F:/guaji/server/app_set/sql"
run_path       = "F:/guaji/run/"
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
    ps = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
    while True:
        data = ps.stdout.readline()
        if data == b'':
            if ps.poll() is not None:
                break
        else:
            print data.strip("\n")
    return ps.returncode == 0


def get_sql_cnf():
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
    return raw


def do_sql_change():
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

    (dbhost, dbusr, dbpsw, dbdatabase) = get_sql_cnf()
    for basename in os.listdir(sql_path):
        fullname = os.path.join(sql_path, basename)
        if os.path.isdir(fullname):
            continue

        cache_dict = get_sql_cache()
        mtime = int(os.path.getmtime(fullname))
        if (not (basename in cache_dict)) or mtime > cache_dict[basename]:
            sql = get_file_content_with_utf8(fullname)
            cmd = 'mysql -u%s -p%s -D %s -e \"%s\"' % (dbusr, dbpsw, dbdatabase, sql)
            print(u"执行sql脚本：" + basename)
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


def main():
    # 编译
    print_head(u"编译")
    answer = ''
    while not (answer == 'y' or answer == 'n'):
        promt = u"需要执行clean？(y/n):"
        answer = raw_input(promt.encode("GBK"))
        if answer == 'y':
            clean_cmd = "cd " + project_path + "&& make_clean"
            execute_cmd_in_subprocess(clean_cmd)

    compile_cmd = "cd " + project_path + "&& make_erl"
    if not execute_cmd_in_subprocess(compile_cmd):
        print(u"编译出错啦!!!")
        return
    print_blankline()

    # 执行sm:install
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
    if not do_sql_change():
        print(u"更新mysql发生错误!!!")
        return
    print_blankline()

    # 启动服务器
    print_head(u"启动服务器")
    os.chdir(run_path)
    os.startfile(os.path.join(run_path, start_game_bat))
    print_blankline()


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print traceback.format_exc()
    finally:
        print("\nPress any key to exit.\n")
        msvcrt.getch()

