#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import DBConnection
from Auth import Authentication 

tag = Blueprint('tag', __name__)
api = Api(tag, prefix="")

parser = reqparse.RequestParser()
parser.add_argument('description')

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

class Tag(Resource):
    def get(self, description):
        try:
            result = DBConnection.callprocONE("getTag", (description))

            if(result['tag'] == None) return {"status", 404}
            return {"status": 200, result['id']}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

    def post(self):
        args = parser.parse_args()
        try:
            DBConnection.callprocONE("createTag", (args['description']))
            return {"status": 201}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

class Tags(Resource):
    def get(self, postID):
        try:
            results = DBConnection.callprocALL("getTags", (postID))

            if(results == None) return {"status", 404}
            return {"status": 200, results}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

# Add all resources to the app
api.add_resource(Tag, '/tag')
api.add_resource(Tags, '/tags')
