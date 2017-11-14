Drop Table Profile;
CREATE TABLE Profile (
   ProfileID int NOT NULL AUTO_INCREMENT,
   UserN varchar(255) NOT NULL,
   Followers varchar(255),
   Following varchar(255),
   PRIMARY KEY (ProfileID),
   Foreign KEY (UserN) REFERENCES Users(PersonID)
);