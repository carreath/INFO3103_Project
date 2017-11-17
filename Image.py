#!/usr/bin/env python3.6
from flask import Blueprint, jsonify, abort, request, make_response, url_for
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
from DBConnection import DatabaseConnection

image = Blueprint('img', __name__)
api = Api(image, prefix="")

UPLOAD_FOLDER = '/path/to/the/uploads'
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])

parser = reqparse.RequestParser()
parser.add_argument('sessionToken')
parser.add_argument('imageName')
parser.add_argument('imageSize')
parser.add_argument('imageExtension')

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

class Image(Resource):
	def get(self, imageID):
		try:
			result = DatabaseConnection.callprocONE("getImage", (imageID))
			return {"status": 200, result}
		except SQLAlchemyError:
			DatabaseConnection.rollback()

		return {"status": 500}

	def post(self):
		args = parser.parse_args()
		try:
			userID = Authentication.isAuthenticated(args['sessionToken'])
			if(userID == -1):
				abort(401)

			file = request.files['image']
			f = os.path.join(UPLOAD_FOLDER, file.filename)
			file.save(f)

			imageURI = UPLOAD_FOLDER + "/" + file.filename

			DatabaseConnection.callprocONE("postImage", (imageID, userID, args['imageName'], args['imageSize'], args['imageExtension'], imageURI))
			return make_response(jsonify( {"status": "Image Successfully Uploaded"} ), 200)
		except SQLAlchemyError:
			DatabaseConnection.rollback()

		abort(500)

	def delete(self):
		args = parser.parse_args()
		try:
			userID = Authentication.isAuthenticated(args['sessionToken'])
			if(userID == -1):
				return {"status", 401}

			DatabaseConnection.callprocONE("deleteImage", (imageID, userID))
			return {"status": 200}
		except SQLAlchemyError:
			DatabaseConnection.rollback()

		return {"status": 500}

def upload_file():
	if request.method == 'POST':
		# check if the post request has the file part
		if 'file' not in request.files:
			flash('No file part')
			return redirect(request.url)
		file = request.files['file']
		# if user does not select file, browser also
		# submit a empty part without filename
		if file.filename == '':
			flash('No selected file')
			return redirect(request.url)
		if file and allowed_file(file.filename):
			filename = secure_filename(file.filename)
			file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

# Add all resources to the app
api.add_resource(Image, '/img')
