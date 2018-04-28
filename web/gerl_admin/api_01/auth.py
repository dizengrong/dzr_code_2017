# *-* coding:utf-8 *-*
from flask import Flask, request, jsonify, g, render_template, redirect, url_for, session, current_app, flash
from app.model import User, db_session, MaintainRecord
import hashlib
import time
import uuid
from app.util import message_validate
import random
import flask_login
from .decorators import login_check

from . import api, login_manager


@login_manager.user_loader
def load_user(user_id):
    return User.get(user_id)


@api.before_request
def before_request():
    token = request.headers.get('token')
    phone_number = current_app.redis.get('token:%s' % token)
    if phone_number:
        g.current_user = User.query.filter_by(phone_number=phone_number).first()
        g.token = token
    return


@api.route('/')
@api.route('/index')
@login_check
def index():
    pass


@api.route('/login', methods=['GET', 'POST'])
def login():
    username = request.get_json().get('username')
    password = request.get_json().get('password')
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({'code': 0, 'message': u'没有此用户'})

    if user.password != password:
        return jsonify({'code': 0, 'message': u'密码错误'})

    flask_login.login_user(user)
    flash('Logged in successfully.')

    # next = request.args.get('next')
    # # is_safe_url should check if the url is safe for redirects.
    # # See http://flask.pocoo.org/snippets/62/ for an example.
    # if not is_safe_url(next):
    #     return flask.abort(400)
    # return flask.redirect(next or flask.url_for('index'))

    return render_template('login.html')

@api.route('/user')
@login_check
def user():
    user = g.current_user

    nickname = current_app.redis.hget('user:%s' % user.phone_number, 'nickname')
    return jsonify({'code': 1, 'nickname': nickname, 'phone_number': user.phone_number})


@api.route('/logout')
@login_check
def logout():
    user = g.current_user

    pipeline = current_app.redis.pipeline()
    pipeline.delete('token:%s' % g.token)
    pipeline.hmset('user:%s' % user.phone_number, {'app_online': 0})
    pipeline.execute()
    return jsonify({'code': 1, 'message': '成功注销'})


@api.route('/get-qiniu-token')
def get_qiniu_token():
    key = uuid.uuid4()
    token = current_app.q.upload_token(current_app.bucket_name, key, 3600)
    return jsonify({'code': 1, 'key': key, 'token': token})


@api.route('/set-head-picture', methods=['POST'])
@login_check
def set_head_picture():
    head_picture = request.get_json().get('head_picture')
    user = g.current_user
    user.head_picture = head_picture
    try:
        db_session.commit()
    except Exception as e:
        print e
        db_session.rollback()
        return jsonify({'code': 0, 'message': '未能成功上传'})
    current_app.redis.hset('user:%s' % user.phone_number, 'head_picture', head_picture)
    return jsonify({'code': 1, 'message': '成功上传'})


@api.route('/register-step-1', methods=['POST'])
def register_step_1():
    """
    接受phone_number,发送短信
    """
    phone_number = request.get_json().get('phone_number')
    user = User.query.filter_by(phone_number=phone_number).first()

    if user:
        return jsonify({'code': 0, 'message': '该用户已经存在,注册失败'})
    validate_number = str(random.randint(100000, 1000000))
    result, err_message = message_validate(phone_number, validate_number)

    if not result:
        return jsonify({'code': 0, 'message': err_message})

    pipeline = current_app.redis.pipeline()
    pipeline.set('validate:%s' % phone_number, validate_number)
    pipeline.expire('validate:%s' % phone_number, 60)
    pipeline.execute()

    return jsonify({'code': 1, 'message': '发送成功'})


@api.route('/register-step-2', methods=['POST'])
def register_step_2():
    """
    验证短信接口
    """
    phone_number = request.get_json().get('phone_number')
    validate_number = request.get_json().get('validate_number')
    validate_number_in_redis = current_app.redis.get('validate:%s' % phone_number)

    if validate_number != validate_number_in_redis:
        return jsonify({'code': 0, 'message': '验证没有通过'})

    pipe_line = current_app.redis.pipeline()
    pipe_line.set('is_validate:%s' % phone_number, '1')
    pipe_line.expire('is_validate:%s' % phone_number, 120)
    pipe_line.execute()

    return jsonify({'code': 1, 'message': '短信验证通过'})


@api.route('/register-step-3', methods=['POST'])
def register_step_3():
    """
    密码提交
    """
    phone_number = request.get_json().get('phone_number')
    password = request.get_json().get('password')
    password_confirm = request.get_json().get('password_confirm')

    if len(password) < 7 or len(password) > 30:
        # 这边可以自己拓展条件
        return jsonify({'code': 0, 'message': '密码长度不符合要求'})

    if password != password_confirm:
        return jsonify({'code': 0, 'message': '密码和密码确认不一致'})

    is_validate = current_app.redis.get('is_validate:%s' % phone_number)

    if is_validate != '1':
        return jsonify({'code': 0, 'message': '验证码没有通过'})

    pipeline = current_app.redis.pipeline()
    pipeline.hset('register:%s' % phone_number, 'password', password)
    pipeline.expire('register:%s' % phone_number, 120)
    pipeline.execute()

    return jsonify({'code': 1, 'message': '提交密码成功'})


@api.route('/register-step-4', methods=['POST'])
def register_step_4():
    """
    基本资料提交
    """
    phone_number = request.get_json().get('phone_number')
    nickname = request.get_json().get('nickname')

    is_validate = current_app.redis.get('is_validate:%s' % phone_number)

    if is_validate != '1':
        return jsonify({'code': 0, 'message': '验证码没有通过'})

    password = current_app.redis.hget('register:%s' % phone_number, 'password')

    new_user = User(phone_number=phone_number, password=password, nickname=nickname)
    db_session.add(new_user)

    try:
        db_session.commit()
    except Exception as e:
        print e
        db_session.rollback()
        return jsonify({'code': 0, 'message': '注册失败'})
    finally:
        current_app.redis.delete('is_validate:%s' % phone_number)
        current_app.redis.delete('register:%s' % phone_number)

    return jsonify({'code': 1, 'message': '注册成功'})


@api.teardown_request
def handle_teardown_request(exception):
    db_session.remove()


