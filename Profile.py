#!/usr/bin/env python3.6
from flask import Blueprint, request, jsonify, abort, make_response
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
from DBConnection import DatabaseConnection
from Auth import Authentication

# Initialize this python file as a flask blueprint and define api
profile = Blueprint('profile', __name__)
api = Api(profile, prefix="")

class Profile(Resource):
	def get(self):
		parser = reqparse.RequestParser()
		parser.add_argument('profile_id')
		args = parser.parse_args()
		try:
			profile_id = args['profile_id']
			if args['profile_id'] == None:
				result = Authentication.isAuthenticated()
				if(result['profile_id'] == None):
					return make_response(jsonify({"status": "You are not Logged In"}), 401)
				profile_id = result['profile_id']

			result = DatabaseConnection.callprocONE("GetProfile", (profile_id, ""))

			if(result == None):
				return make_response(jsonify({"status": "Profile Not Found"}), 404)
			else:
				return make_response(jsonify({"profile": result}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	def put(self):
		if not request.json:
			abort(400) # bad request

		parser = reqparse.RequestParser()
		parser.add_argument('display_name')
		args = parser.parse_args()
		try:
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
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
