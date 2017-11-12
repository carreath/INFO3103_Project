CREATE TABLE Users (
   PersonID int NOT NULL AUTO_INCREMENT,
   Username varchar(255) NOT NULL,
   TokenP varchar(255) NOT NULL,
   SessionToken varchar(255),
   PRIMARY KEY (PersonID)
);

DELIMITER //
CREATE PROCEDURE SessionUpdate(
  IN SessionT varchar(255),
  IN usernm varchar(255)
)
  BEGIN

  UPDATE Users
  SET SessionToken = SessionT
  WHERE Username = usernm;

  END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE NewLogin(
  IN usernm varchar(255),
  IN token varchar(255)
)
    BEGIN
    INSERT INTO Users (Username, TokenP)
    VALUES (usernm, token);

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
