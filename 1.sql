
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
DROP PROCEDURE IF EXISTS NewImage;
DROP PROCEDURE IF EXISTS DeleteImage;
DROP PROCEDURE IF EXISTS NewPost;
DROP PROCEDURE IF EXISTS DeletePost;
DROP PROCEDURE IF EXISTS GetPost;
DROP PROCEDURE IF EXISTS GetRandomPosts;
DROP PROCEDURE IF EXISTS GetRecentPosts;
DROP PROCEDURE IF EXISTS GetPopularPosts;
DROP PROCEDURE IF EXISTS GetStarredPosts;
DROP PROCEDURE IF EXISTS GetStarsCount;
DROP PROCEDURE IF EXISTS CreateStars;
DROP PROCEDURE IF EXISTS CreateTag;
DROP PROCEDURE IF EXISTS GetTag;
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
   size varchar(255) NOT NULL,
   extension varchar(255) NOT NULL,
   uri varchar(255) NOT NULL,
   PRIMARY KEY (id),
   FOREIGN KEY (profile_id) REFERENCES Profile(id)
);

CREATE TABLE Post (
   id int NOT NULL AUTO_INCREMENT,
   profile_id int NOT NULL,
   image_id int NOT NULL,
   title varchar(255) NOT NULL,
   description varchar(255),
   dates TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   likes int,
   dislikes int,
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
   FOREIGN KEY (post_id) REFERENCES Profile(id),
   FOREIGN KEY (profile_id) REFERENCES Post(id)
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
   FOREIGN KEY (post_id) REFERENCES Profile(id),
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
	IN username varchar(255)
)
  BEGIN
    SELECT id FROM Profile AS p
		Where username = p.username;

END //

CREATE PROCEDURE GetProfile(
  IN profile_id int
)
  BEGIN
    SELECT p.DisplayName, p.username, Count(po.id), Count(f.id), Count(c.id), Count(s.id)
    	FROM Profile as p 
    	JOIN Post as po
    		ON po.profile_id = p.profile_id
    	JOIN Follows as f
    		ON f.profile_id = p.profile_id
    	JOIN Comments as c
    		ON c.profile_id = p.profile_id
    	JOIN Stars as s
    		ON s.profile_id = p.profile_id
    WHERE p.profile_id = profile_id;
END //

CREATE PROCEDURE UpdateProfile(
  IN username varchar(255),
  IN display_name varchar(255)
)
  BEGIN
	UPDATE Profile as p
	SET p.display_name = display_name
	WHERE p.username = username;
END //

CREATE PROCEDURE NewProfile(
  IN username varchar(255),
  IN display_name varchar(255)
)
    BEGIN
    INSERT INTO Profile (username, display_name)
    	VALUES (username, display_name);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE GetImage(
  IN image_id int
)
  BEGIN
    SELECT name, uri FROM Image as i
    WHERE i.id = image_id;
  END //

CREATE PROCEDURE NewImage(
  IN username varchar(255),
  IN name varchar(255),
  IN size varchar(255),
  IN extension varchar(255),
  IN uri varchar(255)
)
    BEGIN
	    INSERT INTO Image (username, name, size, extension, uri)
		    VALUES (username, name, size, extension, uri);
			SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeleteImage(
  IN image_id int
)
  BEGIN
    DELETE FROM Image USING i as Image
    	WHERE i.id = image_id;
  END //

CREATE PROCEDURE NewPost(
  IN username int,
  IN image_id int,
  IN title varchar(255),
  IN description varchar(255)
)
    BEGIN
	    INSERT INTO Post (username, image_id, title, description)
		    VALUES (username, image_id, title, description, 0, 0);
			SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeletePost(
  IN post_id int
)
  BEGIN
    DELETE FROM Post USING p as Post
    WHERE p.id = post_id;
  END //


CREATE PROCEDURE GetPost(
  IN post_id int
  )
  BEGIN
    SELECT * FROM Post as p
    WHERE p.id = post_id;
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
    SELECT * FROM Post
    ORDER BY likes desc;
  END //


CREATE PROCEDURE GetStarredPosts(
  IN profile_id int
)
  BEGIN
    SELECT post_id, image_id, title, description, dates, likes, dislikes
	FROM Stars AS s
	JOIN Post AS p
		ON s.post_id = p.id
    WHERE profile_id = p.profile_id;
  END //

CREATE PROCEDURE GetStarsCount(
  IN profile_id int
)
  BEGIN
    SELECT Count(*)
		FROM Stars AS s
		JOIN Post AS p
			ON s.post_id = p.id
    	WHERE profile_id = p.profile_id;
  END //

CREATE PROCEDURE CreateStars(
  IN post_id int,
  IN profile_id int
)
    BEGIN
	    INSERT INTO Stars (post_id, profile_id)
	    	VALUES (post_id, profile_id);
			SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE CreateTag(
  IN description varchar(255)
)
    BEGIN
	    INSERT INTO Tag (description)
	    VALUES (description);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE GetTag(
  IN tag_id int
  )
  BEGIN
    SELECT description FROM Tag as t
    WHERE t.tag_id = tag_id;
  END //

CREATE PROCEDURE getTags(
  IN post_id int
  )
  BEGIN
    SELECT post_id, image_id, title, description, dates, likes, dislikes
	FROM Tags AS s
	JOIN Tag AS t
		ON t.tag_id = s.tag_id
    WHERE post_id = s.post_id;
  END //

CREATE PROCEDURE GetPosts(
  IN tag_id int
  )
  BEGIN
    SELECT post_id, image_id, title, description, dates, likes, dislikes
	FROM Tags AS t
	JOIN Post AS p
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
    DELETE FROM Follows USING f as Follows
    WHERE f.following_id = following_id AND f.follower_id = follower_id;
  END //

CREATE PROCEDURE GetFollowers(
  IN follower_id int
  )
  BEGIN
    SELECT following_id FROM Follows as f
    WHERE f.follower_id = follower_id;
  END //

CREATE PROCEDURE GetFollowed(
  IN following_id int
  )
  BEGIN
    SELECT follower_id FROM Follows as f
    WHERE f.following_id = following_id;
  END //

CREATE PROCEDURE GetComments(
  IN post_id int
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
    WHERE c.user_id = user_id;
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
  IN user_id int,
  IN post_id int,
  IN comment_body varchar(255)
)
    BEGIN
    INSERT INTO Comments (user_id, post_id, comment_body)
	    VALUES (user_id, post_id, comment_body);
		SELECT LAST_INSERT_ID();
    End //

CREATE PROCEDURE DeleteComment(
  IN comment_id int
)
  BEGIN
    DELETE FROM Comments USING c as Comments
    WHERE c.comment_id = comment_id;
  END //


DELIMITER ;