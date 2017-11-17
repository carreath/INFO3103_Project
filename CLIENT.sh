#!/bin/bash

# Read username and password
username="creath"
password="${PASS}"

mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"
# TEST 1: Login Logout
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"
# TEST 2: Login GetProfile Logout
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "GetProfile"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"
# TEST 3: Login Edit Display_Name in profile
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Update Profile"
curl -i -H "Content-Type: application/json" -X PUT -d '{"display_name": "NEW_DISPLAYNAME"}' -b cookie-jar http://info3103.cs.unb.ca:14637/profile
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"
# TEST 4: Login Get another user profile
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "GetProfile"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile?profile_id=1
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 5: Get All Followed Posts
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Get Followed Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/following
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 6: Get all Starred Posts
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Get Starred Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/starred
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 7: Get Recent Posts
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Get Recent Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/recent
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 8: Get Random Posts
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Get Random Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/random
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 9: Get specific Post
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Get Followed Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post?post_id=1
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 10: Get All of a specific Users Posts
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "Get Followed Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post?profile_id=1
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
 
echo " "
echo " "
echo " "

# Test 11: New post
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "New Post"
curl -i -H "Content-Type: application/json" -X POST -d '{"image_id": "1", "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "

# Test 12: Update Post
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "New Post"
curl -i -H "Content-Type: application/json" -X PUT -d '{"post_id": "5", "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout



# Test 13: Delete Post
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "New Post"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"post_id": "5"}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

echo " "
echo " "
echo " "
<<COMMENT1
# Test 14:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
# Test 14:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
# Test 15:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
# Test 16:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
# Test 17:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
# Test 18:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
# Test 19:
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
mysql -u creath -pP3OO9JnQ -D creath -e "source TestData.sql"

echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "TEST"
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
COMMENT1