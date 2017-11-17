Insert Into Profile (username, display_name)
	Values('user1', 'Name 1');
Insert Into Profile (username, display_name)
	Values('user2', 'Name 2');
Insert Into Profile (username, display_name)
	Values('user3', 'Name 3');
Insert Into Profile (username, display_name)
	Values('user4', 'Name 4');




Insert Into Image(profile_id, name, size, extension, uri)
	Values(1, 'image 1', '100MB', '.png', 'i dont know yet');
Insert Into Image(profile_id, name, size, extension, uri)
	Values(2, 'image 2', '25MB', '.png', 'i dont know yet');
Insert Into Image(profile_id, name, size, extension, uri)
	Values(3, 'image 3', '75MB', '.png', 'i dont know yet');
Insert Into Image(profile_id, name, size, extension, uri)
	Values(4, 'image 4', '50MB', '.png', 'i dont know yet');



Insert Into Post(profile_id, image_id, title, description)
	Values(1, 1, 'post1', 'this is the first post');
Insert Into Post(profile_id, image_id, title, description)
	Values(2, 2, 'post2', 'this is the second post');
Insert Into Post(profile_id, image_id, title, description)
	Values(3, 3, 'post3', 'this is the third post');
Insert Into Post(profile_id, image_id, title, description)
	Values(4, 4, 'post4', 'this is the fourth post');



Insert Into Stars(post_id, profile_id)
	Values(1, 2);
Insert Into Stars(post_id, profile_id)
	Values(2, 3);
Insert Into Stars(post_id, profile_id)
	Values(3, 4);
Insert Into Stars(post_id, profile_id)
	Values(4, 1);

Insert Into Tag(description)
	Values('scary');
Insert Into Tag(description)
	Values('funny');
Insert Into Tag(description)
	Values('cute');


Insert Into Tags(post_id, tag_id)
	Values(1, 1);
Insert Into Tags(post_id, tag_id)
	Values(2, 2);
Insert Into Tags(post_id, tag_id)
	Values(2, 3);
Insert Into Tags(post_id, tag_id)
	Values(3, 1);
Insert Into Tags(post_id, tag_id)
	Values(3, 2);
Insert Into Tags(post_id, tag_id)
	Values(3, 3);
Insert Into Tags(post_id, tag_id)
	Values(4, 1);
Insert Into Tags(post_id, tag_id)
	Values(4, 3);

Insert Into Follows(following_id, follower_id)
	Values(1, 2);
Insert Into Follows(following_id, follower_id)
	Values(1, 3);
Insert Into Follows(following_id, follower_id)
	Values(1, 4);
Insert Into Follows(following_id, follower_id)
	Values(2, 1);
Insert Into Follows(following_id, follower_id)
	Values(3, 2);
Insert Into Follows(following_id, follower_id)
	Values(2, 4);
Insert Into Follows(following_id, follower_id)
	Values(4, 3);
Insert Into Follows(following_id, follower_id)
	Values(4, 1);


Insert Into Comments(comment_body, post_id, profile_id)
	Values('wow', 1, 1);
Insert Into Comments(comment_body, post_id, profile_id)
	Values('cool', 1, 2);
Insert Into Comments(comment_body, post_id, profile_id)
	Values('awesome', 2, 3);
Insert Into Comments(comment_body, post_id, profile_id)
	Values('first', 3, 4);
Insert Into Comments(comment_body, post_id, profile_id)
	Values('first', 1, 1);
Insert Into Comments(comment_body, post_id, profile_id)
	Values('first', 2, 2);



