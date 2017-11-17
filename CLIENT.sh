#!/bin/bash

# Read username and password
username="creath"
password="${PASS}"

mkdir images
mkdir static
mkdir templates

mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"

# TEST 1: Login Logout
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# TEST 2: Login GetProfile Logout
#=====================================================================================================
echo "GetProfile"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# TEST 3: Login Edit Display_Name in profile
#=====================================================================================================
echo "Update Profile"
curl -i -H "Content-Type: application/json" -X PUT -d '{"display_name": "NEW_DISPLAYNAME"}' -b cookie-jar http://info3103.cs.unb.ca:14637/profile



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# TEST 4: Login Get another user profile
#=====================================================================================================
echo "GetProfile"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile?profile_id=1



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# Test 5: Get All Followed Posts
#=====================================================================================================
echo "Get Followed Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/following



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login



#=====================================================================================================
# Test 6: Get all Starred Posts
#=====================================================================================================
echo "Get Starred Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/starred



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login



#=====================================================================================================
# Test 7: Get Recent Posts
#=====================================================================================================
echo "Get Recent Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/recent



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login



#=====================================================================================================
# Test 8: Get Random Posts
#=====================================================================================================
echo "Get Random Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/random



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# Test 9: Get specific Post
#=====================================================================================================
echo "Get Followed Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post?post_id=1



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# Test 10: Get All of a specific Users Posts
#=====================================================================================================
echo "Get Followed Posts"
curl -b cookie-jar http://info3103.cs.unb.ca:14637/post?profile_id=1



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# Test 11: New post
#=====================================================================================================
echo "New Post"
curl -i -H "Content-Type: application/json" -X POST -d '{"image_id": 1, "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post

#=====================================================================================================
# Test 12: Update Post
#=====================================================================================================
echo "Update Post"
curl -i -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post

#=====================================================================================================
# Test 13: Delete Post
#=====================================================================================================
echo "Delete Post"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"post_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/post



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login



#=====================================================================================================
# Test 14:
#=====================================================================================================
echo "New Image"
curl -i -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:14637/img
echo "New Post"
curl -i -H "Content-Type: application/json" -X POST -d '{"image_id": 5, "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post

#=====================================================================================================
# Test 15:
#=====================================================================================================
echo "Get Image"
curl -i -X GET -b cookie-jar http://info3103.cs.unb.ca:14637/post?post_id=5

#=====================================================================================================
# Test 16 DELETE Image When referenced By a post: RESULT=FAIL (400):
#=====================================================================================================
echo "Delete Image"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/img

#=====================================================================================================
# Test 16 DELETE Image When referenced By a post: RESULT=FAIL (400):
#=====================================================================================================
echo "Delete Post"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"post_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
echo "Delete Image"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/img



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login



#=====================================================================================================
# Test 17: Create new Comment
#=====================================================================================================
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment

#=====================================================================================================
# Test 18: Get Comment
#=====================================================================================================
echo "Get Comments"
curl -i http://info3103.cs.unb.ca:14637/comment?post_id=1


#=====================================================================================================
# Test 19: Delete Comment
#=====================================================================================================
echo "Delete Image"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"comment_id": 7}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login


#=====================================================================================================
# Test 20: Get All Comments
#=====================================================================================================
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "New Comment"
curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
echo "Get Comments"
curl -i http://info3103.cs.unb.ca:14637/comment?post_id=1
echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout

#=====================================================================================================
# Test 21: Get All Comments by YOU
#=====================================================================================================
echo "Get Comments"
curl -i http://info3103.cs.unb.ca:14637/profile/comments

#=====================================================================================================
# Test 22: Get All Comments by profile 1
#=====================================================================================================
echo "Get Comments"
curl -i http://info3103.cs.unb.ca:14637/profile/comments?profile_id=1



echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
echo "LOGIN"
curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login



#=====================================================================================================
# Test 24:  Follow Someone
#=====================================================================================================
echo "Follow Someone"
curl -i -H "Content-Type: application/json" -X POST -d '{"followed_profile_id":1}' -b cookie-jar http://info3103.cs.unb.ca:14637/follow

#=====================================================================================================
# Test 25: Get followers
#=====================================================================================================
echo "Get Followers"
curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following

#=====================================================================================================
# Test 26: Get following
#=====================================================================================================
echo "Get Following profiles for profile 1"
curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following?profile_id=1


#=====================================================================================================
# Test 27: Unfollow
#=====================================================================================================
echo "UnFollow"
curl -i -H "Content-Type: application/json" -X DELETE -d '{"followed_profile_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:14637/unfollow

#=====================================================================================================
# Test 28: Get followers id 1
#=====================================================================================================
echo "Get Followers"
curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following

#=====================================================================================================
# Test 29: Get following id 1
#=====================================================================================================
echo "Get Following profiles"
curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following?profile_id=1

#=====================================================================================================
# Test 30: Get following
#=====================================================================================================
eecho "Get Following profiles"
curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following




echo "LOGOUT"
curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
