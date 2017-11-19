#!/bin/bash

# Read username and password
username="mjared"
password="${PASS}"
port="14637"

rmdir images && mkdir images
rmdir static && mkdir static
rmdir templates && mkdir templates

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



####################################################################################################
# FUNCTIONS
####################################################################################################
ResetDatabase () {
	mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
}

Login () {
	echo "Login"
	curl  -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:$port/login
}

Logout () {
	echo "LOGOUT"
	curl  -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:$port/logout
}

Get_Your_Profile () {
	echo "GetYourProfile"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/profile
}

Get_User1_Profile () {
	echo "GetProfile id=1"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/profile?profile_id=1
}

Update_Profile () {
	echo "Update Profile"
	curl  -H "Content-Type: application/json" -X PUT -d '{"display_name": "NEW_DISPLAYNAME"}' -b cookie-jar http://info3103.cs.unb.ca:$port/profile
}

Get_Recent_Posts () {
	echo "Get Recent Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post/recent
}

Get_Random_Posts () {
	echo "Get Random Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post/random
}

Get_Popular_Posts () {
	echo "Get Popular Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post/popular
}

Get_Followed_Posts () {
	echo "Get Posts from people you follow"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post/following
}

Get_Starred_Posts () {
	echo "Get Starred Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post/starred
}

Get_User1_Posts () {
	echo "Get Posts from Profile 1"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post?profile_id=1
}

Get_Specific_Post () {
	echo "Get Specific Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/post?post_id=5
}

New_Post () {
	echo "New Post"
	curl  -H "Content-Type: application/json" -X POST -d '{"image_id": 1, "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post
}

Update_Post () {
	echo "Update Post"
	curl  -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post
}

Delete_Post () {
	echo "Delete Post"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"post_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/post
}

New_Image () {
	echo "New Image"
	curl  -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:$port/img
}

Get_Image_From_Post () {
	echo "Get Image"
	New_Post
	curl  -X GET -b cookie-jar http://info3103.cs.unb.ca:$port/post?post_id=5
}

Update_Image () {
	echo "Update Post"
	curl  -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:$port/post
}

Delete_Image_FAIL () {
	echo "Delete Image When Attached To Post 5"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img
}

Delete_Image_PASS () {
	Delete_Post
	echo "Delete Image After Post 5 Delete"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img
}


New_Comment () {
	echo "New Comment on Post 1"
	curl  -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:$port/comment
}

Get_Comments_On_Post () {
	echo "Get Comments For Post 1"
	curl  http://info3103.cs.unb.ca:$port/comment?post_id=1
}

Get_Your_Comments () {
	echo "Get Comments"
	curl -b cookie-jar http://info3103.cs.unb.ca:$port/profile/comments
}

Get_User1_Comments () {
	echo "Get Comments by User 1"
	curl  http://info3103.cs.unb.ca:$port/profile/comments?profile_id=1
}

Update_Comment () {
	Delete_Post
	echo "Delete Image After Post 5 Delete"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img
}

Delete_Comment () {
	echo "Delete Comment"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"comment_id": 7}' -b cookie-jar http://info3103.cs.unb.ca:$port/comment
}

Follow () {
	echo "Follow Someone"
	curl  -H "Content-Type: application/json" -X POST -d '{"followed_profile_id":1}' -b cookie-jar http://info3103.cs.unb.ca:$port/follow
}

Get_Your_Followers () {
	echo "Get people who Follow you"
	curl  -b cookie-jar http://info3103.cs.unb.ca:$port/profile/following
}

Get_User1_Followers () {
	echo "Get People Profile 1 is following"
	curl  -b cookie-jar http://info3103.cs.unb.ca:$port/profile/followers?profile_id=1
}

Get_People_You_Follow () {
	echo "Get People You Follow"
	curl  -b cookie-jar http://info3103.cs.unb.ca:$port/profile/followers
}

Get_People_Following_User1 () {
	echo "Get People Following Profile 1"
	curl  -b cookie-jar http://info3103.cs.unb.ca:$port/profile/following?profile_id=1
}

UnFollow () {
	echo "UnFollow"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"followed_profile_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/unfollow
}

Create_Star () {
	echo "New Star Created"
	curl  -H "Content-Type: application/json" -X POST -d '{"post_id":1}' -b cookie-jar http://info3103.cs.unb.ca:$port/star

}
Create_Star () {
	echo "New Star 2 Created"
	curl  -H "Content-Type: application/json" -X POST -d '{"post_id":2}' -b cookie-jar http://info3103.cs.unb.ca:$port/star

}

