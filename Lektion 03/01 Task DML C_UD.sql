-- INSERT INTO authors (lastname, firstname) VALUES ('Irving', 'John');
/*
INSERT INTO places 
  (zip, city) 
VALUES 
(33016, 'Ottawa'), 
(33017, 'Mississauga'), 
(33018, 'Hamilton'), 
(33019, 'Oshawa');
*/
/*
SELECT * FROM places 
  WHERE zip > 33015 AND zip < 33020 
  ORDER BY zip; 
*/
-- 1.3
/*
INSERT INTO authors (lastname, firstname) VALUES 
('Hornby', 'Nick'),
('Rowling','Joanne K.');
*/
-- SELECT * FROM authors WHERE lastname='Hornby' OR lastname='Rowling'

-- 2
/* UPDATE places 
  SET zip = 33020
  WHERE city = 'Oshawa'; */
-- 2.1
/*
-- SELECT * FROM authors WHERE lastname='Matthews' AND firstname='Summer'
UPDATE authors SET lastname='Armistead', firstname='Maupin' 
  WHERE lastname='Matthews' AND firstname='Summer';
  */
  
/*  
SELECT ID FROM Publishers 
WHERE Name = 'B & W Publishing';
*/
/*
SELECT ISBN, Title, Published_Date 
FROM books
WHERE PublishersID= (SELECT ID FROM Publishers 
WHERE Name = 'B & W Publishing');
*/
/*
UPDATE books 
 SET PublishersID = (SELECT ID FROM Publishers WHERE Name = 'Lakewater Press') 
  WHERE PublishersID =  (SELECT ID FROM Publishers 
							WHERE Name = 'B & W Publishing');
							*/
-- 2.2
/*
-- SELECT id FROM authors WHERE lastname LIKE 'M%';
SELECT * FROM books
  WHERE autorid IN (SELECT id FROM authors WHERE lastname LIKE 'M%');
  */
-- 2.3
/*
-- SELECT id FROM authors WHERE lastname LIKE 'Z%';
-- SELECT * FROM places WHERE zip=97499
UPDATE authors SET Locationid = (SELECT id FROM places WHERE zip=97499)
  WHERE  lastname LIKE 'Z%'; */

-- 2.4
-- SELECT * FROM authors WHERE lastname LIKE 'Z%';

-- 3.0
/*
DELETE FROM places 
  WHERE city = 'Oshawa';
*/
-- 3.1
/*
-- SELECT * FROM authors WHERE firstname='Daphne' AND lastname='Scott'
-- SELECT * FROM books WHERE autorid= (
--	  SELECT ID FROM authors WHERE firstname='Daphne' AND lastname='Scott');
	
DELETE FROM books WHERE autorid= (
 SELECT ID FROM authors WHERE firstname='Daphne' AND lastname='Scott');
*/

-- 4.1
/*
INSERT INTO places (zip, city) VALUES ('25000', 'Biel/Bienne');
INSERT INTO authors (lastname, firstname, Adresse, LocationID, Email) 
  VALUES 
  ( 'Jordan', 
    'Robert',
	 'Fiktionsstrasse 12',
	  (SELECT id FROM places WHERE zip='25000'),
	  'robert.jordan@hftm.ch'
  );
*/
/*
-- 4.2
INSERT INTO Publishers (Name, Email, Phonenumber) VALUES 
      ('hftm Publishing', 'publish@hftm.ch', '032 xxx xx xx');
-- 4.3
INSERT INTO authors_Publishers (autorid, PublishersID)
  VALUES (
           (SELECT id FROM authors WHERE firstname='Robert' AND lastname='Jordan'),
           (SELECT id FROM Publishers WHERE Name='hftm Publishing')
         );
         
-- 4.4
INSERT INTO places (zip, city) VALUES ('25630', 'Ipsach');
INSERT INTO Customers (lastname, firstname, Adresse, Email, Birthdate, LocationID)
   VALUES 
	('Schild', 'André', 'Brunnackerstrasse 21', 'andre.schild@hftm.ch', 
	'1966-08-24', (SELECT id FROM places WHERE zip='25630'));
	
-- 4.5
INSERT INTO authors_genres 
   (autorsid, GenresID) VALUES 
	((SELECT id FROM authors WHERE firstname='Robert' AND lastname='Jordan'),
	 (SELECT id FROM genres WHERE genre='Fantasy')
	), 
	((SELECT id FROM authors WHERE firstname='Robert' AND lastname='Jordan'),
	 (SELECT id FROM genres WHERE genre='Horror')
	);
	
-- 4.6
INSERT INTO books
  (isbn, Title, Published_Date, AmountInStock, AutorID, PublishersID, GenresID)
  VALUES 
  ('ISBN-00001', 'Wheel of time, Band 1', '1990-11-28', 100, 
     (SELECT id FROM authors WHERE firstname='Robert' AND lastname='Jordan'),
     (SELECT id FROM Publishers WHERE Name='hftm Publishing'),
     (SELECT id FROM genres WHERE genre='Fantasy')
  ),
  ('ISBN-00002', 'Wheel of time, Band 2', '1995-01-28', 500, 
     (SELECT id FROM authors WHERE firstname='Robert' AND lastname='Jordan'),
     (SELECT id FROM Publishers WHERE Name='hftm Publishing'),
     (SELECT id FROM genres WHERE genre='Fantasy')
	),
  ('ISBN-00003', 'Wheel of time, Band 3', '2004-02-29', 10000, 
     (SELECT id FROM authors WHERE firstname='Robert' AND lastname='Jordan'),
     (SELECT id FROM Publishers WHERE Name='hftm Publishing'),
     (SELECT id FROM genres WHERE genre='Fantasy')
	  );
	  
-- 4.7
INSERT INTO lends
  (Date_From, Date_To, Price, CustomerID, BookID)
  VALUES 
  ('2024-02-27', '2024-03-26', 10, 
  		(SELECT id FROM Customers WHERE email='andre.schild@dozent.hftm.ch'),
  		(SELECT id FROM books WHERE isbn='ISBN-00001')
  ),
    ('2024-02-27', '2024-03-26', 10, 
  		(SELECT id FROM Customers WHERE email='andre.schild@dozent.hftm.ch'),
  		(SELECT id FROM books WHERE isbn='ISBN-00002')
  ),
    ('2024-02-27', '2024-03-26', 10, 
  		(SELECT id FROM Customers WHERE email='andre.schild@dozent.hftm.ch'),
  		(SELECT id FROM books WHERE isbn='ISBN-00003')
  );
  
  */
  
