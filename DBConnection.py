#!/usr/bin/env python3.6
import pymysql.cursors
import settings

class DatabaseConnection():            
        def  callprocONE(proc, args):
                dbConnection = pymysql.connect('localhost',settings.DBUSER,settings.DBPASSWD,settings.DBDATABASE,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)
                cursor = dbConnection.cursor()
                cursor. callprocONE(proc, args)
                dbConnection.commit()
                result = cursor.fetchone()
                dbConnection.close()
                return result    

        def  callprocALL(proc, args):
                dbConnection = pymysql.connect('localhost',settings.DBUSER,settings.DBPASSWD,settings.DBDATABASE,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)
                cursor = dbConnection.cursor()
                cursor. callprocONE(proc, args)
                dbConnection.commit()
                result = cursor.fetchall()
                dbConnection.close()
                return result
            
        def rollback():
                dbConnection = pymysql.connect('localhost',settings.DBUSER,settings.DBPASSWD,settings.DBDATABASE,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)
                dbConnection.rollback()