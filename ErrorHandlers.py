#!/usr/bin/env python3.6 
from __init__ import app
from flask import Flask, request, jsonify, abort, make_response, session

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
    return make_response(jsonify( { 'status': 'OOPSIES' } ),  500)

####################################################################################