-- 5.1
--   SELECT * FROM Publishers WHERE Name='Sleepytown Press'
--  UPDATE Publishers SET email='john.sleepy@mail.com', 
--        TelefonNr='5-555-555-5555' WHERE Name='Sleepytown Press' 

-- 5.2
-- SELECT * FROM books WHERE Title LIKE ' %';
-- UPDATE books SET Title= TRIM(Title) WHERE Title LIKE ' %';

-- 5.3
-- SELECT * FROM authors WHERE lastname='Murphy' AND firstname='Abdul';
/*
UPDATE authors SET adresse='Kensington Street, 876',
  LocationID= (SELECT id FROM places WHERE zip='61093'),
  email= 'abdul.murphy@mail.com'
  WHERE     lastname='Murphy' AND firstname='Abdul';
*/

-- 5.4
/*
update books 
   SET GenresID=(SELECT id FROM genres WHERE Genre='Science fiction') 
	WHERE Title='Nineteen Eighty Four';
*/

-- 5.5
-- SELECT * FROM lends WHERE Date_To >= CURDATE();
-- UPDATE lends SET Date_To= DATE_ADD(Date_To, INTERVAL 14 DAY) WHERE Date_To >= CURDATE();

-- 5.6
/*
SELECT * from authors_genres WHERE
  autorid= (SELECT id FROM authors WHERE firstname='Belinda' AND lastname='Shaw')
  AND GenresID= (SELECT id FROM genres WHERE genre='Contemporary Fiction');
	
	
update authors_genres 
 SET GenresID=(SELECT id FROM genres WHERE genre='Mystery')
 WHERE
  autorid= (SELECT id FROM authors WHERE firstname='Belinda' AND lastname='Shaw')
  AND GenresID= (SELECT id FROM genres WHERE genre='Contemporary Fiction');
*/


-- 5.7
/*
ALTER TABLE Customers 
ADD Birthdate_Day TINYINT, 
ADD Birthdate_Month TINYINT, 
ADD Birthdate_Year SMALLINT; 

UPDATE Customers SET 
  Birthdate_Day=DAY(Birthdate),
  Birthdate_Month=MONTH(Birthdate),
  Birthdate_Year=YEAR(Birthdate);
  
*/


-- 5.8
-- ALTER TABLE Customers ADD Birthdate_CH CHAR(10); 

-- Variante ohne führende 0 bei tag+monat
/*
UPDATE Customers SET Birthdate_CH= 
  CONCAT(
    CONCAT(
	   CONCAT(
        CONCAT(Birthdate_Day, '.'),
         Birthdate_Month), '.'), Birthdate_Year)
*/
/*
UPDATE Customers SET Birthdate_CH= 
  CONCAT(
    CONCAT(
	   CONCAT(
        CONCAT(LPAD(Birthdate_Day, 2, 0), '.'),
         LPAD(Birthdate_Month, 2, 0)), '.'), 
			  LPAD(Birthdate_Year, 4, 0))
			  */
			  
-- 5.9
-- SELECT lastname, firstname, DATE_FORMAT(Birthdate, '%m.%d.%Y') AS Birthdate_US, Birthdate_CH FROM Customers;