Remove_Star (){
	echo "Star Removed"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"post_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/star
}

Get_Image_from_Image (){
	echo "Get Image"
	curl  -X GET -b cookie-jar http://info3103.cs.unb.ca:$port/img?image_id=5
}

Create_Image () {
	echo "New Image Created"
	curl  -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:$port/img

}

Remove_Image (){
	echo "Remove Image"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:$port/img
}

Remove_used_Image (){
	echo "Remove used Image    should fail"
	curl  -H "Content-Type: application/json" -X DELETE -d '{"image_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:$port/img
}
####################################################################################################
# TESTS
####################################################################################################

#AuthenticationTests loging in and loging out and a simple get when logged in and logged out.
AuthenticationTest () {
	echo "########################################"
	echo "        AUTHENTICATION TESTS            "
	echo "########################################"
	ResetDatabase

	# TEST 1: Login - Logout
	# Output: 201     200
	Login
	Logout


	# TEST 2: Access Data - Login - Access Data - Logout - Access Data
	# Output: 401           201     200           200      401
	Get_Your_Comments
	Login
	Get_Your_Comments
	Logout
	Get_Your_Comments
}

#ProfileTests test getting your pofile before and after an update.
ProfileTests () {
	echo "########################################"
	echo "            Profile TESTS               "
	echo "########################################"
	ResetDatabase
	Login


	Get_Your_Profile

	Get_User1_Profile

	Update_Profile

	Get_Your_Profile

	Logout
}

#PostTests test getting a post before and after an update and also
#   tests getting our different lists of posts
PostTests () {
	echo "########################################"
	echo "             Post TESTS                 "
	echo "########################################"
	ResetDatabase
	Login

	New_Post
	Get_Specific_Post
	Update_Post
	Get_Specific_Post

	Create_Star
	Create_Star2
	Follow

	Get_Recent_Posts
	Get_Random_Posts
	Get_Popular_Posts
	Get_Followed_Posts
	Get_Starred_Posts
	Get_User1_Posts

	Delete_Post

	Logout
}

#CommentTests tests making comments and getting lists of comments from a user and a post
CommentTests () {
	echo "########################################"
	echo "            Comment TESTS               "
	echo "########################################"
	ResetDatabase

	# TEST 1: Login - Create Comment
	# Output: 201     201
	Login
	New_Comment

	# TEST 2: get Comment from test 1
	# Output: 200
	Get_Comments_On_Post


	# TEST 3: get all Comments from post 1
	# Output: 200   w/ 8ish comment bodies
	New_Comment
	New_Comment
	New_Comment
	New_Comment
	New_Comment
	New_Comment
	Get_Comments

	# TEST 4: get all Comments from you
	# Output: 200   w/ 7 comment bodies
	Get_Your_Comments

	# TEST 5: get all Comments from user 1
	# Output: 200   w/ 2 comment bodies
	Get_User1_Comments

	# TEST 6: update one of your comments
	# Output: 200
	Update_Comment

	# TEST 7: delete one of your comments
	# Output: 200
	Delete_Comment
}

#FollowerTests tests following and unfollowing a profile
#    as well as the lists involved with followers
FollowerTests () {
	echo "########################################"
	echo "           Follower TESTS               "
	echo "########################################"
	ResetDatabase
	Login


	Follow

	Get_Your_Followers

	Get_User1_Followers

	Get_People_You_Follow

	Get_People_Following_User1

	UnFollow

	Logout
}

#StarTests tests creating and removing a star
StarTests () {
	echo "########################################"
	echo "             Star TESTS                 "
	echo "########################################"
	ResetDatabase
	Login

	CreateStars

	Remove_Star


	Logout
}

#ImageTests tests creating and getting an image as well as removing a used and unused image
ImageTests () {
	echo "########################################"
	echo "            Image TESTS                "
	echo "########################################"
	ResetDatabase
	Login

	Create_Image
	Get_Image_from_Image
  Remove_Image
	Get_Image_from_Image
	Remove_used_Image
	Logout
}

#AuthenticationTest
#ProfileTests
PostTests
#CommentTests
#FollowerTests
#StarTests
#ImageTests
