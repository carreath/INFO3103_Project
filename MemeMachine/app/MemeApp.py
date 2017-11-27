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

 
from flask import Flask, request, jsonify, abort, make_response, session, redirect, url_for, g, send_from_directory
from flask_restful import reqparse, Resource, Api 
from werkzeug.utils import secure_filename
from ldap3 import Server, Connection, ALL
from flask_session import Session
import pymysql.cursors
import settings 
import json
import sys
import hashlib, uuid
import math
import os
from flask_cors import CORS

app = Flask(__name__, static_url_path='') 
api = Api(app) 
CORS(app)

# Define the LDap security variables
app.secret_key = settings.SECRET_KEY
app.config['SESSION_TYPE'] = settings.SESSION_TYPE
app.config['SESSION_COOKIE_NAME'] = settings.SESSION_COOKIE_NAME
app.config['SESSION_COOKIE_DOMAIN'] = settings.SESSION_COOKIE_DOMAIN
Session(app)


####################################################################################
#
# Error handlers
#

@app.errorhandler(400) # decorators to add to 400 response
def BadRequest(error):
	message = 'Bad Request'
	if error.description == None:
		message = error.description
	return make_response(jsonify( { 'message': message } ), 400)

@app.errorhandler(401) # decorators to add to 401 response
def Unauthorised(error):
	message = 'Unauthorised'
	if error.description == None:
		message = error.description
	return make_response(jsonify( { 'message': message } ), 401)

@app.errorhandler(404) # decorators to add to 404 response
def NotFound(error):
	message = 'Resource not found'
	if error.description == None:
		message = error.description
	return make_response(jsonify( { 'message': message } ), 404)

@app.errorhandler(500) # decorators to add to 500 response
def InternalError(error):
	message = 'Internal Server Error'
	if error.description == None:
		message = error.description
	return make_response(jsonify( { 'message': message } ), 500)

####################################################################################

class DatabaseConnection():
	def connect_db():
		return pymysql.connect('localhost',settings.MYSQL_USER,settings.MYSQL_PASSWD,settings.MYSQL_DB,charset='utf8mb4',cursorclass= pymysql.cursors.DictCursor)

	# closes the database
	def close_db():
		if hasattr(g, 'db'):
			g.db.close()
	# get_db connects db to the database
	def get_db():
		if not hasattr(g, 'db'):
			g.db = DatabaseConnection.connect_db()
		return g.db

	# returns a single entry from the database
	def callprocONE(proc, args):
		dbConnection = DatabaseConnection.get_db()
		cursor = dbConnection.cursor()
		cursor.callproc(proc, args)
		result = cursor.fetchone()
		return result	
	
	# returns a table from the database
	def callprocALL(proc, args):
		dbConnection = DatabaseConnection.get_db()
		cursor = dbConnection.cursor()
		cursor.callproc(proc, args)
		result = cursor.fetchall()
		return result
	
	# returns databse to previous state
	def rollback():
		dbConnection = DatabaseConnection.get_db()
		dbConnection.rollback()

	# commits changes to the database
	def commit():
		dbConnection = DatabaseConnection.get_db()
		dbConnection.commit()


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
	def get(self):
		if(Authentication.isAuthenticated()):
			return make_response(jsonify({'status': 'success'}), 200)
		else:
			return make_response(jsonify({'status': 'fail'}), 500)

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

				return make_response(jsonify({"status": response}), responseCode)
		except:
			DatabaseConnection.rollback()
			print("Profile Not Created")
			abort(500)
		return make_response(jsonify(response), responseCode)
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

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in settings.ALLOWED_EXTENSIONS

def getImage(image_id):
	result = DatabaseConnection.callprocONE("GetImage", (image_id, ""))

	return result['uri']

