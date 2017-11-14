Drop Table Image;
CREATE TABLE Image (
   ImageID int NOT NULL AUTO_INCREMENT,
   UserN varchar(255) NOT NULL,
   Name varchar(255) NOT NULL,
   Size varchar(255) NOT NULL,
   Extention varchar(255) NOT NULL,
   URI varchar(255) NOT NULL,
   PRIMARY KEY (ImageID),
   FOREIGN KEY (UserN) REFERENCES Users(PersonID)
);