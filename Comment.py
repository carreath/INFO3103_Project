#!/usr/bin/env python3.6
from flask import Blueprint, jsonify, abort, request, make_response, url_for, render_template, send_from_directory
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
from DBConnection import DatabaseConnection
from __init__ import app
from Auth import Authentication

comment = Blueprint('comment', __name__)
api = Api(comment, prefix="")


@app.route("/profile/comments")
def GetCommentsByProfile():
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

class Comments(Resource):
	def get(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()
		
		try:
			results = DatabaseConnection.callprocALL("GetComments", (args['post_id'], ""))
			return make_response(jsonify({"comments":results}), 200)
		except:
			abort(500)

	def post(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		parser.add_argument('comment_body')
		args = parser.parse_args()

		try:
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("NewComment", (profile_id, args['post_id'], args['comment_body']))
			return make_response(jsonify({"status": "Comment has been posted"}), 201)
		except:
			DatabaseConnection.rollback()
			abort(500)

	def update(self):
		parser = reqparse.RequestParser()
		parser.add_argument('comment_id')
		parser.add_argument('comment_body')
		args = parser.parse_args()

		try:
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)

			DatabaseConnection.callprocONE("UpdateComment", (args['comment_id'], args['comment_body']))
			return make_response(jsonify({"status": "Comment has been updated"}), 200)
		except:
			DatabaseConnection.rollback()
			abort(500)

	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('comment_id')
		args = parser.parse_args()

		try:
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("DeleteComment", (args['comment_id'], ""))
			return make_response(jsonify({"status": "Comment has been deleted"}), 200)
		except:
			DatabaseConnection.rollback()
			abort(500)

# Add all resources to the app
api.add_resource(Comments, '/comment')
