#!/bin/bash

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

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color


read -p "Would you like coloured output (y or n): " colour

SUCCESS=$NC
FAIL=$NC
if [ $colour == "y" ]; then
	SUCCESS=$GREEN
	FAIL=$RED
fi

# Read username and password
read -p "username: " username
read -s -p "password: " password

port=14637

rmdir ../app/images
mkdir ../app/images
rmdir ../app/static
mkdir ../app/static
rmdir ../app/templates
mkdir ../app/templates

####################################################################################################
####################################################################################################
####################################################################################################

# TESTING BASH FILE
# Functions:
#	Everything used in tests
#
# Tests (At Bottom Of File):
#	AuthenticationTest()
#	ProfileTest()
#	PostTests()
#	CommentTests()
#	FollowerTests()
# ImageTests()
#	StarTests()

####################################################################################################
####################################################################################################
####################################################################################################

HTTP_RESPONSE=""

####################################################################################################
# FUNCTIONS
####################################################################################################
ResetDatabase () {
	mysql -u creath -pP3OO9JnQ -D creath -e "source ../sql/1.sql"
}

Login () {
	echo "Login"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:$port/login)
}

Logout () {
	echo "LOGOUT"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:$port/logout)
}

Get_Your_Profile () {
	echo "GetYourProfile"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/profile)
}

Get_User1_Profile () {
	echo "GetProfile id=1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/profile?profile_id=1)
}

Update_Profile () {
	echo "Update Profile"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X PUT -d '{"display_name": "NEW_DISPLAYNAME"}' -b cookie-jar http://info3103.cs.unb.ca:$port/profile)
}

Get_Recent_Posts () {
	echo "Get Recent Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/recent)
}

Get_Random_Posts () {
	echo "Get Random Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/random)
}

Get_Popular_Posts () {
	echo "Get Popular Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/popular)
}

Get_Followed_Posts () {
	echo "Get Posts from people you follow"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/following)
}

Get_Starred_Posts () {
	echo "Get Starred Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/starred)
}

Get_User1_Posts () {
	echo "Get Posts from Profile 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post?profile_id=1)
}

Get_Specific_Post () {
	echo "Get Specific Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post?post_id=5)
}

New_Post () {
	echo "New Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"image_id": 1, "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
}

Update_Post () {
	echo "Update Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
}

Delete_Post () {
	echo "Delete Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"post_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
}

New_Image () {
	echo "New Image"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:$port/img)
}

Get_Image_From_Post () {
	echo "Get Image"
	New_Post
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X GET -b cookie-jar http://info3103.cs.unb.ca:$port/post?post_id=5)
}

Update_Image () {
	echo "Update Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
}

Delete_Image_FAIL () {
	echo "Delete Image When Attached To Post 5"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
}

Delete_Image_PASS () {
	Delete_Post
	echo "Delete Image After Post 5 Delete"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
}


New_Comment () {
	echo "New Comment on Post 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:$port/comment)
}

Get_Comments_On_Post () {
	echo "Get Comments For Post 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   http://info3103.cs.unb.ca:$port/comment?post_id=1)
}

Get_Your_Comments () {
	echo "Get Your Comments"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/profile/comments)
}

Get_User1_Comments () {
	echo "Get Comments by User 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   http://info3103.cs.unb.ca:$port/profile/comments?profile_id=1)
}

Update_Comment () {
	Delete_Post
	echo "Delete Image After Post 5 Delete"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
}

Delete_Comment () {
	echo "Delete Comment"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"comment_id": 7}' -b cookie-jar http://info3103.cs.unb.ca:$port/comment)
}

Follow () {
	echo "Follow Someone"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"followed_profile_id":1}' -b cookie-jar http://info3103.cs.unb.ca:$port/follow)
}

Get_Your_Followers () {
	echo "Get people who Follow you"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/following)
}

Get_User1_Followers () {
	echo "Get People Profile 1 is following"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/followers?profile_id=1)
}

Get_People_You_Follow () {
	echo "Get People You Follow"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/followers)
}

Get_People_Following_User1 () {
	echo "Get People Following Profile 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/following?profile_id=1)
}

UnFollow () {
	echo "UnFollow"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"followed_profile_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/unfollow)
}

Create_Star () {
	echo "New Star Created"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"post_id":1}' -b cookie-jar http://info3103.cs.unb.ca:$port/star)

}
Create_Star () {
	echo "New Star 2 Created"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"post_id":2}' -b cookie-jar http://info3103.cs.unb.ca:$port/star)

}

Remove_Star (){
	echo "Star Removed"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"post_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/star)
}

