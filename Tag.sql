Drop Table Tag;
CREATE TABLE Tag (
   TagID int NOT NULL AUTO_INCREMENT,
   Description varchar(255) NOT NULL UNIQUE,
   PRIMARY KEY (TagID)
);