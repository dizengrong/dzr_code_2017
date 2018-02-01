# -*- coding: utf-8 -*-

import os
import logging


def is_excel_file(filename):
    return filename.endswith('xlsx') or filename.endswith('xlsm')


def is_cell_unicode(sheet, row, col):
    logging.debug("sheet %s cell row:%s col:%s" % (sheet.name, row, col))
    s = sheet.cell(row, col).value
    if isinstance(s, str) or isinstance(s, unicode):
        try:
            s.decode('ascii')
        except UnicodeDecodeError:
            return True
        except UnicodeEncodeError:
            return True
        else:
            return False
    else:
        return False

