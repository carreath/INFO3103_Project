#!/usr/bin/env python3.6 
from flask import Flask, jsonify, make_response

# Initialize the app and distribute to other components
app = Flask(__name__, static_folder='/images') 
