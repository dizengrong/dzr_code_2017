# *-* coding:utf-8 *-*
from flask import Blueprint, current_app
# from flask_login import LoginManager

api = Blueprint('api_01', __name__)

# login_manager = LoginManager()
# login_manager.init_app(current_app)


from . import auth, decorator

