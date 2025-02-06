/**************************************
 * CROSS JOIN
 **************************************/

SELECT COUNT(*) AS SupplierCount
FROM Purchasing.Suppliers;

SELECT COUNT(*) AS CategoryCount
FROM Purchasing.SupplierCategories;

-- It produces all combinations of the rows from the two tables.

-- ANSI SQL-92
-- Any column from any table in the joins are available
--    for reference by any other element, because FROM is
--    the first logical processing phase.
SELECT S.SupplierID, S.SupplierName, SC.SupplierCategoryID, SC.SupplierCategoryName
FROM Purchasing.Suppliers S
   CROSS JOIN Purchasing.SupplierCategories SC
ORDER BY S.SupplierID ASC, SC.SupplierCategoryID ASC;

-- ANSI SQL-89
SELECT S.SupplierID, S.SupplierName, SC.SupplierCategoryID, SC.SupplierCategoryName
FROM Purchasing.Suppliers S,
   Purchasing.SupplierCategories SC
ORDER BY S.SupplierID ASC, SC.SupplierCategoryID ASC;


/**************************************
 * INNER JOIN
 **************************************/
SELECT COUNT(*) AS SupplierCount
FROM Purchasing.Suppliers;

SELECT COUNT(*) AS CategoryCount
FROM Purchasing.SupplierCategories;

-- Let's look at the CROSS JOIN again with
--    the Supplier's SupplierCategoryID
SELECT S.SupplierID, S.SupplierName, S.SupplierCategoryID,
   SC.SupplierCategoryID, SC.SupplierCategoryName
FROM Purchasing.Suppliers S
   CROSS JOIN Purchasing.SupplierCategories SC
ORDER BY S.SupplierID ASC, SC.SupplierCategoryID ASC;

-- We really would only want those rows where the SupplierCategoryID's match.

-- ANSI SQL-92
-- INNER keyword is optional.
SELECT S.SupplierID, S.SupplierName, S.SupplierCategoryID,
   SC.SupplierCategoryID, SC.SupplierCategoryName
FROM Purchasing.Suppliers S
   INNER JOIN Purchasing.SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
ORDER BY S.SupplierID ASC, SC.SupplierCategoryID ASC;

-- ANSI SQL-89
SELECT S.SupplierID, S.SupplierName, S.SupplierCategoryID,
   SC.SupplierCategoryID, SC.SupplierCategoryName
FROM Purchasing.Suppliers S,
   Purchasing.SupplierCategories SC
WHERE S.SupplierCategoryID = SC.SupplierCategoryID
ORDER BY S.SupplierID ASC, SC.SupplierCategoryID ASC;

-- We only get 1 row for each supplier.
-- Note the direction of the relationship.

/*
Use the ANSI-92 syntax:
- Provides join safety, where compiler will let you know the predicate is missing.
- Consistent with outer join.
*/

-- Let's look at other examples.
-- Is it OK to have OrderDate as part of the GROUP BY?
-- What does a row represent after the FROM?
-- What does a row represent after the GROUP BY?
SELECT O.OrderID, O.OrderDate,
   COUNT(*) AS LineCount,
   SUM(OL.Quantity * OL.UnitPrice) AS OrderSubtotal
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
GROUP BY O.OrderID, O.OrderDate
HAVING SUM(OL.Quantity * OL.UnitPrice) >= 25000
ORDER BY OrderSubtotal DESC;

-- Now just a daily total
-- How would I add OrderCount?
-- How about average order value?
SELECT O.OrderDate, COUNT(*) AS LineCount,
   SUM(OL.Quantity * OL.UnitPrice) AS Sales
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate BETWEEN '2016-03-01' AND '2016-04-01'
GROUP BY O.OrderDate
ORDER BY O.OrderDate ASC;

----------------------------------

-- Composite Joins
SELECT S.SupplierID, S.SupplierName, C.CustomerID, C.CustomerName,
   C.PostalCityID, C.PostalPostalCode
FROM Purchasing.Suppliers S
   INNER JOIN Sales.Customers C ON C.PostalCityID = S.PostalCityID
      AND C.PostalPostalCode = S.PostalPostalCode;

-- Self Join
SELECT C.CustomerID, C.CustomerName,
   C.BillToCustomerID, BC.CustomerName AS BillToCustomerName
FROM Sales.Customers C
   INNER JOIN Sales.Customers BC ON BC.CustomerID = C.BillToCustomerID
ORDER BY C.CustomerID ASC;

-- Another example
SELECT COUNT(*) AS PersonCount
FROM [Application].People;

-- Let's look for shared email addresses.
-- We want the names of the person and the one sharing the email.
SELECT P.EmailAddress, P.FullName, SP.FullName AS SharedWithName
FROM [Application].People P
   INNER JOIN [Application].People SP ON SP.EmailAddress = P.EmailAddress
ORDER BY P.EmailAddress ASC;

-- Composite, Self, and Non-equi Join
SELECT P.EmailAddress, P.PersonID, P.FullName,
   SP.PersonID AS SharedWithPersonID, SP.FullName AS SharedWithName
FROM [Application].People P
   INNER JOIN [Application].People SP ON SP.EmailAddress = P.EmailAddress
      AND P.PersonID < SP.PersonID
ORDER BY P.EmailAddress ASC;

----------------------------------------

-- Multi-Join Queries
-- It's important to focus on each join and the table structure:
--    What does a row represent at each join?
--    ...after the FROM is processed?
--    ...after the GROUP BY is processed?
-- Query from earlier, but how do we add CustomerID?
-- How do we add CustomerName?
SELECT O.OrderID, O.OrderDate,
   COUNT(*) AS LineCount,
   SUM(OL.Quantity * OL.UnitPrice) AS OrderSubtotal
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
GROUP BY O.OrderID, O.OrderDate
HAVING SUM(OL.Quantity * OL.UnitPrice) >= 25000
ORDER BY OrderSubtotal DESC;


-- Let's look at total sales by customer for 2015.
-- How can we get just the top 25 customers?
SELECT C.CustomerID, C.CustomerName,
   COUNT(DISTINCT O.OrderID) AS OrderCount,
   SUM(OL.Quantity * OL.UnitPrice) AS Sales
FROM Sales.Customers C
   INNER JOIN Sales.Orders O ON O.CustomerID = C.CustomerID
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY C.CustomerID, C.CustomerName
ORDER BY Sales DESC;


-- We don't have a need to yet, but
--    can force processing order with parentheses.
SELECT C.CustomerID, C.CustomerName,
   COUNT(DISTINCT O.OrderID) AS OrderCount,
   SUM(OL.Quantity * OL.UnitPrice) AS Sales
FROM Sales.Customers C
   INNER JOIN (Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID)
      ON O.CustomerID = C.CustomerID
WHERE O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY C.CustomerID, C.CustomerName
ORDER BY Sales DESC;
