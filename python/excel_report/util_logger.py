# -*- coding: utf-8 -*-

import os
import logging.config
import yaml


class Logger(object):
    """docstring for Logger"""
    logger = None

    @staticmethod
    def setup_logging(path, default_level=logging.INFO):
        """Setup logging configuration"""
        log_dir = os.path.join(os.getcwd(), 'log')
        if not os.path.exists(log_dir):
            os.mkdir(log_dir)
        if os.path.exists(path):
            with open(path, 'rt') as f:
                config = yaml.load(f.read())
            logging.config.dictConfig(config)
            Logger.logger = logging.getLogger()
        else:
            logging.basicConfig(level=default_level)
            Logger.logger = logging.getLogger()
            Logger.logger.warning('Cannot find logger config file:%s, using default config!!!' % (path))

    # @staticmethod
    # def info(message):
    #     Logger.logger.info(message)

    # @staticmethod
    # def warning(message):
    #     Logger.logger.warning(message)

    # @staticmethod
    # def error(message):
    #     Logger.logger.error(message)
