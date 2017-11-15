#!/usr/bin/env python3.6
import sys
from flask import Blueprint, request, jsonify, abort, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session
import json
from ldap3 import Server, Connection, ALL
from DBConnection import DatabaseConnection
import settings
from __init__ import app
import ErrorHandlers

auth = Blueprint('auth', __name__)
api = Api(auth, prefix="")

app.secret_key = settings.SECRET_KEY
app.config['SESSION_TYPE'] = settings.SESSION_TYPE
app.config['SESSION_COOKIE_NAME'] = settings.SESSION_COOKIE_NAME
app.config['SESSION_COOKIE_DOMAIN'] = settings.SESSION_COOKIE_DOMAIN
Session(app)


@app.errorhandler(401) # decorators to add to 404 response
def not_found(error):
    return make_response(jsonify( { 'status': 'Unauthorised' } ), 401)

class Authentication():
    def isAuthenticated(self):
        if 'username' in session:
            return session['username']
        else:
            return None

class Login(Resource):
    def post(self):
        if not request.json:
            abort(400) # bad request
        
        # Parse the json
        parser = reqparse.RequestParser()
        try:
            # Check for required attributes in json document, create a dictionary
            parser.add_argument('username', type=str, required=True)
            parser.add_argument('password', type=str, required=True)
            request_params = parser.parse_args()
        except:
            abort(400) # bad request

        # Already logged in
        if request_params['username'] in session:
            response = {'status': 'success'}
            responseCode = 200
        else:
            try:
                ldapServer = Server(host=settings.LDAP_HOST)
                ldapConnection = Connection(ldapServer, raise_exceptions=True, user='uid='+request_params['username']+', ou=People,ou=fcs,o=unb', password = request_params['password'])
                ldapConnection.open()
                ldapConnection.start_tls()
                ldapConnection.bind()

                # At this point we have sucessfully authenticated.
                session['username'] = request_params['username']
                response = {'status': 'success' }
                responseCode = 201
            except (LDAPException, error_message):
                response = {'status': 'Access denied'}
                responseCode = 403
            finally:
                ldapConnection.unbind()

        return make_response(jsonify(response), responseCode)

class Logout(Resource):
    def delete(self):
        if 'username' in session:
            del session['username']
            response = {'status': 'success'}
            responseCode = 200
        else:
            response = {'status': 'fail'}
            responseCode = 403

        return make_response(jsonify(response), responseCode)


# Add all resources to the app
api.add_resource(Login, '/login')
api.add_resource(Logout, '/logout')
