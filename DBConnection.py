#!/usr/bin/env python3.6
import pymysql.cursors
import settings
from __init__ import app
from flask import g

class DatabaseConnection():
	def connect_db():
		return pymysql.connect('localhost',settings.MYSQL_USER,settings.MYSQL_PASSWD,settings.MYSQL_DB,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)

	# closes the database
	def close_db():
		if hasattr(g, 'db'):
			g.db.close()
	# get_db connects db to the database
	def get_db():
		if not hasattr(g, 'db'):
			g.db = DatabaseConnection.connect_db()
		return g.db

	# returns a single entry from the database
 	def callprocONE(proc, args):
		dbConnection = DatabaseConnection.get_db()
		cursor = dbConnection.cursor()
		cursor.callproc(proc, args)
		result = cursor.fetchone()
		return result	
	
	# returns a table from the database
	def callprocALL(proc, args):
		dbConnection = DatabaseConnection.get_db()
		cursor = dbConnection.cursor()
		cursor.callproc(proc, args)
		result = cursor.fetchall()
		return result
	
	# returns databse to previous state
	def rollback():
		dbConnection = DatabaseConnection.get_db()
		dbConnection.rollback()

	# commits changes to the database
	def commit():
		dbConnection = DatabaseConnection.get_db()
		dbConnection.commit()
