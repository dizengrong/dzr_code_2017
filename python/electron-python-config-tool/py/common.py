# -*- coding: utf-8 -*-
import os
import tenjin

tenjin.set_template_encoding("utf-8")
# create engine object
engine = tenjin.SafeEngine(path=[os.path.join(os.getcwd(), u'config')])


# ==================== xml functions ====================
def get_attrvalue(node, attrname):
    return node.getAttribute(attrname) if node else ''


def get_nodevalue(node, index=0):
    return node.childNodes[index].nodeValue if node else ''


def get_xmlnode(node, name):
    return node.getElementsByTagName(name) if node else []

