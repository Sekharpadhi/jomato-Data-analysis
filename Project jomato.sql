-- Creating a database for project
Create DATABASE jomato_project

-- Using database
USE jomato_project

-- Viewing table data 
select * from jomato

--1.Create a user-defined functions to stuff the Chicken into ‘Quick Bites’. Eg: ‘Quick Chicken Bites’.
CREATE FUNCTION CHICKEN_BITES()
 RETURNS TABLE 
 AS 
 RETURN
       SELECT REPLACE(RestaurantType ,'Quick Bites', 'Quick Chicken Bites') as Restauranttype FROM jomato

SELECT * FROM CHICKEN_BITES()

/*2. Use the function to display the restaurant name and cuisine type which has the
maximum number of rating.*/
CREATE FUNCTION MAX_NUM_RATING()
RETURNS TABLE
AS 
RETURN 
       SELECT RestaurantName , CuisinesType FROM jomato
	   WHERE No_of_Rating >= (SELECT MAX( No_of_Rating) FROM jomato) 

SELECT * FROM dbo.MAX_NUM_RATING()

/*3. Create a Rating Status column to display the rating as ‘Excellent’ if it has more the 4 
     start rating, ‘Good’ if it has above 3.5 and below 5 star rating, ‘Average’ if it is above 3
     and below 3.5 and ‘Bad’ if it is below 3 star rating. */

SELECT *, 
CASE 
    WHEN Rating > 4 THEN 'Excellent'
    WHEN Rating > 3.5 AND Rating < 5  THEN 'Good'
	WHEN Rating > 3 AND Rating < 3.5  THEN 'Average'
	ELSE 'Bad'
	END AS   [RATING STATUS ]
	
FROM jomato

-- If we want to save it as column 
--  Add the new column
--ALTER TABLE jomato
--ADD [RATING STATUS] VARCHAR(10);

--  Update the new column with the case statement
--UPDATE jomato
--SET [RATING STATUS] = 
--    CASE 
--        WHEN Rating > 4 THEN 'Excellent'
--        WHEN Rating > 3.5 AND Rating <= 4 THEN 'Good'
--        WHEN Rating > 3 AND Rating <= 3.5 THEN 'Average'
--        ELSE 'Bad'
--    END;

--4. Find the Ceil, floor and absolute values of the rating column and display the current date
--and separately display the year, month_name and day.

SELECT * , 
CEILING(Rating) AS CEIL ,
FLOOR(Rating) AS FLOOR ,
ABS(Rating) AS ABSOLUTE , 
GETDATE() AS [CURRENT DATE] ,
YEAR(GETDATE()) AS [YEAR] ,
DATENAME(MONTH , GETDATE()) AS [MONTH] ,
DAY(GETDATE()) AS [DAY]
from jomato

--5. Display the restaurant type and total average cost using rollup
SELECT RestaurantType , AVG(AverageCost) AS AVG_COST 
FROM jomato
GROUP BY RestaurantType WITH ROLLUP


 /* 6. Create a stored procedure to display the restaurant name, type and cuisine where the
table booking is not zero. */

CREATE PROCEDURE table_booked
AS
SELECT RestaurantName, RestaurantType , CuisinesType 
FROM Jomato
WHERE  NOT TableBooking = 0

exec table_booked

/* 7. Create a transaction and update the cuisine type ‘Cafe’ to ‘Cafeteria’. Check the result
and rollback it. */

BEGIN TRANSACTION 
        UPDATE Jomato SET CuisinesType = 'Cafeteria' WHERE CuisinesType = 'Cafe'

        SELECT * FROM Jomato

      ROLLBACK

 /* 8. Generate a row number column and find the top 5 areas with the highest rating of
restaurants. */

SELECT DISTINCT 
       TOP 5  ROW_NUMBER() OVER (ORDER BY Rating desc ) [ Highest Rating ] ,
       Area  FROM Jomato


--9.Use the while loop to display the 1 to 50.

  DECLARE @loop INT
  SET @loop = 1

  WHILE @loop <= 50
  BEGIN
   PRINT @loop 
   SET @loop = @loop + 1
   END

--10. Write a query to Create a Top rating view to store the generated top 5 highest rating of restaurants.

CREATE VIEW top_rating AS
SELECT TOP 5 * FROM Jomato
ORDER BY Rating DESC

SELECT * FROM top_rating

--11. Write a trigger that sends an email notification to the restaurant owner whenever a new
--record is inserted.

CREATE  TRIGGER Update_Notification
ON jomato
AFTER INSERT
AS
EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'ADMIN',  
		@recipients = 'ADMIN@EXAMPLE.com',  
		@body = 'NEW RECORD IS INSERTED',  
		@subject = 'REMINDER FOR UPDATES IN RECORD'