Drop Table Stars;
CREATE TABLE Stars (
   StarsID int NOT NULL AUTO_INCREMENT,
   UserN varchar(255) NOT NULL,
   PostID varchar(255) NOT NULL,
   PRIMARY KEY (StarsID),
   FOREIGN KEY (UserN) REFERENCES Users(PersonID)
   FOREIGN KEY (PostID) REFERENCES Post(PostID)
);