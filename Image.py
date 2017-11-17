#!/usr/bin/env python3.6
import os
from flask import Blueprint, jsonify, abort, request, make_response, url_for, render_template, send_from_directory
from flask_restful import reqparse, Resource, Api
from werkzeug.utils import secure_filename
import settings
from __init__ import app
from DBConnection import DatabaseConnection
from Auth import Authentication
import uuid


image = Blueprint('image', __name__)
api = Api(image, prefix="")

ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])

####################################################################################
#
# Error handlers
#
@app.errorhandler(400) # decorators to add to 400 response
def not_found(error):
		return make_response(jsonify( { 'status': 'Bad request' } ), 400)

@app.errorhandler(401) # decorators to add to 404 response
def not_found(error):
		return make_response(jsonify( { 'status': 'Unauthorised' } ), 401)

@app.errorhandler(404) # decorators to add to 404 response
def not_found(error):
		return make_response(jsonify( { 'status': 'Resource not found' } ), 404)

@app.errorhandler(500) # decorators to add to 404 response
def not_found(error):
		return make_response(jsonify( { 'status': 'Internal Server Error' } ), 500)

@app.errorhandler(501) # decorators to add to 404 response
def not_found(error):
		return make_response(jsonify( { 'status': 'Something Went Wrong' } ), 501)

####################################################################################
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

def getImage(image_id):
	try:
		result = DatabaseConnection.callprocONE("GetImage", (image_id, ""))

		return result['uri']
	except:
		return ""

class Image(Resource):
	def post(self):
		result = Authentication.isAuthenticated()
		if(result['profile_id'] == None):
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
			abort(500)

	def delete(self):
		parser = reqparse.RequestParser()
		parser.add_argument('image_id')
		args = parser.parse_args()
		try:
			result = Authentication.isAuthenticated()
			if(result['profile_id'] == None):
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
			abort(500)

# Add all resources to the app
api.add_resource(Image, '/img')
