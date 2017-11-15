#!/usr/bin/env python3.6
from flask import Blueprint, request, jsonify, abort, make_response
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import DBConnection 

profile = Blueprint('users', __name__)
api = Api(profile, prefix="/users")

class Profile(Resource):
    def get(self, userID):
        try:
            result = DBConnection.callproc("GetProfile", (userID))

            if(result == None):
                return make_response(jsonify({"status": "Profile Not Found"}), 404)
            else:
                return make_response(jsonify({"profile": result}), 200)

        except:
            DBConnection.rollback()

        return make_response(jsonify({"status": "Internal Server Error"}), 500)

    def update(self):
    	parser = reqparse.RequestParser()
		parser.add_argument('username')
		parser.add_argument('display_name')
        args = parser.parse_args()
        try:
        	username = Authentication.IsAuthenticated(args['sessionToken'])
            if(username == None):
            	return make_response(jsonify({"status", "You are not Logged In"}), 401)

            DBConnection.callproc("updateProfile", (args['username'], args['display_name']))
            DBConnection.commit()
        except:
            DBConnection.rollback()
            return make_response(jsonify({"status": "Internal Server Error"}), 500)

        return make_response(jsonify({"status": "Profile Updated"}), 200)

# Add all resources to the app
api.add_resource(Profile, '/Profile')
