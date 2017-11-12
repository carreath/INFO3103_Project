CREATE TABLE Users (
   PersonID int NOT NULL AUTO_INCREMENT,
   Username varchar(255) NOT NULL,
   TokenP varchar(255) NOT NULL,

   PRIMARY KEY (PersonID)
);



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
