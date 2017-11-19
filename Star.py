#!/usr/bin/env python3.6
from flask import Blueprint, jsonify, abort, request, make_response, url_for, render_template, send_from_directory
from flask_restful import reqparse, Resource, Api
from DBConnection import DatabaseConnection
from Auth import Authentication
from __init__ import app

# Initialize this python file as a flask blueprint and define api
star = Blueprint('star', __name__)
api = Api(star, prefix="")

# Helper method for two endpoints to get all posts starred by current user
def getStarredPosts():
	try:
		result = Authentication.isAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			return {"result": {"status", "You are not Logged In"}, "code":402}

		result = DatabaseConnection.callprocALL("GetStarredPosts", (profile_id, ""))

		if(result == None):
			{"result": {"status": "Posts Do not Exist"}, "code":400}
		return {"result": {"posts": result}, "code": 200}
	except:
		return {"result": {"status": "Internal Server Error"}, "code": 500}

# Get All posts the current user has starred
@app.route("/profile/starred")
def GetStarredPosts():		
	# Call helper method to get all starred posts
	result = getStarredPosts()
	return make_response(jsonify(result['result']), result['code'])

# Creates a star or deletes it 
class Star(Resource):
	def post(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()

		try:
			# Check if Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("CreateStar", (args['post_id'], profile_id))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Successfully starred a post"}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()

		try:
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("DeleteStar", (args['post_id'], profile_id))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Successfully removed star from a post"}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

# Add all resources to the app
api.add_resource(Star, '/star')
