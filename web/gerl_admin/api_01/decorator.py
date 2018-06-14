# *-* coding:utf-8 *-*
from flask import Flask, request, jsonify, g, render_template, redirect, url_for, session, current_app
from functools import wraps
from models import Online
from datetime import datetime


def login_check(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        print request.args
        username = request.args.get('username')
        online = Online.query.filter_by(username=username).first()
        if not online:
            return jsonify({'code': 0, 'message': u'需要验证1'})
        else:
            if (online.expire_time - datetime.now()).seconds <= 0:
                return jsonify({'code': 0, 'message': u'需要验证2'})

        return f(*args, **kwargs)
    return decorator


