#!/usr/bin/env python3.6
from flask import Blueprint, request, jsonify, abort, make_response,redirect, render_template
from flask_restful import reqparse, Resource, Api
from DBConnection import DatabaseConnection
from Auth import Authentication
import Star
import settings 
import Image
from __init__ import app

# Initialize this python file as a flask blueprint and define api
post = Blueprint('post', __name__)
api = Api(post, prefix="")

@app.route("/post/recent")
def GetRecentPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetRecentPosts", ())

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"status": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/random")
def GetRandomPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetRandomPosts", ())

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"status": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/starred")
def GetStarredPosts2():		
	result = Star.getStarredPosts()
	return make_response(jsonify(result['result']), result['code'])

@app.route("/post/popular")
def GetPopularPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetPopularPosts", ())

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/post/following")
def GetFollowerPosts():	   
	try:
		result = Authentication.isAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			abort(401, "Unauthorised")

		result = DatabaseConnection.callprocALL("GetFollowedPosts", (profile_id, ""))

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

@app.route("/profile/posts")
def GetUserPosts():	 
	try:
		result = Authentication.isAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			abort(401, "Unauthorised")

		result = DatabaseConnection.callprocALL("GetUserPosts", (profile_id, ""))

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

class Post(Resource):
	# /profile GET
	#	Gets either one post with post_id
	#   or a list of posts by a user
	#
	# 	parameters:
	#		post_id (optional):
	#			Selects a single post connected to this id
	#		profile_id (optional):
	#			Selects a list of posts connected to this profile
	#
	def get(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		parser.add_argument('profile_id')
		args = parser.parse_args()
		try:
			if args['post_id'] == None and args['profile_id'] == None:
				return make_response(jsonify({"status": "Bad Request"}), 400)

			if args['post_id'] != None:
				result = DatabaseConnection.callprocONE("GetPost", (args['post_id'], ""))
				if(result == None):
					return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
				return make_response(jsonify({"post": result}), 200)

			if args['profile_id'] != None:
				result = DatabaseConnection.callprocALL("GetUserPosts", (args['profile_id'], ""))
				if(result == None):
					return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
				return make_response(jsonify({"posts": result}), 200)
		except:
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	# /profile POST
	#	Creates a new post connected to the current user, image, tags, stars
	#
	# 	parameters:
	#		image_id:
	#			Image for this post
	#		title:
	#			title of this post
	#		description:
	#			description for this post
	#		tags:
	#			tag array on this post
	#
	def post(self):
		if not request.json:
			return make_response(jsonify({"status": "Bad Request"}), 400) # bad request

		parser = reqparse.RequestParser()
		parser.add_argument('image_id')
		parser.add_argument('title')
		parser.add_argument('description')
		parser.add_argument('tags', action='append')
		args = parser.parse_args()
		try:
			#Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				abort(401, "Unauthorised")

			# Check if all required args are present
			if args['image_id'] == None or args['title'] == None or args['description'] == None:
				return make_response(jsonify({"status": "Bad Request"}), 400)

			# Create the post
			result = DatabaseConnection.callprocONE("NewPost", (profile_id, args['image_id'], args['title'], args['description']))

			# Get the new post ID. If it is None there was an error
			if result['LAST_INSERT_ID()'] == None:
				return make_response(jsonify({"status": "Bad Request"}), 400)

			# Commit the changes to the DB
			DatabaseConnection.commit()

			# Organize and Init the tags
			post_id = result['LAST_INSERT_ID()']

			# For each tag which was passed in:
			#	Check if it exists:
			#		if not create
			#	Add the tag ID to the post
			for tag in args['tags']:
				try:
					# Get tag if it exists in the DB already
					result = DatabaseConnection.callprocONE("GetTagID", (tag, ""))

					# if result is None then the tag is not yet present
					if(result == None):
						#create tag
						result = DatabaseConnection.callprocONE("CreateTag", (tag, ""))

						#get that tags new id
						if result['LAST_INSERT_ID()'] == None:
							return make_response(jsonify({"status": "Bad Request"}), 400)
						tag_id = result['LAST_INSERT_ID()']
					else:
						tag_id = result['id']

					# tag_id is now the tag to be added to the post
					# add the tag to the post
					DatabaseConnection.callprocONE("AddTags", (post_id, tag_id))
					DatabaseConnection.commit()
				except:
					# If we end up here we encountered a problem with one of the tags
					# So it skips that tag and continues
					tag_id = -1

			# When the post is fully built redirect the user to their new post
			return redirect(settings.APP_HOST + ":" + str(settings.APP_PORT) + "/post?post_id=" + str(post_id), code=302)
		except:
			# There was an issue if we got here...
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	# /profile PUT
	#	Updates a Post with new title, description, or tags
	#	IMAGES ARE IMMUTABLE ONCE ATTACHED CANNOT BE CHANGED
	#
	# 	parameters:
	#		title:
	#			title of this post
	#		description:
	#			description for this post
	#		tags:
	#			tag array on this post
	#
	def put(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		parser.add_argument('title')
		parser.add_argument('description')
		parser.add_argument('tags', action='append')
		args = parser.parse_args()
		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				abort(401, "Unauthorised")

			# Update the post
			DatabaseConnection.callprocONE("UpdatePost", (args['post_id'], args['title'], args['description']))
			DatabaseConnection.commit()
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

		# Update the tags
		# First Get a list of the current tags on the post
		# Then get a list of the new tags being put on the post
		# then determine the tags that are new and deleted from the post
		# Then loop through the new tags create tags that dont exist and attach to DB
		# Then loop through deleted tags and remove them from the post
		try:
			# Get all tags from the current post
			result = DatabaseConnection.callprocALL("GetTags", (args['post_id'], ""))
			currentTags = []
			for tag in result:
				currentTags.append(tag['id'])

			# Get the new and removed tags from the args list
			newTags = []
			removedTags = []
			for tag in args['tags']:
				try:
					tag_id = -1
					result = DatabaseConnection.callprocONE("GetTagID", (tag, ""))
					if(result == None):
						result = DatabaseConnection.callprocONE("CreateTag", (tag, ""))
						tag_id = result['LAST_INSERT_ID()']
					else:
						tag_id = result['id']
					if tag_id not in currentTags:
						DatabaseConnection.callprocONE("AddTags", (args['post_id'], tag_id))
					newTags.append(tag_id)
				except:
					tag_id = -1

			for tag_id in currentTags:
				try:	
					if tag_id not in newTags:
						DatabaseConnection.callprocONE("DeleteTags", (args['post_id'], tag_id))

				except:
					tag_id = -1

			DatabaseConnection.commit()
			return redirect(settings.APP_HOST + ":" + str(settings.APP_PORT) + "/post?post_id=" + str(args['post_id']), code=302)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)
	
	# /profile DELETE
	#	Updates the profile of the current user with a given display_name
	#
	# 	parameters:
	#		display_name:
	#			Updated display name to hide username (if you want that)
	#
	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()
		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				abort(401, "Unauthorised")

			profile_id = result['profile_id']
			
			# Delete all foreign key references prior to deleting the post
			DatabaseConnection.callprocONE("DeleteAllStars", (args['post_id'], ""))
			DatabaseConnection.callprocONE("DeleteAllTags", (args['post_id'], ""))
			DatabaseConnection.callprocONE("DeletePost", (args['post_id'], ""))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Post has been deleted"}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

# Add all resources to the app
api.add_resource(Post, '/post')
