#!/bin/bash

# Read username and password
username="creath"
password="${PASS}"

rmdir images && mkdir images
rmdir static && mkdir static
rmdir templates && mkdir templates

ResetDatabase () {
	mysql -u creath -pP3OO9JnQ -D creath -e "source 1.sql"
}

Login () {
	echo "Login"
	curl -i -H "Content-Type: application/json" -X POST -d '{"username": "'$username'", "password": "'$password'"}' -c cookie-jar http://info3103.cs.unb.ca:14637/login
}

Logout () {
	echo "LOGOUT"
	curl -i -H "Content-Type: application/json" -X DELETE -b cookie-jar http://info3103.cs.unb.ca:14637/logout
}

Get_Your_Profile () {
	echo "GetYourProfile"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile
}

Get_User1_Profile () {
	echo "GetProfile id=1"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/profile?profile_id=1
}

Update_Profile () {
	echo "Update Profile"
	curl -i -H "Content-Type: application/json" -X PUT -d '{"display_name": "NEW_DISPLAYNAME"}' -b cookie-jar http://info3103.cs.unb.ca:14637/profile
}

Get_Recent_Posts () {
	echo "Get Recent Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/recent
}

Get_Random_Posts () {
	echo "Get Random Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/random
}

Get_Popular_Posts () {
	echo "Get Starred Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/starred
}

Get_Followed_Posts () {
	echo "Get Followed Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/following
}

Get_Starred_Posts () {
	echo "Get Starred Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post/starred
}

Get_User1_Posts () {
	echo "Get Followed Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post?profile_id=1
}

Get_Specific_Post () {
	echo "Get Specific Posts"
	curl -b cookie-jar http://info3103.cs.unb.ca:14637/post?post_id=1
}

New_Post () {
	echo "New Post"
	curl -i -H "Content-Type: application/json" -X POST -d '{"image_id": 1, "title": "TEST NEW POST", "description": "TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
}

Update_Post () {
	echo "Update Post"
	curl -i -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
}

Delete_Post () {
	echo "Delete Post"
	curl -i -H "Content-Type: application/json" -X DELETE -d '{"post_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
}

New_Image () {
	echo "New Image"
	curl -i -X POST -F "image=@./TestImages/test.jpg" -b cookie-jar http://info3103.cs.unb.ca:14637/img
}

Get_Image () {
	echo "Get Image"
	New_Post()
	curl -i -X GET -b cookie-jar http://info3103.cs.unb.ca:14637/post?post_id=5
}

Update_Image () {
	echo "Update Post"
	curl -i -H "Content-Type: application/json" -X PUT -d '{"post_id": 5, "title": "TEST UPDATE ", "description": "NEW UPDATE TEST DESCRIPTION", "tags": ["Funny","Hilarious","UNB","NOT RICK"]}' -b cookie-jar http://info3103.cs.unb.ca:14637/post
}

Delete_Image_FAIL () {
	echo "Delete Image When Attached To Post 5"
	curl -i -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/img
}

Delete_Image_PASS () {
	Delete_Post()
	echo "Delete Image After Post 5 Delete"
	curl -i -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/img
}


New_Comment () {
	echo "New Comment on Post 1"
	curl -i -H "Content-Type: application/json" -X POST -d '{"post_id": 1, "comment_body": "TEST NEW Comment"}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
}

Get_Comments () {
	echo "Get Comments For Post 1"
	curl -i http://info3103.cs.unb.ca:14637/comment?post_id=1
}

Get_Your_Comments () {
	echo "Get Comments"
	curl -i http://info3103.cs.unb.ca:14637/profile/comments
}

Get_User1_Comments () {
	echo "Get Comments by User 1"
	curl -i http://info3103.cs.unb.ca:14637/profile/comments?profile_id=1
}

Update_Comment () {
	Delete_Post()
	echo "Delete Image After Post 5 Delete"
	curl -i -H "Content-Type: application/json" -X DELETE -d '{"image_id": 5}' -b cookie-jar http://info3103.cs.unb.ca:14637/img
}

Delete_Comment () {
	echo "Delete Comment"
	curl -i -H "Content-Type: application/json" -X DELETE -d '{"comment_id": 7}' -b cookie-jar http://info3103.cs.unb.ca:14637/comment
}

Follow () {
	echo "Follow Someone"
	curl -i -H "Content-Type: application/json" -X POST -d '{"followed_profile_id":1}' -b cookie-jar http://info3103.cs.unb.ca:14637/follow
}

Get_Your_Followers () {
	echo "Get Followers"
	curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following
}

Get_User1_Followers () {
	echo "Get Followers"
	curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following
}

Get_People_Following_You () {
	echo "Get Following profiles for profile 1"
	curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following?profile_id=1
}

Get_People_Following_User1 () {
	echo "Get Following profiles for profile 1"
	curl -i -b cookie-jar http://info3103.cs.unb.ca:14637/profile/following?profile_id=1
}

UnFollow () {
	echo "UnFollow"
	curl -i -H "Content-Type: application/json" -X DELETE -d '{"followed_profile_id": 1}' -b cookie-jar http://info3103.cs.unb.ca:14637/unfollow
}

AuthenticationTest () {
	ResetDatabase()

	# TEST 1: Login - Logout
	# Output: 201     200
	Login()
	Logout()


	# TEST 2: Access Data - Login - Access Data - Logout - Access Data
	# Output: 401           201     200           200      401
	Login()

	Logout()
}

CommentTest () {
	ResetDatabase()

	# TEST 1: Login - Create Comment
	# Output: 201     201
	Login()
	New_Comment()

	# TEST 2: get Comment from test 1
	# Output: 200    
	Get_Comments()


	# TEST 3: get all Comments from post 1
	# Output: 200   w/ 8ish comment bodies
	New_Comment()
	New_Comment()
	New_Comment()
	New_Comment()
	New_Comment()
	New_Comment()
	Get_Comments()

	# TEST 4: get all Comments from you
	# Output: 200   w/ 7 comment bodies
	Get_Your_Comments()

	# TEST 5: get all Comments from user 1
	# Output: 200   w/ 2 comment bodies
	Get_User1_Comments()

	# TEST 6: update one of your comments
	# Output: 200 
	Update_Comment()

	# TEST 7: delete one of your comments
	# Output: 200  
	Delete_Comment()
}