Get_Image_from_Image (){
	echo "Get Image"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X GET -b cookie-jar http://info3103.cs.unb.ca:$port/img?image_id=5)
}

Create_Image () {
	echo "New Image Created"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:$port/img)

}

Remove_Image (){
	echo "Remove Image"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
}

Remove_used_Image (){
	echo "Remove used Image	should fail"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
}

Check_Response() {
	if [ -n "$1" ]; then
		echo $HTTP_STATUS
	fi
	if [ ! $HTTP_STATUS -eq $1  ]; then
		echo -e ${FAIL}$HTTP_STATUS
		echo -e ${FAIL}$HTTP_BODY${NC}
	else
		echo -e ${SUCCESS}$HTTP_STATUS
		echo -e ${SUCCESS}$HTTP_BODY${NC}
	fi
}

####################################################################################################
# TESTS
####################################################################################################

#AuthenticationTests loging in and loging out and a simple get when logged in and logged out.
AuthenticationTest () {
	echo "########################################"
	echo "		AUTHENTICATION TESTS			"
	echo "########################################"
	ResetDatabase

	# TEST 1: Login - Logout
	# Output: 201	 200
	Login 201
	Logout 200


	# TEST 2: Access Data - Login - Access Data - Logout - Access Data
	# Output: 401		   201	 200		   200	  401
	Get_Your_Comments 401
	Login 201
	Get_Your_Comments 200
	Logout 200
	Get_Your_Comments 401
}

#ProfileTests test getting your pofile before and after an update.
ProfileTests () {
	echo "########################################"
	echo "			Profile TESTS			   "
	echo "########################################"
	ResetDatabase
	Login


	Get_Your_Profile 200

	Get_User1_Profile 200

	Update_Profile 200

	Get_Your_Profile 200

	Logout
}

#PostTests test getting a post before and after an update and also
#   tests getting our different lists of posts
PostTests () {
	echo "########################################"
	echo "			 Post TESTS				 "
	echo "########################################"
	ResetDatabase
	Login

	New_Post 302
	Get_Specific_Post 200
	Update_Post 200
	Get_Specific_Post 200

	Create_Star 201
	Create_Star2 201
	Follow 201

	Get_Recent_Posts 200
	Get_Random_Posts 200
	Get_Popular_Posts 200
	Get_Followed_Posts 200
	Get_Starred_Posts 200
	Get_User1_Posts 200

	Delete_Post 200

	Logout
}

#CommentTests tests making comments and getting lists of comments from a user and a post
CommentTests () {
	echo "########################################"
	echo "			Comment TESTS			   "
	echo "########################################"
	ResetDatabase

	# TEST 1: Login - Create Comment
	# Output: 201	 201
	Login
	New_Comment 201

	# TEST 2: get Comment from test 1
	# Output: 200
	Get_Comments_On_Post 200


	# TEST 3: get all Comments from post 1
	# Output: 200   w/ 8ish comment bodies
	New_Comment 
	New_Comment 
	New_Comment 
	New_Comment 
	New_Comment 
	New_Comment 
	Get_Comments_On_Post 200

	# TEST 4: get all Comments from you
	# Output: 200   w/ 7 comment bodies
	Get_Your_Comments 200

	# TEST 5: get all Comments from user 1
	# Output: 200   w/ 2 comment bodies
	Get_User1_Comments 200

	# TEST 6: update one of your comments
	# Output: 200
	Update_Comment 200

	# TEST 7: delete one of your comments
	# Output: 200
	Delete_Comment 200
}

#FollowerTests tests following and unfollowing a profile
#	as well as the lists involved with followers
FollowerTests () {
	echo "########################################"
	echo "		   Follower TESTS			   "
	echo "########################################"
	ResetDatabase
	Login


	Follow 201

	Get_Your_Followers 200

	Get_User1_Followers 200

	Get_People_You_Follow 200

	Get_People_Following_User1 200

	UnFollow 200

	Logout
}

#StarTests tests creating and removing a star
StarTests () {
	echo "########################################"
	echo "			 Star TESTS				 "
	echo "########################################"
	ResetDatabase
	Login

	Create_Star 201

	Remove_Star 200


	Logout
}

#ImageTests tests creating and getting an image as well as removing a used and unused image
ImageTests () {
	echo "########################################"
	echo "			Image TESTS				"
	echo "########################################"
	ResetDatabase
	Login

	Create_Image 201
	Get_Image_from_Image 200
  	Remove_Image 200
	Get_Image_from_Image 200
	Remove_used_Image 400
	Logout
}

AuthenticationTest
ProfileTests
PostTests
CommentTests
FollowerTests
StarTests
ImageTests

