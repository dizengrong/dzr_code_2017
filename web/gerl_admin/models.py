# -*- coding: utf-8 -*-

from sqlalchemy import create_engine, ForeignKey, Column, Integer, String, Text, DateTime,\
    and_, or_, SmallInteger, Float, DECIMAL, desc, asc, Table, join, event
from sqlalchemy.orm import relationship, backref, sessionmaker, scoped_session, aliased, mapper
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
from config import Conf


engine = create_engine(Conf.DB_INFO, pool_recycle=7200)
Base = declarative_base()

db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))

Base.query = db_session.query_property()


def init_db():
    Base.metadata.create_all(engine)


class User(Base):
    __tablename__ = 'user'

    id            = Column('id', Integer, primary_key=True)
    username      = Column('username', String(30), index=True)
    password      = Column('password', String(30))
    head_picture  = Column('head_picture', String(100), default='')
    register_time = Column('register_time', DateTime, index=True, default=datetime.now)


class Online(Base):
    __tablename__ = 'on_line'

    username    = Column(String(30), primary_key=True)
    expire_time = Column(DateTime(), default=datetime.now)

    def __init__(self, username, expire_time = expire_time):
        super(Online, self).__init__()
        self.username    = username
        self.expire_time = expire_time


def add_online(rec):
    if not Online.query.filter_by(username=rec.username).first():
        db_session.add(rec)
        db_session.commit()


def delete_online(rec):
    db_session.delete(rec)
    db_session.commit()


# if __name__ == '__main__':
#     Base.metadata.create_all(engine)


