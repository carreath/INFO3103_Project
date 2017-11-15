#!/usr/bin/env python3.6
import pymysql.cursors
import settings
from flask import g

class DatabaseConnection():
    def connect_db():
        return pymysql.connect('localhost',settings.MYSQL_USER,settings.MYSQL_PASSWD,settings.MYSQL_DB,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)

    def close_db():
        if hasattr(g, 'db'):
            g.db.close()

    def get_db():
        if not hasattr(g, 'db'):
            g.db = DatabaseConnection.connect_db()
        return g.db

    def callprocONE(proc, args):
        dbConnection = DatabaseConnection.get_db()
        cursor = dbConnection.cursor()
        cursor.callproc(proc, args)
        dbConnection.commit()
        result = cursor.fetchone()
        return result    

    def callprocALL(proc, args):
        dbConnection = DatabaseConnection.get_db()
        cursor = dbConnection.cursor()
        cursor.callproc(proc, args)
        dbConnection.commit()
        result = cursor.fetchall()
        return result

    def rollback():
        dbConnection = DatabaseConnection.get_db()
        dbConnection.rollback()