class Image(Resource):
	# /img GET
	#	returns an image uri based on a specified image_id
	#
	# 	parameters:
	#		image_id
	#
	def get(self):
		parser = reqparse.RequestParser()
		parser.add_argument('image_id')
		args = parser.parse_args()
		try:
			return send_from_directory("images", getImage(args['image_id']))
		except:
			return make_response(jsonify({"status": "Internal Server Error"}), 500)
	# /img POST
	#	uploads an image to filesystem
	#
	# 	parameters:
	#		Image File through multipart form data
	#
	def post(self):
		result = Authentication.isAuthenticated()
		if(result == None):
			return make_response(jsonify({"status": "You are not Logged In"}), 401)
		profile_id = result['profile_id']

		try:
			if request.method == 'POST':
				# check if the post request has the image part
				if 'image' not in request.files:
					print('No image part')
					abort(404)
				image = request.files['image']

				# if user does not select image, browser also
				# submit a empty part without filename
				if image.filename == '':
					print('No image part')
					abort(404)
				if image and allowed_file(image.filename):
					filename = secure_filename(image.filename)
					unique_filename = str(uuid.uuid4()) + "." + filename.rsplit('.', 1)[1]
					image.save(os.path.join(settings.STATIC_FOLDER, settings.UPLOAD_FOLDER, unique_filename))
				image_id = DatabaseConnection.callprocONE("NewImage", (profile_id, image.filename,unique_filename))
				DatabaseConnection.commit()
				return make_response(jsonify({"image_id": image_id}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)
	# /img DELETE
	#	Deletes an image based on a specified image_id
	#
	# 	parameters:
	#		image_id
	#
	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('image_id')
		args = parser.parse_args()
		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			result = DatabaseConnection.callprocONE("GetImageUsage", (args['image_id'], ""))
			if(result['numPosts'] == 0):
				DatabaseConnection.callprocONE("DeleteImage", (args['image_id'], ""))
				DatabaseConnection.commit()
				return make_response(jsonify({"status": "Image Delete Successfully"}), 200)
			else:
				return make_response(jsonify({"status": "Image is being referenced by a Post"}), 400)

		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

# Helper method for two endpoints to get all posts starred by current user
def getStarredPosts():
	try:
		result = Authentication.isAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			return {"result": {"status", "You are not Logged In"}, "code":402}

		# Gets a list of starred posts
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
	# /star POST
	#	return a profile mayching the profile_id given or authenticated
	#
	# 	parameters:
	#		profile_id (optional):
	#			If not defined use currently authenticated users id
	#			otherwise return given profile_id's profile
	#
	def post(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			# Create star link
			DatabaseConnection.callprocONE("CreateStar", (args['post_id'], profile_id))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Successfully starred a post"}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	# /star DELETE
	#	Removes a star link
	#
	# 	parameters:
	#		post_id:
	#			Deletes the star on one post
	#
	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']


			DatabaseConnection.callprocONE("DeleteStar", (args['post_id'], profile_id))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Successfully removed star from a post"}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

# /profile GET
#	Gets some recent posts
#
@app.route("/post/recent")
def GetRecentPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetRecentPosts", ())

		for post in result:
			imageObj = DatabaseConnection.callprocONE("GetImage", (post['image_id'], ""))
			post['uri'] = imageObj['uri']

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"posts": ""}), 500)

# /profile GET
#	Gets some random posts
#
@app.route("/post/random")
def GetRandomPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetRandomPosts", ())

		for post in result:
			imageObj = DatabaseConnection.callprocONE("GetImage", (post['image_id'], ""))
			post['uri'] = imageObj['uri']

		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

# /profile GET
#	Gets all the posts you starred
#
@app.route("/post/starred")
def GetStarredPosts2():		
	result = getStarredPosts()

	for post in result:
		imageObj = DatabaseConnection.callprocONE("GetImage", (post['image_id'], ""))
		post['uri'] = imageObj['uri']
		
	return make_response(jsonify(result['result']), result['code'])

# /profile GET
#	Gets all the posts from user you follow
#
@app.route("/post/popular")
def GetPopularPosts():		
	try:
		result = DatabaseConnection.callprocALL("GetPopularPosts", ())

		for post in result:
			imageObj = DatabaseConnection.callprocONE("GetImage", (post['image_id'], ""))
			post['uri'] = imageObj['uri']
			
		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

