/**************************************
 * SELECT Element
 **************************************/

-- Expressions do not have a name by default.
-- AS is optional.
SELECT 0 AS IntColumn, N'No name provided', SYSDATETIMEOFFSET() AS ExecutedOn;

/**************************************
 * FROM Element
 **************************************/
/*
   Simple SELECT with FROM
   FROM defines the table(s) -- provides where to pull the data.
*/
SELECT *
FROM Sales.Orders;

-- Don't use SELECT *
-- Column names default to the table's column name
--    if it's a direct reference.
-- Recommend a table reference on column names.
-- This makes it clear which table.
-- A table reference is required if column name is ambiguous.
SELECT Orders.OrderID, Orders.OrderDate,
   Orders.CustomerID, Orders.SalespersonPersonID
FROM Sales.Orders;

-- With table alias.
-- Again, AS is optional.
-- Table names/aliases also help with auto-complete.
SELECT O.OrderID, O.OrderDate,
   O.CustomerID, O.SalespersonPersonID
FROM Sales.Orders O;

-- Column alias
-- Here we add OrderYear
-- Remember, an expression will not have a default column name.
SELECT O.OrderID, O.OrderDate,
   YEAR(O.OrderDate) AS OrderYear,
   O.CustomerID, O.SalespersonPersonID
FROM Sales.Orders O;

/**************************************
 * WHERE Element
 **************************************/

/*
 Provides a filter.
 Accepts any predicate (boolean expression)
*/
SELECT O.OrderID, O.OrderDate,
   O.CustomerID, O.SalespersonPersonID
FROM Sales.Orders O
WHERE YEAR(O.OrderDate) = 2016;

-- This accomplishes the same thing,
-- but better for performance reasons.
-- This is what you'll usually see me do.
-- Date literals are just well-formed character strings.
SELECT O.OrderID, O.OrderDate,
   O.CustomerID, O.SalespersonPersonID
FROM Sales.Orders O
WHERE O.OrderDate >= '2016-01-01'
   AND O.OrderDate < '2017-01-01'

/**************************************
 * Boolean Expressions
 **************************************/

-- How many rows will this return?
-- Sales.Orders contains 73,595 rows.
SELECT *
FROM Sales.Orders O
WHERE O.OrderDate <> NULL;

/**************************************
 * GROUP BY Element
 **************************************/
-- Groups into a new set of customer IDs.
-- Each row now represents a CustomerID
--    rather than an Order.
SELECT O.CustomerID
FROM Sales.Orders O
GROUP BY O.CustomerID;

-- What if we want to add a column?
SELECT O.CustomerID, O.OrderDate
FROM Sales.Orders O
GROUP BY O.CustomerID;

-- Exercises
-- 1. How many orders for each year?
-- 2. When was the first order placed in each year?
-- 3. When was the last order placed in each year?
-- 4. Count number of orders with a picking date.

SELECT *
FROM Sales.Orders O;


/**************************************
 * HAVING Element
 **************************************/
SELECT YEAR(O.OrderDate) AS OrderYear,
   COUNT(*) AS OrderCount
FROM Sales.Orders O
GROUP BY YEAR(O.OrderDate)
HAVING COUNT(*) > 20000;
