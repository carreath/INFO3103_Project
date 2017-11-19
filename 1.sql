-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------   DROPS   -------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------

Drop Table IF EXISTS Comments;
Drop Table IF EXISTS Follows;
Drop Table IF EXISTS Tags;
Drop Table IF EXISTS Tag;
Drop Table IF EXISTS Stars;
Drop Table IF EXISTS Post;
Drop Table IF EXISTS Image;
Drop Table IF EXISTS Profile;

DROP PROCEDURE IF EXISTS GetProfileID;
DROP PROCEDURE IF EXISTS GetProfile;
DROP PROCEDURE IF EXISTS UpdateProfile;
DROP PROCEDURE IF EXISTS NewProfile;
DROP PROCEDURE IF EXISTS GetImage;
DROP PROCEDURE IF EXISTS GetImageUsage;
DROP PROCEDURE IF EXISTS NewImage;
DROP PROCEDURE IF EXISTS DeleteImage;
DROP PROCEDURE IF EXISTS NewPost;
DROP PROCEDURE IF EXISTS DeletePost;
DROP PROCEDURE IF EXISTS GetPost;
DROP PROCEDURE IF EXISTS UpdatePost;
DROP PROCEDURE IF EXISTS GetUserPosts;
DROP PROCEDURE IF EXISTS GetRandomPosts;
DROP PROCEDURE IF EXISTS GetRecentPosts;
DROP PROCEDURE IF EXISTS GetPopularPosts;
DROP PROCEDURE IF EXISTS GetStarredPosts;
DROP PROCEDURE IF EXISTS GetFollowedPosts;
DROP PROCEDURE IF EXISTS GetStarsCount;
DROP PROCEDURE IF EXISTS CreateStar;
DROP PROCEDURE IF EXISTS DeleteStar;
DROP PROCEDURE IF EXISTS DeleteAllStars;
DROP PROCEDURE IF EXISTS CreateTag;
DROP PROCEDURE IF EXISTS GetTagID;
DROP PROCEDURE IF EXISTS GetTagDescription;
DROP PROCEDURE IF EXISTS AddTags;
DROP PROCEDURE IF EXISTS DeleteTags;
DROP PROCEDURE IF EXISTS DeleteAllTags;
DROP PROCEDURE IF EXISTS GetTags;
DROP PROCEDURE IF EXISTS GetPosts;
DROP PROCEDURE IF EXISTS CreateFollow;
DROP PROCEDURE IF EXISTS Unfollow;
DROP PROCEDURE IF EXISTS GetFollowers;
DROP PROCEDURE IF EXISTS GetFollowed;
DROP PROCEDURE IF EXISTS GetComments;
DROP PROCEDURE IF EXISTS GetCommentsByUser;
DROP PROCEDURE IF EXISTS UpdateComment;
DROP PROCEDURE IF EXISTS NewComment;
DROP PROCEDURE IF EXISTS DeleteComment;


-------------------------------------------------------------------
-------------------------------------------------------------------
------------------------   TABLES   -------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------


CREATE TABLE Profile (
	id int NOT NULL AUTO_INCREMENT,
	username varchar(255) NOT NULL UNIQUE,
	display_name varchar(255),
	PRIMARY KEY (id)
);

CREATE TABLE Image (
   id int NOT NULL AUTO_INCREMENT,
   profile_id int NOT NULL,
   name varchar(255) NOT NULL,
   uri varchar(255) NOT NULL,
   PRIMARY KEY (id),
   FOREIGN KEY (profile_id) REFERENCES Profile(id)
);

CREATE TABLE Post (
   id int NOT NULL AUTO_INCREMENT,
   profile_id int NOT NULL,
   image_id int NOT NULL,
   title varchar(255) NOT NULL,
   description varchar(255) NOT NULL,
   dates TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (id),
   Foreign KEY (profile_id) REFERENCES Profile(id),
   Foreign KEY (image_id) REFERENCES Image(id)
);

CREATE TABLE Stars (
   id int NOT NULL AUTO_INCREMENT,
   post_id int NOT NULL,
   profile_id int NOT NULL,
   PRIMARY KEY (id),
   UNIQUE KEY (post_id, profile_id),
   FOREIGN KEY (post_id) REFERENCES Post(id),
   FOREIGN KEY (profile_id) REFERENCES Profile(id)
);

