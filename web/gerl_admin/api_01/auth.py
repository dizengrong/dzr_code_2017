# -*- coding: utf-8 -*-
from flask import Flask, request, jsonify, render_template, redirect, url_for, make_response, g
import models
from models import User, db_session, Online
import hashlib
import time
from . import api
from decorator import login_check
from datetime import datetime, timedelta


def get_expire_time():
    now = datetime.now()
    return now + timedelta(seconds = 3600)


def is_login(username):
    rec = Online.query.filter_by(username = username).first()
    if rec :
        if (rec.expire_time - datetime.now()).seconds > 0:
            return True
    return False


@api.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        username = request.headers.get('username')
        print username
        if is_login(username):
            return redirect(url_for('api_01.index'))
        return render_template('login.html')
    else:
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if not user:
            return render_template('login.html', error=u"用户不存在")

        if user.password != password:
            return render_template('login.html', error=u"密码错误")

        rec = Online(username, get_expire_time())
        models.add_online(rec)
        response = make_response(redirect(url_for('api_01.index', username=username)))
        # response.headers['username'] = username
        print "1111111111"
        return response


@api.route('/logout')
@login_check
def logout():
    username = request.headers.get('username')
    rec = Online.query.filter_by(username = username).first()
    if rec:
        models.delete_online(rec)
    return jsonify({'code': 1, 'message': u'成功注销'})


@api.teardown_request
def handle_teardown_request(exception):
    db_session.remove()


@api.route('/index')
@login_check
def index():
    return render_template('index.html')


