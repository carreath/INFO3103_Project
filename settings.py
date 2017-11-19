#/usr/bin/env python
APP_HOST = 'info3103.cs.unb.ca'
APP_PORT =	 14637	# no quotes - it's a number!
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

APP_HOME = '/var/www/html/creath/'

UPLOAD_FOLDER = 'images'
STATIC_FOLDER = 'static'
TEMPLATE_FOLDER = 'templates'

ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])