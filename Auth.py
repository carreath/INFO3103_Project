#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import DBConnection

auth = Blueprint('auth', __name__)
api = Api(auth, prefix="")

parser = reqparse.RequestParser()
parser.add_argument('username')
parser.add_argument('password')

class Authentication():
        def IsAuthenticated(sessionToken):
                try:
                        result = DBConnection.callproc("IsAuthenticated", (sessionToken, ""))
                        if(result['count(*)'] == 0):
                                return false
                        else:
                                return true
                except SQLAlchemyError:
                        DBConnection.rollback()

                return false

class Login(Resource):
        def post(self):
                args = parser.parse_args()
                try:
                        result = DBConnection.callproc("Login", (args['username'], ""))
                        salt = result["SaltyToken"]
                        token = hashlib.sha512(args['password'].encode('utf-8') + salt.encode('utf-8')).hexdigest()

                        if(token != result['TokenP']):
                                return {"status": 401}
                        else:
                                sessionToken = uuid.uuid4().hex 
                                DBConnection.callproc("UpdateSession", (sessionToken, ""))
                                return {"status": 200, "sessionToken": sessionToken}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

class Register(Resource): 
        def post(self):
                args = parser.parse_args()
                salt = uuid.uuid4().hex 
                sessionToken = uuid.uuid4().hex 
                token = hashlib.sha512(args['password'].encode('utf-8') + salt.encode('utf-8')).hexdigest()

                try:
                        DBConnection.callproc("NewLogin", (args['username'], token, salt, sessionToken))
                        return {"status": 200, "sessionToken": sessionToken}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

# Add all resources to the app
api.add_resource(Login, '/login')
api.add_resource(Register, '/register')
