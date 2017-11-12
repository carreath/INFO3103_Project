#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import Resource, Api
import math

auth = Blueprint('auth', __name__)
api = Api(auth, prefix="/auth")

class Name(Resource):
   def get(self, name):
      return {"name" : name}
class Sqrt(Resource):
   def get(self, name, value):
      sqrtValue = math.sqrt(value)
      return {"name" : name, "value" : value, "square_root" : sqrtValue}

# Add all resources to the app
api.add_resource(Sqrt, '/<string:name>/sqrt/<int:value>')
api.add_resource(Name, '/<string:name>')