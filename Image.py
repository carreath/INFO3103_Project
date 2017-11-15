#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import DBConnection

image = Blueprint('img', __name__)
api = Api(image, prefix="")

parser = reqparse.RequestParser()
parser.add_argument('sessionToken')
parser.add_argument('imageName')
parser.add_argument('imageSize')
parser.add_argument('imageExtension')


class Image(Resource):
        def get(self, imageID):
                try:
                        result = DBConnection.callprocONE("getImage", (imageID))
                        return {"status": 200, result}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

        def post(self):
                args = parser.parse_args()
                try:
                        userID = Authentication.IsAuthenticated(args['sessionToken'])
                        if(userID == -1) return {"status", 401}

                        imageURI = "UNKNOWN???????"

                        DBConnection.callprocONE("postImage", (imageID, userID, args['imageName'], args['imageSize'], args['imageExtension'], imageURI))
                        return {"status": 200}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

        def delete(self):
                args = parser.parse_args()
                try:
                        userID = Authentication.IsAuthenticated(args['sessionToken'])
                        if(userID == -1) return {"status", 401}

                        DBConnection.callprocONE("deleteImage", (imageID, userID))
                        return {"status": 200}
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

# Add all resources to the app
api.add_resource(Image, '/img')
