# -*- coding: utf-8 -*-
from flask import Flask, jsonify
from flask import render_template


class Todo(object):
    """docstring for Todo"""
    def __init__(self, text):
        super(Todo, self).__init__()
        self.text = text


def convert_to_dict(obj):
    '''把Object对象转换成Dict对象'''
    dict = {}
    dict.update(obj.__dict__)
    return dict

       
app = Flask(__name__)


# 修正jinja2语法与vue语法冲突的问题
# jinja2: {{ arg }}
# vue: {{arg}}
# 另一个方法是不动jinja2，vue里面的{{arg}}都用如下方式：
# <span v-text="arg"></span>
app.jinja_env.variable_start_string = '{{ '
app.jinja_env.variable_end_string = ' }}'


@app.route('/')
def index():
    return 'Hello, this is index page!'


@app.route('/hello')
def hello_world():
    return 'Hello, World!'


@app.route('/user/')
@app.route('/user/<username>')
def show_user_profile(username = None):
    # show the user profile for that user
    # return 'User %s' % username
    todos = [
        # convert_to_dict(Todo(u'学习 JavaScript')),
        # convert_to_dict(Todo(u'学习 Vue')),
        # convert_to_dict(Todo(u'整个牛项目')),
        {'text': "text1"},
        {"text": "text2"},
        {"text": "text3"},
    ]
    # 包含vue代码的html页面里是无法直接绑定到todos的？
    return render_template('hello.html', name=username, todos=todos)


