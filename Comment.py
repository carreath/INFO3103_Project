#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import DBConnection

comment = Blueprint('auth', __name__)
api = Api(comment, prefix="")

parser = reqparse.RequestParser()
parser.add_argument('sessionToken')
parser.add_argument('commentID')
parser.add_argument('postID')

class Comment(Resource):
        def get(self, id, idType):
                procedure = "getCommentsByUser"
                if(idType == 0):
                        procedure = "getCommentsByPost"

                try:
                        results = DBConnection.callprocALL(procedure, (id))
                        return {"status": 200, results}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 404}

        def post(self):
                args = parser.parse_args()
                try:
                        userID = Authentication.IsAuthenticated(args['sessionToken'])
                        if(userID == -1) return {"status", 401}

                        DBConnection.callprocONE("postComment", (userID, args['commentBody'], args['postID']))
                        return {"status": 201}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

        def update(self):
                args = parser.parse_args()
                try:
                        userID = Authentication.IsAuthenticated(args['sessionToken'])
                        if(userID == -1) return {"status", 401}

                        DBConnection.callprocONE("updateComment", (userID, args['commentBody'], args['commentID']))
                        return {"status": 201}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 404}

        def delete(self):
                args = parser.parse_args()
                try:
                        userID = Authentication.IsAuthenticated(args['sessionToken'])
                        if(userID == -1) return {"status", 401}

                        DBConnection.callprocONE("deleteComment", (userID, args['commentID']))
                        return {"status": 200}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 404}

# Add all resources to the app
api.add_resource(Comment, '/Comment')