CREATE TABLE Tag (
   id int NOT NULL AUTO_INCREMENT,
   description varchar(255) NOT NULL UNIQUE,
   PRIMARY KEY (id)
);

CREATE TABLE Tags (
   id int NOT NULL AUTO_INCREMENT,
   post_id int NOT NULL,
   tag_id int NOT NULL,
   PRIMARY KEY (id),
   UNIQUE KEY (post_id, tag_id),
   FOREIGN KEY (post_id) REFERENCES Post(id),
   FOREIGN KEY (tag_id) REFERENCES Tag(id)
);

CREATE TABLE Follows (
   id int NOT NULL AUTO_INCREMENT,
   following_id int NOT NULL,
   follower_id int NOT NULL,
   PRIMARY KEY (id),
   UNIQUE KEY (following_id, follower_id),
   FOREIGN KEY (following_id) REFERENCES Profile(id),
   FOREIGN KEY (follower_id) REFERENCES Profile(id)
);

CREATE TABLE Comments (
   id int NOT NULL AUTO_INCREMENT,
   comment_body varchar(255) NOT NULL,
   post_id int NOT NULL,
   profile_id int NOT NULL,
   PRIMARY KEY (id),
   Foreign KEY (post_id) REFERENCES Post(id),
   Foreign KEY (profile_id) REFERENCES Profile(id)
);



-------------------------------------------------------------------
-------------------------------------------------------------------
----------------------   PROCEDURES   -----------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------



DELIMITER //
CREATE PROCEDURE GetProfileID(
	IN username varchar(255),
	IN dummy varchar(1)
)
  BEGIN
    SELECT id FROM Profile AS p
		Where username = p.username;

END //

CREATE PROCEDURE GetProfile(
  IN profile_id int,
	IN dummy varchar(1)
)
  BEGIN
    Select p.display_name, p.username, COALESCE(po.posts,0) posts, COALESCE(f.followers,0) followers, COALESCE(fo.following,0) following, COALESCE(c.comments,0) comments, COALESCE(s.stars,0) stars from Profile as p
    LEFT JOIN (
        Select po.profile_id, Count(*) as posts from Post as po
        where po.profile_id = profile_id
        group by po.profile_id
    ) as po
    on po.profile_id = p.id
    LEFT JOIN (
        Select f.follower_id, Count(*) as followers from Follows as f
        where f.follower_id = profile_id
        group by f.follower_id
    ) as f
    on f.follower_id = p.id
    LEFT JOIN (
        Select fo.following_id, Count(*) as following from Follows as fo
        where fo.following_id = profile_id
        group by fo.following_id
    ) as fo
    on fo.following_id = p.id
    LEFT JOIN (
        Select c.profile_id, Count(*) as comments from Comments as c
        where c.profile_id = profile_id
        group by c.profile_id
    ) as c
    on c.profile_id = p.id
    LEFT JOIN (
        Select s.profile_id, Count(*) as stars from Stars as s
        where s.profile_id = profile_id
        group by s.profile_id
    ) as s
    on s.profile_id = p.id
    where p.id = profile_id;
END //

CREATE PROCEDURE UpdateProfile(
  IN profile_id varchar(255),
  IN display_name varchar(255)
)
  BEGIN
	UPDATE Profile as p
	SET p.display_name = display_name
	WHERE p.id = profile_id;
END //

CREATE PROCEDURE NewProfile(
  IN username varchar(255),
	IN dummy varchar(1)
)
    BEGIN
    INSERT INTO Profile (username, display_name)
    	VALUES (username, username);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE GetImage(
  IN image_id int,
	IN dummy varchar(1)
)
  BEGIN
    SELECT name, uri FROM Image as i
    WHERE i.id = image_id;
  END //

CREATE PROCEDURE GetImageUsage(
  IN image_id int,
	IN dummy varchar(1)
)
  BEGIN
    SELECT Count(*) as numPosts FROM Post as p
    WHERE p.image_id = image_id;
  END //

