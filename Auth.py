#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import pymysql.cursors
import settings

auth = Blueprint('auth', __name__)
api = Api(auth, prefix="")

parser = reqparse.RequestParser()
parser.add_argument('username')
parser.add_argument('password')

class Login(Resource):
        def post(self):
                args = parser.parse_args()
                # Make the connection

                dbConnection = pymysql.connect('localhost',settings.DBUSER,settings.DBPASSWD,settings.DBDATABASE,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)

                print(args)             
                cursor = dbConnection.cursor()
                cursor.callproc("GetSalty", (args["username"], ""))
                dbConnection.commit()
                result = cursor.fetchone()

                salt = result["SaltyToken"]

                token = hashlib.sha512(args['password'].encode('utf-8') + salt.encode('utf-8')).hexdigest()

                sqlProcName = 'Login'

                cursor = dbConnection.cursor()
                cursor.callproc(sqlProcName, (args['username'], token))
                dbConnection.commit()
                result = cursor.fetchone()
      
                dbConnection.close()

                if(result["Count(*)"] == 0):
                        return {"status": 401}
                else:
                        return {"status": 200}
    
class Register(Resource): 
        def post(self):
                args = parser.parse_args()
                salt = uuid.uuid4().hex 
                token = hashlib.sha512(args['password'].encode('utf-8') + salt.encode('utf-8')).hexdigest()
                # Make the connection
                dbConnection = pymysql.connect('localhost',settings.DBUSER,settings.DBPASSWD,settings.DBDATABASE,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)
                sqlProcName = 'NewLogin'

                cursor = dbConnection.cursor()
                cursor.callproc(sqlProcName, (args['username'], token, salt))
                dbConnection.commit()
                result = cursor.fetchone()

                dbConnection.close()

                return {"status": 200}

# Add all resources to the app
api.add_resource(Login, '/login')
api.add_resource(Register, '/register')
