import os
import tenjin

# tab类别
TAB_TYPE_ERL = 1
TAB_TYPE_LUA = 2
TAB_TYPE_CS = 3

# create engine object
engine = tenjin.SafeEngine(path=[os.path.join(os.getcwd(), 'config')])


# ==================== xml functions ====================
def get_attrvalue(node, attrname):
    return node.getAttribute(attrname) if node else ''


def get_nodevalue(node, index=0):
    return node.childNodes[index].nodeValue if node else ''


def get_xmlnode(node, name):
    return node.getElementsByTagName(name) if node else []

