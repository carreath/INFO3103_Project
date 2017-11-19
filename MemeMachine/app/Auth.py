#!/usr/bin/env python3.6

#========================================
# Caleb Reath 3514637					#
#   - Project Lead						#
#   - Python Expert						#
#   - Database anti-specialist			#
#										#
# Matthew jared 3501514					#
#	- SQL Guy							#
#   - Overlord of the test cases		#
#	- Raml Man							#
#========================================


from flask import Blueprint, request, jsonify, abort, make_response, session,redirect
from flask_restful import reqparse, Resource, Api
from DBConnection import DatabaseConnection
from ldap3 import Server, Connection, ALL
from flask_session import Session
from __init__ import app
import ErrorHandlers
import settings
import json
import sys

# Initialize this python file as a flask blueprint and define api
auth = Blueprint('auth', __name__)
api = Api(auth, prefix="")

# Define the LDap security variables
app.secret_key = settings.SECRET_KEY
app.config['SESSION_TYPE'] = settings.SESSION_TYPE
app.config['SESSION_COOKIE_NAME'] = settings.SESSION_COOKIE_NAME
app.config['SESSION_COOKIE_DOMAIN'] = settings.SESSION_COOKIE_DOMAIN
Session(app)


@app.errorhandler(401) # decorators to add to 404 response
def not_found(error):
	return make_response(jsonify( { 'status': 'Unauthorised' } ), 401)

# Define an  Authentication helper class
# Called with Authentication.isAuthenticated()
# Returns
#	 AUTHENTICATED
#	 {
#		  'profile_id': 'authenticated user profile_id',
#		  'username': 'authenticated user username'
#	 }
#
#	 NOT AUTHENTICATED
#	 None
#
class Authentication():
	def isAuthenticated():
		if 'username' in session:
			#Hit DB get the profile_id
			result = DatabaseConnection.callprocONE('GetProfileID', (session['username'], ""))

			#if the DB doesnt have one set it to ""
			if(result == None):
				return None

			#return object for use in the calling function
			return {"profile_id": result['id'], "username": session['username']}
		else:
			#Not authenticated returns None
			return None

	#Simply grab current username
	def getUserName():
		return session['username']

# Login class, handles the signin Post request
#
# parameters: 
#	 username: Your computer username
#	 password: Your computer password
#
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

		try:
			if responseCode == 200 or responseCode == 201:
				result = DatabaseConnection.callprocONE("GetProfileID", (session['username'], ""))
				if result == None:
					try:
						result = DatabaseConnection.callprocONE("NewProfile", (session['username'], ""))
						profile_id = result['LAST_INSERT_ID()']
						DatabaseConnection.commit()
					except:
						DatabaseConnection.rollback()
						return make_response(jsonify({"status": "Unknown error has occurred"}), 500)
				else:
					profile_id = result['id']

				return redirect(settings.APP_HOST + ":" + str(settings.APP_PORT) + "/profile?profile_id=" + str(profile_id), code=302)
		except:
			DatabaseConnection.rollback()
			print("Profile Not Created")
			abort(500)
		return make_response(jsonify(response), responseCode)


# Class Logout handles the logout request
# No parameters
class Logout(Resource):
	def delete(self):
		#if username is in the session delete it
		if 'username' in session:
			del session['username']
			response = {'status': 'success'}
			responseCode = 200
		else:
			response = {'status': 'fail'}
			responseCode = 403

		# return the response if logour was successful
		return make_response(jsonify(response), responseCode)


# Add all resources to the app
api.add_resource(Login, '/login')
api.add_resource(Logout, '/logout')