# /profile GET
#	Gets all the posts from user you follow
#
@app.route("/post/following")
def GetFollowedPosts():	   
	try:
		result = Authentication.isAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			abort(401, "Unauthorised")

		result = DatabaseConnection.callprocALL("GetFollowedPosts", (profile_id, ""))

		for post in result:
			imageObj = DatabaseConnection.callprocONE("GetImage", (post['image_id'], ""))
			post['uri'] = imageObj['uri']
			
		if(result == None):
			return make_response(jsonify( {"message": "Posts Do not Exist"}), 404)
		return make_response(jsonify({"posts": result}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

# /profile GET
#	Gets all the posts from a specific user or the current authenticated user
#
# 	parameters:
#		profile_id (optional):
#			Selects a list of posts connected to this profile otherwise return current authenticated users posts
#
@app.route("/profile/posts")
def GetUserPosts():	 
	try:
		result = Authentication.isAuthenticated()
		profile_id = result['profile_id']
		if(profile_id == None):
			abort(401, "Unauthorised")

		result = DatabaseConnection.callprocALL("GetUserPosts", (profile_id, ""))

		for post in result:
			imageObj = DatabaseConnection.callprocONE("GetImage", (post['image_id'], ""))
			post['uri'] = imageObj['uri']
			
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

			profile_id = result['profile_id']
		
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
			return make_response(jsonify({'post_id': post_id}), 200)
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
					# Get tag if it exists
					result = DatabaseConnection.callprocONE("GetTagID", (tag, ""))
					if(result == None):
						# Tag doesnt exist create it
						result = DatabaseConnection.callprocONE("CreateTag", (tag, ""))
						tag_id = result['LAST_INSERT_ID()']
					else:
						# tag exists set tag_id 
						tag_id = result['id']
					# If tag_id is not currently on the post add it
					if tag_id not in currentTags:
						DatabaseConnection.callprocONE("AddTags", (args['post_id'], tag_id))

					# Append all tags to the new tags array (it is the new list on the DB)
					newTags.append(tag_id)
				except:
					tag_id = -1

			# Loop through the old current tags on the post
			for tag_id in currentTags:
				try:	
					# If the current tag from the before update post does not exist in new tags remove it from the post
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

# Get all comments by either current user or a given user profile_id
@app.route("/profile/comments")
def GetCommentsByProfile():
	parser = reqparse.RequestParser()
	parser.add_argument('profile_id')
	args = parser.parse_args()

	profile_id = args['profile_id']
	try:
		#If profile_id is not given we take the current users id
		if(profile_id == None):
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']


		results = DatabaseConnection.callprocALL("GetCommentsByUser", (profile_id, ""))
		return make_response(jsonify({"comments":results}), 200)
	except:
		return make_response(jsonify({"status": "Internal Server Error"}), 500)

# Class Comments handles all requests to do
# with comments on posts
class Comments(Resource):
	# /comments GET
	#	return the comments on the post with matching post_id
	#
	# 	parameters:
	#		post_id
	#
	def get(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		args = parser.parse_args()

		try:
			results = DatabaseConnection.callprocALL("GetComments", (args['post_id'], ""))
			return make_response(jsonify({"comments":results}), 200)
		except:
			return make_response(jsonify({"status": "Internal Server Error"}), 500)
	# /comments POST
	#	Creates the Comment on a Post with a given post_id and sets the
	#		Comments body = comment_body
	#
	# 	parameters:
	#		post_id, comment_body
	#
	def post(self):
		parser = reqparse.RequestParser()
		parser.add_argument('post_id')
		parser.add_argument('comment_body')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("NewComment", (profile_id, args['post_id'], args['comment_body']))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Comment has been posted"}), 201)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)
	# /comments PUT
	#	Updates the Comment on a Post with a given post_id and changes the
	#		Comments body to comment_body
	#
	# 	parameters:
	#		post_id, comment_body
	#
	def put(self):
		parser = reqparse.RequestParser()
		parser.add_argument('comment_id')
		parser.add_argument('comment_body')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)

			DatabaseConnection.callprocONE("UpdateComment", (args['comment_id'], args['comment_body']))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Comment has been updated"}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

	# /comments Delete
	#	Delets the Comment with a given comment_id
	#
	# 	parameters:
	#		comment_id
	#
	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('comment_id')
		args = parser.parse_args()

		try:
			# Check Authenticated
			result = Authentication.isAuthenticated()
			if(result == None):
				return make_response(jsonify({"status": "You are not Logged In"}), 401)
			profile_id = result['profile_id']

			DatabaseConnection.callprocONE("DeleteComment", (args['comment_id'], ""))
			DatabaseConnection.commit()
			return make_response(jsonify({"status": "Comment has been deleted"}), 200)
		except:
			DatabaseConnection.rollback()
			return make_response(jsonify({"status": "Internal Server Error"}), 500)

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

# Redirect user from / to /post to avoid issues
class Root(Resource): 
	def get(self): 
		return app.send_static_file('index.html')


app.register_error_handler(400, BadRequest)
app.register_error_handler(401, Unauthorised)
app.register_error_handler(404, NotFound)
app.register_error_handler(500, InternalError)

api.add_resource(Root,'/') 

# Add all resources to the app
api.add_resource(Login, '/login')

# Add all resources to the app
api.add_resource(Image, '/img')

# Add all resources to the app
api.add_resource(Star, '/star')

# Add all resources to the app
api.add_resource(Post, '/post')

# Add all resources to the app
api.add_resource(Profile, '/profile')

# Add all resources to the app
api.add_resource(Comments, '/comment')

# Add all resources to the app
api.add_resource(Follow, '/follow')
api.add_resource(UnFollow, '/unfollow')


if __name__ == "__main__": 
	app.run(host=settings.APP_HOST, port=settings.APP_PORT, debug=True)
