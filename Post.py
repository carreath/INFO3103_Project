#!/usr/bin/env python3.6
from flask import Blueprint, request, jsonify, abort, make_response
from flask_restful import reqparse, Resource, Api
from DBConnection import DatabaseConnection
from Auth import Authentication 
from __init__ import app

post = Blueprint('post', __name__)
api = Api(post, prefix="")

####################################################################################
#
# Error handlers
#
@app.errorhandler(400) # decorators to add to 400 response
def not_found(error):
	return make_response(jsonify( { 'status': 'Bad request' } ), 400)

@app.errorhandler(404) # decorators to add to 404 response
def not_found(error):
	return make_response(jsonify( { 'status': 'Resource not found' } ), 404)

####################################################################################

@app.route("/post/recent")
def GetRecentPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetRecentPosts", ())

		if(result == None):
			make_response(jsonify({"status", "Posts Do not Exist"}), 404)
		return make_response(jsonify({"status": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/random")
def GetRandomPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetRandomPosts", ())

		if(result == None):
			make_response(jsonify({"status", "Posts Do not Exist"}), 404)
		return make_response(jsonify({"status": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/starred")
def GetStarredPosts():		
	try:
		result = Authentication.IsAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			return make_response(jsonify({"status", "You are not Logged In"}), 401)

		result = DatabaseConnection.callprocALL("GetStarredPosts", (profile_id))

		if(result == None):
			make_response(jsonify({"status", "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/popular")
def GetPopularPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetPopularPosts", ())

		if(result == None):
			make_response(jsonify({"status", "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/following")
def GetFollowerPosts():	   
	try:
		result = Authentication.IsAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			return make_response(jsonify({"status", "You are not Logged In"}), 401)

		result = DatabaseConnection.callprocALL("GetFollowedPosts", (profile_id))

		if(result == None):
			make_response(jsonify({"status", "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/profile/posts")
def GetUserPosts():	 
	try:
		result = Authentication.IsAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			return make_response(jsonify({"status", "You are not Logged In"}), 401)

		result = DatabaseConnection.callprocALL("GetUserPosts", (profile_id))

		if(result == None):
			make_response(jsonify({"status", "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

class Post(Resource):
	def get(self):
		if not request.json:
			abort(400) # bad request

		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		parser.add_argument('profile_id')
		args = parser.parse_args()
		try:
			if 'post_id' not in args and 'profile_id' not in args:
				abort(400)

			if 'post_id' in args:
				result = DatabaseConnection.callprocONE("GetPost", (args['post_id']))
				if(result == None):
					make_response(jsonify({"status", "Post Does Not Exist"}), 404)
				return make_response(jsonify({"posts": result}), 200)

			if 'profile_id' in args:
				result = DatabaseConnection.callprocALL("GetUserPosts", (args['profile_id']))
				if(result == None):
					make_response(jsonify({"status", "Post Does Not Exist"}), 404)
				return make_response(jsonify({"posts": result}), 200)
		except:
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	def post(self):
		if not request.json:
			abort(400) # bad request

		parser = reqparse.RequestParser()
		parser.add_argument('image_id')
		parser.add_argument('title')
		parser.add_argument('description')
		parser.add_argument('tags')
		args = parser.parse_args()
		try:
			result = Authentication.IsAuthenticated()
			profile_id = result['profile_id']
			if(profile_id == None):
				return make_response(jsonify({"status", "You are not Logged In"}), 401)

			if 'image_id' in args or 'title' in args or 'description' in args:
				abort(400)

			result = DatabaseConnection.callprocONE("NewPost", (profile_id, args['imageID'], args['title'], args['description']))

			if 'post_id' in result:
				abort(400)

			post_id = result['post_id']
			for tag in args['tags']:
				result = DatabaseConnection.callprocONE("GetTag", (tag))
				tag_id = result['id']
				if(tag_id == None):
					result = DatabaseConnection.callprocONE("CreateTag", (tag))
					if 'tag_id' in result:
						abort(400)
					tag_id = result['tag_id']
				DatabaseConnection.callprocONE("AddTag", (post_id, tag_id))
			dbConnection.commit()
			return redirect(settings.APP_HOST + ":" + settings.APP_PORT + "/post?post_id=" + post_id, code=302)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	def update(self):
		if not request.json:
			abort(400) # bad request

		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		parser.add_argument('title')
		parser.add_argument('description')
		parser.add_argument('tags')
		args = parser.parse_args()
		try:
			result = Authentication.IsAuthenticated()
			profile_id = result['profile_id']
			if(profile_id == None):
				return make_response(jsonify({"status", "You are not Logged In"}), 401)

			DatabaseConnection.callprocONE("UpdatePost", (args['post_id'], args['title'], args['description']))
			dbConnection.commit()
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

		try:
			result = DatabaseConnection.callprocALL("GetTags", (args['post_id']))
			currentTags = result['id']
			newTags = []
			removedTags = []
			i = 0
			for tag in args['tags']:
				result = DatabaseConnection.callprocONE("GetTag", (tag))
				tag_id = result['id']
				if(tag_id == None):
					tag_id = DatabaseConnection.callprocONE("CreateTag", (tag))
				if tag_id not in currentTags:
					DatabaseConnection.callprocONE("AddTags", (args['post_id'], tag_id))

				newTags[i] = tag
				i = i + 1

			i = 0
			for tag_id in currentTags:
				if tag_id not in newTags:
					DatabaseConnection.callprocONE("DeleteTags", (args['post_id'], tag_id))

				i = i + 1

			dbConnection.commit()
			return make_response(jsonify({"status": 201}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()
		try:
			result = Authentication.IsAuthenticated()
			profile_id = result['profile_id']
			if(profile_id == None):
				return make_response(jsonify({"status", "You are not Logged In"}), 401)
			
			DatabaseConnection.callprocONE("DeletePost", (args['post_id']))
			dbConnection.commit()
			return make_response(jsonify({"status": "Post has been deleted"}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

# Add all resources to the app
api.add_resource(Post, '/posts')
