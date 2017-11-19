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

 
from flask import Flask, jsonify, make_response

# Initialize the app and distribute to other components
app = Flask(__name__, static_folder='/images') 
