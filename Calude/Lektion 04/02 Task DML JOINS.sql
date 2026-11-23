SELECT a.Lastname, a.Firstname, a.Address, o.ZIP, o.City 
	FROM Authors a 
	INNER JOIN Places o 
	ON a.LocationID = o.ID 
	LIMIT 1000;

select * from books;
-- 2.4
select books.id,books.title, genres.Genre
	from books 
	inner join genres
		on books.GenreID=genres.ID
		order by title;

		
SELECT b.title, a.Lastname, a.Firstname, v.Name  
	FROM books AS b  
		INNER JOIN Authors AS a  
	ON b.AutorID = a.ID  
		INNER JOIN Publishers AS v  
	ON b.PublishersID = v.ID  
	LIMIT 1000;  		
	
SELECT b.title, a.Lastname, a.Firstname, v.Name, g.Genre
	FROM books AS b  
		INNER JOIN Authors AS a  
			ON b.AutorID = a.ID  
		INNER JOIN Publishers AS v  
			ON b.PublishersID = v.ID
		inner join genres as g
			on b.GenreID = g.id
	LIMIT 1000;	
	
--
SELECT a.Lastname, a.Firstname, a.Address, o.ZIP, o.City  
	FROM Authors AS a  
	LEFT JOIN Places AS o  
	ON a.LocationID = o.ID  
	LIMIT 10000;
	
-- 3.5
select b.title, a.Firstname, a.Lastname, g.genre
		from books as b
		left join Authors a
			on b.AutorID=a.id
		left join genres as g
			on b.GenreID=g.id
	order by g.Genre, b.title;
	
-- 3.6
select a.Lastname, a.Firstname, g.Genre
	from Authors as a
		left join Authors_genres as ag
			on ag.AutorID=a.id
		left join genres as g
			on ag.GenreID=g.id
	order by a.Lastname, a.Firstname;
	
-- 4.0
SELECT a.Firstname, a.Lastname, a.Address, o.ZIP, o.City  
	FROM Places  AS o
	LEFT JOIN Authors AS a  
	ON a.LocationID = o.ID  
	LIMIT 10000;  	
-- 4.3	
select count(*) from Places;	

-- 4.4
select Lastname,Firstname,
	ZIP, City
	from Customers
	left join Places 
		on Customers.LocationID = Places.ID
	order by Lastname, Firstname;
	
-- 4.5
select k.Firstname, k.Lastname, k.Address
		from Customers as k
		left join Places as o
			on k.LocationID=o.id
	where o.City='Seattle'
	order by Lastname

select k.Firstname, k.Lastname, k.Address
		from Customers as k
		left join Places as o
			on k.LocationID=o.id
	where o.ZIP between 20000 and 25000
	order by Lastname;
	
-- 4.8
select books.id, books.title
		from books
		inner join genres 
			on books.GenreID = genres.id 
			   and genres.Fiction=1
	order by title;
			   
select books.id, books.title
		from books
		inner join genres 
			on books.GenreID = genres.id 
	where genres.Fiction=1
	order by title;

-- 4.9
select GenreID, count(books.id) as Anzahl,
	genres.Genre
	from books
		left join genres on books.GenreID=genres.ID
	group by GenreID
	order by Anzahl desc; 	
	
-- 4.10
select books.title,
		Authors.Lastname, Authors.Firstname,
		genres.Genre
	from books
		left join Authors on books.AutorID=Authors.ID
		left join genres on books.GenreID=genres.id
		inner join Publishers on books.PublisherID=Publishers.id
	where Publishers.Name='Wiley'
	order by title
	;

-- 4.11
SELECT au.Date_From, au.Date_to,
  au.preis, CustomerID, b.title
  FROM lends au
  JOIN books b ON au.BookID=b.id
  ORDER BY Date_From;
  
-- 4.12
SELECT au.Date_From, au.Date_to,
  au.preis, CustomerID, b.title, k.Lastname, k.Firstname
  FROM lends au
  JOIN books b ON au.BookID=b.id
  JOIN Customers k ON au.CustomerID=k.id
  WHERE au.Date_From BETWEEN '2021-01-01' AND '2021-01-31'
  ORDER BY Lastname, Firstname;
 
SELECT au.Date_From, au.Date_to,
  au.preis, CustomerID, b.title, k.Lastname, k.Firstname
  FROM lends au
  JOIN books b ON au.BookID=b.id
  JOIN Customers k ON au.CustomerID=k.id
  WHERE year(au.Date_From)= 2021
    AND MONTH(au.Date_From) = 1
  ORDER BY Lastname, Firstname;

-- 4.13
SELECT COUNT(*) AS Anzahlbooks, CustomerID
  FROM lends au
  GROUP BY CustomerID
  ORDER BY Anzahlbooks desc;

-- 4.14
SELECT * 
  FROM books
  JOIN Publishers ON books.PublisherID=Publishers.id
  WHERE books.AutorID
  IN (SELECT id FROM Authors 
       WHERE Lastname='Adams' AND Firstname='William');
	   