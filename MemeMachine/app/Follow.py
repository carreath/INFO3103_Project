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


from flask import Blueprint, jsonify, abort, request, make_response, url_for, render_template, send_from_directory
from flask_restful import reqparse, Resource, Api
from DBConnection import DatabaseConnection
from Auth import Authentication
from __init__ import app

# Initialize this python file as a flask blueprint and define api
follow = Blueprint('follow', __name__)
api = Api(follow, prefix="")

# /profile/following GET
#	If you pass in a profile_id this will return the users following the user
#   with the specified profile_id
#
#   if not then it will return the users following the currently authenticated user
#
# 	parameters:
#		profile_id (optional):
#
@app.route("/profile/following")
def GetFollowing():
	parser = reqparse.RequestParser()
	parser.add_argument('profile_id')
	args = parser.parse_args()

	profile_id = args['profile_id']
	try:
		if(profile_id == None):
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

		results = DatabaseConnection.callprocALL("GetFollowed", (profile_id, ""))
		return make_response(jsonify({"followed":results}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)
		
# /profile/following GET
#	If you pass in a profile_id this will return the users that the user
#   with the specified profile_id is following
#
#   if not then it will return users that are being
#   followed by the currently authenticated user
#
# 	parameters:
#		profile_id (optional):
#
@app.route("/profile/followers")
def GetFollowers():
	parser = reqparse.RequestParser()
	parser.add_argument('profile_id')
	args = parser.parse_args()

	profile_id = args['profile_id']
	try:
		if(profile_id == None):
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

		results = DatabaseConnection.callprocALL("GetFollowers", (profile_id, ""))
		return make_response(jsonify({"followers":results}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

class Follow(Resource):
		# /Follow POST
		#	Creates a connection between 2 users of the currently authenticated
		#   user following the user with the specified followed_profile_id
		#
		# 	parameters:
		#		followed_profile_id
		#
	def post(self):
		parser = reqparse.RequestParser()
		parser.add_argument('followed_profile_id')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			result = DatabaseConnection.callprocONE("CreateFollow", (args['followed_profile_id'], profile_id))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Successfully Followed Someone"}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

class UnFollow(Resource):
		# /Follow DELETE
		#	Deletes a connection between 2 users of the currently authenticated
		#   user following the user with the specified followed_profile_id
		#
		# 	parameters:
		#		followed_profile_id
		#
	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('followed_profile_id')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("UnFollow", (args['followed_profile_id'], profile_id))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Successfully UnFollowed"}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

# Add all resources to the app
api.add_resource(Follow, '/follow')
api.add_resource(UnFollow, '/unfollow')
