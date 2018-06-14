# -*- coding: utf-8 -*-
from flask import Flask
from config import Conf
# import redis
import models


def create_app():
    app = Flask(__name__)
    app.config.from_object(Conf)
    app.secret_key = app.config['SECRET_KEY']
    # app.redis = redis.Redis(host=app.config['REDIS_HOST'], port=app.config['REDIS_PORT'],
    #                         db=app.config['REDIS_DB'], password=app.config['REDIS_PASSWORD'])

    app.bucket_name = app.config['BUCKET_NAME']
    app.debug = app.config['DEBUG']

    from api_01 import api as api_01_blueprint
    app.register_blueprint(api_01_blueprint, url_prefix='/api/v01')

    from api_02 import api as api_02_blueprint
    app.register_blueprint(api_02_blueprint, url_prefix='/api/v02')

    return app


if __name__ == '__main__':
    models.init_db()
    app = create_app()
    app.run(debug=app.debug, host='0.0.0.0', port=app.config['HTTPD_PORT'])