CREATE PROCEDURE NewImage(
  IN profile_id int,
  IN name varchar(255),
  IN uri varchar(255)
)
    BEGIN
	    INSERT INTO Image (profile_id, name, uri)
		    VALUES (profile_id, name, uri);
			SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeleteImage(
  IN image_id int,
	IN dummy varchar(1)
)
  BEGIN
    DELETE i FROM Image as i
    	WHERE i.id = image_id;
  END //

CREATE PROCEDURE NewPost(
  IN profile_id int,
  IN image_id int,
  IN title varchar(255),
  IN description varchar(255)
)
    BEGIN
	    INSERT INTO Post (profile_id, image_id, title, description)
		    VALUES (profile_id, image_id, title, description);
			SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeletePost(
  IN post_id int,
	IN dummy varchar(1)
)
  BEGIN
    DELETE p FROM Post as p
    WHERE p.id = post_id;
  END //


CREATE PROCEDURE GetPost(
  IN post_id int,
	IN dummy varchar(1)
  )
  BEGIN
    SELECT * FROM Post as p
    WHERE p.id = post_id;
  END //

CREATE PROCEDURE UpdatePost(
  IN post_id int,
  IN title varchar(255),
  IN description varchar(255)
)
  BEGIN
	UPDATE Post as p
	SET p.title = title, p.description = description
	WHERE p.id = post_id;
    END //

CREATE PROCEDURE GetUserPosts(
	IN profile_id int,
		IN dummy varchar(1)
)
  BEGIN
    SELECT * FROM Post as p
    WHERE p.profile_id = profile_id;
  END //

CREATE PROCEDURE GetRandomPosts()
  BEGIN
    SELECT * FROM Post
    ORDER BY RAND();
  END //

CREATE PROCEDURE GetRecentPosts()
  BEGIN
    SELECT * FROM Post
    ORDER BY dates desc;
  END //

CREATE PROCEDURE GetPopularPosts()
  BEGIN
    SELECT p.id, profile_id, image_id, title, description, dates, COALESCE(s.stars,0) stars FROM Post as p
		LEFT JOIN (
        Select s.post_id, Count(*) as stars from Stars as s
        group by s.post_id
    ) as s
		on s.post_id = p.id
    ORDER BY stars desc;
  END //


CREATE PROCEDURE GetStarredPosts(
  IN profile_id int,
	IN dummy varchar(1)
)
  BEGIN
    SELECT p.id, image_id, title, description, dates
	FROM Stars AS s
	LEFT JOIN Post AS p
		ON s.profile_id = profile_id
    WHERE profile_id = p.profile_id
    Order By p.dates;
  END //

CREATE PROCEDURE GetFollowedPosts(
  IN profile_id int,
	IN dummy varchar(1)
)
  BEGIN
    SELECT p.id, image_id, title, description, dates
	FROM Post AS p
	LEFT JOIN Follows AS f
		ON f.follower_id = profile_id
    WHERE p.profile_id = f.following_id
    Order By p.dates;
  END //

CREATE PROCEDURE GetStarsCount(
  IN profile_id int,
	IN dummy varchar(1)
)
  BEGIN
    SELECT Count(*)
		FROM Stars AS s
		LEFT JOIN Post AS p
			ON s.post_id = p.id
    	WHERE profile_id = p.profile_id;
  END //

CREATE PROCEDURE CreateStar(
  IN post_id int,
  IN profile_id int
)
    BEGIN
	    INSERT INTO Stars (post_id, profile_id)
	    	VALUES (post_id, profile_id);
			SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeleteStar(
  IN post_id int,
	IN profile_id int
)
  BEGIN
    DELETE s FROM Stars as s
    WHERE s.post_id = post_id AND s.profile_id = profile_id;
  END //

CREATE PROCEDURE DeleteAllStars(
  IN post_id int,
	IN dummy varchar(1)
)
  BEGIN
    DELETE s FROM Stars as s
    WHERE s.post_id = post_id;
  END //


CREATE PROCEDURE CreateTag(
  IN description varchar(255),
	IN dummy varchar(1)
)
    BEGIN
	    INSERT INTO Tag (description)
	    VALUES (description);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE GetTagDescription(
  IN tag_id int,
	IN dummy varchar(1)
  )
  BEGIN
    SELECT description FROM Tag as t
    WHERE t.id = tag_id;
  END //

