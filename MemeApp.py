#!/usr/bin/env python3.6 
from flask import Flask, request, jsonify, abort, make_response, session, redirect
from flask_restful import Resource, Api 
from DBConnection import DatabaseConnection
from ErrorHandlers import error_handlers
from __init__ import app
from Profile import profile 
from Comment import comment 
from Follow import follow 
from Image import image 
from Auth import auth 
from Post import post 
from Star import star 
import settings 

api = Api(app) 

#Blueprint the other modules into the project
app.register_blueprint(error_handlers) 
app.register_blueprint(auth) 
app.register_blueprint(profile) 
app.register_blueprint(post) 
app.register_blueprint(image) 
app.register_blueprint(comment) 
app.register_blueprint(follow) 
app.register_blueprint(star) 


app.config['TRAP_HTTP_EXCEPTIONS']=True

class Root(Resource): 
	def get(self): 
		return redirect(settings.APP_HOST + ":" + str(settings.APP_PORT) + "/post/recent", code=302)

api.add_resource(Root,'/') 

if __name__ == "__main__": 
	app.run(host=settings.APP_HOST, port=settings.APP_PORT, debug=True)
