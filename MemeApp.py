#!/usr/bin/env python3.6 
from flask import Flask, request, jsonify, abort, make_response, session
from flask_restful import Resource, Api 
from DBConnection import DatabaseConnection
from __init__ import app
from Profile import profile 
from Comment import comment 
from Follow import follow 
from Image import image 
from Auth import auth 
from Post import post 
import settings 

api = Api(app) 

#Blueprint the other modules into the project
app.register_blueprint(auth) 
app.register_blueprint(profile) 
app.register_blueprint(post) 
app.register_blueprint(image) 
app.register_blueprint(comment) 
app.register_blueprint(follow) 

#class Root(Resource): 
# get method. What might others be aptly named? (hint: post) 
#	def get(self): 
#		return app.send_static_file('index.html') 

#api.add_resource(Root,'/') 

#class Developer(Resource): 
#	# get method. What might others be aptly named? (hint: post) #
#	def get(self): 
#		return app.send_static_file('developer.html')  
#
#	def post(self):
#		DatabaseConnection.init_db()
#		return {"Status", 200}

#api.add_resource(Developer,'/dev') 

if __name__ == "__main__": 
	app.run(host=settings.APP_HOST, port=settings.APP_PORT, debug=True)
