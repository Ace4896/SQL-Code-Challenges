-- 01: Check book availability
-- Count how many books are out on loan, and how many are still in the library
-- Find out how many copies of "Dracula" are available

-- Part 1: Find copies of Dracula
SELECT COUNT(*)
FROM Books
WHERE Title = "Dracula";

-- Part 2: Find how many aren't available
SELECT COUNT(*)
FROM Loans l
INNER JOIN Books b ON l.BookID = b.BookID AND b.Title = "Dracula"
WHERE l.ReturnedDate IS NULL;

-- Part 3: Combine results from part 1 and 2 to get total available
SELECT
    (SELECT COUNT(*) FROM Books WHERE Title = "Dracula")
    -
    (SELECT COUNT(*)
    FROM Loans l
    INNER JOIN Books b ON l.BookID = b.BookID AND b.Title = "Dracula"
    WHERE l.ReturnedDate IS NULL)
    AS AvailableBooks;

-- 02: Add new books to the library
INSERT INTO Books (Title, Author, Published, Barcode)
VALUES
    ("Dracula", "Bram Stoker", 1897, 4819277482),
    ("Gulliver's Travels", "Jonathan Swift", 1729, 4899254401);

-- 03: Check out books
-- Customer: Jack Vaan, jvaan@wisdompets.com
-- The Picture of Dorian Gray, 2855934983
-- Great Expectations, 4043822646
-- Loaned on 2020-08-25
-- Due on 2020-09-08
SELECT PatronID
FROM Patrons
WHERE FirstName = "Jack" AND LastName = "Vaan"
AND Email = "jvaan@wisdompets.com";

-- Returned ID was 50
INSERT INTO Loans (BookID, PatronID, LoanDate, DueDate)
VALUES
    (
        (SELECT BookID FROM Books WHERE Barcode = 2855934983),
        50,
        "2020-08-25",
        "2020-09-08"
    ),
    (
        (SELECT BookID FROM Books WHERE Barcode = 4043822646),
        50,
        "2020-08-25",
        "2020-09-08"
    );

-- 04: Generate a report of books due back on July 13 2020, with patron contact information
SELECT b.Title, p.FirstName, p.LastName, p.Email
FROM Books b, Patrons p
INNER JOIN Loans l ON b.BookID = l.BookID AND p.PatronID = l.PatronID
WHERE l.DueDate = "2020-07-13"
AND l.ReturnedDate IS NULL;

-- 05: Return books to the library
-- Return these books on July 5 2020
UPDATE Loans
SET ReturnedDate = "2020-07-05"
WHERE ReturnedDate IS NULL
AND BookID IN (
    SELECT BookID
    FROM Books
    WHERE Barcode IN (6435968624, 5677520613, 8730298424)
);

-- 06: Encourage patrons to check out books
-- Create a report showing the 10 patrons who have checked out the fewest books
SELECT p.FirstName, p.LastName, p.Email, COUNT(*) AS LoanCount
FROM Patrons p
INNER JOIN Loans l ON l.PatronID = p.PatronID
GROUP BY p.PatronID
ORDER BY LoanCount, p.PatronID
LIMIT 10;

-- 07: Find books to feature for an event
-- Create a list of books from the 1890s that are currently available

-- Part 1: Books from the 1890s
SELECT Title, Author, Published
FROM Books
WHERE Published >= 1890 AND Published < 1900;

-- Part 2: Combine with Loans table to only include ones that aren't present
-- There's an issue though - this gives us too many, since there's a row for each time a book is loaned
-- So need to group by BookID
SELECT b.Title, b.Author, b.Published
FROM Books b
INNER JOIN Loans l ON b.BookID = l.LoanID
WHERE b.Published >= 1890 AND b.Published < 1900
AND l.ReturnedDate IS NOT NULL
GROUP BY b.BookID
ORDER BY b.Title;

-- 08: Book statistics
-- Create a report showing how many books were published each year
-- Create another report showing the five most popular books to check out

-- Part 1: How many books were published each year
-- Be careful - there's multiple copies of each book, so each title shouldn't be counted more than once
SELECT COUNT(DISTINCT(Title)) AS PublishCount, Published
FROM Books
GROUP BY Published
ORDER BY PublishCount DESC;

-- Part 2: Five most popular books to check out
SELECT b.Title, b.Author, COUNT(*) AS LoanCount
FROM Books b
INNER JOIN Loans l ON b.BookID = l.BookID
GROUP BY b.Title
ORDER BY LoanCount DESC
LIMIT 5;
