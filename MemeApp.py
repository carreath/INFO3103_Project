#!/usr/bin/env python3.6 
from flask import Flask, request 
from flask_restful import Resource, Api 
import math 
import settings 
from Auth import auth 
 
app = Flask(__name__, static_url_path='/static') 
api = Api(app) 
 
app.register_blueprint(auth) 
 
class Root(Resource): 
   # get method. What might others be aptly named? (hint: post) 
   def get(self): 
      return app.send_static_file('index.html') 
 
api.add_resource(Root,'/') 
 
class Developer(Resource): 
   # get method. What might others be aptly named? (hint: post) 
   def get(self): 
      return app.send_static_file('developer.html') 
 
api.add_resource(Developer,'/dev') 
 
if __name__ == "__main__": 
   app.run(host=settings.APPHOST, port=settings.APPPORT, debug=True)
