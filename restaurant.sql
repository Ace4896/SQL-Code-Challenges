-- 01: Create invitations for a party
-- Retrieve first name, last name and email
-- Order by last name alphabetically
SELECT FirstName, LastName, Email
FROM Customers
ORDER BY LastName;

-- 02: Create a table to store information
-- Record customer ID and party size
-- Table name doesn't matter, but they used AnniversaryAttendees
-- Interestingly, they didn't use any primary/foreign keys in this step...
CREATE TABLE AnniversaryAttendees (
    CustomerID INTEGER PRIMARY KEY,
    PartySize INTEGER NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

-- 03: Print a menu
-- A few things to do here:
-- * All items sorted by price, from low to high
-- * Appetizers and beverages, ordered by type
-- * All items except beverages, ordered by type
SELECT Name, Description, Price, Type
FROM Dishes
ORDER BY PRICE;

SELECT Name, Description, Price, Type
FROM Dishes
WHERE Type = "Appetizer" OR Type = "Beverage"
ORDER BY Type;

SELECT Name, Description, Price, Type
FROM Dishes
WHERE Type != "Beverage"
ORDER BY Type;

-- 04: Sign a customer up for your loyalty program
-- No sample values provided - it was just showing how to use INSERT
INSERT INTO Customers (FirstName, LastName, Email, Address, City, State, Phone, Birthday, FavoriteDish)
VALUES ("Yoimiya", "Naganohara", "yoimiya@inazuma.com", "01 Hanamizaka St", "Inazuma City", "Inazuma", "111-111-1111", "2000-01-01", 1);

-- 05: Update a customer's personal information
-- Look for a customer named Taylor Jenkins who lives at 27170 6th Center, Washington, DC
-- Change this address to 74 Pine St., New York, NY
SELECT CustomerID
FROM Customers
WHERE FirstName = "Taylor" AND LastName = "Jenkins"
AND Address = "27170 6th Center";

-- Output of above query should be 26
UPDATE Customers
SET Address = "74 Pine St.",
    City = "New York",
    State = "NY"
WHERE CustomerID = 26;

-- 06: Remove a customer's record
-- Delete the entry for Taylor Jenkins whose email is tjenkins@rouxacademy.org
SELECT CustomerID
FROM Customers
WHERE FirstName = "Taylor" AND LastName = "Jenkins"
AND Email = "tjenkins@rouxacademy.org";

-- Output of above query should be 4
DELETE FROM Customers
WHERE CustomerID = 4;

-- 07: Log customer responses
-- This uses the table we created in step 02
-- Customer is Asher Tapley, atapley2j@kinetecoinc.com
-- They are bringing 3 friends, so total 4
-- Challenge is to do this in one statement
INSERT INTO AnniversaryAttendees (CustomerID, PartySize)
VALUES (
    (SELECT CustomerID FROM Customers
    WHERE FirstName = "Asher" AND LastName = "Tapley"
    AND Email = "atapley2j@kinetecoinc.com"),
    4
);

-- 08: Look up reservations
-- Wanted first name, reservation date, party size
-- Fuzzy search - look for names like Stevenson, Stephenson, ... - there's various spellings
SELECT c.FirstName, c.LastName, r.Date, r.PartySize
FROM Reservations r
INNER JOIN Customers c ON r.CustomerID = c.CustomerID
WHERE c.LastName LIKE "Ste%n";

-- 09: Take a reservation
-- Customer is Sam McAdams, smac@kinetecoinc.com, 555-555-1212
-- Reservation on 14 July 2020, 6PM, for 5 people
-- Issue here is that the customer doesn't exist - no choice but to query and find out beforehand
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES ("Sam", "McAdams", "smac@kinetecoinc.com", "555-555-1212");

-- Use whichever ID this gives
-- Their schema is not good - it allows null reservation ID and foreign keys...
INSERT INTO Reservations (CustomerID, Date, PartySize)
VALUES (102, "2020-07-14 18:00:00", 5);

-- 10: Take a delivery order
-- Order is for "Loretta Hundey", "6939 Elka Place"
-- House Salad, Mini Cheeseburgers, Tropical Blue Smoothie
-- Then find total cost

-- Part 1: Find customer ID and add order to database
-- Assume order date is 2022-03-15 09:22:00
INSERT INTO Orders (CustomerID, OrderDate)
VALUES (
    (SELECT CustomerID
    FROM Customers
    WHERE FirstName = "Loretta" AND LastName = "Hundey"
    AND Address = "6939 Elka Place"),
    "2022-03-15 09:22:00"
);

-- Part 2: Add items to this order
-- Use whichever order ID the previous statement gives
INSERT INTO OrdersDishes (OrderID, DishID)
VALUES
    (1001, (SELECT DishID FROM Dishes WHERE Name = "House Salad")),
    (1001, (SELECT DishID FROM Dishes WHERE Name = "Mini Cheeseburgers")),
    (1001, (SELECT DishID FROM Dishes WHERE Name = "Tropical Blue Smoothie"));

-- Part 3: Find total price
SELECT SUM(d.Price)
FROM Dishes d
INNER JOIN OrdersDishes od ON od.OrderID = 1001 AND d.DishID = od.DishID;

-- 11: Track your customer's favorite dishes
-- Associate Cleo Goldwater with favorite dish, Quinoa Salmon Salad
-- Annoying how we aren't using primary keys...
UPDATE Customers
SET FavoriteDish = (
    SELECT DishID
    FROM Dishes
    WHERE Name = "Quinoa Salmon Salad"
)
WHERE FirstName = "Cleo" AND LastName = "Goldwater";

-- 12: Prepare a report of your top five customers
-- Goal is to send an email to these customers
-- "Top" in this case refers to the customers that have ordered from the restaurant the most (i.e. count no. of orders)
SELECT c.FirstName, c.LastName, c.Email, COUNT(*) AS OrderCount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
ORDER BY OrderCount DESC, c.CustomerID
LIMIT 5;
