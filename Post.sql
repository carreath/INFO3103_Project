Drop Table Post;
CREATE TABLE Post (
   PostID int NOT NULL AUTO_INCREMENT,
   UserN varchar(255) NOT NULL,
   ImageID varchar(255) NOT NULL,
   Title varchar(255) NOT NULL,
   Description varchar(255),
   Likes int,
   Dislikes int,
   StarsID varchar(255),
   PRIMARY KEY (PostID),
   Foreign KEY (UserN) REFERENCES Users(PersonID),
   Foreign KEY (StarsID) REFERENCES Stars(StarsID),
   Foreign KEY (ImageID) REFERENCES Image(ImageID)
);