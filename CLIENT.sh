#!/bin/bash
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"


# Read username and password
username="creath"
password="${PASS}"

# TEST 1: Login Logout
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout


# TEST 2: Login GetProfile Logout
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "GetProfile"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

#echo "What is your Display Name?"
#read -p "display_name: " Display Name

# Create New Profile
# Create New Profile
#curl -i -H "Content-Type: application/json" -X GET -b cookie-jar http://info3103.cs.unb.ca:14637/profile?userID=1

#curl -i -H "Content-Type: application/json" -X POST -d '{"display_name": "'$display_name'"}' -b cookie-jar http://info3103.cs.unb.ca:14637/profile
