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
from werkzeug.utils import secure_filename
from Auth import Authentication
from __init__ import app
import settings
import uuid
import os


# Initialize this python file as a flask blueprint and define api
image = Blueprint('image', __name__)
api = Api(image, prefix="")

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
			return make_response(jsonify({"imageURI": getImage(args['image_id'])}), 200)
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
					image.save(os.path.join(settings.UPLOAD_FOLDER, unique_filename))
				DatabaseConnection.callprocONE("NewImage", (profile_id, image.filename,unique_filename))
				DatabaseConnection.commit()
				return make_response(jsonify({"status": "Image Uploaded Successfully"}), 201)
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

# Add all resources to the app
api.add_resource(Image, '/img')
