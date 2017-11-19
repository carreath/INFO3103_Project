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

rmdir -f ../app/images
mkdir ../app/images
rmdir -f ../app/static
mkdir ../app/static
rmdir -f ../app/templates
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
Check_Response () {
	# extract the body
	HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

	# extract the status
	HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

	if [ ! $HTTP_STATUS -eq $1  ]; then
		echo -e ${FAIL}$HTTP_STATUS
		if [ $2 == true ]; then
			echo -e ${FAIL}$HTTP_BODY${NC}
		fi
	else
		echo -e ${SUCCESS}$HTTP_STATUS
		if [ $2 == true ]; then
			echo -e ${SUCCESS}$HTTP_BODY${NC}	
		fi
	fi
	echo -e "\n"
}

ResetDatabase () {
	mysql -u creath -pP3OO9JnQ -D creath -e "source ../sql/1.sql"
}
Login () {
	echo "Login"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:$port/login)
	Check_Response $1 $2
}
Logout () {
	echo "LOGOUT"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:$port/logout)
	Check_Response $1 $2
}
Get_Your_Profile () {
	echo "GetYourProfile"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/profile)
	Check_Response $1 $2
}
Get_User1_Profile () {
	echo "GetProfile id=1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/profile?profile_id=1)
	Check_Response $1 $2
}
Update_Profile () {
	echo "Update Profile"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X PUT -d '{"display_name": "NEW_DISPLAYNAME"}' -b cookie-jar http://info3103.cs.unb.ca:$port/profile)
	Check_Response $1 $2
}
Get_Recent_Posts () {
	echo "Get Recent Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/recent)
	Check_Response $1 $2
}
Get_Random_Posts () {
	echo "Get Random Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/random)
	Check_Response $1 $2
}
Get_Popular_Posts () {
	echo "Get Popular Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/popular)
	Check_Response $1 $2
}
Get_Followed_Posts () {
	echo "Get Posts from people you follow"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/following)
	Check_Response $1 $2
}
Get_Starred_Posts () {
	echo "Get Starred Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post/starred)
	Check_Response $1 $2
}
Get_User1_Posts () {
	echo "Get Posts from Profile 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post?profile_id=1)
	Check_Response $1 $2
}
Get_Specific_Post () {
	echo "Get Specific Posts"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/post?post_id=5)
	Check_Response $1 $2
}
New_Post () {
	echo "New Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"image_id": 1, "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
	Check_Response $1 $2
}
Update_Post () {
	echo "Update Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
	Check_Response $1 $2
}
Delete_Post () {
	echo "Delete Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"post_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
	Check_Response $1 $2
}
New_Image () {
	echo "New Image"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:$port/img)
	Check_Response $1 $2
}
Get_Image_From_Post () {
	echo "Get Image"
	New_Post
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X GET -b cookie-jar http://info3103.cs.unb.ca:$port/post?post_id=5)
	Check_Response $1 $2
}
Update_Image () {
	echo "Update Post"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post)
	Check_Response $1 $2
}
Delete_Image_FAIL () {
	echo "Delete Image When Attached To Post 5"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
	Check_Response $1 $2
}
Delete_Image_PASS () {
	Delete_Post
	echo "Delete Image After Post 5 Delete"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
	Check_Response $1 $2
}

