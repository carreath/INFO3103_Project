
Drop Table Users;
CREATE TABLE Users (
   PersonID int NOT NULL AUTO_INCREMENT,
   Username varchar(255) NOT NULL,
   TokenP varchar(255) NOT NULL,
   SaltyToken varchar(255) NOT NULL,
   SessionToken varchar(255),
   PRIMARY KEY (PersonID)
);

Drop Table Users;
CREATE TABLE Image (
   ImageID int NOT NULL AUTO_INCREMENT,
   Name varchar(255) NOT NULL,
   FileSize varchar(255) NOT NULL,
   Extension varchar(255) NOT NULL,
   FileLocation varchar(255) NOT NULL,
   UserID varchar(255),
   PRIMARY KEY (PersonID)
);


-- add more to GetUser at a later time

DELIMITER //
DROP PROCEDURE IF EXISTS GetUser;
CREATE PROCEDURE GetUser(
  IN usernm varchar(255),
  IN dummy varchar(255)
)

  BEGIN
    SELECT Username FROM Users
    WHERE Username = usernm;
  END //
DELIMITER;





DELIMITER //
DROP PROCEDURE IF EXISTS GetSalty;
CREATE PROCEDURE GetSalty(
  IN usernm varchar(255),
  IN dummy varchar(255)
)

  BEGIN
    SELECT SaltyToken FROM Users
    WHERE Username = usernm;
  END //
DELIMITER ;




DELIMITER //
DROP PROCEDURE IF EXISTS SessionUpdate;
CREATE PROCEDURE SessionUpdate(
  IN usernm varchar(255),
  IN SessionT varchar(255)
)
  BEGIN

  UPDATE Users
  SET SessionToken = SessionT
  WHERE Username = usernm;

  END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS NewLogin;
CREATE PROCEDURE NewLogin(
  IN usernm varchar(255),
  IN token varchar(255),
  In saltyT varchar(255)
)
    BEGIN
    INSERT INTO Users (Username, TokenP, SaltyToken)
    VALUES (usernm, token, saltyT);

    End //
DELIMITER ;


DELIMITER //
DROP PROCEDURE IF EXISTS Login;
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
