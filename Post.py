#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import DBConnection
from Auth import Authentication 
from __init__ import app

post = Blueprint('post', __name__)
api = Api(post, prefix="")

parser = reqparse.RequestParser()
parser.add_argument('sessionToken')
parser.add_argument('commentID')
parser.add_argument('postID')

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

class Posts(Resource):
    def get(self, filterArg, userID):
        try:
            filterName = filterArg
            if(filterName == ""): #filter: 0=recent, 1=popular, 2=random, 3=following
                result = DBConnection.callprocONE("getRecentPosts", ())
            else if(filterName == 1): 
                result = DBConnection.callprocONE("getPopularPosts", ())
            else if(filterName == 2): 
                result = DBConnection.callprocONE("getRandomPosts", ())
            else if(filterName == 3): 
                userID = Authentication.IsAuthenticated(self)
                if(userID == -1) return {"status", 401}
                profileID = DBConnection.callprocONE("getProfileID", (userID))
                result = DBConnection.callprocONE("getStarredPosts", (profileID))
            else if(filterName == 3): 
                userID = Authentication.IsAuthenticated(args['sessionToken'])
                if(userID == -1) return {"status", 401}
                profileID = DBConnection.callprocONE("getProfileID", (userID))
                result = DBConnection.callprocONE("getStarredPosts", (profileID))

            if(result['userID'] == None) return {"status", 404}
            return {"status": 200, result}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

class Post(Resource):
    def get(self, postID):
        try:
            result = DBConnection.callprocONE("getPost", (postID))
            if(result['userID'] == None) return {"status", 404}
            return {"status": 200, result}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

    def post(self):
        args = parser.parse_args()
        try:
            userID = Authentication.IsAuthenticated(args['sessionToken'])
            if(userID == -1) return {"status", 401}

            postID = DBConnection.callprocONE("postPost", (userID, args['imageID'], args['title'], args['description']))

            for tagDescription in args['tagDescriptions']:
                result = DBConnection.callprocONE("getTag", (tagDescription))
                tagID = result['tagID']
                if(tagID == None):
                    tagID = DBConnection.callprocONE("createTag", (tagDescription))
                DBConnection.callprocONE("addTag", (tagID, postID))

            return {"status": 201}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

    def update(self):
        args = parser.parse_args()
        try:
            userID = Authentication.IsAuthenticated(args['sessionToken'])
            if(userID == -1) return {"status", 401}

            DBConnection.callprocONE("updatePost", (userID, args['title'], args['description'], args['tagIDs']))
            return {"status": 201}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

    def delete(self):
        args = parser.parse_args()
        try:
            userID = Authentication.IsAuthenticated(args['sessionToken'])
            if(userID == -1) return {"status", 401}
            
            DBConnection.callprocONE("deletePost", (userID, args['commentID']))
            return {"status": 200}
        except SQLAlchemyError:
            DBConnection.rollback()

        return {"status": 500}

# Add all resources to the app
api.add_resource(Post, '/post')
