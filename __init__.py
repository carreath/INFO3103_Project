#!/usr/bin/env python3.6 
from flask import Flask, jsonify, make_response

app = Flask(__name__, static_folder='/images') 
