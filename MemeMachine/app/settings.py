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
import os 
dir_path = os.path.dirname(os.path.realpath(__file__))

APP_HOST = 'info3103.cs.unb.ca'
APP_PORT =	 14637
APP_DEBUG = True

MYSQL_File = "1.sql"

MYSQL_HOST = 'localhost'
MYSQL_USER = 'creath'
MYSQL_PASSWD = 'P3OO9JnQ'
MYSQL_DB = 'creath'

SESSION_TYPE = "filesystem"
SESSION_COOKIE_NAME = "LDAP_SESSION"
SESSION_COOKIE_DOMAIN = "info3103.cs.unb.ca"

SECRET_KEY = 'd41d8cd98f00b204e9800998ecf8427e'

LDAP_HOST =  'ldap-student.cs.unb.ca'

APP_HOME = os.path.dirname(os.path.realpath(__file__))
print(APP_HOME)

UPLOAD_FOLDER = 'images'
STATIC_FOLDER = 'static'
TEMPLATE_FOLDER = 'templates'

ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])