New_Comment () {
	echo "New Comment on Post 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:$port/comment)
	Check_Response $1 $2
}
Get_Comments_On_Post () {
	echo "Get Comments For Post 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   http://info3103.cs.unb.ca:$port/comment?post_id=1)
	Check_Response $1 $2
}
Get_Your_Comments () {
	echo "Get Your Comments"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"  -b cookie-jar http://info3103.cs.unb.ca:$port/profile/comments)
	Check_Response $1 $2
}
Get_User1_Comments () {
	echo "Get Comments by User 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   http://info3103.cs.unb.ca:$port/profile/comments?profile_id=1)
	Check_Response $1 $2
}
Update_Comment () {
	Delete_Post
	echo "Delete Image After Post 5 Delete"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
	Check_Response $1 $2
}
Delete_Comment () {
	echo "Delete Comment"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"comment_id": 7}' -b cookie-jar http://info3103.cs.unb.ca:$port/comment)
	Check_Response $1 $2
}
Follow () {
	echo "Follow Someone"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"followed_profile_id":1}' -b cookie-jar http://info3103.cs.unb.ca:$port/follow)
	Check_Response $1 $2
}
Get_Your_Followers () {
	echo "Get people who Follow you"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/following)
	Check_Response $1 $2
}
Get_User1_Followers () {
	echo "Get People Profile 1 is following"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/followers?profile_id=1)
	Check_Response $1 $2
}
Get_People_You_Follow () {
	echo "Get People You Follow"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/followers)
	Check_Response $1 $2
}
Get_People_Following_User1 () {
	echo "Get People Following Profile 1"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -b cookie-jar http://info3103.cs.unb.ca:$port/profile/following?profile_id=1)
	Check_Response $1 $2
}
UnFollow () {
	echo "UnFollow"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"followed_profile_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/unfollow)
	Check_Response $1 $2
}
Create_Star () {
	echo "New Star Created"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"post_id":1}' -b cookie-jar http://info3103.cs.unb.ca:$port/star)

	Check_Response $1 $2
}
Create_Star () {
	echo "New Star 2 Created"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X POST -d '{"post_id":2}' -b cookie-jar http://info3103.cs.unb.ca:$port/star)

	Check_Response $1 $2
}
Remove_Star (){
	echo "Star Removed"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"post_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/star)
	Check_Response $1 $2
}
Get_Image_from_Image (){
	echo "Get Image"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X GET -b cookie-jar http://info3103.cs.unb.ca:$port/img?image_id=5)
	Check_Response $1 $2
}
Create_Image () {
	echo "New Image Created"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:$port/img)

	Check_Response $1 $2
}
Remove_Image (){
	echo "Remove Image"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
	Check_Response $1 $2
}
Remove_used_Image (){
	echo "Remove used Image	should fail"
	HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}"   -H "Content-Type: application/json" -X DELETE -d '{"image_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/img)
	Check_Response $1 $2
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
	Login 201 true
	Logout 200 true


	# TEST 2: Access Data - Login - Access Data - Logout - Access Data
	# Output: 401		   201	 200		   200	  401
	Get_Your_Comments 401 true
	Login 201 true
	Get_Your_Comments 200 true
	Logout 200 true
	Get_Your_Comments 401 true
}
#ProfileTests test getting your pofile before and after an update.
ProfileTests () {
	echo "########################################"
	echo "			Profile TESTS			   "
	echo "########################################"
	ResetDatabase
	Login 201 false


	Get_Your_Profile 200 true

	Get_User1_Profile 200 true

	Update_Profile 200 true

	Get_Your_Profile 200 true

	Logout 200 false
}
#PostTests test getting a post before and after an update and also
#   tests getting our different lists of posts
PostTests () {
	echo "########################################"
	echo "			 Post TESTS				 "
	echo "########################################"
	ResetDatabase
	Login 201 false

	New_Post 302 true
	Get_Specific_Post 200 true
	Update_Post 200 true
	Get_Specific_Post 200 true

	Create_Star 201 true
	Create_Star2 201 true
	Follow 201 true

	Get_Recent_Posts 200 true
	Get_Random_Posts 200 true
	Get_Popular_Posts 200 true
	Get_Followed_Posts 200 true
	Get_Starred_Posts 200 true
	Get_User1_Posts 200 true

	Delete_Post 200 true

	Logout 200 false
}
#CommentTests tests making comments and getting lists of comments from a user and a post
CommentTests () {
	echo "########################################"
	echo "			Comment TESTS			   "
	echo "########################################"
	ResetDatabase
	Login 201 false

	# TEST 1: Create Comment
	# Output: 201
	New_Comment 201 true

	# TEST 2: get Comment from test 1
	# Output: 200
	Get_Comments_On_Post 200 true


	# TEST 3: get all Comments from post 1
	# Output: 200   w/ 8ish comment bodies
	New_Comment 200 false
	New_Comment 200 false
	New_Comment 200 false
	New_Comment 200 false
	New_Comment 200 false
	New_Comment 200 false
	Get_Comments_On_Post 200 true

	# TEST 4: get all Comments from you
	# Output: 200   w/ 7 comment bodies
	Get_Your_Comments 200 true

	# TEST 5: get all Comments from user 1
	# Output: 200   w/ 2 comment bodies
	Get_User1_Comments 200 true

	# TEST 6: update one of your comments
	# Output: 200
	Update_Comment 200 true

	# TEST 7: delete one of your comments
	# Output: 200
	Delete_Comment 200 true

	Logout 200 false
}
#FollowerTests tests following and unfollowing a profile
#	as well as the lists involved with followers
FollowerTests () {
	echo "########################################"
	echo "		   Follower TESTS			   "
	echo "########################################"
	ResetDatabase
	Login 201 false


	Follow 201 true

	Get_Your_Followers 200 true

	Get_User1_Followers 200 true

	Get_People_You_Follow 200 true

	Get_People_Following_User1 200 true

	UnFollow 200 true

	Logout 200 false
}
#StarTests tests creating and removing a star
StarTests () {
	echo "########################################"
	echo "			 Star TESTS				 "
	echo "########################################"
	ResetDatabase
	Login 201 false

	Create_Star 201 true

	Remove_Star 200 true


	Logout 200 false
}
#ImageTests tests creating and getting an image as well as removing a used and unused image
ImageTests () {
	echo "########################################"
	echo "			Image TESTS				"
	echo "########################################"
	ResetDatabase
	Login 201 false

	Create_Image 201 true
	Get_Image_from_Image 200 true
  	Remove_Image 200 true
	Get_Image_from_Image 200 true
	Remove_used_Image 400 true

	Logout 200 false
}
AuthenticationTest
ProfileTests
PostTests
CommentTests
FollowerTests
StarTests
ImageTests