CREATE PROCEDURE GetTagID(
  IN description varchar(255),
	IN dummy varchar(1)
  )
  BEGIN
    SELECT t.id FROM Tag as t
    WHERE t.description = description;
  END //

CREATE PROCEDURE AddTags(
  IN post_id int,
  IN tag_id int
  )
  BEGIN
    INSERT INTO Tags (post_id, tag_id)
    VALUES (post_id, tag_id);
    SELECT LAST_INSERT_ID();
  END //

CREATE PROCEDURE DeleteTags(
  IN post_id int,
  IN tag_id int
  )
  BEGIN
    DELETE t FROM Tags as t
    WHERE t.post_id = post_id AND t.id = tag_id;
  END //

CREATE PROCEDURE DeleteAllTags(
  IN post_id int,
	IN dummy varchar(1)
)
  BEGIN
    DELETE t FROM Tags as t
    WHERE t.post_id = post_id;
  END //

CREATE PROCEDURE getTags(
  IN post_id int,
	IN dummy varchar(1)
  )
  BEGIN
    SELECT t.id
	FROM Tag AS t
	LEFT JOIN Tags AS s
		ON t.id = s.tag_id
    WHERE post_id = s.post_id;
  END //

CREATE PROCEDURE GetPosts(
  IN tag_id int,
	IN dummy varchar(1)
  )
  BEGIN
    SELECT post_id, image_id, title, description, dates
	FROM Tags AS t
	LEFT JOIN Post AS p
		ON s.post_id = p.post_id
    WHERE tag_id = t.tag_id;
  END //

CREATE PROCEDURE CreateFollow(
  IN following_id int,
  IN follower_id int
)
    BEGIN
    INSERT INTO Follows (following_id, follower_id)
	    VALUES (following_id, follower_id);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE Unfollow(
  IN following_id int,
  IN follower_id int
)
  BEGIN
    DELETE f FROM Follows as f
    WHERE f.following_id = following_id AND f.follower_id = follower_id;
  END //

CREATE PROCEDURE GetFollowers(
  IN follower_id int,
	IN dummy varchar(1)
  )
  BEGIN
    SELECT following_id FROM Follows as f
    WHERE f.follower_id = follower_id;
  END //

CREATE PROCEDURE GetFollowed(
  IN following_id int,
	IN dummy varchar(1)
  )
  BEGIN
    SELECT follower_id FROM Follows as f
    WHERE f.following_id = following_id;
  END //

CREATE PROCEDURE GetComments(
  IN post_id int,
	IN dummy varchar(1)
)
  BEGIN
    SELECT comment_body FROM Comments as c
    WHERE c.post_id = post_id;
  END //

CREATE PROCEDURE GetCommentsByUser(
  IN post_id int,
  IN user_id int
)
  BEGIN
    SELECT comment_body FROM Comments as c
    WHERE c.profile_id = user_id;
  END //

CREATE PROCEDURE UpdateComment(
  IN comment_id int,
  IN comment_body varchar(255)
)
  BEGIN
	UPDATE Comments as c
	SET c.comment_body = comment_body
	WHERE c.comment_id = comment_id;
    END //

CREATE PROCEDURE NewComment(
  IN profile_id int,
  IN post_id int,
  IN comment_body varchar(255)
)
    BEGIN
    INSERT INTO Comments (profile_id, post_id, comment_body)
	    VALUES (profile_id, post_id, comment_body);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeleteComment(
  IN comment_id int,
	IN dummy varchar(1)
)
  BEGIN
    DELETE c FROM Comments as c
    WHERE c.id = comment_id;
  END //


DELIMITER ;



Insert Into Profile (username, display_name)
	Values('user1', 'Name 1');
Insert Into Profile (username, display_name)
	Values('user2', 'Name 2');
Insert Into Profile (username, display_name)
	Values('user3', 'Name 3');
Insert Into Profile (username, display_name)
	Values('user4', 'Name 4');




Insert Into Image(profile_id, name, uri)
	Values(1, 'image 1', 'i dont know yet');
Insert Into Image(profile_id, name, uri)
	Values(2, 'image 2', 'i dont know yet');
Insert Into Image(profile_id, name, uri)
	Values(3, 'image 3', 'i dont know yet');
Insert Into Image(profile_id, name, uri)
	Values(4, 'image 4', 'i dont know yet');



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
