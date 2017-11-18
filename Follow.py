#!/usr/bin/env python3.6
from flask import Blueprint, jsonify, abort, request, make_response, url_for, render_template, send_from_directory
from flask_restful import reqparse, Resource, Api
from DBConnection import DatabaseConnection
from Auth import Authentication
from __init__ import app

# Initialize this python file as a flask blueprint and define api
follow = Blueprint('follow', __name__)
api = Api(follow, prefix="")


@app.route("/profile/following")
def GetFollowing():
	parser = reqparse.RequestParser()
	parser.add_argument('profile_id')
	args = parser.parse_args()
	
	profile_id = args['profile_id']
	try:
		if(profile_id == None):
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

		results = DatabaseConnection.callprocALL("GetCommentsByUser", (profile_id, ""))
		return make_response(jsonify({"comments":results}), 200)
	except:
		abort(500)

@app.route("/profile/followers")
def GetFollowers():
	parser = reqparse.RequestParser()
	parser.add_argument('profile_id')
	args = parser.parse_args()
	
	profile_id = args['profile_id']
	try:
		if(profile_id == None):
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

		results = DatabaseConnection.callprocALL("GetCommentsByUser", (profile_id, ""))
		return make_response(jsonify({"comments":results}), 200)
	except:
		abort(500)

class Follow(Resource):
	def post(self):
		parser = reqparse.RequestParser()
		parser.add_argument('followed_profile_id')
		args = parser.parse_args()

		try:
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("CreateFollow", (args['followed_profile_id'], profile_id))
			return make_response(jsonify({"status": "Successfully following someone"}), 201)
		except:
			DatabaseConnection.rollback()
			abort(500)

class UnFollow(Resource):
	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('followed_profile_id')
		args = parser.parse_args()

		try:
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("UnFollow", (args['followed_profile_id'], profile_id))
			return make_response(jsonify({"status": "Successfully UnFollowed"}), 200)
		except:
			DatabaseConnection.rollback()
			abort(500)

# Add all resources to the app
api.add_resource(Follow, '/follow')
api.add_resource(UnFollow, '/unfollow')
