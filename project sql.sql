CREATE TABLE Users (
   PersonID int NOT NULL AUTO_INCREMENT,
   Username varchar(255) NOT NULL,
   TokenP varchar(255) NOT NULL,

   PRIMARY KEY (PersonID)
);




DELIMITER //
CREATE PROCEDURE NewLogin(
  IN usernm varchar(255),
  IN token varchar(255)
)
    BEGIN
    INSERT INTO Users (Username, TokenP)
    Values (usernm, token);

    End //
DELIMITER ;





DELIMITER //
 CREATE PROCEDURE Login(
  IN usernm varchar(255),
  IN token varchar(255)
)
   BEGIN
   SELECT Count(*)  FROM Users
   WHERE Username = usernm
   AND TokenP = token;

   END //
 DELIMITER ;
