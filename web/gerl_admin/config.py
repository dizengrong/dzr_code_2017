# -*- coding: utf-8 -*-
import os

basedir = os.path.abspath(os.path.dirname(__file__))
db_filename = os.path.join(basedir, "gerl.db")


class Config(object):
    """基础的共用配置放这里"""
    SECRET_KEY       = 'saduhsuaihfe332r32rfo43rtn3noiYUG9jijoNF23'
    QINIU_ACCESS_KEY = 'hP7WNic×××××××××××××××××××××××××oZfrVs6'
    QINIU_SECRET_KEY = 'bBZ×××××××××××××××××××××××××××××××××VAV'
    BUCKET_NAME      = 'dameinv'


class DevelopmentConfig(Config):
    """开发时的配置"""
    DEBUG      = True
    HTTPD_PORT = 5001

    REDIS_HOST     = 'localhost'
    REDIS_PORT     = 6380
    REDIS_DB       = 4
    REDIS_PASSWORD = '××××××'

    DB_INFO = "sqlite:///%s" % db_filename


class ProductionConfig(Config):
    """发布产品时的配置"""
    DEBUG      = False
    HTTPD_PORT = 5001

    REDIS_HOST     = 'server-ip'
    REDIS_PORT     = 6380
    REDIS_DB       = 4
    REDIS_PASSWORD = '×××××××××××'

    DB_INFO = "sqlite:///%s" % db_filename


Conf = DevelopmentConfig
