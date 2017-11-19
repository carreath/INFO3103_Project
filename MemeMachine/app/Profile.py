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


from flask import Blueprint, request, jsonify, abort, make_response
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
from DBConnection import DatabaseConnection
from Auth import Authentication

# Initialize this python file as a flask blueprint and define api
profile = Blueprint('profile', __name__)
api = Api(profile, prefix="")

# Profile class, handles the profile requests
class Profile(Resource):
	# /profile GET
	#	return a profile mayching the profile_id given or authenticated
	#
	# 	parameters:
	#		profile_id (optional):
	#			If not defined use currently authenticated users id
	#			otherwise return given profile_id's profile
	#
	def get(self):
		parser = reqparse.RequestParser()
		parser.add_argument('profile_id')
		args = parser.parse_args()
		try:
			profile_id = args['profile_id']

			# If profile_id is not defined return current users profile
			if args['profile_id'] == None:
				# Check Authentication
				result = Authentication.isAuthenticated()
				if(result == None):
					return make_response(jsonify({"status": "You are not Logged In"}), 401)
				profile_id = result['profile_id']

			# Get profile
			result = DatabaseConnection.callprocONE("GetProfile", (profile_id, ""))

			# If null then 404
			if(result == None):
				return make_response(jsonify({"status": "Profile Not Found"}), 404)
			else:
				return make_response(jsonify({"profile": result}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	# /profile PUT
	#	Updates the profile of the current user with a given display_name
	#
	# 	parameters:
	#		display_name:
	#			Updated display name to hide username (if you want that)
	#
	def put(self):
		if not request.json:
			return make_response(jsonify({"status": "Bad Request"}), 400) # bad request

		parser = reqparse.RequestParser()
		parser.add_argument('display_name')
		args = parser.parse_args()
		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("UpdateProfile", (profile_id, args['display_name']))
			DatabaseConnection.commit()
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

		return make_response(jsonify({"status": "Profile Updated"}), 202)

# Add all resources to the app
api.add_resource(Profile, '/profile')
