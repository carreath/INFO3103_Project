#!/usr/bin/env python3.6

#========================================
# Caleb Reath 3514637					#
#   - Project Lead						#
#   - Python Expert						#
#   - Database anti-specialist			#
#										#
# Matthew jared 3501514					#
#	- SQL Guy							#
#   - Overlord of the test cases		#
#	- Raml Man							#
#========================================


import flask
####################################################################################
#
# Error handlers
#

error_handlers = flask.Blueprint('error_handlers', __name__)

@error_handlers.errorhandler(400) # decorators to add to 400 response
def BadRequest(error):
	message = 'Bad Request'
	if error.description['message'] == None:
		message = error.description['message']
	return make_response(jsonify( { 'message': message } ), 400)

@error_handlers.errorhandler(401) # decorators to add to 401 response
def Unauthorised(error):
	message = 'Unauthorised'
	if error.description['message'] == None:
		message = error.description['message']
	return make_response(jsonify( { 'message': message } ), 401)

@error_handlers.errorhandler(404) # decorators to add to 404 response
def NotFound(error):
	message = 'Resource not found'
	if error.description['message'] == None:
		message = error.description['message']
	return make_response(jsonify( { 'message': message } ), 404)

@error_handlers.errorhandler(500) # decorators to add to 500 response
def InternalError(error):
	message = 'Internal Server Error'
	if error.description['message'] == None:
		message = error.description['message']
	return make_response(jsonify( { 'message': message } ), 500)

####################################################################################

error_handlers.register_error_handler(400, BadRequest)
error_handlers.register_error_handler(401, Unauthorised)
error_handlers.register_error_handler(404, NotFound)
error_handlers.register_error_handler(500, InternalError)