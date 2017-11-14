Drop Table Tags;
CREATE TABLE Tags (
   TagsID int NOT NULL AUTO_INCREMENT,
   PostID varchar(255) NOT NULL,
   TagID varchar (255) NOT NULL,
   PRIMARY KEY (TagsID)
   Foreign KEY (PostID) REFERENCES Post(PostID)
   Foreign KEY (TagID) REFERENCES Tag(TagID)
);