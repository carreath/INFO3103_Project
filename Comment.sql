Drop Table Comments;
CREATE TABLE Comments (
   CommentID int NOT NULL AUTO_INCREMENT,
   Username varchar(255) NOT NULL,
   PostID varchar(255) NOT NULL,
   PRIMARY KEY (CommentID)
   Foreign KEY (PostID) REFERENCES Post(PostID)
);