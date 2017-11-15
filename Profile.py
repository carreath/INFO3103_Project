#!/usr/bin/env python3.6
from flask import Blueprint
from flask_restful import reqparse, Resource, Api
import math
import hashlib, uuid
import DBConnection 

profile = Blueprint('users', __name__)
api = Api(profile, prefix="/users")

class Profile(Resource):
        def get(self, userID):
                try:
                        result = DBConnection.callproc("loadProfile", (userID))

                        if(result["Count(*)"] == 0):
                                return {"status": 404}
                        else:
                                return {"status": 200}

                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 500}

        def update(self):
                args = parser.parse_args()
                try:
                        DBConnection.callproc("updateProfile", args)
                        DBConnection.commit()
                except SQLAlchemyError:
                        DBConnection.rollback()

                return {"status": 200}

# Add all resources to the app
api.add_resource(Profile, '/Profile')
